# Workspaces Table Schema

Complete documentation for the `workspaces` table and related structures.

## Table Definition

### Workspaces Table

```sql
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Points:**
- `owner_id` references `profiles(id)`, NOT `users(id)`
- `NOT NULL` constraint on `owner_id` ensures every workspace has an owner
- `ON DELETE CASCADE` means if owner profile is deleted, workspace is deleted
- Auto-updates `updated_at` via trigger

### Workspace Members Table

```sql
CREATE TABLE workspace_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'Viewer',  -- Owner, Editor, Viewer, or custom
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, user_id)
);
```

**Purpose:**
- Many-to-many relationship between users and workspaces
- Tracks all members, not just owners
- Supports role-based access control

---

## Row Level Security (RLS) Policies

### Workspaces Policies

#### 1. View Workspaces
```sql
CREATE POLICY "Users can view their workspaces"
ON workspaces FOR SELECT
USING (
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);
```

**What it does:**
- Users can view workspaces they're members of
- Includes owners and all other members
- More permissive than PRD (which only allows owners)

**Why:**
- Supports collaboration - members need to see workspace
- Aligns with real-world usage patterns

#### 2. Create Workspaces
```sql
CREATE POLICY "Users can create workspaces"
ON workspaces FOR INSERT
WITH CHECK (auth.uid() = owner_id);
```

**What it does:**
- Users can create workspaces
- Must set themselves as owner
- Prevents creating workspaces for other users

#### 3. Update Workspaces
```sql
CREATE POLICY "Owners can update workspaces"
ON workspaces FOR UPDATE
USING (
  owner_id = auth.uid() OR
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role = 'Owner'
  )
);
```

**What it does:**
- Owners can update their workspaces
- Members with "Owner" role can also update
- Supports custom roles with Owner base role

#### 4. Delete Workspaces
```sql
CREATE POLICY "Owners can delete workspaces"
ON workspaces FOR DELETE
USING (owner_id = auth.uid());
```

**What it does:**
- Only the actual owner can delete
- Even members with "Owner" role cannot delete
- Prevents accidental deletion

### Workspace Members Policies

#### 1. View Members
```sql
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);
```

**What it does:**
- Members can see who else is in the workspace
- Supports collaboration and transparency

#### 2. Add Members
```sql
CREATE POLICY "Owners can add workspace members"
ON workspace_members FOR INSERT
WITH CHECK (
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);
```

**What it does:**
- Only workspace owners can add members
- Prevents unauthorized member additions

#### 3. Update Members
```sql
CREATE POLICY "Owners can update workspace members"
ON workspace_members FOR UPDATE
USING (
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);
```

**What it does:**
- Owners can change member roles
- Supports role management

#### 4. Remove Members
```sql
CREATE POLICY "Owners can remove workspace members"
ON workspace_members FOR DELETE
USING (
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);
```

**What it does:**
- Owners can remove members
- Members can remove themselves (via separate policy if needed)

---

## Comparison: PRD vs Implementation

### PRD Version

```sql
-- Only owners can view
CREATE POLICY "Workspace owners can view their workspaces." 
ON workspaces FOR SELECT USING (owner_id = auth.uid());
```

**Limitations:**
- ❌ Only owners can see workspaces
- ❌ No member support
- ❌ No role system
- ❌ References `users(id)` (custom table)

### Our Implementation

```sql
-- All members can view
CREATE POLICY "Users can view their workspaces"
ON workspaces FOR SELECT
USING (
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);
```

**Advantages:**
- ✅ All members can view
- ✅ Supports collaboration
- ✅ Includes `workspace_members` table
- ✅ References `profiles(id)` (Supabase Auth)

---

## Usage Examples

### Create Workspace

```typescript
import { createWorkspace } from './services/workspaceService';

const workspace = await createWorkspace('My Workspace', userId);
// Automatically adds creator as owner in workspace_members
```

### Add Member to Workspace

```typescript
import { addWorkspaceMember } from './services/workspaceService';

await addWorkspaceMember(workspaceId, userId, 'Editor');
```

### Get User's Workspaces

```typescript
const supabase = getSupabaseClient();

const { data: workspaces } = await supabase
  .from('workspaces')
  .select(`
    *,
    workspace_members (
      user_id,
      role,
      profiles (name, email)
    )
  `)
  .order('created_at', { ascending: false });
```

### Check if User is Member

```typescript
const { data: membership } = await supabase
  .from('workspace_members')
  .select('role')
  .eq('workspace_id', workspaceId)
  .eq('user_id', userId)
  .single();

if (membership) {
  console.log('User is member with role:', membership.role);
}
```

---

## Role System

### Default Roles

1. **Owner** - Full control
   - Can add/remove members
   - Can update workspace
   - Can delete workspace
   - Can manage roles

2. **Editor** - Can edit content
   - Can create/edit projects
   - Can manage sheets and rows
   - Cannot manage members

3. **Viewer** - Read-only
   - Can view workspace and projects
   - Cannot make changes

### Custom Roles

Defined in `role_definitions` table:
- Custom role names
- Base role (Owner, Editor, Viewer)
- Custom permissions via base role inheritance

---

## Best Practices

1. **Always create workspace_members entry**
   - When creating workspace, add owner to `workspace_members`
   - Don't rely on `owner_id` alone for access control

2. **Use workspace_members for access checks**
   - Check membership via `workspace_members` table
   - Don't just check `owner_id`

3. **Handle role changes carefully**
   - When changing owner, update both `owner_id` and `workspace_members.role`
   - Maintain data consistency

4. **Cascade deletions**
   - Deleting workspace deletes all members (CASCADE)
   - Deleting user profile removes them from all workspaces

---

## Migration Notes

If migrating from PRD schema:

1. **Update foreign key:**
   ```sql
   ALTER TABLE workspaces 
     DROP CONSTRAINT workspaces_owner_id_fkey,
     ADD CONSTRAINT workspaces_owner_id_fkey 
     FOREIGN KEY (owner_id) REFERENCES profiles(id);
   ```

2. **Create workspace_members entries:**
   ```sql
   INSERT INTO workspace_members (workspace_id, user_id, role)
   SELECT id, owner_id, 'Owner'
   FROM workspaces;
   ```

3. **Update RLS policies:**
   - Replace owner-only policies with member-based policies
   - See `001_initial_schema.sql` for complete policies

---

**The workspaces schema is ready for production use with full collaboration support!** 🚀
