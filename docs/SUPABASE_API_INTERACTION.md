# Supabase API Interaction Guide

This document explains how Supabase automatically generates RESTful APIs for your tables and how to interact with them.

## Table of Contents

1. [Overview](#1-overview)
2. [Auto-generated APIs](#2-auto-generated-apis)
3. [Using the JavaScript Client](#3-using-the-javascript-client)
4. [Direct HTTP Requests](#4-direct-http-requests)
5. [Query Examples](#5-query-examples)
6. [API Documentation](#6-api-documentation)
7. [Best Practices](#7-best-practices)

---

## 1. Overview

### What are Auto-generated APIs?

Supabase automatically creates RESTful API endpoints for every table in your database. **No backend code required!**

```
Database Schema → Supabase → Auto-generated REST API
     (SQL)          (Magic)      (HTTP Endpoints)
```

### How It Works

1. **Define Schema**: Create tables in PostgreSQL
2. **Automatic Generation**: Supabase creates REST endpoints
3. **Use APIs**: Call endpoints via HTTP or client library
4. **RLS Enforcement**: Security policies automatically applied

### Benefits

- ✅ **No Backend Code** - Database schema = API automatically
- ✅ **Type-safe** - TypeScript client with autocomplete
- ✅ **Secure** - RLS policies enforced automatically
- ✅ **Fast** - Direct database access
- ✅ **Real-time** - WebSocket subscriptions available

---

## 2. Auto-generated APIs

### API Endpoints Structure

For every table, Supabase creates:

```
Base URL: https://[project-ref].supabase.co/rest/v1/

Endpoints:
GET    /rest/v1/table_name          # List all rows
GET    /rest/v1/table_name?id=eq.1  # Filter rows
POST   /rest/v1/table_name          # Create row
PATCH  /rest/v1/table_name?id=eq.1  # Update row
DELETE /rest/v1/table_name?id=eq.1  # Delete row
```

### Example: Projects Table

```
GET    /rest/v1/projects                    # Get all projects
GET    /rest/v1/projects?id=eq.123          # Get project by ID
GET    /rest/v1/projects?workspace_id=eq.1  # Filter by workspace
POST   /rest/v1/projects                    # Create project
PATCH  /rest/v1/projects?id=eq.123          # Update project
DELETE /rest/v1/projects?id=eq.123          # Delete project
```

### Automatic Features

- ✅ **Filtering** - Query parameters for filtering
- ✅ **Sorting** - Order results
- ✅ **Pagination** - Limit and offset
- ✅ **Relationships** - Join related tables
- ✅ **Count** - Get total count
- ✅ **RLS** - Security automatically enforced

---

## 3. Using the JavaScript Client

### Setup

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();
```

### Basic Operations

#### Select (Read)

```typescript
// Get all rows
const { data, error } = await supabase
  .from('projects')
  .select('*');

// Get single row
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .eq('id', projectId)
  .single();

// Filter rows
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .eq('workspace_id', workspaceId)
  .order('created_at', { ascending: false });
```

#### Insert (Create)

```typescript
// Create single row
const { data, error } = await supabase
  .from('projects')
  .insert({
    name: 'My Project',
    workspace_id: workspaceId,
    owner_id: userId
  })
  .select()
  .single();

// Create multiple rows
const { data, error } = await supabase
  .from('rows')
  .insert([
    { sheet_id: sheetId, row_data: { task: 'Task 1' } },
    { sheet_id: sheetId, row_data: { task: 'Task 2' } }
  ])
  .select();
```

#### Update

```typescript
// Update single row
const { data, error } = await supabase
  .from('projects')
  .update({ name: 'Updated Name' })
  .eq('id', projectId)
  .select()
  .single();

// Update multiple rows
const { data, error } = await supabase
  .from('rows')
  .update({ row_data: { status: 'Done' } })
  .in('id', [rowId1, rowId2]);
```

#### Delete

```typescript
// Delete single row
const { error } = await supabase
  .from('projects')
  .delete()
  .eq('id', projectId);

// Delete multiple rows
const { error } = await supabase
  .from('rows')
  .delete()
  .in('id', [rowId1, rowId2]);
```

---

## 4. Direct HTTP Requests

### Using Fetch API

```typescript
const SUPABASE_URL = 'https://woigtfojjixtmwaoamap.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';

// Get projects
const response = await fetch(`${SUPABASE_URL}/rest/v1/projects`, {
  method: 'GET',
  headers: {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'  // Return created/updated data
  }
});

const projects = await response.json();
```

### Using cURL

```bash
# Get projects
curl 'https://woigtfojjixtmwaoamap.supabase.co/rest/v1/projects' \
  -H "apikey: your-anon-key" \
  -H "Authorization: Bearer your-anon-key"

# Create project
curl -X POST 'https://woigtfojjixtmwaoamap.supabase.co/rest/v1/projects' \
  -H "apikey: your-anon-key" \
  -H "Authorization: Bearer your-anon-key" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "My Project",
    "workspace_id": "workspace-id",
    "owner_id": "user-id"
  }'
```

---

## 5. Query Examples

### Filtering

```typescript
// Equal
.eq('workspace_id', workspaceId)

// Not equal
.neq('status', 'Done')

// Greater than
.gt('progress', 50)

// Less than
.lt('dueDate', today)

// In array
.in('id', [id1, id2, id3])

// Contains (for arrays)
.contains('dependencies', [rowId])

// Text search
.ilike('name', '%search%')
```

### Relationships (Joins)

```typescript
// Get project with sheets and rows
const { data } = await supabase
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

### Sorting

```typescript
// Single column
.order('created_at', { ascending: false })

// Multiple columns
.order('status', { ascending: true })
.order('dueDate', { ascending: true })
```

### Pagination

```typescript
// Get 50 rows, starting from row 100
const { data } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .range(100, 149)
  .order('created_at', { ascending: false });
```

### Counting

```typescript
// Get count
const { count } = await supabase
  .from('projects')
  .select('*', { count: 'exact', head: true })
  .eq('workspace_id', workspaceId);
```

### JSONB Queries

```typescript
// Query JSONB field
const { data } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>status', 'eq', 'In Progress');

// JSONB contains
const { data } = await supabase
  .from('rows')
  .select('*')
  .contains('row_data', { status: 'Done' });
```

---

## 6. API Documentation

### Accessing API Docs

1. **Supabase Dashboard**
   - Go to your project
   - Navigate to **API** → **REST**
   - See auto-generated documentation

2. **API Reference**
   - Shows all endpoints
   - Includes request/response examples
   - Shows available filters and operators

### Example API Documentation

```
GET /rest/v1/projects

Query Parameters:
  - select: Columns to return (default: *)
  - filter: Filter conditions (eq, neq, gt, lt, etc.)
  - order: Sort order
  - limit: Number of rows
  - offset: Skip rows

Headers:
  - apikey: Your anon key
  - Authorization: Bearer token
  - Content-Type: application/json
  - Prefer: return=representation (for POST/PATCH)
```

---

## 7. Best Practices

### 1. Use the JavaScript Client

**Prefer:**
```typescript
const { data, error } = await supabase
  .from('projects')
  .select('*');
```

**Instead of:**
```typescript
const response = await fetch(`${SUPABASE_URL}/rest/v1/projects`, {
  headers: { ... }
});
```

**Why:**
- Type-safe with TypeScript
- Automatic error handling
- Built-in authentication
- Easier to use

### 2. Always Handle Errors

```typescript
const { data, error } = await supabase
  .from('projects')
  .select('*');

if (error) {
  console.error('Error:', error);
  // Handle error appropriately
  return;
}

// Use data
console.log('Projects:', data);
```

### 3. Use Select to Limit Data

```typescript
// Good: Only select needed columns
.select('id, name, workspace_id')

// Avoid: Selecting all columns when not needed
.select('*')
```

### 4. Use Relationships for Joins

```typescript
// Good: Use Supabase relationships
.select(`
  *,
  sheets (*),
  workspace_members (*)
`)

// Avoid: Multiple queries
// (Fetch projects, then sheets, then members separately)
```

### 5. Use Indexed Operators for JSONB

```typescript
// Good: Use indexed operators
.contains('row_data', { status: 'Done' })
.filter('row_data->>status', 'eq', 'Done')

// Avoid: Full table scans
// (Don't fetch all rows and filter in JavaScript)
```

### 6. Implement Pagination

```typescript
// Good: Paginate large datasets
.range(0, 49)  // First 50 rows

// Avoid: Fetching all rows at once
// (Don't fetch 10,000 rows in one query)
```

### 7. Use RLS Policies

```typescript
// RLS automatically filters results
// No need to filter by user_id manually

// Good: RLS handles filtering
const { data } = await supabase
  .from('projects')
  .select('*');
// Returns only projects user has access to

// Avoid: Manual filtering
// (Don't fetch all projects and filter in JavaScript)
```

---

## 8. Advanced Features

### Upsert (Insert or Update)

```typescript
const { data, error } = await supabase
  .from('projects')
  .upsert({
    id: projectId,
    name: 'Updated Name',
    workspace_id: workspaceId
  }, {
    onConflict: 'id'
  })
  .select();
```

### Batch Operations

```typescript
// Update multiple rows
const updates = rows.map(row => ({
  id: row.id,
  row_data: { ...row.row_data, status: 'Done' }
}));

const { data, error } = await supabase
  .from('rows')
  .upsert(updates, { onConflict: 'id' })
  .select();
```

### Stored Procedures (RPC)

```typescript
// Call database function
const { data, error } = await supabase.rpc('get_project_full', {
  p_project_id: projectId
});
```

---

## 9. Error Handling

### Common Errors

```typescript
const { data, error } = await supabase
  .from('projects')
  .select('*');

if (error) {
  switch (error.code) {
    case 'PGRST116':
      // Not found
      console.log('Project not found');
      break;
    case '42501':
      // Permission denied (RLS)
      console.error('Permission denied');
      break;
    case '23505':
      // Unique constraint violation
      console.error('Duplicate entry');
      break;
    default:
      console.error('Error:', error.message);
  }
}
```

### Retry Logic

```typescript
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
  throw new Error('Max retries exceeded');
}

// Usage
const projects = await fetchWithRetry(() =>
  supabase.from('projects').select('*')
);
```

---

## 10. Type Safety

### TypeScript Types

```typescript
// Define types
interface Project {
  id: string;
  name: string;
  workspace_id: string;
  owner_id: string;
  created_at: string;
}

// Use with Supabase
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .eq('id', projectId)
  .single();

const project = data as Project;
```

### Auto-generated Types (Future)

Supabase can generate TypeScript types from your schema:

```bash
# Generate types
npx supabase gen types typescript --project-id woigtfojjixtmwaoamap > types/database.ts
```

Then use:

```typescript
import { Database } from './types/database';

type Project = Database['public']['tables']['projects']['Row'];
```

---

## 11. Real-time Subscriptions

### Subscribe to Changes

```typescript
// Subscribe to row changes
const subscription = supabase
  .channel('rows-changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'rows',
    filter: `sheet_id=eq.${sheetId}`
  }, (payload) => {
    console.log('Change:', payload);
    // Update UI
  })
  .subscribe();

// Cleanup
return () => {
  subscription.unsubscribe();
};
```

---

## 12. Summary

### Key Points

1. ✅ **Auto-generated APIs** - Every table gets REST endpoints
2. ✅ **No backend code** - Database schema = API automatically
3. ✅ **Use JavaScript client** - Type-safe and easier
4. ✅ **RLS enforced** - Security automatically applied
5. ✅ **Type-safe** - TypeScript support
6. ✅ **Real-time** - WebSocket subscriptions available

### Quick Reference

```typescript
// Setup
import { getSupabaseClient } from './services/supabaseService';
const supabase = getSupabaseClient();

// Read
const { data } = await supabase.from('table').select('*');

// Create
const { data } = await supabase.from('table').insert({...}).select();

// Update
const { data } = await supabase.from('table').update({...}).eq('id', id);

// Delete
await supabase.from('table').delete().eq('id', id);
```

---

**Supabase automatically generates powerful APIs from your database schema - no backend code needed!** 🚀
