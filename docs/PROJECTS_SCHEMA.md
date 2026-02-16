# Projects Table Schema

Complete documentation for the `projects` table and related structures.

## Table Definition

### Projects Table

```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  active_sheet_id UUID,  -- References sheets(id), set after sheets are created
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Points:**
- `workspace_id` - Project belongs to a workspace
- `owner_id` - Project has its own owner (may differ from workspace owner)
- `active_sheet_id` - Tracks which sheet user was last viewing
- `NOT NULL` constraints ensure data integrity
- `ON DELETE CASCADE` - Deleting workspace deletes all projects

### Project Members Table

```sql
CREATE TABLE project_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'Viewer',  -- Owner, Editor, Viewer, or custom
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, user_id)
);
```

**Purpose:**
- Many-to-many relationship between users and projects
- Project-level membership (separate from workspace membership)
- Supports project-specific roles

---

## Row Level Security (RLS) Policies

### Projects Policies

#### 1. View Projects
```sql
CREATE POLICY "Users can view projects"
ON projects FOR SELECT
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);
```

**What it does:**
- Users can view projects in workspaces they're members of
- Includes all workspace members (not just owners)
- Supports collaboration and transparency

**Why:**
- Members need to see projects to collaborate
- Aligns with real-world usage patterns

#### 2. Create Projects
```sql
CREATE POLICY "Editors can create projects"
ON projects FOR INSERT
WITH CHECK (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
  ) AND auth.uid() = owner_id
);
```

**What it does:**
- Users with Editor or Owner role can create projects
- Creator must set themselves as project owner
- Prevents creating projects for other users

**Why:**
- Allows delegation - Editors can create projects
- Maintains ownership tracking

#### 3. Update Projects
```sql
CREATE POLICY "Editors can update projects"
ON projects FOR UPDATE
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
  )
);
```

**What it does:**
- Editors and Owners can update projects
- Supports collaborative editing
- More flexible than PRD (which only allows workspace owners)

#### 4. Delete Projects
```sql
CREATE POLICY "Owners can delete projects"
ON projects FOR DELETE
USING (owner_id = auth.uid());
```

**What it does:**
- Only project owners can delete
- Workspace owners cannot delete projects they don't own
- Prevents accidental deletion

**Why:**
- Respects project ownership
- Prevents workspace owners from deleting user projects

### Project Members Policies

#### 1. View Members
```sql
CREATE POLICY "Users can view project members"
ON project_members FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);
```

**What it does:**
- Members can see who else is in the project
- Supports collaboration

#### 2. Manage Members
```sql
CREATE POLICY "Owners can manage project members"
ON project_members FOR ALL
USING (
  project_id IN (
    SELECT id FROM projects WHERE owner_id = auth.uid()
  )
);
```

**What it does:**
- Project owners can add/update/remove members
- Supports project-level team management

---

## Comparison: PRD vs Implementation

### PRD Version

```sql
-- Only workspace owners can view
CREATE POLICY "Users can view projects in their workspaces." 
ON projects FOR SELECT 
USING (EXISTS (
  SELECT 1 FROM workspaces 
  WHERE id = workspace_id AND owner_id = auth.uid()
));
```

**Limitations:**
- ❌ Only workspace owners can view projects
- ❌ Only workspace owners can create/update/delete
- ❌ No project-level ownership
- ❌ No project members table
- ❌ No role-based access

### Our Implementation

```sql
-- All workspace members can view
CREATE POLICY "Users can view projects"
ON projects FOR SELECT
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);
```

**Advantages:**
- ✅ All workspace members can view
- ✅ Editors and Owners can create/update
- ✅ Project-level ownership (`owner_id`)
- ✅ Project members table for team management
- ✅ Role-based access control

---

## Usage Examples

### Create Project

```typescript
import { createProject } from './services/projectService';

const project = await createProject(
  workspaceId,
  'My New Project',
  userId  // Project owner
);
```

### Get Projects for Workspace

```typescript
const supabase = getSupabaseClient();

const { data: projects } = await supabase
  .from('projects')
  .select(`
    *,
    sheets (
      *,
      columns (*),
      rows (*)
    )
  `)
  .eq('workspace_id', workspaceId)
  .order('created_at', { ascending: false });
```

### Update Project

```typescript
import { updateProject } from './services/projectService';

await updateProject(projectId, {
  name: 'Updated Project Name',
  activeSheetId: sheetId
});
```

### Add Project Member

```typescript
const supabase = getSupabaseClient();

await supabase
  .from('project_members')
  .insert({
    project_id: projectId,
    user_id: userId,
    role: 'Editor'
  });
```

### Check Project Access

```typescript
// Check if user can view project
const { data: project } = await supabase
  .from('projects')
  .select('*')
  .eq('id', projectId)
  .single();

if (project) {
  // User has access (RLS ensures this)
  console.log('Project:', project.name);
}
```

---

## Project Ownership Model

### Two-Level Ownership

1. **Workspace Level**
   - Workspace has an owner (`workspaces.owner_id`)
   - Workspace owner has full control over workspace

2. **Project Level**
   - Project has its own owner (`projects.owner_id`)
   - Project owner has control over their project
   - Project owner may differ from workspace owner

### Benefits

- ✅ **Delegation**: Workspace owner can delegate project creation
- ✅ **Autonomy**: Project owners manage their own projects
- ✅ **Flexibility**: Multiple project owners in one workspace
- ✅ **Protection**: Project owners control deletion of their projects

---

## Relationship with Sheets

Projects contain sheets:

```
workspaces
  └── projects
      └── sheets
          ├── columns
          └── rows
```

**Active Sheet:**
- `active_sheet_id` tracks which sheet user was viewing
- Used for UX - remember last viewed sheet
- Can be null if no sheets exist yet

**Example:**
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

1. **Always set owner_id**
   - When creating project, set creator as owner
   - Maintains ownership tracking

2. **Use project_members for access**
   - Check project membership via `project_members` table
   - Don't just rely on workspace membership

3. **Handle active_sheet_id carefully**
   - Set when user opens a sheet
   - Clear or update when sheets are deleted
   - Can be null initially

4. **Respect ownership hierarchy**
   - Workspace owner > Project owner > Project members
   - Each level has appropriate permissions

5. **Cascade deletions**
   - Deleting workspace deletes all projects (CASCADE)
   - Deleting project deletes all sheets (CASCADE)
   - Maintains data integrity

---

## Migration Notes

If migrating from PRD schema:

1. **Add missing fields:**
   ```sql
   ALTER TABLE projects 
     ADD COLUMN owner_id UUID REFERENCES profiles(id),
     ADD COLUMN active_sheet_id UUID REFERENCES sheets(id);
   
   -- Set existing projects' owner to workspace owner
   UPDATE projects p
   SET owner_id = w.owner_id
   FROM workspaces w
   WHERE p.workspace_id = w.id;
   
   -- Make owner_id NOT NULL after setting values
   ALTER TABLE projects 
     ALTER COLUMN owner_id SET NOT NULL;
   ```

2. **Create project_members table:**
   ```sql
   CREATE TABLE project_members (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
     user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
     role TEXT NOT NULL DEFAULT 'Viewer',
     created_at TIMESTAMPTZ DEFAULT NOW(),
     UNIQUE(project_id, user_id)
   );
   ```

3. **Update RLS policies:**
   - Replace owner-only policies with member-based policies
   - See `001_initial_schema.sql` for complete policies

4. **Add project members:**
   ```sql
   -- Add project owners as members
   INSERT INTO project_members (project_id, user_id, role)
   SELECT id, owner_id, 'Owner'
   FROM projects
   ON CONFLICT DO NOTHING;
   ```

---

## Additional Fields (Optional)

If you need the `description` field from PRD:

```sql
ALTER TABLE projects 
  ADD COLUMN description TEXT;
```

This can be added without breaking existing functionality.

---

**The projects schema supports full collaboration with role-based access control!** 🚀
