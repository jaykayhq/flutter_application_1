// File: supabase/functions/orchestrator-agent/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Define a type for our data sources table
interface DataSource {
  id: number;
  source_name: string;
  cool_down_until: string | null;
}

console.log("Orchestrator Agent script started.");

serve(async (_req) => {
  console.log("Orchestrator Agent invoked.");

  try {
    // 1. --- Get Environment Variables & Create Supabase Client ---
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY.");
    }
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // 2. --- Fetch All Data Sources ---
    const { data: sources, error: sourceError } = await supabase
      .from('data_sources')
      .select('*');

    if (sourceError) {
      throw new Error(`Failed to fetch data sources: ${sourceError.message}`);
    }

    console.log(`Found ${sources.length} data sources to check.`);
    const now = new Date();
    let tasksCreated = 0;

    // 3. --- Loop Through Sources and Decide to Create Tasks ---
    for (const source of sources as DataSource[]) {
      const coolDownUntil = source.cool_down_until ? new Date(source.cool_down_until) : now;

      // Check if the cool down period has passed
      if (now >= coolDownUntil) {
        console.log(`Source '${source.source_name}' is ready. Checking for pending tasks.`);

        // Check if there is already a pending task for this source type
        const { data: pendingTasks, error: pendingCheckError } = await supabase
          .from('agent_tasks')
          .select('id')
          .eq('task_type', source.source_name)
          .eq('status', 'pending')
          .limit(1);
        
        if (pendingCheckError) {
            console.error(`Error checking for pending tasks for ${source.source_name}: ${pendingCheckError.message}`);
            continue; // Skip to the next source
        }

        if (pendingTasks && pendingTasks.length > 0) {
          console.log(`Skipping '${source.source_name}': a pending task already exists.`);
          continue;
        }

        // No pending task, so let's create one.
        console.log(`Creating new task for '${source.source_name}'.`);

        const { error: insertError } = await supabase
          .from('agent_tasks')
          .insert({ task_type: source.source_name, status: 'pending' });

        if (insertError) {
          console.error(`Failed to insert task for ${source.source_name}: ${insertError.message}`);
          continue;
        }

        // Task created, now update the cool down period for this source
        // Example: Set cool down for 15 minutes for X_TRENDS
        const nextCoolDown = new Date(now.getTime() + 15 * 60 * 1000); // 15 minutes

        const { error: updateError } = await supabase
          .from('data_sources')
          .update({ cool_down_until: nextCoolDown.toISOString() })
          .eq('source_name', source.source_name);

        if (updateError) {
            console.error(`Failed to update cool down for ${source.source_name}: ${updateError.message}`);
        }

        tasksCreated++;

      } else {
        console.log(`Source '${source.source_name}' is on cool down. Skipping.`);
      }
    }

    // 4. --- Return Success Response ---
    const message = `Orchestration check complete. Created ${tasksCreated} new tasks.`;
    console.log(message);
    return new Response(
      JSON.stringify({ message }),
      { headers: { "Content-Type": "application/json" }, status: 200 },
    );

  } catch (error) {
    const errorMessage = (error instanceof Error) ? error.message : String(error);
    console.error("An unexpected error occurred in the orchestrator:", errorMessage);
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { headers: { "Content-Type": "application/json" }, status: 500 },
    );
  }
})
