# Tasks Data Model

This document explains how task data is stored in ProjectFlow and why we don't need a separate `tasks` table.

## Table of Contents

1. [Overview](#1-overview)
2. [PRD Approach](#2-prd-approach)
3. [Our Implementation](#3-our-implementation)
4. [Task Fields in JSONB](#4-task-fields-in-jsonb)
5. [When to Add a Tasks Table](#5-when-to-add-a-tasks-table)
6. [Examples](#6-examples)

---

## 1. Overview

### PRD Specification

The PRD suggests two approaches:

1. **Option 1**: Store task fields in `cells` table (as cell values)
2. **Option 2**: Create dedicated `tasks` table linked to `rows`

**PRD Recommendation**: For initial implementation, use Option 1 (cells table) where specific columns define task attributes.

### Our Implementation

**We use a third approach that's better than both:**

- ✅ **No `cells` table** - We use JSONB in `rows` table instead
- ✅ **No separate `tasks` table** - Task data stored in `row_data` JSONB
- ✅ **Task fields as column values** - Stored in JSONB, just like PRD intent
- ✅ **Flexible and performant** - Best of both worlds

---

## 2. PRD Approach

### PRD Option 1: Cells Table

```sql
-- Task fields stored as cells
cells table:
  row_id: 'row-1'
  column_id: 'col-task-name'
  value: 'Complete documentation'

  row_id: 'row-1'
  column_id: 'col-owner'
  value: 'John Doe'

  row_id: 'row-1'
  column_id: 'col-status'
  value: 'In Progress'
```

**Characteristics:**
- Task fields are cell values
- Columns define task attributes
- Requires JOINs to get full task data

### PRD Option 2: Tasks Table

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY,
  row_id UUID REFERENCES rows(id),
  owner_id UUID REFERENCES users(id),
  status TEXT,
  due_date DATE,
  priority TEXT,
  ...
);
```

**Characteristics:**
- Dedicated table for task-specific fields
- More complex task logic possible
- Requires JOIN with rows table

---

## 3. Our Implementation

### We Use JSONB (Better Than Both Options)

```sql
-- Task data stored in row_data JSONB
rows table:
  id: 'row-1'
  sheet_id: 'sheet-1'
  row_data: {
    "task": "Complete documentation",  -- From 'Task Name' column
    "owner": "John Doe",                -- From 'Owner' column
    "status": "In Progress",            -- From 'Status' column
    "dueDate": "2024-12-31",            -- From 'Due Date' column
    "priority": "High"                  -- From 'Priority' column
  }
```

**Why This is Better:**

1. ✅ **No JOINs needed** - All task data in one row
2. ✅ **Flexible schema** - Add task fields without migrations
3. ✅ **Fast queries** - Direct JSONB access
4. ✅ **Aligns with PRD intent** - Tasks as rows with fields
5. ✅ **No separate table** - Simpler architecture

---

## 4. Task Fields in JSONB

### Standard Task Fields

Task-specific fields are stored in `row_data` JSONB, mapped from columns:

| Column Name | Column Type | JSONB Key | Example Value |
|------------|-------------|-----------|---------------|
| Task Name | text | `task` | "Complete documentation" |
| Owner | dropdown | `owner` | "John Doe" |
| Status | dropdown | `status` | "In Progress" |
| Due Date | date | `dueDate` | "2024-12-31" |
| Priority | dropdown | `priority` | "High" |
| Progress | number | `progress` | 50 |
| Start Date | date | `startDate` | "2024-01-01" |

### Example Row Data

```json
{
  "task": "Complete documentation",
  "owner": "John Doe",
  "status": "In Progress",
  "dueDate": "2024-12-31",
  "startDate": "2024-01-01",
  "priority": "High",
  "progress": 50,
  "estimatedHours": 8.5,
  "tags": ["documentation", "urgent"]
}
```

### Column-to-JSONB Mapping

The mapping between columns and JSONB keys is defined by the column `id`:

```typescript
// Column definition
{
  id: 'col-task-name',
  title: 'Task Name',
  type: 'text'
}

// Stored in row_data as:
{
  "col-task-name": "Complete documentation"
  // OR mapped to:
  "task": "Complete documentation"  // If using column title as key
}
```

**Best Practice**: Use column `id` as JSONB key for consistency.

---

## 5. When to Add a Tasks Table

### Current Approach is Sufficient When:

- ✅ Tasks are primarily rows with fields
- ✅ Task data fits in JSONB structure
- ✅ No complex task-specific logic needed
- ✅ Task relationships handled via `dependencies` array
- ✅ Task automation works with row data

### Consider Adding Tasks Table When:

- ❌ Need task-specific triggers/automations
- ❌ Need complex task relationships beyond dependencies
- ❌ Need task-level permissions separate from rows
- ❌ Need task history/versioning
- ❌ Need task-specific indexes/constraints

**For ProjectFlow initial implementation, JSONB is sufficient.**

---

## 6. Examples

### Creating a Task

```typescript
import { createRow } from './services/projectService';

// Create task (stored as row with task fields in JSONB)
const task = await createRow(sheetId, {
  id: 'task-1',
  // Task fields stored in row_data
  task: 'Complete documentation',
  owner: 'John Doe',
  status: 'In Progress',
  dueDate: '2024-12-31',
  priority: 'High',
  progress: 50
});
```

### Querying Tasks

```typescript
// Get all tasks with specific status
const { data: tasks } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>status', 'eq', 'In Progress');

// Get tasks by owner
const { data: myTasks } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>owner', 'eq', 'John Doe');

// Get overdue tasks
const today = new Date().toISOString().split('T')[0];
const { data: overdue } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>dueDate', 'lt', today);
```

### Updating Task Status

```typescript
// Update task status
await supabase
  .from('rows')
  .update({
    row_data: {
      ...existingRowData,
      status: 'Done',
      progress: 100
    }
  })
  .eq('id', taskId);
```

### Task Dependencies

```typescript
// Set task dependencies
await supabase
  .from('rows')
  .update({
    dependencies: ['task-2', 'task-3']  // This task depends on task-2 and task-3
  })
  .eq('id', 'task-1');

// Get tasks that depend on this task
const { data: dependentTasks } = await supabase
  .from('rows')
  .select('*')
  .contains('dependencies', [taskId]);
```

---

## 7. Task-Specific Features

### Task Status Workflow

```typescript
// Status values stored in row_data
const statuses = ['To Do', 'In Progress', 'Blocked', 'Done'];

// Update status
await updateRow(taskId, {
  status: 'In Progress',
  // Can trigger automations based on status change
});
```

### Task Assignments

```typescript
// Owner stored in row_data
await updateRow(taskId, {
  owner: 'Jane Doe'
});

// Get tasks assigned to user
const { data: assignedTasks } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>owner', 'eq', userId);
```

### Task Priorities

```typescript
// Priority stored in row_data
const priorities = ['Low', 'Medium', 'High', 'Critical'];

await updateRow(taskId, {
  priority: 'High'
});

// Get high priority tasks
const { data: highPriority } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .filter('row_data->>priority', 'eq', 'High');
```

### Task Dates

```typescript
// Dates stored in row_data
await updateRow(taskId, {
  startDate: '2024-01-01',
  dueDate: '2024-12-31'
});

// Get tasks due this week
const startOfWeek = getStartOfWeek();
const endOfWeek = getEndOfWeek();

const { data: dueThisWeek } = await supabase
  .from('rows')
  .select('*')
  .eq('sheet_id', sheetId)
  .gte('row_data->>dueDate', startOfWeek)
  .lte('row_data->>dueDate', endOfWeek);
```

---

## 8. Future: Adding Tasks Table (If Needed)

If you need a dedicated `tasks` table later:

### Schema

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  row_id UUID NOT NULL REFERENCES rows(id) ON DELETE CASCADE,
  owner_id UUID REFERENCES profiles(id),
  status TEXT NOT NULL,
  due_date DATE,
  priority TEXT,
  estimated_hours NUMERIC(5, 2),
  actual_hours NUMERIC(5, 2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(row_id)  -- One task per row
);
```

### Migration

```sql
-- Extract task data from row_data JSONB
INSERT INTO tasks (row_id, owner_id, status, due_date, priority)
SELECT 
  id as row_id,
  (row_data->>'owner_id')::uuid as owner_id,
  row_data->>'status' as status,
  (row_data->>'dueDate')::date as due_date,
  row_data->>'priority' as priority
FROM rows
WHERE row_data ? 'status';  -- Only rows with task data
```

### Hybrid Approach

You could also use both:
- `row_data` JSONB for flexible fields
- `tasks` table for structured task-specific data
- Keep them in sync via triggers

---

## 9. Best Practices

1. **Use consistent field names**
   - Map column titles to JSONB keys consistently
   - Use column `id` as key for reliability

2. **Validate task fields**
   - Check required fields exist
   - Validate status values
   - Validate date formats

3. **Handle missing fields**
   - Use defaults for optional fields
   - Handle null/undefined gracefully

4. **Index frequently queried fields**
   - Use GIN index on `row_data` (already done)
   - Query with indexed operators (`@>`, `->>`)

5. **Keep row_data and columns in sync**
   - When adding column, update existing rows
   - When removing column, clean up row_data

---

## 10. Summary

### Our Approach

- ✅ **No `cells` table** - We use JSONB instead
- ✅ **No `tasks` table** - Task data in `row_data` JSONB
- ✅ **Tasks as rows** - Aligns with PRD intent
- ✅ **Flexible and fast** - Best performance

### Task Fields Storage

```
rows.row_data JSONB:
{
  "task": "...",      // From 'Task Name' column
  "owner": "...",     // From 'Owner' column
  "status": "...",    // From 'Status' column
  "dueDate": "...",   // From 'Due Date' column
  "priority": "..."    // From 'Priority' column
}
```

### When to Add Tasks Table

Only if you need:
- Complex task-specific logic
- Task-level permissions
- Task history/versioning
- Task-specific indexes

**For now, JSONB is perfect!** 🚀

---

**Task data is efficiently stored in `row_data` JSONB, providing flexibility and performance without needing a separate table!**
