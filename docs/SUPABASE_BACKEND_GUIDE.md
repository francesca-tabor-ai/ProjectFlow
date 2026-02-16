# Supabase Backend Guide: Database & API

This document explains how Supabase serves as the primary backend for ProjectFlow, providing PostgreSQL database, authentication, instant APIs, and real-time subscriptions.

## Table of Contents

1. [Overview](#1-overview)
2. [PostgreSQL Database](#2-postgresql-database)
3. [Authentication](#3-authentication)
4. [Instant APIs](#4-instant-apis)
5. [Real-time Subscriptions](#5-real-time-subscriptions)
6. [How It All Works Together](#6-how-it-all-works-together)
7. [Architecture Diagram](#7-architecture-diagram)

---

## 1. Overview

Supabase is an open-source Firebase alternative that provides:

```
┌─────────────────────────────────────────────────────────┐
│                    Supabase Backend                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  PostgreSQL  │  │     Auth     │  │   Storage    │ │
│  │   Database   │  │              │  │              │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
│         │                  │                  │         │
│         └──────────────────┼──────────────────┘         │
│                            │                            │
│                  ┌─────────▼─────────┐                  │
│                  │   Auto-generated  │                  │
│                  │   REST & GraphQL │                  │
│                  │       APIs        │                  │
│                  └─────────┬─────────┘                  │
│                            │                            │
│                  ┌─────────▼─────────┐                  │
│                  │   Real-time       │                  │
│                  │   Subscriptions  │                  │
│                  │   (WebSocket)    │                  │
│                  └───────────────────┘                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Key Benefits

- **No Backend Code Required**: Database schema automatically generates REST APIs
- **Built-in Security**: Row Level Security (RLS) at the database level
- **Real-time by Default**: WebSocket subscriptions for live updates
- **Type-safe**: TypeScript client with auto-generated types
- **Scalable**: Built on PostgreSQL, handles millions of requests

---

## 2. PostgreSQL Database

### 2.1 What is PostgreSQL?

PostgreSQL is a powerful, open-source relational database that Supabase uses as its foundation. It provides:

- **ACID Compliance**: Data integrity guarantees
- **JSONB Support**: Store flexible JSON data with query capabilities
- **Full-text Search**: Built-in search functionality
- **Extensions**: Rich ecosystem of PostgreSQL extensions
- **Performance**: Optimized for complex queries and large datasets

### 2.2 Database Structure in ProjectFlow

Our database is organized into logical tables:

```
workspaces (top-level containers)
  └── projects (belong to workspaces)
      └── sheets (belong to projects)
          ├── columns (define sheet structure)
          └── rows (actual data, stored as JSONB)
              ├── comments
              └── file_attachments
```

### 2.3 Key Features

#### **JSONB for Flexible Data**

Rows store data as JSONB, allowing dynamic columns:

```sql
-- Row table structure
CREATE TABLE rows (
  id UUID PRIMARY KEY,
  sheet_id UUID REFERENCES sheets(id),
  row_data JSONB,  -- Flexible: { task: "Do work", status: "Done", ... }
  dependencies TEXT[]
);
```

**Benefits:**
- No schema changes needed when adding new columns
- Fast queries with JSONB indexes
- Type-safe access via TypeScript

#### **Row Level Security (RLS)**

Security is enforced at the database level:

```sql
-- Example: Users can only see rows in sheets they have access to
CREATE POLICY "Users can view rows"
ON rows FOR SELECT
USING (
  sheet_id IN (
    SELECT id FROM sheets WHERE project_id IN (
      SELECT id FROM projects WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = auth.uid()
      )
    )
  )
);
```

**Benefits:**
- Security enforced even if API is bypassed
- No need to check permissions in application code
- Automatic filtering of unauthorized data

---

## 3. Authentication

> **📖 For comprehensive authentication guide, see [AUTHENTICATION_GUIDE.md](./AUTHENTICATION_GUIDE.md)**

### 3.1 How Supabase Auth Works

Supabase provides a complete authentication system:

```
┌─────────────┐
│   Client    │
│  (React)    │
└──────┬──────┘
       │
       │ 1. Sign Up/In Request
       ▼
┌─────────────┐
│  Supabase   │
│    Auth     │
└──────┬──────┘
       │
       │ 2. Create/Verify User
       ▼
┌─────────────┐
│  PostgreSQL │
│ auth.users  │
└──────┬──────┘
       │
       │ 3. Trigger Profile Creation
       ▼
┌─────────────┐
│  profiles   │
│   Table     │
└─────────────┘
```

### 3.2 Authentication Flow

#### **Sign Up**

```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      name: 'John Doe'  // Stored in user metadata
    }
  }
});

// Automatically:
// 1. Creates user in auth.users
// 2. Triggers profile creation in profiles table
// 3. Returns JWT token
```

#### **Sign In**

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure-password'
});

// Returns:
// - User object
// - Session with JWT token
// - Refresh token for token renewal
```

#### **Session Management**

```typescript
// Get current session
const { data: { session } } = await supabase.auth.getSession();

// Session contains:
// - access_token (JWT)
// - refresh_token
// - user object
// - expires_at

// Auto-refresh handled by Supabase client
```

### 3.3 JWT Tokens

Every authenticated request includes a JWT token:

```
Header: Authorization: Bearer <JWT_TOKEN>
```

The token contains:
- User ID (`sub`)
- Email
- Role
- Custom metadata

Supabase validates the token and extracts `auth.uid()` for RLS policies.

**Important**: The JWT token must be included in the `Authorization` header for all API requests to access RLS-protected data.

---

## 4. Instant APIs

> **📖 For detailed API interaction guide, see [SUPABASE_API_INTERACTION.md](./SUPABASE_API_INTERACTION.md)**

### 4.1 What are Instant APIs?

Supabase automatically generates REST and GraphQL APIs from your database schema. **No backend code required!**

```
Database Schema → Auto-generated → REST API
     (SQL)           (Supabase)      (HTTP)
```

### 4.2 REST API Endpoints

For every table, Supabase creates:

```
GET    /rest/v1/table_name          # List all rows
GET    /rest/v1/table_name?id=eq.1  # Filter rows
POST   /rest/v1/table_name          # Create row
PATCH  /rest/v1/table_name?id=eq.1  # Update row
DELETE /rest/v1/table_name?id=eq.1  # Delete row
```

### 4.3 Using the JavaScript Client

The Supabase client provides a type-safe interface:

```typescript
// Instead of writing HTTP requests:
const response = await fetch('https://api.supabase.co/rest/v1/projects', {
  headers: {
    'Authorization': 'Bearer ' + token,
    'apikey': 'your-key'
  }
});

// You write:
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .eq('workspace_id', workspaceId);
```

### 4.4 Query Examples

#### **Simple Select**

```typescript
// Get all projects
const { data: projects } = await supabase
  .from('projects')
  .select('*');
```

#### **Filtering**

```typescript
// Get projects in a workspace
const { data: projects } = await supabase
  .from('projects')
  .select('*')
  .eq('workspace_id', workspaceId);
```

#### **Relationships (Joins)**

```typescript
// Get project with sheets and rows
const { data: project } = await supabase
  .from('projects')
  .select(`
    *,
    sheets (
      *,
      columns (*),
      rows (*)
    )
  `)
  .eq('id', projectId)
  .single();
```

#### **Pagination**

```typescript
// Get 50 rows, starting from row 100
const { data: rows } = await supabase
  .from('rows')
  .select('*')
  .range(100, 149);
```

#### **JSONB Queries**

```typescript
// Query JSONB column
const { data: rows } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>status', 'eq', 'Done');
```

### 4.5 API Features

#### **Automatic Filtering**

RLS policies automatically filter results:

```typescript
// User only sees projects they have access to
// No need to filter in application code!
const { data: projects } = await supabase
  .from('projects')
  .select('*');
// Returns only authorized projects
```

#### **Type Safety**

With TypeScript, you get autocomplete and type checking:

```typescript
// Auto-complete for table names, columns, etc.
const { data } = await supabase
  .from('projects')  // ← Autocomplete suggests table names
  .select('name, workspace_id')  // ← Autocomplete suggests columns
```

### 4.6 Accessing API Documentation

1. **Supabase Dashboard** → **API** → **REST**
2. See auto-generated documentation for all endpoints
3. Includes request/response examples
4. Shows available filters and operators

---

## 5. Real-time Subscriptions

### 5.1 How Real-time Works

Supabase uses WebSockets to push database changes to clients in real-time:

```
┌──────────┐                    ┌──────────┐
│ Database │                    │  Client  │
│          │                    │          │
│  INSERT  │───WebSocket───────▶│  Update  │
│  UPDATE  │                    │   UI     │
│  DELETE  │                    │          │
└──────────┘                    └──────────┘
```

### 5.2 Subscription Example

```typescript
// Subscribe to row changes
const subscription = supabase
  .channel('rows-channel')
  .on('postgres_changes', {
    event: '*',  // INSERT, UPDATE, DELETE
    schema: 'public',
    table: 'rows',
    filter: `sheet_id=eq.${sheetId}`
  }, (payload) => {
    console.log('Change received!', payload);
    
    if (payload.eventType === 'INSERT') {
      // Add new row to UI
      setRows(prev => [...prev, payload.new]);
    } else if (payload.eventType === 'UPDATE') {
      // Update row in UI
      setRows(prev => prev.map(r => 
        r.id === payload.new.id ? payload.new : r
      ));
    } else if (payload.eventType === 'DELETE') {
      // Remove row from UI
      setRows(prev => prev.filter(r => r.id !== payload.old.id));
    }
  })
  .subscribe();

// Cleanup
return () => {
  subscription.unsubscribe();
};
```

### 5.3 Use Cases in ProjectFlow

#### **Collaborative Editing**

```typescript
// Multiple users editing the same sheet
// Changes appear instantly for all users
const subscription = supabase
  .channel('sheet-collaboration')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'rows'
  }, (payload) => {
    // Show "User X is editing row Y"
    showCollaborationIndicator(payload.new);
  })
  .subscribe();
```

#### **Live Activity Feed**

```typescript
// Activity log updates in real-time
const subscription = supabase
  .channel('activity-feed')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'activity_log',
    filter: `project_id=eq.${projectId}`
  }, (payload) => {
    // Add new activity to feed
    addActivityToFeed(payload.new);
  })
  .subscribe();
```

### 5.4 Presence (Who's Online)

```typescript
// Track who's currently viewing a sheet
const channel = supabase.channel('sheet-presence');

channel
  .on('presence', { event: 'sync' }, () => {
    const state = channel.presenceState();
    console.log('Users online:', state);
  })
  .on('presence', { event: 'join' }, ({ key, newPresences }) => {
    console.log('User joined:', newPresences);
  })
  .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
    console.log('User left:', leftPresences);
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await channel.track({
        user: userId,
        online_at: new Date().toISOString()
      });
    }
  });
```

---

## 6. How It All Works Together

### 6.1 Complete Request Flow

```
1. User Action (React Component)
   ↓
2. Service Function (projectService.ts)
   ↓
3. Supabase Client (supabaseService.ts)
   ↓
4. HTTP Request → Supabase API
   ↓
5. Authentication Check (JWT validation)
   ↓
6. RLS Policy Check (Database level)
   ↓
7. PostgreSQL Query Execution
   ↓
8. Response → Client
   ↓
9. Update React State
   ↓
10. Real-time Broadcast (if subscribed)
```

### 6.2 Example: Creating a Row

```typescript
// 1. User clicks "Add Row" button
const handleAddRow = async () => {
  // 2. Call service function
  const newRow = await createRow(sheetId, {
    task: 'New Task',
    status: 'To Do'
  });
  
  // 3. Update UI (optimistic update)
  setRows(prev => [...prev, newRow]);
};

// Service function (projectService.ts)
export const createRow = async (sheetId: string, rowData: any) => {
  // 4. Use Supabase client
  const supabase = getSupabaseClient();
  
  // 5. Make API call
  const { data, error } = await supabase
    .from('rows')
    .insert({
      sheet_id: sheetId,
      row_data: rowData
    })
    .select()
    .single();
  
  // 6. RLS automatically checks permissions
  // 7. Database inserts row
  // 8. Returns new row
  
  return data;
};

// 9. Real-time subscription broadcasts change
// Other users see the new row instantly!
```

### 6.3 Security Flow

```
Request → JWT Token → User ID → RLS Policy → Database Query
                                    ↓
                            ✅ Allowed → Return Data
                            ❌ Denied → Return Error
```

**Key Point**: Security is enforced at the database level, not in application code.

---

## 7. Architecture Diagram

### Complete System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      React Frontend                         │
│  (Vercel Deployment)                                        │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │  Components  │  │   Services   │  │     Hooks     │   │
│  │              │  │              │  │               │   │
│  │  - App.tsx   │→ │ - project    │→ │ - useProjects │   │
│  │  - SheetGrid │  │ - workspace  │  │ - useWorkspace│   │
│  │  - Kanban    │  │ - supabase    │  │               │   │
│  └──────────────┘  └──────┬───────┘  └───────────────┘   │
│                            │                               │
└────────────────────────────┼───────────────────────────────┘
                             │
                             │ HTTPS / WebSocket
                             │
┌────────────────────────────▼───────────────────────────────┐
│                    Supabase Backend                        │
│  (https://woigtfojjixtmwaoamap.supabase.co)                │
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │            Auto-generated REST API                 │   │
│  │  GET/POST/PATCH/DELETE /rest/v1/{table}            │   │
│  └────────────────────────────────────────────────────┘   │
│                            │                                │
│  ┌─────────────────────────┼────────────────────────────┐  │
│  │  Authentication        │  Real-time                 │  │
│  │  - JWT validation      │  - WebSocket               │  │
│  │  - Session management  │  - Subscriptions            │  │
│  └─────────────────────────┼────────────────────────────┘  │
│                            │                                │
│  ┌─────────────────────────▼────────────────────────────┐  │
│  │         Row Level Security (RLS)                     │  │
│  │  - Policy evaluation                                 │  │
│  │  - Automatic filtering                               │  │
│  └─────────────────────────┬────────────────────────────┘  │
│                            │                                │
│  ┌─────────────────────────▼────────────────────────────┐  │
│  │            PostgreSQL Database                         │  │
│  │                                                         │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │  │
│  │  │workspaces│→ │ projects │→ │  sheets  │          │  │
│  │  └──────────┘  └──────────┘  └────┬─────┘          │  │
│  │                                    │                 │  │
│  │                            ┌───────┴───────┐        │  │
│  │                            │   columns    │        │  │
│  │                            │     rows     │        │  │
│  │                            └───────────────┘        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │              Storage (File Attachments)             │   │
│  │              - S3-compatible                        │   │
│  │              - Private buckets                      │   │
│  └────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Key Takeaways

### Why Supabase as Backend?

1. **No Backend Code**: Database schema = API automatically
2. **Built-in Security**: RLS policies enforce access control
3. **Real-time by Default**: WebSocket subscriptions out of the box
4. **Type Safety**: TypeScript client with autocomplete
5. **Scalable**: PostgreSQL handles millions of requests
6. **Developer Experience**: Focus on frontend, not backend infrastructure

### What You Get

✅ **Database**: PostgreSQL with JSONB support  
✅ **API**: Auto-generated REST endpoints  
✅ **Auth**: Complete authentication system  
✅ **Real-time**: WebSocket subscriptions  
✅ **Storage**: File uploads and management  
✅ **Security**: Row Level Security policies  

### Next Steps

1. Run database migrations (see `supabase/migrations/`)
2. Set up authentication (Supabase Dashboard)
3. Use service functions (see `services/` directory)
4. Add real-time subscriptions where needed
5. Deploy to Vercel with environment variables

---

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL JSONB Guide](https://www.postgresql.org/docs/current/datatype-json.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Real-time Subscriptions](https://supabase.com/docs/guides/realtime)
- [JavaScript Client Reference](https://supabase.com/docs/reference/javascript/introduction)

---

**Your Supabase backend is ready to power ProjectFlow!** 🚀
