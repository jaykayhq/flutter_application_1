// File: supabase/functions/get-x-trends/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Define types for clarity
interface XTrend {
  name: string
  url: string
  promoted_content: null | unknown
  query: string
  tweet_volume: number | null
}

interface AgentTask {
  id: number;
  task_type: string;
}

serve(async (_req) => {
  console.log("Agent 'get-x-trends' invoked.");

  let taskId: number | null = null;

  try {
    // 1. --- Create Supabase Client ---
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error("Missing Supabase credentials.");
    }
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // 2. --- Find and Lock a Pending Task ---
    const { data: task, error: rpcError } = await supabase.rpc('get_and_lock_next_task', {
      task_type_filter: 'FETCH_X_TRENDS'
    });

    if (rpcError) {
      throw new Error(`Error fetching task: ${rpcError.message}`);
    }

    if (!task) {
      console.log("No pending 'FETCH_X_TRENDS' tasks found. Agent exiting.");
      return new Response(JSON.stringify({ message: "No pending tasks." }), { status: 200 });
    }
    
    taskId = (task as AgentTask).id;
    console.log(`Locked task ID: ${taskId}`);

    // 3. --- Execute the Task: Fetch from X API ---
    const xBearerToken = Deno.env.get("X_API_BEARER_TOKEN");
    if (!xBearerToken) throw new Error("Missing X_API_BEARER_TOKEN.");

    const woeid = 23424908; // Nigeria
    const xApiUrl = `https://api.twitter.com/1.1/trends/place.json?id=${woeid}`;
    
    const xApiResponse = await fetch(xApiUrl, {
      headers: { "Authorization": `Bearer ${xBearerToken}` },
    });

    if (!xApiResponse.ok) {
      throw new Error(`X API request failed: ${xApiResponse.status}`);
    }

    const trendsData = await xApiResponse.json();
    const trends: XTrend[] = trendsData[0]?.trends || [];
    if (trends.length === 0) throw new Error("No trends found in X API response.");
    
    console.log(`Fetched ${trends.length} trends from X API.`);

    // 4. --- Store Results in 'x_trends' Table ---
    const trendsToInsert = trends.map(t => ({
      topic: t.name,
      tweet_volume: t.tweet_volume || undefined,
      x_woeid: woeid,
    }));

    const { data: insertedTrends, error: insertError } = await supabase
      .from('x_trends')
      .insert(trendsToInsert)
      .select('id'); // Select the IDs of the new trends

    if (insertError) throw new Error(`Supabase insert error: ${insertError.message}`);
    if (!insertedTrends) throw new Error("Failed to get IDs of inserted trends.");

    // 5. --- Create Follow-up Task for Insight Generation ---
    const newTrendIds = insertedTrends.map(t => t.id);
    const { error: followUpError } = await supabase.from('agent_tasks').insert({
      task_type: 'GENERATE_INSIGHTS',
      status: 'pending',
      payload: { trend_ids: newTrendIds } // Pass the new trend IDs to the next agent
    });

    if (followUpError) throw new Error(`Failed to create follow-up task: ${followUpError.message}`);
    console.log("Successfully created 'GENERATE_INSIGHTS' follow-up task.");

    // 6. --- Mark Original Task as Completed ---
    await supabase.from('agent_tasks').update({ 
      status: 'completed',
      result: { message: `Successfully inserted ${trends.length} trends.` }
    }).eq('id', taskId);
    
    console.log(`Task ${taskId} marked as 'completed'.`);
    return new Response(JSON.stringify({ message: "Task completed successfully." }), { status: 200 });

  } catch (error) {
    if (error instanceof Error) {
      console.error("An error occurred:", error.message);
    } else {
      console.error("An error occurred:", error);
    }
    // If an error occurred after we locked a task, mark it as 'failed'.
    if (taskId) {
      const lastErrorMsg = error instanceof Error ? error.message : String(error);
      await createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!)
        .from('agent_tasks')
        .update({ status: 'failed', last_error: lastErrorMsg })
        .eq('id', taskId);
      console.log(`Task ${taskId} marked as 'failed'.`);
    }
    const errorMsg = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ error: errorMsg }), { status: 500 });
  }
});