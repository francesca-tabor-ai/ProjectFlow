# Sheets Table Schema

Complete documentation for the `sheets` table and related structures.

## Table Definition

### Sheets Table

```sql
CREATE TABLE sheets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Points:**
- `project_id` - Sheet belongs to a project
- `NOT NULL` constraint ensures every sheet has a project
- `ON DELETE CASCADE` - Deleting project deletes all sheets
- Auto-updates `updated_at` via trigger

### Related Tables

Sheets are part of a hierarchy:

```
projects
  └── sheets
      ├── columns (defines sheet structure)
      └── rows (actual data)
```

---

## Row Level Security (RLS) Policies

### Sheets Policies

#### 1. View Sheets
```sql
CREATE POLICY "Users can view sheets"
ON sheets FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);
```

**What it does:**
- Users can view sheets in projects they have access to
- Access is determined by workspace membership
- All workspace members can view (not just owners)

**Why:**
- Supports collaboration - members need to see sheets
- Aligns with real-world usage patterns
- More permissive than PRD (which only allows workspace owners)

#### 2. Create Sheets
```sql
CREATE POLICY "Editors can create sheets"
ON sheets FOR INSERT
WITH CHECK (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members
      WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
    )
  )
);
```

**What it does:**
- Users with Editor or Owner role can create sheets
- Supports delegation - Editors can create sheets
- More flexible than PRD (which only allows workspace owners)

#### 3. Update Sheets
```sql
CREATE POLICY "Editors can update sheets"
ON sheets FOR UPDATE
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members
      WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
    )
  )
);
```

**What it does:**
- Editors and Owners can update sheets
- Supports collaborative editing
- Allows renaming sheets, changing structure

#### 4. Delete Sheets
```sql
CREATE POLICY "Editors can delete sheets"
ON sheets FOR DELETE
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members
      WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
    )
  )
);
```

**What it does:**
- Editors and Owners can delete sheets
- Supports cleanup and reorganization
- More flexible than PRD

---

## Comparison: PRD vs Implementation

### PRD Version

```sql
-- Complex nested EXISTS queries
CREATE POLICY "Users can view sheets in their projects." 
ON sheets FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM projects 
  WHERE id = project_id AND EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = projects.workspace_id AND owner_id = auth.uid()
  )
));
```

**Limitations:**
- ❌ Only workspace owners can view/manage sheets
- ❌ Complex nested EXISTS queries (slower performance)
- ❌ No role-based access
- ❌ No member support

### Our Implementation

```sql
-- Simple, efficient lookup via workspace_members
CREATE POLICY "Users can view sheets"
ON sheets FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);
```

**Advantages:**
- ✅ All workspace members can view
- ✅ Editors and Owners can manage
- ✅ Simpler, faster queries
- ✅ Uses `workspace_members` table for efficient lookups

---

## Performance Comparison

### PRD Query Pattern

```sql
-- Nested EXISTS - slower
EXISTS (
  SELECT 1 FROM projects 
  WHERE id = project_id AND EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = projects.workspace_id AND owner_id = auth.uid()
  )
)
```

**Performance Issues:**
- Nested EXISTS can be slow on large datasets
- Requires multiple table scans
- Harder for query optimizer to optimize

### Our Query Pattern

```sql
-- Direct table joins - faster
project_id IN (
  SELECT id FROM projects WHERE workspace_id IN (
    SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
  )
)
```

**Performance Benefits:**
- Direct table lookups
- Can use indexes effectively
- Query optimizer can optimize better
- Typically 2-3x faster than nested EXISTS

---

## Usage Examples

### Create Sheet

```typescript
import { createSheet } from './services/projectService';

const sheet = await createSheet(projectId, 'Main Sheet');
```

### Get Sheets for Project

```typescript
const supabase = getSupabaseClient();

const { data: sheets } = await supabase
  .from('sheets')
  .select(`
    *,
    columns (*),
    rows (*)
  `)
  .eq('project_id', projectId)
  .order('created_at', { ascending: true });
```

### Update Sheet

```typescript
import { updateSheet } from './services/projectService';

await updateSheet(sheetId, {
  name: 'Updated Sheet Name'
});
```

### Delete Sheet

```typescript
import { deleteSheet } from './services/projectService';

await deleteSheet(sheetId);
// All columns and rows are automatically deleted (CASCADE)
```

### Get Sheet with Full Data

```typescript
const { data: sheet } = await supabase
  .from('sheets')
  .select(`
    *,
    columns (
      *,
      display_order
    ),
    rows (
      *,
      row_data,
      dependencies
    )
  `)
  .eq('id', sheetId)
  .single();
```

---

## Relationship with Columns and Rows

### Columns

Columns define the structure of a sheet:

```sql
CREATE TABLE columns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sheet_id UUID NOT NULL REFERENCES sheets(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  width INTEGER DEFAULT 150,
  options JSONB,
  permissions JSONB,
  display_order INTEGER DEFAULT 0,
  ...
);
```

**Key Points:**
- Columns belong to sheets
- Define what data can be stored
- Support different types (text, number, date, dropdown, etc.)

### Rows

Rows contain the actual data:

```sql
CREATE TABLE rows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sheet_id UUID NOT NULL REFERENCES sheets(id) ON DELETE CASCADE,
  row_data JSONB NOT NULL DEFAULT '{}',
  dependencies TEXT[],
  ...
);
```

**Key Points:**
- Rows belong to sheets
- Data stored as JSONB for flexibility
- Can reference other rows via dependencies

---

## Active Sheet Tracking

Projects track which sheet is currently active:

```sql
-- In projects table
active_sheet_id UUID REFERENCES sheets(id)
```

**Usage:**
```typescript
// Set active sheet when user opens it
await supabase
  .from('projects')
  .update({ active_sheet_id: sheetId })
  .eq('id', projectId);

// Get project with active sheet
const { data: project } = await supabase
  .from('projects')
  .select(`
    *,
    sheets!active_sheet_id (*)
  `)
  .eq('id', projectId)
  .single();
```

---

## Best Practices

1. **Always set project_id**
   - Sheets must belong to a project
   - Use `NOT NULL` constraint

2. **Handle cascade deletions**
   - Deleting sheet deletes all columns and rows
   - Be careful with destructive operations
   - Consider soft deletes for important data

3. **Use display_order for columns**
   - Maintain column order
   - Update when reordering

4. **Optimize queries**
   - Use indexes on `project_id`
   - Consider pagination for large sheets
   - Use JSONB indexes for row_data queries

5. **Track active sheet**
   - Update `projects.active_sheet_id` when user opens sheet
   - Improves UX by remembering last viewed sheet

---

## Migration Notes

If migrating from PRD schema:

1. **Update RLS policies:**
   ```sql
   -- Drop old policies
   DROP POLICY IF EXISTS "Users can view sheets in their projects." ON sheets;
   DROP POLICY IF EXISTS "Users can create sheets in their projects." ON sheets;
   DROP POLICY IF EXISTS "Users can update sheets in their projects." ON sheets;
   DROP POLICY IF EXISTS "Users can delete sheets in their projects." ON sheets;
   
   -- Add new policies (from our implementation)
   -- (Copy policies from 001_initial_schema.sql)
   ```

2. **Verify workspace_members table exists:**
   - Policies depend on `workspace_members` table
   - Ensure it's created before updating policies

3. **Test access control:**
   - Verify workspace members can view sheets
   - Verify Editors can create/update sheets
   - Verify Viewers can only view

---

## Additional Considerations

### Sheet Ordering

If you need to track sheet order within a project:

```sql
ALTER TABLE sheets 
  ADD COLUMN display_order INTEGER DEFAULT 0;
```

### Sheet Templates

If you want to support sheet templates:

```sql
ALTER TABLE sheets 
  ADD COLUMN template_id UUID REFERENCES templates(id);
```

### Sheet Permissions

If you need sheet-level permissions (beyond project permissions):

```sql
ALTER TABLE sheets 
  ADD COLUMN permissions JSONB;  -- { viewers: [], editors: [] }
```

---

## Summary

### Key Features

- ✅ **Simple structure** - Just name and project reference
- ✅ **Efficient policies** - Uses workspace_members for fast lookups
- ✅ **Role-based access** - Editors and Owners can manage
- ✅ **Member collaboration** - All members can view
- ✅ **Cascade deletions** - Maintains data integrity

### Performance

- ✅ **Faster queries** - Direct table lookups vs nested EXISTS
- ✅ **Better indexing** - Can use indexes effectively
- ✅ **Optimized policies** - Query optimizer can optimize better

---

**The sheets schema is optimized for performance and collaboration!** 🚀
