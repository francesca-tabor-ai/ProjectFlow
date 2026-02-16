import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabaseClient'

interface AuthCallbackProps {
  onAuthSuccess: (user: { id: string; name: string; email: string }) => void
  onAuthError: () => void
}

export default function AuthCallback({ onAuthSuccess, onAuthError }: AuthCallbackProps) {
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')

  useEffect(() => {
    async function handleCallback() {
      try {
        // Get the session from the URL hash
        const { data: { session }, error } = await supabase.auth.getSession()

        if (error) {
          console.error('Session error:', error)
          setStatus('error')
          setTimeout(() => onAuthError(), 2000)
          return
        }

        if (session?.user) {
          // Extract user info from Supabase session
          const user = {
            id: session.user.id,
            name: session.user.user_metadata?.full_name || session.user.user_metadata?.name || session.user.email?.split('@')[0] || 'User',
            email: session.user.email || ''
          }
          
          setStatus('success')
          onAuthSuccess(user)
        } else {
          setStatus('error')
          setTimeout(() => onAuthError(), 2000)
        }
      } catch (err) {
        console.error('Callback error:', err)
        setStatus('error')
        setTimeout(() => onAuthError(), 2000)
      }
    }

    handleCallback()
  }, [onAuthSuccess, onAuthError])

  return (
    <div className="min-h-screen w-full flex bg-[#f7f8f9] items-center justify-center p-6">
      <div className="text-center">
        {status === 'loading' && (
          <>
            <div className="w-12 h-12 border-4 border-[#6366f1]/30 border-t-[#6366f1] rounded-full animate-spin mx-auto mb-4"></div>
            <p className="text-[#4f566b] font-semibold">Signing you in...</p>
          </>
        )}
        {status === 'success' && (
          <>
            <div className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <p className="text-[#4f566b] font-semibold">Successfully signed in!</p>
          </>
        )}
        {status === 'error' && (
          <>
            <div className="w-12 h-12 bg-red-500 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </div>
            <p className="text-[#4f566b] font-semibold">Authentication failed. Redirecting...</p>
          </>
        )}
      </div>
    </div>
  )
}
