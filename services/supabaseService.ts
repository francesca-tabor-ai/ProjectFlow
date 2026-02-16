import { createClient, SupabaseClient } from '@supabase/supabase-js';

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

// Create Supabase client instance
let supabaseClient: SupabaseClient | null = null;

export const getSupabaseClient = (): SupabaseClient => {
  if (!supabaseClient) {
    const supabaseUrl = getSupabaseUrl();
    const supabaseAnonKey = getSupabaseAnonKey();
    
    supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true
      }
    });
  }
  
  return supabaseClient;
};

// Service role client (for server-side operations only - use with caution)
export const getSupabaseServiceClient = (): SupabaseClient => {
  const supabaseUrl = getSupabaseUrl();
  const serviceRoleKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY || import.meta.env.SUPABASE_SERVICE_ROLE_KEY;
  
  if (!serviceRoleKey) {
    throw new Error('Supabase Service Role Key is not configured. Please set VITE_SUPABASE_SERVICE_ROLE_KEY in your .env.local file (local) or Vercel Environment Variables (production)');
  }
  
  // Create a new client with service role key (bypasses RLS)
  return createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });
};

// Helper function to check if Supabase is configured
export const isSupabaseConfigured = (): boolean => {
  try {
    getSupabaseUrl();
    getSupabaseAnonKey();
    return true;
  } catch {
    return false;
  }
};

// Export types for convenience
export type { SupabaseClient };
