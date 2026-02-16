# Next Steps Guide

Roadmap for implementing ProjectFlow features after initial backend setup.

## Table of Contents

1. [Overview](#1-overview)
2. [Frontend Implementation](#2-frontend-implementation)
3. [RLS Policy Refinement](#3-rls-policy-refinement)
4. [Supabase Functions](#4-supabase-functions)
5. [Implementation Priority](#5-implementation-priority)

---

## 1. Overview

### Current Status

✅ **Completed:**
- Supabase project setup
- Database schema and migrations
- RLS policies (basic)
- Documentation and guides
- Deployment configuration

🚧 **Next Steps:**
- Frontend components
- Advanced RLS policies
- Supabase Functions
- Feature implementation

---

## 2. Frontend Implementation

### 2.1 Component Structure

Implement frontend components to interact with Supabase API for each feature:

```
src/
├── components/
│   ├── auth/
│   │   ├── LoginForm.tsx
│   │   ├── SignUpForm.tsx
│   │   └── ProtectedRoute.tsx
│   ├── workspaces/
│   │   ├── WorkspaceList.tsx
│   │   ├── WorkspaceCard.tsx
│   │   └── CreateWorkspaceModal.tsx
│   ├── projects/
│   │   ├── ProjectList.tsx
│   │   ├── ProjectCard.tsx
│   │   └── CreateProjectModal.tsx
│   ├── sheets/
│   │   ├── SheetGrid.tsx
│   │   ├── RowComponent.tsx
│   │   └── ColumnHeader.tsx
│   └── shared/
│       ├── LoadingSpinner.tsx
│       ├── ErrorMessage.tsx
│       └── ConfirmDialog.tsx
├── services/
│   ├── supabaseService.ts ✅ (Already created)
│   ├── workspaceService.ts ✅ (Already created)
│   ├── projectService.ts ✅ (Already created)
│   └── authService.ts
├── hooks/
│   ├── useAuth.ts
│   ├── useWorkspaces.ts
│   ├── useProjects.ts
│   ├── useSheets.ts
│   └── useRealtime.ts
└── types/
    ├── workspace.ts
    ├── project.ts
    ├── sheet.ts
    └── row.ts
```

### 2.2 Authentication Components

**Priority: High**

#### LoginForm Component

```typescript
// components/auth/LoginForm.tsx
import { useState } from 'react';
import { getSupabaseClient } from '../../services/supabaseService';
import { useNavigate } from 'react-router-dom';

export function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const supabase = getSupabaseClient();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (error) {
      setError(error.message);
      setLoading(false);
    } else {
      navigate('/workspaces');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      {error && <div className="error">{error}</div>}
      <button type="submit" disabled={loading}>
        {loading ? 'Signing in...' : 'Sign In'}
      </button>
    </form>
  );
}
```

#### ProtectedRoute Component

```typescript
// components/auth/ProtectedRoute.tsx
import { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { getSupabaseClient } from '../../services/supabaseService';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const [loading, setLoading] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);
  const supabase = getSupabaseClient();

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      setAuthenticated(!!user);
      setLoading(false);
    });
  }, []);

  if (loading) return <div>Loading...</div>;
  if (!authenticated) return <Navigate to="/login" />;
  return <>{children}</>;
}
```

### 2.3 Workspace Components

**Priority: High**

#### WorkspaceList Component

```typescript
// components/workspaces/WorkspaceList.tsx
import { useEffect, useState } from 'react';
import { getSupabaseClient } from '../../services/supabaseService';
import { WorkspaceCard } from './WorkspaceCard';

export function WorkspaceList() {
  const [workspaces, setWorkspaces] = useState([]);
  const [loading, setLoading] = useState(true);
  const supabase = getSupabaseClient();

  useEffect(() => {
    loadWorkspaces();
  }, []);

  const loadWorkspaces = async () => {
    const { data, error } = await supabase
      .from('workspaces')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error loading workspaces:', error);
    } else {
      setWorkspaces(data || []);
    }
    setLoading(false);
  };

  if (loading) return <div>Loading workspaces...</div>;

  return (
    <div className="workspace-list">
      {workspaces.map(workspace => (
        <WorkspaceCard key={workspace.id} workspace={workspace} />
      ))}
    </div>
  );
}
```

### 2.4 Sheet Grid Component

**Priority: High**

#### SheetGrid Component

```typescript
// components/sheets/SheetGrid.tsx
import { useEffect, useState } from 'react';
import { getSupabaseClient } from '../../services/supabaseService';
import { useRealtime } from '../../hooks/useRealtime';
import { RowComponent } from './RowComponent';
import { ColumnHeader } from './ColumnHeader';

export function SheetGrid({ sheetId }: { sheetId: string }) {
  const [rows, setRows] = useState([]);
  const [columns, setColumns] = useState([]);
  const supabase = getSupabaseClient();

  // Load initial data
  useEffect(() => {
    loadSheetData();
  }, [sheetId]);

  // Subscribe to real-time updates
  useRealtime({
    table: 'rows',
    filter: `sheet_id=eq.${sheetId}`,
    onInsert: (newRow) => {
      setRows(prev => [...prev, newRow]);
    },
    onUpdate: (updatedRow) => {
      setRows(prev => prev.map(row =>
        row.id === updatedRow.id ? updatedRow : row
      ));
    },
    onDelete: (deletedRow) => {
      setRows(prev => prev.filter(row => row.id !== deletedRow.id));
    }
  });

  const loadSheetData = async () => {
    // Load columns
    const { data: columnsData } = await supabase
      .from('columns')
      .select('*')
      .eq('sheet_id', sheetId)
      .order('display_order');

    // Load rows
    const { data: rowsData } = await supabase
      .from('rows')
      .select('*')
      .eq('sheet_id', sheetId)
      .order('created_at');

    setColumns(columnsData || []);
    setRows(rowsData || []);
  };

  return (
    <div className="sheet-grid">
      <div className="columns">
        {columns.map(column => (
          <ColumnHeader key={column.id} column={column} />
        ))}
      </div>
      <div className="rows">
        {rows.map(row => (
          <RowComponent key={row.id} row={row} columns={columns} />
        ))}
      </div>
    </div>
  );
}
```

### 2.5 Implementation Checklist

- [ ] **Authentication**
  - [ ] Login form
  - [ ] Sign up form
  - [ ] Protected routes
  - [ ] Session management
  - [ ] Sign out

- [ ] **Workspaces**
  - [ ] Workspace list
  - [ ] Create workspace
  - [ ] Edit workspace
  - [ ] Delete workspace
  - [ ] Workspace members

- [ ] **Projects**
  - [ ] Project list
  - [ ] Create project
  - [ ] Edit project
  - [ ] Delete project
  - [ ] Project members

- [ ] **Sheets**
  - [ ] Sheet grid
  - [ ] Create sheet
  - [ ] Edit sheet
  - [ ] Delete sheet
  - [ ] Column management

- [ ] **Rows**
  - [ ] Row display
  - [ ] Create row
  - [ ] Edit row (inline)
  - [ ] Delete row
  - [ ] Row data editing

- [ ] **Real-time**
  - [ ] Live updates
  - [ ] Cursor indicators
  - [ ] Presence system
  - [ ] Simultaneous editing

---

## 3. RLS Policy Refinement

### 3.1 Current RLS Status

**Basic RLS policies are in place**, but they need refinement as more complex sharing and permissions are implemented (PRD_07).

### 3.2 Areas for Refinement

#### 3.2.1 Workspace-Level Permissions

**Current**: Basic owner/member distinction

**Needed**: Granular permissions

```sql
-- Example: More granular workspace permissions
CREATE POLICY "Workspace owners can manage everything"
ON workspaces FOR ALL
USING (
  owner_id = auth.uid() OR
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role = 'Owner'
  )
);

CREATE POLICY "Workspace editors can update"
ON workspaces FOR UPDATE
USING (
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
  )
);

CREATE POLICY "Workspace viewers can only view"
ON workspaces FOR SELECT
USING (
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);
```

#### 3.2.2 Project-Level Permissions

**Current**: Inherits from workspace

**Needed**: Project-specific permissions

```sql
-- Project-level permissions override workspace permissions
CREATE POLICY "Project members can view project"
ON projects FOR SELECT
USING (
  -- Workspace member OR project member
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  ) OR
  id IN (
    SELECT project_id FROM project_members
    WHERE user_id = auth.uid()
  )
);
```

#### 3.2.3 Row-Level Permissions

**Current**: Sheet-level access

**Needed**: Row-specific permissions

```sql
-- Row-level permissions based on row_data
CREATE POLICY "Users can view rows they own or are assigned to"
ON rows FOR SELECT
USING (
  sheet_id IN (
    SELECT id FROM sheets WHERE project_id IN (
      SELECT id FROM projects WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  ) AND (
    -- Owner can view
    row_data->>'owner' = (SELECT email FROM profiles WHERE id = auth.uid())
    OR
    -- Assigned user can view
    row_data->>'assignedTo' = auth.uid()::text
    OR
    -- Public rows (no restrictions)
    row_data->>'visibility' = 'public'
  )
);
```

#### 3.2.4 Column-Level Permissions

**Current**: Sheet-level access

**Needed**: Column-specific permissions

```sql
-- Column-level permissions
CREATE POLICY "Users can view columns based on permissions"
ON columns FOR SELECT
USING (
  sheet_id IN (
    SELECT id FROM sheets WHERE project_id IN (
      SELECT id FROM projects WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  ) AND (
    -- No permissions field = everyone can view
    permissions IS NULL
    OR
    -- User is in viewers list
    permissions->'viewers' @> jsonb_build_array(auth.uid()::text)
    OR
    -- User is in editors list
    permissions->'editors' @> jsonb_build_array(auth.uid()::text)
  )
);
```

### 3.3 RLS Refinement Checklist

- [ ] **Workspace Permissions**
  - [ ] Owner role
  - [ ] Editor role
  - [ ] Viewer role
  - [ ] Custom roles

- [ ] **Project Permissions**
  - [ ] Project-level overrides
  - [ ] Project member roles
  - [ ] Inherited permissions

- [ ] **Sheet Permissions**
  - [ ] Sheet-level access
  - [ ] Sheet member roles

- [ ] **Row Permissions**
  - [ ] Row ownership
  - [ ] Row assignment
  - [ ] Row visibility

- [ ] **Column Permissions**
  - [ ] Column-level access
  - [ ] Column viewer/editor lists
  - [ ] Sensitive data protection

- [ ] **Testing**
  - [ ] Test all permission scenarios
  - [ ] Verify RLS policies work correctly
  - [ ] Test edge cases

---

## 4. Supabase Functions

### 4.1 When to Use Supabase Functions

Supabase Functions (Edge Functions) are useful for:

- ✅ **Complex business logic** that can't be handled by RLS
- ✅ **External API integrations** (Slack, Teams, etc.)
- ✅ **Data processing** (batch operations, calculations)
- ✅ **Custom authentication** flows
- ✅ **Webhook handlers** for third-party services
- ✅ **Scheduled tasks** (cron jobs)

### 4.2 Example Use Cases

#### 4.2.1 Automation Triggers

```typescript
// supabase/functions/automation-trigger/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  );

  // Get automation rules
  const { data: automations } = await supabase
    .from('automations')
    .select('*')
    .eq('enabled', true);

  // Process each automation
  for (const automation of automations || []) {
    if (automation.trigger_type === 'status_change') {
      // Check for status changes
      // Send notifications
      await sendNotification(automation);
    }
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

#### 4.2.2 Slack Integration

```typescript
// supabase/functions/slack-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const { webhookUrl, message } = await req.json();

  // Send to Slack
  const response = await fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ text: message }),
  });

  return new Response(JSON.stringify({ success: response.ok }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

#### 4.2.3 Batch Operations

```typescript
// supabase/functions/batch-update/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  );

  const { rowIds, updates } = await req.json();

  // Batch update rows
  const { data, error } = await supabase
    .from('rows')
    .update(updates)
    .in('id', rowIds);

  return new Response(JSON.stringify({ data, error }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

### 4.3 Setting Up Supabase Functions

#### 4.3.1 Install Supabase CLI

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link to project
supabase link --project-ref woigtfojjixtmwaoamap
```

#### 4.3.2 Create Function

```bash
# Create new function
supabase functions new automation-trigger

# Deploy function
supabase functions deploy automation-trigger
```

#### 4.3.3 Call Function from Frontend

```typescript
// Call Supabase Function
const { data, error } = await supabase.functions.invoke('automation-trigger', {
  body: { projectId, triggerType: 'status_change' }
});
```

### 4.4 Supabase Functions Checklist

- [ ] **Setup**
  - [ ] Install Supabase CLI
  - [ ] Link to project
  - [ ] Create functions directory

- [ ] **Automation Functions**
  - [ ] Status change triggers
  - [ ] Date approaching triggers
  - [ ] Notification sending

- [ ] **Integration Functions**
  - [ ] Slack webhook handler
  - [ ] Teams webhook handler
  - [ ] Email sending

- [ ] **Data Processing**
  - [ ] Batch operations
  - [ ] Data aggregation
  - [ ] Report generation

- [ ] **Scheduled Tasks**
  - [ ] Daily summaries
  - [ ] Weekly reports
  - [ ] Cleanup tasks

---

## 5. Implementation Priority

### Phase 1: Core Features (Weeks 1-2)

**Priority: Critical**

1. ✅ Authentication
   - Login/Sign up
   - Session management
   - Protected routes

2. ✅ Workspaces
   - Create/View workspaces
   - Basic member management

3. ✅ Projects
   - Create/View projects
   - Basic project management

### Phase 2: Spreadsheet Features (Weeks 3-4)

**Priority: High**

1. ✅ Sheets
   - Create/View sheets
   - Column management

2. ✅ Rows
   - Create/Edit/Delete rows
   - Row data editing

3. ✅ Basic Real-time
   - Live updates
   - Basic presence

### Phase 3: Advanced Features (Weeks 5-6)

**Priority: Medium**

1. ✅ Advanced RLS
   - Granular permissions
   - Row/column-level access

2. ✅ Real-time Collaboration
   - Cursor indicators
   - Simultaneous editing

3. ✅ Comments & Attachments
   - Add comments
   - File attachments

### Phase 4: Integrations (Weeks 7-8)

**Priority: Low**

1. ✅ Supabase Functions
   - Automation triggers
   - External integrations

2. ✅ Advanced Features
   - Saved views
   - Templates
   - Activity log

---

## 6. Resources

### Documentation

- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Supabase Functions](https://supabase.com/docs/guides/functions)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [React Documentation](https://react.dev)

### Code Examples

- [CRUD Operations](./CRUD_OPERATIONS.md)
- [Real-time Collaboration](./REALTIME_COLLABORATION.md)
- [API Usage Examples](./API_USAGE_EXAMPLES.md)
- [Authentication Guide](./AUTHENTICATION_GUIDE.md)

---

## 7. Summary

### Next Steps Overview

1. **Frontend Implementation** - Build React components for each feature
2. **RLS Refinement** - Implement granular permissions
3. **Supabase Functions** - Add custom backend logic

### Key Priorities

- ✅ Start with authentication and core CRUD
- ✅ Implement real-time features early
- ✅ Refine RLS as features are added
- ✅ Use Functions for complex logic

---

**Start with Phase 1 and build incrementally!** 🚀
