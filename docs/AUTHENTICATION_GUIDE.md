# Authentication Guide

Complete guide to authentication in ProjectFlow using Supabase Auth.

## Table of Contents

1. [Overview](#1-overview)
2. [Setup](#2-setup)
3. [Sign Up](#3-sign-up)
4. [Sign In](#5-sign-in)
5. [Session Management](#5-session-management)
6. [JWT Tokens](#6-jwt-tokens)
7. [Protected Routes](#7-protected-routes)
8. [Sign Out](#8-sign-out)
9. [Password Reset](#9-password-reset)
10. [Best Practices](#10-best-practices)

---

## 1. Overview

### How Supabase Authentication Works

Supabase provides built-in authentication with JWT tokens:

```
1. User signs up/in
   ↓
2. Supabase validates credentials
   ↓
3. Returns JWT token
   ↓
4. Token included in Authorization header
   ↓
5. RLS policies check token
   ↓
6. Access granted/denied
```

### Key Concepts

- **JWT Token**: Contains user ID, email, and metadata
- **Session**: Contains token and user information
- **RLS**: Row Level Security uses token to filter data
- **Auto-refresh**: Tokens automatically refresh

---

## 2. Setup

### Environment Variables

For **Vite** projects (like ProjectFlow), use `VITE_` prefix:

```env
# .env file
VITE_SUPABASE_URL=https://woigtfojjixtmwaoamap.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

**Note**: In Next.js, you'd use `NEXT_PUBLIC_` prefix, but ProjectFlow uses Vite.

### Initialize Supabase Client

**For Vite projects (ProjectFlow):**

```typescript
// services/supabaseService.ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

**Note**: In Next.js, you'd use `process.env.NEXT_PUBLIC_SUPABASE_URL`, but ProjectFlow uses Vite, so we use `import.meta.env.VITE_SUPABASE_URL`.

**Use our service:**

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();
```

**Our service already handles:**
- ✅ Environment variable loading
- ✅ Client initialization
- ✅ Session persistence
- ✅ Auto-refresh token

---

## 3. Sign Up

### Basic Sign Up

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();

const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    data: {
      name: 'John Doe'  // Stored in user metadata
    }
  }
});

if (error) {
  console.error('Sign up error:', error);
} else {
  console.log('User created:', data.user);
  // Profile is automatically created via trigger
}
```

### What Happens

1. ✅ User created in `auth.users`
2. ✅ Trigger fires → Creates profile in `profiles` table
3. ✅ Email verification sent (if enabled)
4. ✅ Returns user object and session

### Sign Up with Email Verification

```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    emailRedirectTo: 'https://yourapp.com/auth/callback',
    data: {
      name: 'John Doe'
    }
  }
});

// User receives verification email
// Must click link to verify email
```

### Check Email Confirmation

```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123'
});

if (data.user && !data.session) {
  // Email confirmation required
  console.log('Please check your email to confirm your account');
}
```

---

## 4. Sign In

### Basic Sign In

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();

// Sign in with email and password
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
});

if (error) {
  console.error('Sign in error:', error);
} else {
  console.log('Signed in:', data.user);
  console.log('Session:', data.session);
  // JWT token is now stored and will be included in all API requests
}
```

**Note**: The PRD example uses `signIn()`, but the correct method is `signInWithPassword()` for email/password authentication.

### What Happens

1. ✅ Credentials validated
2. ✅ JWT token generated
3. ✅ Session created
4. ✅ Token stored (for auto-refresh)
5. ✅ User can now access protected data

### Handle Errors

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
});

if (error) {
  switch (error.message) {
    case 'Invalid login credentials':
      console.error('Wrong email or password');
      break;
    case 'Email not confirmed':
      console.error('Please verify your email first');
      break;
    default:
      console.error('Sign in error:', error.message);
  }
}
```

---

## 5. Session Management

### Get Current Session

```typescript
const { data: { session }, error } = await supabase.auth.getSession();

if (session) {
  console.log('User:', session.user);
  console.log('Token:', session.access_token);
} else {
  console.log('No active session');
}
```

### Get Current User

```typescript
const { data: { user }, error } = await supabase.auth.getUser();

if (user) {
  console.log('User ID:', user.id);
  console.log('Email:', user.email);
  console.log('Metadata:', user.user_metadata);
} else {
  console.log('Not authenticated');
}
```

### Session Structure

```typescript
interface Session {
  access_token: string;      // JWT token
  refresh_token: string;     // For token refresh
  expires_in: number;        // Token expiration (seconds)
  expires_at: number;        // Token expiration (timestamp)
  token_type: string;        // "bearer"
  user: User;                // User object
}
```

### Auto-refresh

Supabase client automatically refreshes tokens:

```typescript
// Token expires in 1 hour
// Supabase automatically refreshes before expiration
// No manual refresh needed!
```

### Manual Refresh

```typescript
const { data, error } = await supabase.auth.refreshSession();

if (data.session) {
  console.log('Session refreshed');
}
```

---

## 6. JWT Tokens

### What is a JWT Token?

JWT (JSON Web Token) contains:
- **User ID** (`sub`)
- **Email**
- **Role** (`role`)
- **Custom metadata** (`user_metadata`)
- **Expiration time**

### Token in API Requests

**The JWT token must be included in the `Authorization` header for all API requests to access RLS-protected data.**

Supabase client automatically includes the token:

```typescript
// Supabase client automatically includes token
const { data } = await supabase
  .from('projects')
  .select('*');
// Token automatically sent in: Authorization: Bearer <JWT_TOKEN>
```

**Manual HTTP request:**

```typescript
const { data: { session } } = await supabase.auth.getSession();

const response = await fetch(`${SUPABASE_URL}/rest/v1/projects`, {
  headers: {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${session.access_token}`,  // JWT token required!
    'Content-Type': 'application/json'
  }
});
```

### Manual HTTP Request with Token

```typescript
const { data: { session } } = await supabase.auth.getSession();

const response = await fetch(`${SUPABASE_URL}/rest/v1/projects`, {
  headers: {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${session.access_token}`,  // JWT token
    'Content-Type': 'application/json'
  }
});
```

### How RLS Uses Token

```sql
-- RLS policy checks auth.uid()
CREATE POLICY "Users can view their workspaces"
ON workspaces FOR SELECT
USING (
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()  -- Extracted from JWT token
  )
);
```

**Flow:**
1. Request includes JWT token
2. Supabase validates token
3. Extracts `auth.uid()` from token
4. RLS policy uses `auth.uid()` to filter data
5. Returns only authorized rows

---

## 7. Protected Routes

### Check Authentication

```typescript
import { useEffect, useState } from 'react';
import { getSupabaseClient } from './services/supabaseService';

function ProtectedComponent() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const supabase = getSupabaseClient();
    
    // Get current user
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user);
      setLoading(false);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        if (session) {
          setUser(session.user);
        } else {
          setUser(null);
        }
      }
    );

    return () => subscription.unsubscribe();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>Please sign in</div>;

  return <div>Welcome, {user.email}!</div>;
}
```

### Auth State Listener

```typescript
const supabase = getSupabaseClient();

const { data: { subscription } } = supabase.auth.onAuthStateChange(
  (event, session) => {
    console.log('Auth event:', event);
    // 'SIGNED_IN', 'SIGNED_OUT', 'TOKEN_REFRESHED', 'USER_UPDATED'
    
    if (session) {
      console.log('User signed in:', session.user);
    } else {
      console.log('User signed out');
    }
  }
);

// Cleanup
subscription.unsubscribe();
```

### Redirect if Not Authenticated

```typescript
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getSupabaseClient } from './services/supabaseService';

function ProtectedRoute({ children }) {
  const navigate = useNavigate();
  const supabase = getSupabaseClient();

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) {
        navigate('/login');
      }
    });
  }, [navigate]);

  return children;
}
```

---

## 8. Sign Out

### Basic Sign Out

```typescript
const supabase = getSupabaseClient();

const { error } = await supabase.auth.signOut();

if (error) {
  console.error('Sign out error:', error);
} else {
  console.log('Signed out successfully');
  // Redirect to login page
}
```

### Sign Out and Clear Session

```typescript
// Sign out from all devices
const { error } = await supabase.auth.signOut({ scope: 'global' });

// Sign out from current device only (default)
const { error } = await supabase.auth.signOut();
```

---

## 9. Password Reset

### Request Password Reset

```typescript
const supabase = getSupabaseClient();

const { data, error } = await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  {
    redirectTo: 'https://yourapp.com/reset-password'
  }
);

if (error) {
  console.error('Error:', error);
} else {
  console.log('Password reset email sent');
}
```

### Update Password

```typescript
const supabase = getSupabaseClient();

const { data, error } = await supabase.auth.updateUser({
  password: 'new-password123'
});

if (error) {
  console.error('Error:', error);
} else {
  console.log('Password updated');
}
```

---

## 10. Best Practices

### 1. Always Check for Errors

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
});

if (error) {
  // Always handle errors
  console.error('Error:', error);
  return;
}

// Use data
console.log('User:', data.user);
```

### 2. Use Environment Variables

```typescript
// ✅ Good: Use environment variables
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// ❌ Bad: Hardcode credentials
const supabaseUrl = 'https://...';
```

### 3. Handle Token Expiration

```typescript
// Supabase client handles this automatically
// But you can listen for token refresh:

supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'TOKEN_REFRESHED') {
    console.log('Token refreshed');
  }
});
```

### 4. Store Session Securely

```typescript
// Supabase client stores session in localStorage by default
// For production, consider:
// - httpOnly cookies (server-side)
// - Secure storage (mobile apps)
```

### 5. Validate Email Format

```typescript
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

if (!isValidEmail(email)) {
  console.error('Invalid email format');
  return;
}
```

### 6. Strong Password Requirements

```typescript
function isStrongPassword(password: string): boolean {
  return (
    password.length >= 8 &&
    /[A-Z]/.test(password) &&
    /[a-z]/.test(password) &&
    /[0-9]/.test(password)
  );
}

if (!isStrongPassword(password)) {
  console.error('Password too weak');
  return;
}
```

---

## 11. Complete Authentication Flow

### Sign Up Flow

```typescript
async function handleSignUp(email: string, password: string, name: string) {
  const supabase = getSupabaseClient();

  // 1. Validate input
  if (!isValidEmail(email)) {
    throw new Error('Invalid email format');
  }
  if (!isStrongPassword(password)) {
    throw new Error('Password too weak');
  }

  // 2. Sign up
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { name }
    }
  });

  if (error) throw error;

  // 3. Check if email confirmation needed
  if (data.user && !data.session) {
    return { needsConfirmation: true, user: data.user };
  }

  // 4. User is signed in
  return { user: data.user, session: data.session };
}
```

### Sign In Flow

```typescript
async function handleSignIn(email: string, password: string) {
  const supabase = getSupabaseClient();

  // 1. Sign in
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (error) {
    // Handle specific errors
    if (error.message === 'Invalid login credentials') {
      throw new Error('Wrong email or password');
    }
    if (error.message === 'Email not confirmed') {
      throw new Error('Please verify your email first');
    }
    throw error;
  }

  // 2. User is signed in
  return { user: data.user, session: data.session };
}
```

### Protected API Call

```typescript
async function fetchUserProjects() {
  const supabase = getSupabaseClient();

  // 1. Check authentication
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    throw new Error('Not authenticated');
  }

  // 2. Make API call (token automatically included)
  const { data: projects, error } = await supabase
    .from('projects')
    .select('*');

  if (error) throw error;

  // 3. RLS automatically filtered results
  return projects; // Only projects user has access to
}
```

---

## 12. React Hook Example

### useAuth Hook

```typescript
import { useState, useEffect } from 'react';
import { getSupabaseClient } from './services/supabaseService';
import type { User, Session } from '@supabase/supabase-js';

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const supabase = getSupabaseClient();

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      setLoading(false);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
        setLoading(false);
      }
    );

    return () => subscription.unsubscribe();
  }, []);

  return {
    user,
    session,
    loading,
    signIn: (email: string, password: string) =>
      supabase.auth.signInWithPassword({ email, password }),
    signUp: (email: string, password: string, name?: string) =>
      supabase.auth.signUp({
        email,
        password,
        options: { data: { name } }
      }),
    signOut: () => supabase.auth.signOut()
  };
}
```

### Usage in Component

```typescript
function App() {
  const { user, loading, signIn, signOut } = useAuth();

  if (loading) return <div>Loading...</div>;

  if (!user) {
    return <LoginForm onSignIn={signIn} />;
  }

  return (
    <div>
      <p>Welcome, {user.email}!</p>
      <button onClick={signOut}>Sign Out</button>
    </div>
  );
}
```

---

## 13. Summary

### Key Points

1. ✅ **JWT Tokens** - Automatically included in requests
2. ✅ **RLS Protection** - Security enforced automatically
3. ✅ **Auto-refresh** - Tokens refresh automatically
4. ✅ **Session Management** - Handled by Supabase client
5. ✅ **Type-safe** - TypeScript support

### Quick Reference

```typescript
// Setup
import { getSupabaseClient } from './services/supabaseService';
const supabase = getSupabaseClient();

// Sign up
await supabase.auth.signUp({ email, password });

// Sign in
await supabase.auth.signInWithPassword({ email, password });

// Get user
const { data: { user } } = await supabase.auth.getUser();

// Sign out
await supabase.auth.signOut();
```

---

**Authentication is handled automatically by Supabase - just use the client library!** 🚀
