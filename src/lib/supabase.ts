import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

// Create a client only if environment variables are supplied
const isSupabaseConfigured = !!(supabaseUrl && supabaseAnonKey);

export const supabase = isSupabaseConfigured
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

export async function saveDateCompletion(
  activityKey: string,
  activityName: string,
  matchPercentage: number,
  userVector: number[],
  activityVector: number[]
) {
  if (!supabase) {
    console.warn('Supabase is not configured. Saving date completion to local storage.');
    // Save to localStorage for demo purposes
    const stored = localStorage.getItem('date_completions');
    const completions = stored ? JSON.parse(stored) : [];
    completions.push({
      activity_key: activityKey,
      activity_name: activityName,
      match_percentage: matchPercentage,
      user_vector: userVector,
      activity_vector: activityVector,
      completed_at: new Date().toISOString(),
    });
    localStorage.setItem('date_completions', JSON.stringify(completions));
    return;
  }

  const { error } = await supabase.from('date_completions').insert({
    activity_key: activityKey,
    activity_name: activityName,
    match_percentage: matchPercentage,
    user_vector: userVector,
    activity_vector: activityVector,
  });

  if (error) {
    console.error('Error saving date completion:', error);
    throw error;
  }
}

export async function getCompletionStats() {
  if (!supabase) {
    console.warn('Supabase is not configured. Fetching date completions from local storage.');
    const stored = localStorage.getItem('date_completions');
    return stored ? JSON.parse(stored) : [];
  }

  const { data, error } = await supabase
    .from('date_completions')
    .select('activity_key, match_percentage, completed_at')
    .order('completed_at', { ascending: false });

  if (error) {
    console.error('Error fetching completion stats:', error);
    return [];
  }

  return data;
}

