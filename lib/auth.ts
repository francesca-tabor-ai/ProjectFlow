import { supabase } from './supabaseClient'

export async function signInWithGoogle() {
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: window.location.origin
    }
  })

  if (error) {
    console.error('Google login error:', error)
    throw error
  }
}
