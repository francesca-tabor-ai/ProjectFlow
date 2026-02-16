# Backend Setup Guide: ProjectFlow with Supabase

This document provides detailed instructions for setting up the backend infrastructure of the ProjectFlow application using **Supabase** for the database and API, and deploying the associated frontend on **Vercel**.

## Table of Contents

1. [Introduction](#1-introduction)
2. [Supabase Setup](#2-supabase-setup)
3. [Database Schema](#3-database-schema)
4. [Row Level Security (RLS)](#4-row-level-security-rls)
5. [API Usage](#5-api-usage)
6. [Frontend Integration](#6-frontend-integration)
7. [Deployment](#7-deployment)

---

## 1. Introduction

ProjectFlow uses **Supabase** as its backend-as-a-service (BaaS) platform, providing:
- **PostgreSQL Database**: Relational database with JSONB support for flexible data structures
- **Auto-generated REST APIs**: Automatic REST endpoints for all tables
- **Real-time Subscriptions**: WebSocket-based real-time updates
- **Authentication**: Built-in user authentication and authorization
- **Row Level Security (RLS)**: Fine-grained access control at the database level
- **Storage**: File storage for attachments

### Architecture Overview

```
┌─────────────────┐
│   React App     │  (Frontend - Vercel)
│   (Vite)        │
└────────┬────────┘
         │
         │ HTTPS/REST/WebSocket
         │
┌────────▼────────┐
│   Supabase      │
│   - PostgreSQL  │
│   - REST API    │
│   - Realtime    │
│   - Auth        │
│   - Storage     │
└─────────────────┘
```

---

## 2. Supabase Setup

> **📖 For a detailed explanation of how Supabase works as your backend, see [SUPABASE_BACKEND_GUIDE.md](./SUPABASE_BACKEND_GUIDE.md)**  
> **📖 For step-by-step project creation instructions, see [SUPABASE_PROJECT_SETUP.md](./SUPABASE_PROJECT_SETUP.md)**

### 2.1 Sign Up / Log In to Supabase

1. Navigate to [https://supabase.com/](https://supabase.com/)
2. Click **Start your project** (new users) or **Sign in** (existing users)
3. Choose authentication method:
   - **GitHub** (recommended for developers)
   - **Email** (email and password)
   - **Google** (Google account)
4. Complete authentication

> **Note**: If you already have a Supabase account, simply log in. Your ProjectFlow project is already set up.

### 2.2 Access Your Project

Your Supabase project is already configured with:
- **Project URL**: `https://woigtfojjixtmwaoamap.supabase.co`
- **Project ID**: `woigtfojjixtmwaoamap`

To access:
1. Log in to [Supabase Dashboard](https://supabase.com/dashboard)
2. Find your project in the list (search for `woigtfojjixtmwaoamap`)
3. Click to open the project dashboard

### 2.3 Project Configuration

Your project credentials are configured in `.env`:
- **Anon Key**: `VITE_SUPABASE_ANON_KEY` (safe for client-side)
- **Service Role Key**: `VITE_SUPABASE_SERVICE_ROLE_KEY` (server-side only, never expose!)

### 2.2 What Supabase Provides

Supabase serves as your complete backend, providing:

1. **PostgreSQL Database**: Your data is stored in a managed PostgreSQL database
2. **Instant APIs**: Every table automatically gets REST endpoints (no backend code needed!)
3. **Authentication**: Built-in user authentication with JWT tokens
4. **Real-time**: WebSocket subscriptions for live updates
5. **Storage**: File storage for attachments
6. **Security**: Row Level Security (RLS) enforces permissions at the database level

### 2.2 Accessing Supabase Dashboard

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your project: `woigtfojjixtmwaoamap`
3. Navigate to **SQL Editor** to run migrations
4. Navigate to **Table Editor** to view/manage data
5. Navigate to **Authentication** to manage users

### 2.3 Environment Variables

Ensure your `.env` file contains:

```env
VITE_SUPABASE_URL=https://woigtfojjixtmwaoamap.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
VITE_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

**Important**: Never commit the `.env` file to version control. The `.env` file is already in `.gitignore`.

---

## 3. Database Schema

### 3.1 Schema Overview

The database schema is designed to support:
- **Multi-tenancy**: Workspaces isolate data
- **Flexible data model**: JSONB columns for dynamic row data
- **Collaboration**: Real-time updates and presence
- **Permissions**: Granular access control
- **Audit trail**: Activity logging

### 3.2 Core Tables

#### **profiles**
Stores user profile information (extends Supabase Auth users).

#### **workspaces**
Top-level organization containers.

#### **workspace_members**
Many-to-many relationship between users and workspaces with roles.

#### **projects**
Projects belong to workspaces and contain sheets.

#### **project_members**
Many-to-many relationship between users and projects with roles.

#### **sheets**
Sheets belong to projects and contain rows.

#### **columns**
Column definitions for sheets (flexible schema).

#### **rows**
Row data stored as JSONB for flexibility.

#### **comments**
Comments attached to rows.

#### **file_attachments**
File attachments for rows.

#### **activity_log**
Audit trail of user actions.

#### **automations**
Automation rules for projects.

#### **saved_views**
Saved filter/view configurations.

#### **ai_metrics**
AI performance metrics.

#### **retraining_jobs**
AI model retraining job history.

#### **templates**
Project templates.

### 3.3 Running Migrations

1. Open Supabase Dashboard → **SQL Editor**
2. Copy the contents of `supabase/migrations/001_initial_schema.sql`
3. Paste and execute in the SQL Editor
4. Verify tables were created in **Table Editor**

---

## 4. Row Level Security (RLS)

### 4.1 RLS Overview

Row Level Security ensures users can only access data they're authorized to see. Policies are defined at the database level.

### 4.2 Key Policies

- **Workspaces**: Users can only access workspaces they're members of
- **Projects**: Users can only access projects in workspaces they belong to
- **Sheets/Rows**: Inherit permissions from parent project
- **Comments/Attachments**: Users can view if they can view the parent row

### 4.3 Policy Examples

```sql
-- Users can only see workspaces they're members of
CREATE POLICY "Users can view their workspaces"
ON workspaces FOR SELECT
USING (
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);
```

All RLS policies are included in the migration files.

---

## 5. Frontend Deployment

> **📖 For comprehensive deployment guide, see [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md)**

### Quick Deployment Steps

1. **Push code to Git repository**
2. **Connect to Vercel**
3. **Add environment variables**:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. **Deploy**

**Note**: ProjectFlow uses **Vite + React** (not Next.js), so environment variables use `VITE_` prefix, not `NEXT_PUBLIC_`.

---

## 6. API Usage

> **📖 For comprehensive API interaction guide, see [SUPABASE_API_INTERACTION.md](./SUPABASE_API_INTERACTION.md)**

### 5.1 Auto-generated APIs

Supabase automatically generates RESTful APIs for all your tables. **No backend code required!**

Once your schema is defined, you can interact with your data using:
- **JavaScript Client** (recommended) - Type-safe, easier to use
- **Direct HTTP Requests** - Using fetch API or cURL
- **Real-time Subscriptions** - WebSocket-based live updates

### 5.2 Supabase Client

The Supabase client is initialized in `services/supabaseService.ts`:

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();
```

### 5.3 Basic CRUD Operations

#### **Select (Read)**

```typescript
// Get all workspaces for current user
const { data: workspaces, error } = await supabase
  .from('workspaces')
  .select('*')
  .order('created_at', { ascending: false });

// Get workspace with members
const { data: workspace, error } = await supabase
  .from('workspaces')
  .select(`
    *,
    workspace_members (
      user_id,
      role,
      profiles (name, email)
    )
  `)
  .eq('id', workspaceId)
  .single();
```

#### **Insert (Create)**

```typescript
// Create a new workspace
const { data: workspace, error } = await supabase
  .from('workspaces')
  .insert({
    name: 'My Workspace',
    owner_id: userId
  })
  .select()
  .single();

// Create a project
const { data: project, error } = await supabase
  .from('projects')
  .insert({
    name: 'My Project',
    workspace_id: workspaceId,
    owner_id: userId,
    active_sheet_id: null
  })
  .select()
  .single();
```

#### **Update**

```typescript
// Update a row
const { data: row, error } = await supabase
  .from('rows')
  .update({
    row_data: { ...rowData, status: 'Done' }
  })
  .eq('id', rowId)
  .select()
  .single();
```

#### **Delete**

```typescript
// Delete a row
const { error } = await supabase
  .from('rows')
  .delete()
  .eq('id', rowId);
```

### 5.3 Advanced Queries

#### **Filtering**

```typescript
// Get rows with specific status
const { data: rows, error } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .contains('row_data', { status: 'In Progress' });
```

#### **Pagination**

```typescript
const pageSize = 50;
const page = 1;

const { data: rows, error } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .range((page - 1) * pageSize, page * pageSize - 1)
  .order('created_at', { ascending: false });
```

#### **JSONB Queries**

```typescript
// Query JSONB column
const { data: rows, error } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>status', 'eq', 'Done');
```

### 5.4 Real-time Subscriptions

```typescript
// Subscribe to row changes
const subscription = supabase
  .channel('rows-changes')
  .on('postgres_changes', {
    event: '*', // INSERT, UPDATE, DELETE
    schema: 'public',
    table: 'rows',
    filter: `sheet_id=eq.${sheetId}`
  }, (payload) => {
    console.log('Change received!', payload);
    // Update local state
  })
  .subscribe();

// Cleanup
return () => {
  subscription.unsubscribe();
};
```

### 5.5 Accessing API Documentation

1. **Supabase Dashboard** → **API** → **REST**
2. See auto-generated documentation for all endpoints
3. Includes:
   - Request/response examples
   - Available filters and operators
   - Authentication requirements
   - Query parameter options

### 5.6 File Storage

```typescript
// Upload file
const { data, error } = await supabase.storage
  .from('attachments')
  .upload(`${rowId}/${fileName}`, file);

// Get public URL
const { data: { publicUrl } } = supabase.storage
  .from('attachments')
  .getPublicUrl(`${rowId}/${fileName}`);

// Download file
const { data, error } = await supabase.storage
  .from('attachments')
  .download(`${rowId}/${fileName}`);
```

---

## 6. Frontend Integration

### 6.1 Service Layer Pattern

Create service functions in `services/` directory:

```typescript
// services/projectService.ts
import { getSupabaseClient } from './supabaseService';
import { Project } from '../types';

export const getProjects = async (workspaceId: string): Promise<Project[]> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      sheets (
        *,
        columns (*),
        rows (*)
      )
    `)
    .eq('workspace_id', workspaceId);
  
  if (error) throw error;
  return data as Project[];
};
```

### 6.2 React Hooks

Create custom hooks for data fetching:

```typescript
// hooks/useProjects.ts
import { useState, useEffect } from 'react';
import { getProjects } from '../services/projectService';
import { Project } from '../types';

export const useProjects = (workspaceId: string) => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    getProjects(workspaceId)
      .then(setProjects)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [workspaceId]);

  return { projects, loading, error };
};
```

### 6.3 Optimistic Updates

```typescript
// Update UI immediately, sync with backend
const updateRow = async (rowId: string, updates: Partial<RowData>) => {
  // Optimistic update
  setRows(prev => prev.map(r => 
    r.id === rowId ? { ...r, ...updates } : r
  ));

  try {
    await supabase
      .from('rows')
      .update({ row_data: updates })
      .eq('id', rowId);
  } catch (error) {
    // Revert on error
    setRows(prev => prev.map(r => 
      r.id === rowId ? originalRow : r
    ));
    throw error;
  }
};
```

---

## 7. Deployment

### 7.1 Vercel Deployment

1. **Connect Repository**
   - Push code to GitHub/GitLab
   - Import project in Vercel

2. **Environment Variables**
   - Add all `VITE_*` variables in Vercel dashboard
   - Settings → Environment Variables

3. **Build Settings**
   - Framework Preset: Vite
   - Build Command: `npm run build`
   - Output Directory: `dist`

4. **Deploy**
   - Vercel will auto-deploy on push to main branch

### 7.2 Supabase Production Checklist

- [ ] Enable RLS on all tables
- [ ] Review and test all policies
- [ ] Set up database backups
- [ ] Configure CORS in Supabase dashboard
- [ ] Set up monitoring/alerts
- [ ] Review API rate limits
- [ ] Test authentication flows
- [ ] Verify file storage permissions

### 7.3 Environment-Specific Configuration

```env
# Development (.env.local)
VITE_SUPABASE_URL=https://woigtfojjixtmwaoamap.supabase.co

# Production (Vercel)
VITE_SUPABASE_URL=https://woigtfojjixtmwaoamap.supabase.co
```

---

## 8. Next Steps

> **📖 For comprehensive next steps guide, see [NEXT_STEPS.md](./NEXT_STEPS.md)**

### Immediate Next Steps

1. **Run Database Migrations**: Execute SQL files in Supabase dashboard
2. **Set Up Storage Buckets**: Create `attachments` bucket in Storage
3. **Configure Authentication**: Set up email/password or OAuth providers
4. **Test API Endpoints**: Use Supabase dashboard API docs

### Development Roadmap

1. **Frontend Implementation**
   - Implement React components to interact with Supabase API
   - Build authentication flows
   - Create workspace/project/sheet components
   - Add real-time collaboration features

2. **RLS Policy Refinement**
   - Refine RLS policies as more complex sharing and permissions are implemented
   - Add granular permissions (PRD_07)
   - Implement row/column-level access control

3. **Supabase Functions**
   - Explore Supabase Functions (Edge Functions) for custom backend logic
   - Implement automation triggers
   - Add external integrations (Slack, Teams, etc.)

4. **Deploy to Vercel**
   - Connect repo and configure environment variables
   - Set up continuous deployment
   - Configure custom domain (optional)

---

## 9. Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [PostgreSQL JSONB Guide](https://www.postgresql.org/docs/current/datatype-json.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Vercel Deployment Guide](https://vercel.com/docs)

---

## 10. Support

For issues or questions:
- Check Supabase dashboard logs
- Review API error messages
- Consult Supabase documentation
- Check browser console for client errors
