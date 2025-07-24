// File: supabase/functions/generate-gemini-insights/index.ts (V2 - Source Agnostic)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface AgentTask {
  id: number;
  payload: {
    trend_ids?: number[]; // Optional: for X trends
    prompt?: string;      // Optional: for direct prompts from other agents
  };
}

serve(async (_req) => {
  console.log("Agent 'generate-gemini-insights' V2 invoked.");

  let taskId: number | null = null;

  try {
    // 1. --- Setup client and get task ---
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !supabaseServiceRoleKey) throw new Error("Missing Supabase credentials.");
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    const { data: task, error: rpcError } = await supabase.rpc('get_and_lock_next_task', {
      task_type_filter: 'GENERATE_INSIGHTS'
    });

    if (rpcError) throw new Error(`Error fetching task: ${rpcError.message}`);
    if (!task) {
      console.log("No pending 'GENERATE_INSIGHTS' tasks found. Agent exiting.");
      return new Response(JSON.stringify({ message: "No pending tasks." }), { status: 200 });
    }
    
    const agentTask = task as AgentTask;
    taskId = agentTask.id;
    console.log(`Locked task ID: ${taskId}`);

    // 2. --- Determine the prompt for Gemini ---
    let prompt = "";
    const payload = agentTask.payload;

    if (payload.prompt) {
      // If a prompt is provided directly (e.g., from the web scraper), use it.
      prompt = payload.prompt;
      console.log("Using direct prompt from task payload.");
    } else if (payload.trend_ids && payload.trend_ids.length > 0) {
      // Otherwise, build the prompt from X trend IDs.
      console.log(`Building prompt from trend IDs: ${payload.trend_ids}`);
      const { data: trends, error: trendsError } = await supabase
        .from('x_trends')
        .select('topic')
        .in('id', payload.trend_ids);

      if (trendsError) throw new Error(`Failed to fetch trends: ${trendsError.message}`);
      if (!trends || trends.length === 0) throw new Error("No matching trends found.");

      const trendTopics = trends.map(t => t.topic).join(', ');
      prompt = `Based on these trending topics on social media in Nigeria: \"${trendTopics}\", generate three short, actionable marketing insights for small businesses. Each insight should be a single, complete sentence. Format the response as a simple JSON array of strings, like [\"insight 1\", \"insight 2\", \"insight 3\"].`;
    } else {
      throw new Error("Task payload is invalid. Must contain either 'prompt' or 'trend_ids'.");
    }

    // 3. --- Call Gemini API with the determined prompt ---
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiApiKey) throw new Error("Missing GEMINI_API_KEY.");
    const geminiApiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${geminiApiKey}`;

    console.log("Sending prompt to Gemini API...");
    const geminiResponse = await fetch(geminiApiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
    });

    if (!geminiResponse.ok) throw new Error(`Gemini API Error: ${await geminiResponse.text()}`);

    const geminiData = await geminiResponse.json();
    const insightsText = geminiData.candidates[0].content.parts[0].text.trim();
    const insightsArray: string[] = JSON.parse(insightsText.replace(/```json|```/g, ''));
    console.log(`Received ${insightsArray.length} insights from Gemini.`);

    // 4. --- Store results and mark task as completed ---
    const { error: insertError } = await supabase
      .from('actionable_insights')
      .insert(insightsArray.map(insight => ({ insight_text: insight })));

    if (insertError) throw new Error(`Failed to insert insights: ${insertError.message}`);

    await supabase.from('agent_tasks').update({ 
      status: 'completed',
      result: { insights: insightsArray }
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
    }
    const errorMsg = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ error: errorMsg }), { status: 500 });
  }
});