import { createClient } from '@supabase/supabase-js'

// Get Supabase credentials from environment variables
// Note: In Vite, use import.meta.env (not process.env)
const getSupabaseUrl = (): string => {
  const url = (import.meta.env.VITE_SUPABASE_URL || import.meta.env.SUPABASE_URL)?.trim();
  if (!url) {
    throw new Error('Supabase URL is not configured. Please set VITE_SUPABASE_URL in your .env.local file (local) or Vercel Environment Variables (production)');
  }
  // Validate URL format
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    throw new Error(`Invalid Supabase URL format: "${url}". Must start with http:// or https://`);
  }
  try {
    new URL(url);
  } catch {
    throw new Error(`Invalid Supabase URL format: "${url}". Must be a valid URL`);
  }
  return url;
};

const getSupabaseAnonKey = (): string => {
  const key = (import.meta.env.VITE_SUPABASE_ANON_KEY || import.meta.env.SUPABASE_ANON_KEY)?.trim();
  if (!key) {
    throw new Error('Supabase Anon Key is not configured. Please set VITE_SUPABASE_ANON_KEY in your .env.local file (local) or Vercel Environment Variables (production)');
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
