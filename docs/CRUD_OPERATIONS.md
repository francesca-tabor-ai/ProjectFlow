# CRUD Operations Guide

Complete guide to Create, Read, Update, and Delete operations in ProjectFlow using Supabase.

## Table of Contents

1. [Overview](#1-overview)
2. [Workspaces CRUD](#2-workspaces-crud)
3. [Projects CRUD](#3-projects-crud)
4. [Sheets CRUD](#4-sheets-crud)
5. [Columns CRUD](#5-columns-crud)
6. [Rows CRUD](#6-rows-crud)
7. [Best Practices](#7-best-practices)

---

## 1. Overview

### What is CRUD?

**CRUD** stands for:
- **C**reate - Insert new records
- **R**ead - Query/select records
- **U**pdate - Modify existing records
- **D**elete - Remove records

### RLS Enforcement

**Important**: All CRUD operations are automatically protected by Row Level Security (RLS) policies. Users can only:
- ✅ Create records they're authorized to create
- ✅ Read records they have access to
- ✅ Update records they have permission to update
- ✅ Delete records they're allowed to delete

**No need to manually check permissions - RLS handles it automatically!**

---

## 2. Workspaces CRUD

### Create a Workspace

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();

// Get current user
const { data: { user } } = await supabase.auth.getUser();
if (!user) throw new Error('Not authenticated');

// Create workspace
const { data, error } = await supabase
  .from('workspaces')
  .insert({
    name: 'My First Workspace',
    owner_id: user.id  // ✅ Use user.id (not supabase.auth.user().id)
  })
  .select()
  .single();

if (error) {
  console.error('Error creating workspace:', error);
} else {
  console.log('Workspace created:', data);
  
  // Add owner as workspace member
  await supabase
    .from('workspace_members')
    .insert({
      workspace_id: data.id,
      user_id: user.id,
      role: 'Owner'
    });
}
```

**Note**: The PRD example uses `supabase.auth.user().id` which is deprecated. Use `supabase.auth.getUser()` instead.

### Read Workspaces

```typescript
// Get all workspaces user has access to (RLS filters automatically)
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

// Get single workspace
const { data: workspace, error } = await supabase
  .from('workspaces')
  .select('*')
  .eq('id', workspaceId)
  .single();
```

### Update a Workspace

```typescript
// Update workspace name
const { data, error } = await supabase
  .from('workspaces')
  .update({ name: 'Updated Workspace Name' })
  .eq('id', workspaceId)  // ✅ Use .eq() (not .match())
  .select()
  .single();

if (error) {
  console.error('Error updating workspace:', error);
} else {
  console.log('Workspace updated:', data);
}
```

**Note**: The PRD example uses `.match()` which is deprecated. Use `.eq()` instead.

### Delete a Workspace

```typescript
// Delete workspace (cascades to projects, sheets, etc.)
const { error } = await supabase
  .from('workspaces')
  .delete()
  .eq('id', workspaceId);  // ✅ Use .eq() (not .match())

if (error) {
  console.error('Error deleting workspace:', error);
} else {
  console.log('Workspace deleted');
}
```

---

## 3. Projects CRUD

### Create a Project

```typescript
const supabase = getSupabaseClient();
const { data: { user } } = await supabase.auth.getUser();

// Create project
const { data: project, error } = await supabase
  .from('projects')
  .insert({
    name: 'My First Project',
    workspace_id: workspaceId,
    owner_id: user.id
  })
  .select()
  .single();

if (error) throw error;

// Add owner as project member
await supabase
  .from('project_members')
  .insert({
    project_id: project.id,
    user_id: user.id,
    role: 'Owner'
  });
```

### Read Projects

```typescript
// Get all projects in workspace
const { data: projects, error } = await supabase
  .from('projects')
  .select('*')
  .eq('workspace_id', workspaceId)
  .order('created_at', { ascending: false });

// Get project with sheets and rows
const { data: project, error } = await supabase
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

### Update a Project

```typescript
// Update project name
const { data, error } = await supabase
  .from('projects')
  .update({ name: 'Updated Project Name' })
  .eq('id', projectId)
  .select()
  .single();

// Update active sheet
const { data, error } = await supabase
  .from('projects')
  .update({ active_sheet_id: sheetId })
  .eq('id', projectId);
```

### Delete a Project

```typescript
// Delete project (cascades to sheets, rows, etc.)
const { error } = await supabase
  .from('projects')
  .delete()
  .eq('id', projectId);
```

---

## 4. Sheets CRUD

### Create a Sheet

```typescript
// Create sheet
const { data: sheet, error } = await supabase
  .from('sheets')
  .insert({
    project_id: projectId,
    name: 'Main Sheet'
  })
  .select()
  .single();

if (error) throw error;

// Optionally set as active sheet
await supabase
  .from('projects')
  .update({ active_sheet_id: sheet.id })
  .eq('id', projectId);
```

### Read Sheets

```typescript
// Get all sheets in project
const { data: sheets, error } = await supabase
  .from('sheets')
  .select('*')
  .eq('project_id', projectId)
  .order('created_at', { ascending: true });

// Get sheet with columns and rows
const { data: sheet, error } = await supabase
  .from('sheets')
  .select(`
    *,
    columns (*),
    rows (*)
  `)
  .eq('id', sheetId)
  .single();
```

### Update a Sheet

```typescript
// Update sheet name
const { data, error } = await supabase
  .from('sheets')
  .update({ name: 'Updated Sheet Name' })
  .eq('id', sheetId)
  .select()
  .single();
```

### Delete a Sheet

```typescript
// Delete sheet (cascades to columns and rows)
const { error } = await supabase
  .from('sheets')
  .delete()
  .eq('id', sheetId);
```

---

## 5. Columns CRUD

### Create a Column

```typescript
// Create text column
const { data: column, error } = await supabase
  .from('columns')
  .insert({
    sheet_id: sheetId,
    title: 'Task Name',
    type: 'text',
    width: 300,
    display_order: 0
  })
  .select()
  .single();

// Create dropdown column
const { data: statusColumn, error } = await supabase
  .from('columns')
  .insert({
    sheet_id: sheetId,
    title: 'Status',
    type: 'dropdown',
    width: 150,
    options: ['To Do', 'In Progress', 'Done'],
    display_order: 1
  })
  .select()
  .single();
```

### Read Columns

```typescript
// Get all columns in sheet
const { data: columns, error } = await supabase
  .from('columns')
  .select('*')
  .eq('sheet_id', sheetId)
  .order('display_order', { ascending: true });
```

### Update a Column

```typescript
// Update column title
const { data, error } = await supabase
  .from('columns')
  .update({ title: 'Updated Column Name' })
  .eq('id', columnId)
  .select()
  .single();

// Update column width
const { data, error } = await supabase
  .from('columns')
  .update({ width: 250 })
  .eq('id', columnId);

// Reorder columns
const { data, error } = await supabase
  .from('columns')
  .update({ display_order: 0 })
  .eq('id', columnId);
```

### Delete a Column

```typescript
// Delete column
const { error } = await supabase
  .from('columns')
  .delete()
  .eq('id', columnId);
```

---

## 6. Rows CRUD

### Create a Row

```typescript
// Create row with task data
const { data: row, error } = await supabase
  .from('rows')
  .insert({
    sheet_id: sheetId,
    row_data: {
      task: 'Complete documentation',
      status: 'In Progress',
      owner: 'John Doe',
      dueDate: '2024-12-31',
      priority: 'High',
      progress: 50
    },
    dependencies: []  // No dependencies initially
  })
  .select()
  .single();

if (error) throw error;
console.log('Row created:', row);
```

### Read Rows

```typescript
// Get all rows in sheet
const { data: rows, error } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .order('created_at', { ascending: true });

// Get rows with specific status (JSONB query)
const { data: inProgressRows, error } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>status', 'eq', 'In Progress');

// Get rows by owner
const { data: myTasks, error } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>owner', 'eq', 'John Doe');
```

### Update a Row

```typescript
// Update specific fields in row_data
const { data: existingRow } = await supabase
  .from('rows')
  .select('row_data')
  .eq('id', rowId)
  .single();

const { data, error } = await supabase
  .from('rows')
  .update({
    row_data: {
      ...existingRow.row_data,
      status: 'Done',
      progress: 100
    }
  })
  .eq('id', rowId)
  .select()
  .single();

// Update dependencies
const { data, error } = await supabase
  .from('rows')
  .update({
    dependencies: ['row-2', 'row-3']
  })
  .eq('id', rowId);
```

### Delete a Row

```typescript
// Delete row (cascades to comments and attachments)
const { error } = await supabase
  .from('rows')
  .delete()
  .eq('id', rowId);
```

---

## 7. Complete Examples

### Create Project with Sheet and Columns

```typescript
async function createProjectWithSheet(
  workspaceId: string,
  projectName: string,
  sheetName: string
) {
  const supabase = getSupabaseClient();
  const { data: { user } } = await supabase.auth.getUser();

  // 1. Create project
  const { data: project, error: projectError } = await supabase
    .from('projects')
    .insert({
      name: projectName,
      workspace_id: workspaceId,
      owner_id: user.id
    })
    .select()
    .single();

  if (projectError) throw projectError;

  // 2. Add owner as member
  await supabase
    .from('project_members')
    .insert({
      project_id: project.id,
      user_id: user.id,
      role: 'Owner'
    });

  // 3. Create sheet
  const { data: sheet, error: sheetError } = await supabase
    .from('sheets')
    .insert({
      project_id: project.id,
      name: sheetName
    })
    .select()
    .single();

  if (sheetError) throw sheetError;

  // 4. Create columns
  const columns = [
    { title: 'Task', type: 'text', width: 300, display_order: 0 },
    { title: 'Status', type: 'dropdown', width: 150, options: ['To Do', 'In Progress', 'Done'], display_order: 1 },
    { title: 'Owner', type: 'text', width: 150, display_order: 2 },
    { title: 'Due Date', type: 'date', width: 150, display_order: 3 }
  ];

  const { data: createdColumns, error: columnsError } = await supabase
    .from('columns')
    .insert(
      columns.map(col => ({
        sheet_id: sheet.id,
        ...col
      }))
    )
    .select();

  if (columnsError) throw columnsError;

  // 5. Set as active sheet
  await supabase
    .from('projects')
    .update({ active_sheet_id: sheet.id })
    .eq('id', project.id);

  return { project, sheet, columns: createdColumns };
}
```

### Create Task (Row)

```typescript
async function createTask(
  sheetId: string,
  taskData: {
    task: string;
    status: string;
    owner: string;
    dueDate: string;
    priority?: string;
    progress?: number;
  }
) {
  const supabase = getSupabaseClient();

  const { data: row, error } = await supabase
    .from('rows')
    .insert({
      sheet_id: sheetId,
      row_data: {
        task: taskData.task,
        status: taskData.status,
        owner: taskData.owner,
        dueDate: taskData.dueDate,
        priority: taskData.priority || 'Medium',
        progress: taskData.progress || 0
      },
      dependencies: []
    })
    .select()
    .single();

  if (error) throw error;

  // Log activity
  const { data: { user } } = await supabase.auth.getUser();
  await supabase.rpc('log_activity', {
    p_project_id: projectId,
    p_user_id: user.id,
    p_user_name: user.user_metadata.name || user.email,
    p_action: 'Created task',
    p_row_id: row.id,
    p_details: `Created task: ${taskData.task}`
  });

  return row;
}
```

---

## 8. Best Practices

### 1. Always Use `.select()` After Insert/Update

```typescript
// ✅ Good: Returns created/updated data
const { data } = await supabase
  .from('workspaces')
  .insert({ name: 'Workspace' })
  .select()
  .single();

// ❌ Avoid: No data returned
await supabase
  .from('workspaces')
  .insert({ name: 'Workspace' });
```

### 2. Use `.single()` for One Result

```typescript
// ✅ Good: Returns single object
const { data } = await supabase
  .from('workspaces')
  .select('*')
  .eq('id', workspaceId)
  .single();

// ❌ Avoid: Returns array
const { data } = await supabase
  .from('workspaces')
  .select('*')
  .eq('id', workspaceId);
// data is an array, need data[0]
```

### 3. Always Handle Errors

```typescript
// ✅ Good: Error handling
const { data, error } = await supabase
  .from('workspaces')
  .select('*');

if (error) {
  console.error('Error:', error);
  // Handle error appropriately
  return;
}

// Use data
console.log('Workspaces:', data);
```

### 4. Use Relationships for Joins

```typescript
// ✅ Good: Use Supabase relationships
const { data } = await supabase
  .from('projects')
  .select(`
    *,
    sheets (*),
    workspace_members (*)
  `);

// ❌ Avoid: Multiple queries
// (Fetch projects, then sheets, then members separately)
```

### 5. Use Indexed Operators for JSONB

```typescript
// ✅ Good: Use indexed operators
.filter('row_data->>status', 'eq', 'Done')
.contains('row_data', { status: 'Done' })

// ❌ Avoid: Full table scans
// (Don't fetch all rows and filter in JavaScript)
```

### 6. Batch Operations When Possible

```typescript
// ✅ Good: Batch insert
const { data } = await supabase
  .from('rows')
  .insert([
    { sheet_id: sheetId, row_data: { task: 'Task 1' } },
    { sheet_id: sheetId, row_data: { task: 'Task 2' } },
    { sheet_id: sheetId, row_data: { task: 'Task 3' } }
  ])
  .select();

// ❌ Avoid: Multiple individual inserts
// (Slower, more API calls)
```

---

## 9. Common Patterns

### Get Current User ID

```typescript
// ✅ Correct way (not deprecated)
const { data: { user } } = await supabase.auth.getUser();
const userId = user?.id;

// ❌ Deprecated (don't use)
const userId = supabase.auth.user()?.id;
```

### Filter by Current User

```typescript
// RLS automatically filters, but you can also filter explicitly
const { data: { user } } = await supabase.auth.getUser();

const { data: myProjects } = await supabase
  .from('projects')
  .select('*')
  .eq('owner_id', user.id);
```

### Update with Merge

```typescript
// Merge new data with existing JSONB
const { data: existing } = await supabase
  .from('rows')
  .select('row_data')
  .eq('id', rowId)
  .single();

await supabase
  .from('rows')
  .update({
    row_data: {
      ...existing.row_data,  // Keep existing data
      ...newData              // Merge new data
    }
  })
  .eq('id', rowId);
```

### Conditional Updates

```typescript
// Only update if condition is met
const { data, error } = await supabase
  .from('workspaces')
  .update({ name: 'New Name' })
  .eq('id', workspaceId)
  .eq('owner_id', userId);  // Only if user is owner
```

---

## 10. Error Handling

### Common Errors

```typescript
const { data, error } = await supabase
  .from('workspaces')
  .select('*');

if (error) {
  switch (error.code) {
    case 'PGRST116':
      // Not found
      console.log('Workspace not found');
      break;
    case '42501':
      // Permission denied (RLS)
      console.error('Permission denied');
      break;
    case '23505':
      // Unique constraint violation
      console.error('Duplicate entry');
      break;
    case '23503':
      // Foreign key violation
      console.error('Invalid reference');
      break;
    default:
      console.error('Error:', error.message);
  }
}
```

### Retry Logic

```typescript
async function createWithRetry(data: any, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    const { data: result, error } = await supabase
      .from('workspaces')
      .insert(data)
      .select()
      .single();

    if (!error) return result;
    
    if (i === maxRetries - 1) throw error;
    await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
  }
}
```

---

## 11. Summary

### Key Points

1. ✅ **RLS Automatic** - Security enforced automatically
2. ✅ **Use `.eq()`** - Not deprecated `.match()`
3. ✅ **Use `getUser()`** - Not deprecated `user()`
4. ✅ **Always handle errors** - Check error before using data
5. ✅ **Use `.select()`** - Get data back from insert/update
6. ✅ **Use relationships** - Join tables efficiently

### Quick Reference

```typescript
// Create
await supabase.from('table').insert({...}).select();

// Read
await supabase.from('table').select('*').eq('id', id);

// Update
await supabase.from('table').update({...}).eq('id', id);

// Delete
await supabase.from('table').delete().eq('id', id);
```

---

**CRUD operations are simple with Supabase - RLS handles security automatically!** 🚀
