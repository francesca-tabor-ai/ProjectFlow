# Data Model Documentation

This document explains the ProjectFlow database schema and how it maps to the PRD requirements.

## Table of Contents

1. [Overview](#1-overview)
2. [Authentication Architecture](#2-authentication-architecture)
3. [Core Tables](#3-core-tables)
4. [Schema Mapping to PRDs](#4-schema-mapping-to-prds)
5. [Running the Schema](#5-running-the-schema)

---

## 1. Overview

ProjectFlow uses **Supabase's built-in authentication system** combined with custom tables for application data. This approach provides:

- ✅ **Secure authentication** handled by Supabase (password hashing, JWT tokens, sessions)
- ✅ **Flexible user profiles** with custom fields
- ✅ **Row Level Security** for data access control
- ✅ **Automatic API generation** from database schema

### Key Design Decision

**We do NOT create a custom `users` table with password hashing.**

Instead, we use:
- **`auth.users`** (Supabase managed) - Authentication, passwords, sessions
- **`profiles`** (Our table) - User profile data, display names, preferences

This is the **recommended Supabase pattern** and provides better security and features.

---

## 2. Authentication Architecture

### 2.1 Supabase Auth System

```
┌─────────────────────────────────────────┐
│      Supabase Authentication            │
├─────────────────────────────────────────┤
│                                         │
│  auth.users (Supabase managed)          │
│  ├── id (UUID)                          │
│  ├── email                              │
│  ├── encrypted_password                 │
│  ├── email_confirmed_at                 │
│  ├── created_at                         │
│  └── raw_user_meta_data (JSONB)        │
│                                         │
│  ✅ Password hashing (bcrypt)           │
│  ✅ JWT token generation                │
│  ✅ Session management                  │
│  ✅ Email verification                  │
│  ✅ Password reset flows                │
└─────────────────────────────────────────┘
```

### 2.2 Our Profile Extension

```
┌─────────────────────────────────────────┐
│      Application Profile Data           │
├─────────────────────────────────────────┤
│                                         │
│  profiles (Our table)                  │
│  ├── id → REFERENCES auth.users(id)    │
│  ├── name (display_name)                │
│  ├── email (synced from auth.users)    │
│  ├── avatar                             │
│  ├── color (UI color assignment)       │
│  ├── created_at                         │
│  └── updated_at                         │
│                                         │
│  ✅ Extends auth.users                  │
│  ✅ Stores app-specific data            │
│  ✅ Auto-created on signup (trigger)   │
└─────────────────────────────────────────┘
```

### 2.3 Why This Approach?

**Benefits:**
1. **Security**: Supabase handles password hashing with industry-standard bcrypt
2. **Features**: Built-in email verification, password reset, OAuth
3. **Maintenance**: No need to manage authentication logic
4. **Scalability**: Supabase handles auth infrastructure
5. **Compliance**: Built-in security best practices

**vs. Custom Users Table:**
- ❌ You'd need to implement password hashing
- ❌ You'd need to manage sessions
- ❌ You'd need to handle email verification
- ❌ More code to maintain
- ❌ Security risks if not done correctly

---

## 3. Core Tables

### 3.1 Profiles Table

**Purpose**: Extends Supabase Auth with application-specific user data.

**SQL Schema** (from `001_initial_schema.sql`):

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar TEXT,
  color TEXT, -- Assigned color for UI (cursor, etc.)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can view all profiles (for collaboration)
CREATE POLICY "Users can view profiles"
ON profiles FOR SELECT
USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);
```

**Key Points:**
- `id` references `auth.users(id)` - One-to-one relationship
- `name` corresponds to `display_name` in PRD
- `email` is synced from `auth.users` but stored for quick access
- Auto-created via trigger when user signs up

### 3.2 Automatic Profile Creation

When a user signs up via Supabase Auth, a trigger automatically creates their profile:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, color)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    NEW.email,
    -- Assign a random color from predefined palette
    (ARRAY['#6366f1', '#a855f7', '#ec4899', '#f97316', '#10b981', '#06b6d4'])[
      floor(random() * 6 + 1)
    ]
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**This means:**
- ✅ User signs up → `auth.users` record created
- ✅ Trigger fires → `profiles` record created automatically
- ✅ No manual profile creation needed

---

## 4. Schema Mapping to PRDs

### 4.1 PRD_01_User_Accounts

**PRD Requirement:**
- User registration and authentication
- Email and password
- Display name
- Profile management

**Our Implementation:**

| PRD Field | Supabase Auth | Our Schema |
|-----------|--------------|------------|
| Email | `auth.users.email` | `profiles.email` (synced) |
| Password | `auth.users.encrypted_password` | Managed by Supabase |
| Display Name | `auth.users.raw_user_meta_data->>'name'` | `profiles.name` |
| User ID | `auth.users.id` | `profiles.id` (same UUID) |
| Created At | `auth.users.created_at` | `profiles.created_at` |
| Avatar | N/A | `profiles.avatar` |
| Color | N/A | `profiles.color` (UI assignment) |

**Authentication Flow:**

```typescript
// Sign Up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      name: 'John Doe'  // Stored in metadata, copied to profiles.name
    }
  }
});

// Profile is automatically created via trigger
// No need to manually create profile record
```

### 4.2 Complete Table Structure

For reference, here's how all tables relate:

```
auth.users (Supabase)
    ↓ (1:1)
profiles
    ↓ (1:many)
workspace_members → workspaces
    ↓ (1:many)
projects
    ↓ (1:many)
sheets
    ├── columns
    └── rows
        ├── comments
        └── file_attachments
```

---

## 5. Running the Schema

### 5.1 Complete Schema Files

The complete database schema is in:

1. **`supabase/migrations/001_initial_schema.sql`**
   - Core tables (profiles, workspaces, projects, sheets, rows, etc.)
   - Row Level Security policies
   - Indexes and constraints

2. **`supabase/migrations/002_storage_and_functions.sql`**
   - Helper functions
   - Triggers (including profile creation)
   - Database views

### 5.2 Execution Steps

1. **Open Supabase Dashboard**
   - Go to your project
   - Navigate to **SQL Editor**

2. **Run First Migration**
   ```sql
   -- Copy contents of 001_initial_schema.sql
   -- Paste into SQL Editor
   -- Click "Run" or press Cmd/Ctrl + Enter
   ```

3. **Run Second Migration**
   ```sql
   -- Copy contents of 002_storage_and_functions.sql
   -- Paste into SQL Editor
   -- Click "Run"
   ```

4. **Verify Tables Created**
   - Go to **Table Editor**
   - Verify `profiles` table exists
   - Check other tables are created

### 5.3 Important Notes

**DO NOT create a custom `users` table:**
- ❌ Supabase already provides `auth.users`
- ❌ Creating your own would conflict with Supabase Auth
- ❌ Use `profiles` table instead

**DO use the provided schema:**
- ✅ `profiles` table extends `auth.users`
- ✅ Trigger automatically creates profiles
- ✅ RLS policies are configured
- ✅ All relationships are set up correctly

---

## 6. Querying User Data

### 6.1 Get Current User Profile

```typescript
const supabase = getSupabaseClient();

// Get authenticated user
const { data: { user } } = await supabase.auth.getUser();

// Get profile
const { data: profile } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', user.id)
  .single();
```

### 6.2 Get User with Auth Data

```typescript
// Get user from auth
const { data: { user } } = await supabase.auth.getUser();

// Get profile
const { data: profile } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', user.id)
  .single();

// Combine data
const userData = {
  id: user.id,
  email: user.email,
  emailConfirmed: user.email_confirmed_at !== null,
  displayName: profile.name,
  avatar: profile.avatar,
  color: profile.color,
  createdAt: profile.created_at
};
```

### 6.3 Update Profile

```typescript
const { data, error } = await supabase
  .from('profiles')
  .update({
    name: 'New Display Name',
    avatar: 'https://example.com/avatar.jpg'
  })
  .eq('id', userId); // RLS ensures user can only update own profile
```

---

## 7. Migration from Custom Users Table

If you have an existing custom `users` table, here's how to migrate:

### 7.1 Migration Steps

1. **Export existing user data**
2. **Create profiles from existing users**
3. **Update foreign key references**
4. **Remove custom users table**

**Example migration script:**

```sql
-- Migrate existing users to profiles
INSERT INTO profiles (id, name, email, created_at)
SELECT 
  id,
  display_name,
  email,
  created_at
FROM old_users_table
ON CONFLICT (id) DO NOTHING;

-- Update foreign keys in other tables
-- (Update workspace_members, project_members, etc. to reference profiles)
```

---

## 8. Summary

### Key Takeaways

1. ✅ **Use `auth.users`** for authentication (Supabase managed)
2. ✅ **Use `profiles`** for user profile data (our table)
3. ✅ **Automatic profile creation** via trigger on signup
4. ✅ **RLS policies** ensure users can only access/modify their own data
5. ✅ **No password hashing needed** - Supabase handles it

### Schema Files

- **Initial Schema**: `supabase/migrations/001_initial_schema.sql`
- **Functions & Triggers**: `supabase/migrations/002_storage_and_functions.sql`
- **Storage Setup**: See `supabase/README.md`

### Next Steps

1. Run the migrations in Supabase SQL Editor
2. Test user signup (profile should auto-create)
3. Verify RLS policies work correctly
4. Start building your application!

---

**The schema is ready to use! Just run the migration files in Supabase SQL Editor.** 🚀
