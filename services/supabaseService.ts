import { createClient, SupabaseClient } from '@supabase/supabase-js';

// Get Supabase credentials from environment variables
const getSupabaseUrl = (): string => {
  const url = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  if (!url) {
    throw new Error('Supabase URL is not configured. Please set VITE_SUPABASE_URL or SUPABASE_URL in your .env file');
  }
  return url;
};

const getSupabaseAnonKey = (): string => {
  const key = process.env.VITE_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY;
  if (!key) {
    throw new Error('Supabase Anon Key is not configured. Please set VITE_SUPABASE_ANON_KEY or SUPABASE_ANON_KEY in your .env file');
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
  const serviceRoleKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
  
  if (!serviceRoleKey) {
    throw new Error('Supabase Service Role Key is not configured. Please set VITE_SUPABASE_SERVICE_ROLE_KEY or SUPABASE_SERVICE_ROLE_KEY in your .env file');
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
