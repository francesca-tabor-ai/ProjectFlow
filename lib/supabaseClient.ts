import { createClient } from '@supabase/supabase-js'

// Get Supabase credentials from environment variables
// Note: In Vite, use import.meta.env (not process.env)
const getSupabaseUrl = (): string => {
  const url = import.meta.env.VITE_SUPABASE_URL || import.meta.env.SUPABASE_URL;
  if (!url) {
    throw new Error('Supabase URL is not configured. Please set VITE_SUPABASE_URL or SUPABASE_URL in your .env.local file');
  }
  return url;
};

const getSupabaseAnonKey = (): string => {
  const key = import.meta.env.VITE_SUPABASE_ANON_KEY || import.meta.env.SUPABASE_ANON_KEY;
  if (!key) {
    throw new Error('Supabase Anon Key is not configured. Please set VITE_SUPABASE_ANON_KEY or SUPABASE_ANON_KEY in your .env.local file');
  }
  return key;
};

export const supabase = createClient(
  getSupabaseUrl(),
  getSupabaseAnonKey(),
  {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true
    }
  }
)
