# Supabase API Usage Examples

This document provides practical examples of how to use Supabase APIs in the ProjectFlow application.

## Table of Contents

1. [Authentication](#1-authentication)
2. [CRUD Operations](#2-crud-operations)
3. [Workspaces](#3-workspaces)
4. [Projects](#4-projects)
5. [Sheets, Columns, and Rows](#5-sheets-columns-and-rows)
6. [Real-time Subscriptions](#6-real-time-subscriptions)
7. [File Storage](#7-file-storage)
8. [Comments and Activity](#8-comments-and-activity)
9. [Error Handling](#9-error-handling)

---

## 1. Authentication

### Sign Up

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();

const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      name: 'John Doe'
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

### Sign In

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure-password'
});

if (error) {
  console.error('Sign in error:', error);
} else {
  console.log('Signed in:', data.user);
}
```

### Get Current User

```typescript
const { data: { user } } = await supabase.auth.getUser();

if (user) {
  console.log('Current user:', user);
}
```

### Sign Out

```typescript
const { error } = await supabase.auth.signOut();
```

---

## 2. CRUD Operations

> **📖 For comprehensive CRUD guide, see [CRUD_OPERATIONS.md](./CRUD_OPERATIONS.md)**

### Basic CRUD Pattern

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();

// Create
const { data, error } = await supabase
  .from('table_name')
  .insert({ field: 'value' })
  .select()
  .single();

// Read
const { data, error } = await supabase
  .from('table_name')
  .select('*')
  .eq('id', id);

// Update
const { data, error } = await supabase
  .from('table_name')
  .update({ field: 'new value' })
  .eq('id', id)
  .select()
  .single();

// Delete
const { error } = await supabase
  .from('table_name')
  .delete()
  .eq('id', id);
```

**Important Notes:**
- ✅ Use `.eq()` instead of deprecated `.match()`
- ✅ Use `getUser()` instead of deprecated `user()`
- ✅ Always use `.select()` after insert/update to get data back
- ✅ RLS policies automatically enforce access control

---

## 3. Workspaces

### Get All Workspaces

```typescript
import { getWorkspaces } from './services/workspaceService';

const workspaces = await getWorkspaces();
console.log('Workspaces:', workspaces);
```

### Create Workspace

```typescript
import { createWorkspace } from './services/workspaceService';

const workspace = await createWorkspace('My New Workspace', userId);
console.log('Created workspace:', workspace);
```

### Add Member to Workspace

```typescript
import { addWorkspaceMember } from './services/workspaceService';

await addWorkspaceMember(workspaceId, userId, 'Editor');
```

### Subscribe to Workspace Changes

```typescript
const supabase = getSupabaseClient();

const subscription = supabase
  .channel('workspace-changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'workspaces',
    filter: `id=eq.${workspaceId}`
  }, (payload) => {
    console.log('Workspace changed:', payload);
    // Update UI
  })
  .subscribe();

// Cleanup
return () => {
  subscription.unsubscribe();
};
```

---

## 4. Projects

### Get Projects for Workspace

```typescript
import { getProjects } from './services/projectService';

const projects = await getProjects(workspaceId);
console.log('Projects:', projects);
```

### Create Project

```typescript
import { createProject } from './services/projectService';

const project = await createProject(workspaceId, 'My Project', userId);
console.log('Created project:', project);
```

### Create Project with Initial Sheet

```typescript
import { createProject, createSheet, createColumn } from './services/projectService';

// Create project
const project = await createProject(workspaceId, 'My Project', userId);

// Create sheet
const sheet = await createSheet(project.id, 'Main Sheet');

// Add columns
await createColumn(sheet.id, {
  title: 'Task',
  type: 'text',
  width: 300
});

await createColumn(sheet.id, {
  title: 'Status',
  type: 'dropdown',
  width: 150,
  options: ['To Do', 'In Progress', 'Done']
});

await createColumn(sheet.id, {
  title: 'Due Date',
  type: 'date',
  width: 150
});
```

### Update Project

```typescript
import { updateProject } from './services/projectService';

await updateProject(projectId, {
  name: 'Updated Project Name',
  activeSheetId: sheetId
});
```

---

## 5. Sheets, Columns, and Rows

### Create Row

```typescript
import { createRow } from './services/projectService';

const row = await createRow(sheetId, {
  id: 'row-1',
  task: 'Complete documentation',
  status: 'In Progress',
  owner: 'John Doe',
  dueDate: '2024-12-31',
  progress: 50
});

console.log('Created row:', row);
```

### Update Row

```typescript
import { updateRow } from './services/projectService';

// Update specific fields
await updateRow(rowId, {
  status: 'Done',
  progress: 100
});

// Update with dependencies
await updateRow(rowId, {
  dependencies: ['row-2', 'row-3']
});
```

### Query Rows with Filters

```typescript
const supabase = getSupabaseClient();

// Get rows with specific status
const { data: rows, error } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>status', 'eq', 'In Progress');

// Get rows with date filter
const { data: overdueRows } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>dueDate', 'lt', new Date().toISOString().split('T')[0]);
```

### Batch Update Rows

```typescript
const supabase = getSupabaseClient();

// Update multiple rows
const updates = [
  { id: 'row-1', row_data: { status: 'Done' } },
  { id: 'row-2', row_data: { status: 'Done' } }
];

for (const update of updates) {
  await supabase
    .from('rows')
    .update({ row_data: update.row_data })
    .eq('id', update.id);
}
```

### Search Rows

```typescript
const supabase = getSupabaseClient();

// Use the search function
const { data: results } = await supabase.rpc('search_rows', {
  p_sheet_id: sheetId,
  p_search_term: 'documentation'
});

console.log('Search results:', results);
```

---

## 6. Real-time Subscriptions

> **📖 For comprehensive real-time guide, see [REALTIME_COLLABORATION.md](./REALTIME_COLLABORATION.md)**

### Subscribe to Row Changes

```typescript
import { useEffect } from 'react';
import { getSupabaseClient } from './services/supabaseService';

function useRowUpdates(sheetId: string, onUpdate: (payload: any) => void) {
  useEffect(() => {
    const supabase = getSupabaseClient();
    
    const subscription = supabase
      .channel(`sheet-${sheetId}`)
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'rows',
        filter: `sheet_id=eq.${sheetId}`
      }, (payload) => {
        console.log('Row change:', payload);
        onUpdate(payload);
      })
      .subscribe();

    return () => {
      subscription.unsubscribe();
    };
  }, [sheetId, onUpdate]);
}

// Usage in component
function SheetComponent({ sheetId }: { sheetId: string }) {
  const [rows, setRows] = useState([]);

  useRowUpdates(sheetId, (payload) => {
    if (payload.eventType === 'INSERT') {
      setRows(prev => [...prev, payload.new]);
    } else if (payload.eventType === 'UPDATE') {
      setRows(prev => prev.map(r => 
        r.id === payload.new.id ? payload.new : r
      ));
    } else if (payload.eventType === 'DELETE') {
      setRows(prev => prev.filter(r => r.id !== payload.old.id));
    }
  });

  // ... rest of component
}
```

### Subscribe to Multiple Tables

```typescript
const supabase = getSupabaseClient();

const subscription = supabase
  .channel('project-updates')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'rows',
    filter: `sheet_id=eq.${sheetId}`
  }, handleRowChange)
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'comments',
    filter: `row_id=in.(${rowIds.join(',')})`
  }, handleCommentChange)
  .subscribe();
```

---

## 7. File Storage

### Upload File

```typescript
const supabase = getSupabaseClient();

const file = event.target.files[0];
const fileName = `${rowId}/${Date.now()}-${file.name}`;

const { data, error } = await supabase.storage
  .from('attachments')
  .upload(fileName, file, {
    cacheControl: '3600',
    upsert: false
  });

if (error) {
  console.error('Upload error:', error);
} else {
  // Get public URL
  const { data: { publicUrl } } = supabase.storage
    .from('attachments')
    .getPublicUrl(fileName);

  // Save attachment record
  await supabase
    .from('file_attachments')
    .insert({
      row_id: rowId,
      name: file.name,
      type: file.type,
      size: file.size,
      url: publicUrl,
      provider: 'local'
    });
}
```

### List Files for Row

```typescript
const { data: attachments, error } = await supabase
  .from('file_attachments')
  .select('*')
  .eq('row_id', rowId)
  .order('created_at', { ascending: false });
```

### Delete File

```typescript
// Delete from storage
const { error: storageError } = await supabase.storage
  .from('attachments')
  .remove([`${rowId}/${fileName}`]);

// Delete record
const { error: dbError } = await supabase
  .from('file_attachments')
  .delete()
  .eq('id', attachmentId);
```

---

## 8. Comments and Activity

### Add Comment

```typescript
const supabase = getSupabaseClient();
const { data: { user } } = await supabase.auth.getUser();

const { data: profile } = await supabase
  .from('profiles')
  .select('name')
  .eq('id', user.id)
  .single();

const { data: comment, error } = await supabase
  .from('comments')
  .insert({
    row_id: rowId,
    user_id: user.id,
    user_name: profile.name,
    text: 'This looks good!'
  })
  .select()
  .single();
```

### Get Comments for Row

```typescript
const { data: comments, error } = await supabase
  .from('comments')
  .select('*')
  .eq('row_id', rowId)
  .order('created_at', { ascending: true });
```

### Log Activity

```typescript
const supabase = getSupabaseClient();

// Using the helper function
const { data: activityId } = await supabase.rpc('log_activity', {
  p_project_id: projectId,
  p_user_id: userId,
  p_user_name: userName,
  p_action: 'Updated row',
  p_row_id: rowId,
  p_details: 'Changed status to Done'
});
```

### Get Activity Log

```typescript
const { data: activities, error } = await supabase
  .from('activity_log')
  .select(`
    *,
    profiles (name, email)
  `)
  .eq('project_id', projectId)
  .order('created_at', { ascending: false })
  .limit(50);
```

---

## 9. Error Handling

### Basic Error Handling

```typescript
try {
  const projects = await getProjects(workspaceId);
  // Use projects
} catch (error) {
  console.error('Error fetching projects:', error);
  
  if (error.code === 'PGRST301') {
    // Not found
    console.log('No projects found');
  } else if (error.code === '42501') {
    // Permission denied (RLS)
    console.error('Permission denied');
  } else {
    // Other error
    console.error('Unexpected error:', error.message);
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
const projects = await fetchWithRetry(() => getProjects(workspaceId));
```

### Optimistic Updates with Rollback

```typescript
async function updateRowOptimistic(
  rowId: string,
  updates: Partial<RowData>
) {
  // Save original state
  const originalRow = rows.find(r => r.id === rowId);
  
  // Optimistic update
  setRows(prev => prev.map(r => 
    r.id === rowId ? { ...r, ...updates } : r
  ));
  
  try {
    await updateRow(rowId, updates);
  } catch (error) {
    // Rollback on error
    setRows(prev => prev.map(r => 
      r.id === rowId ? originalRow : r
    ));
    throw error;
  }
}
```

---

## 10. Advanced Patterns

### Pagination

```typescript
async function getRowsPaginated(
  sheetId: string,
  page: number,
  pageSize: number = 50
) {
  const supabase = getSupabaseClient();
  
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;
  
  const { data, error, count } = await supabase
    .from('rows')
    .select('*', { count: 'exact' })
    .eq('sheet_id', sheetId)
    .range(from, to)
    .order('created_at', { ascending: false });
  
  if (error) throw error;
  
  return {
    data: data || [],
    total: count || 0,
    page,
    pageSize,
    totalPages: Math.ceil((count || 0) / pageSize)
  };
}
```

### Bulk Operations

```typescript
async function bulkUpdateRows(
  rowIds: string[],
  updates: Partial<RowData>
) {
  const supabase = getSupabaseClient();
  
  // Get existing rows
  const { data: existingRows } = await supabase
    .from('rows')
    .select('*')
    .in('id', rowIds);
  
  // Update each row
  const promises = existingRows.map(row => {
    const newRowData = { ...row.row_data, ...updates };
    return supabase
      .from('rows')
      .update({ row_data: newRowData })
      .eq('id', row.id);
  });
  
  await Promise.all(promises);
}
```

---

## 11. Best Practices

1. **Always handle errors**: Wrap API calls in try-catch blocks
2. **Use TypeScript**: Leverage type safety for better code quality
3. **Optimistic updates**: Update UI immediately, sync with backend
4. **Cleanup subscriptions**: Always unsubscribe from real-time channels
5. **Use service layer**: Keep API logic in service files, not components
6. **Cache data**: Use React Query or similar for caching and refetching
7. **Batch operations**: Group multiple updates when possible
8. **Validate input**: Validate data before sending to API
9. **Handle loading states**: Show loading indicators during API calls
10. **Test error scenarios**: Test network failures, permission errors, etc.
