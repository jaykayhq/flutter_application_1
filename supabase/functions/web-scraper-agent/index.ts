// File: supabase/functions/web-scraper-agent/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { parseFeed } from "https://deno.land/x/rss/mod.ts";

interface AgentTask {
  id: number;
  payload: {
    url: string;
    source_name: string;
  };
}

serve(async (_req) => {
  console.log("Agent 'web-scraper-agent' invoked.");

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
      task_type_filter: 'SCRAPE_RSS_FEED'
    });

    if (rpcError) throw new Error(`Error fetching task: ${rpcError.message}`);

    if (!task) {
      console.log("No pending 'SCRAPE_RSS_FEED' tasks found. Agent exiting.");
      return new Response(JSON.stringify({ message: "No pending tasks." }), { status: 200 });
    }
    
    const agentTask = task as AgentTask;
    taskId = agentTask.id;
    console.log(`Locked task ID: ${taskId}`);

    // 3. --- Execute the Task: Fetch and Parse RSS Feed ---
    const feedUrl = agentTask.payload?.url;
    if (!feedUrl) throw new Error("Task payload is missing 'url'.");

    console.log(`Fetching RSS feed from: ${feedUrl}`);
    const response = await fetch(feedUrl);
    if (!response.ok) throw new Error(`Failed to fetch RSS feed. Status: ${response.status}`);
    
    const xml = await response.text();
    const feed = await parseFeed(xml);

    const headlines = feed.entries.map(entry => entry.title?.value).filter(Boolean).slice(0, 10);
    if (headlines.length === 0) throw new Error("No headlines found in the RSS feed.");

    console.log(`Successfully parsed ${headlines.length} headlines.`);

    // 4. --- Create Follow-up Task for Insight Generation ---
    const headlinesText = headlines.join('; ');
    const prompt = `Based on these recent news headlines from Nigeria: \"${headlinesText}\", generate three short, actionable marketing insights for small businesses. Each insight should be a single, complete sentence. Format the response as a simple JSON array of strings, like [\"insight 1\", \"insight 2\", \"insight 3\"].`;

    const { error: followUpError } = await supabase.from('agent_tasks').insert({
      task_type: 'GENERATE_INSIGHTS',
      status: 'pending',
      payload: { 
        prompt: prompt, 
        source: agentTask.payload.source_name 
      }
    });

    if (followUpError) throw new Error(`Failed to create follow-up task: ${followUpError.message}`);
    console.log("Successfully created 'GENERATE_INSIGHTS' follow-up task for scraped data.");

    // 5. --- Mark Original Task as Completed ---
    await supabase.from('agent_tasks').update({ 
      status: 'completed',
      result: { message: `Successfully scraped ${headlines.length} headlines.` }
    }).eq('id', taskId);
    
    console.log(`Task ${taskId} marked as 'completed'.`);
    return new Response(JSON.stringify({ message: "Task completed successfully." }), { status: 200 });

  } catch (error) {
    if (error instanceof Error) {
      console.error("An error occurred:", error.message);
    } else {
      console.error("An error occurred:", error);
    }
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