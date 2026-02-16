# Database Schema Reference

Quick reference guide for the ProjectFlow database schema.

## Authentication & Users

### Supabase Auth (`auth.users`)
**Managed by Supabase** - Do not modify directly.

```sql
-- This table is managed by Supabase
-- Contains: id, email, encrypted_password, email_confirmed_at, etc.
-- Access via: supabase.auth.signUp(), supabase.auth.signIn(), etc.
```

### Profiles Table
**Our custom table** - Extends `auth.users` with application data.

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,              -- Display name
  email TEXT NOT NULL,             -- Synced from auth.users
  avatar TEXT,                      -- Avatar URL
  color TEXT,                       -- UI color assignment
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Key Relationships:**
- `id` → `auth.users(id)` (1:1 relationship)
- Referenced by: `workspace_members`, `project_members`, `comments`, `activity_log`

**RLS Policies:**
- ✅ Users can view all profiles (for collaboration)
- ✅ Users can update their own profile only

---

## Core Application Tables

### Workspaces
```sql
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Workspace Members
```sql
CREATE TABLE workspace_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  user_id UUID NOT NULL REFERENCES profiles(id),
  role TEXT NOT NULL DEFAULT 'Viewer',  -- Owner, Editor, Viewer
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, user_id)
);
```

### Projects
```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  owner_id UUID NOT NULL REFERENCES profiles(id),
  active_sheet_id UUID,  -- References sheets(id)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Sheets
```sql
CREATE TABLE sheets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Columns
```sql
CREATE TABLE columns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sheet_id UUID NOT NULL REFERENCES sheets(id),
  title TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('text', 'number', 'date', 'dropdown', 'checkbox', 'status')),
  width INTEGER DEFAULT 150,
  options JSONB,              -- For dropdowns: ["Option 1", "Option 2"]
  permissions JSONB,          -- { viewers: [], editors: [] }
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Rows
```sql
CREATE TABLE rows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sheet_id UUID NOT NULL REFERENCES sheets(id),
  row_data JSONB NOT NULL DEFAULT '{}',  -- Flexible column data
  dependencies TEXT[],                    -- Array of row IDs
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_rows_row_data ON rows USING GIN (row_data);
CREATE INDEX idx_rows_sheet_id ON rows (sheet_id);
```

**Example `row_data`:**
```json
{
  "task": "Complete documentation",
  "status": "In Progress",
  "owner": "John Doe",
  "dueDate": "2024-12-31",
  "progress": 50
}
```

---

## Supporting Tables

### Comments
```sql
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  row_id UUID NOT NULL REFERENCES rows(id),
  user_id UUID NOT NULL REFERENCES profiles(id),
  user_name TEXT NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### File Attachments
```sql
CREATE TABLE file_attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  row_id UUID NOT NULL REFERENCES rows(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  size INTEGER NOT NULL,
  url TEXT NOT NULL,
  provider TEXT CHECK (provider IN ('local', 'google_drive')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Activity Log
```sql
CREATE TABLE activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id),
  user_id UUID NOT NULL REFERENCES profiles(id),
  user_name TEXT NOT NULL,
  action TEXT NOT NULL,
  row_id UUID REFERENCES rows(id),
  details TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_activity_log_project_id ON activity_log (project_id);
CREATE INDEX idx_activity_log_created_at ON activity_log (created_at DESC);
```

### Automations
```sql
CREATE TABLE automations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id),
  name TEXT NOT NULL,
  enabled BOOLEAN DEFAULT true,
  trigger_type TEXT NOT NULL CHECK (trigger_type IN ('status_change', 'date_approaching')),
  trigger_value TEXT,
  trigger_days_before INTEGER,
  action_type TEXT NOT NULL CHECK (action_type = 'notify'),
  action_channel TEXT NOT NULL CHECK (action_channel IN ('in_app', 'email', 'slack', 'teams')),
  action_recipient TEXT NOT NULL CHECK (action_recipient IN ('owner', 'all')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Saved Views
```sql
CREATE TABLE saved_views (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id),
  user_id UUID NOT NULL REFERENCES profiles(id),
  name TEXT NOT NULL,
  filters JSONB NOT NULL DEFAULT '{}',  -- { owners: [], statuses: [], dateRange: 'all' }
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Integrations
```sql
CREATE TABLE integrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id),
  slack_webhook TEXT,
  teams_webhook TEXT,
  google_drive_connected BOOLEAN DEFAULT false,
  api_keys JSONB DEFAULT '[]',  -- [{ id, name, key, createdAt }]
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id)
);
```

### Role Definitions
```sql
CREATE TABLE role_definitions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  base_role TEXT NOT NULL CHECK (base_role IN ('Owner', 'Editor', 'Viewer')),
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, name)
);
```

---

## AI & Analytics Tables

### AI Metrics
```sql
CREATE TABLE ai_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  timestamp BIGINT NOT NULL,
  latency INTEGER NOT NULL,  -- milliseconds
  model TEXT NOT NULL,
  success BOOLEAN NOT NULL,
  confidence NUMERIC(3, 2) NOT NULL,  -- 0.00 to 1.00
  task_type TEXT NOT NULL CHECK (task_type IN ('planner', 'insight', 'command')),
  consensus_score NUMERIC(3, 2),  -- 0.00 to 1.00
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_ai_metrics_timestamp ON ai_metrics (timestamp DESC);
CREATE INDEX idx_ai_metrics_task_type ON ai_metrics (task_type);
```

### Retraining Jobs
```sql
CREATE TABLE retraining_jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  start_time BIGINT NOT NULL,
  end_time BIGINT,
  status TEXT NOT NULL CHECK (status IN ('idle', 'running', 'validating', 'success', 'failed')),
  trigger_type TEXT NOT NULL CHECK (trigger_type IN ('drift', 'performance', 'schedule')),
  base_version TEXT NOT NULL,
  new_version TEXT,
  accuracy_gain NUMERIC(5, 2),
  log JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Retraining Config
```sql
CREATE TABLE retraining_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  enabled BOOLEAN DEFAULT false,
  schedule TEXT CHECK (schedule IN ('daily', 'weekly', 'monthly')),
  drift_threshold NUMERIC(3, 2) DEFAULT 0.1,
  performance_threshold NUMERIC(3, 2) DEFAULT 0.8,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(id)  -- Single global config
);
```

### Templates
```sql
CREATE TABLE templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  template_data JSONB NOT NULL,  -- Full template structure
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Relationships Diagram

```
auth.users (Supabase)
    │
    │ 1:1
    ▼
profiles
    │
    │ 1:many
    ├── workspace_members ──┐
    ├── project_members     │
    ├── comments            │
    └── activity_log        │
                            │
workspaces ◄────────────────┘
    │
    │ 1:many
    ├── workspace_members
    ├── role_definitions
    └── projects
            │
            │ 1:many
            ├── project_members
            ├── sheets
            ├── activity_log
            ├── automations
            ├── saved_views
            └── integrations
                    │
                    │ 1:many
                    └── sheets
                            │
                            │ 1:many
                            ├── columns
                            └── rows
                                    │
                                    │ 1:many
                                    ├── comments
                                    └── file_attachments
```

---

## Row Level Security (RLS)

All tables have RLS enabled. Key policies:

- **Profiles**: Users can view all, update own
- **Workspaces**: Users can view if member, owners can manage
- **Projects**: Users can view if workspace member, editors can manage
- **Sheets/Rows**: Inherit permissions from parent project
- **Comments**: Users can view if can view row, create if can view row

---

## Indexes

Performance indexes created:

- `idx_rows_row_data` - GIN index for JSONB queries on rows
- `idx_rows_sheet_id` - B-tree index for sheet lookups
- `idx_activity_log_project_id` - Fast activity queries
- `idx_activity_log_created_at` - Sorted activity feed
- `idx_ai_metrics_timestamp` - Time-series queries
- `idx_ai_metrics_task_type` - Filter by task type

---

## Triggers

### Auto-update `updated_at`
All tables with `updated_at` have triggers to auto-update on row changes.

### Auto-create Profile
When a user signs up via Supabase Auth, a trigger automatically creates a `profiles` record.

---

**For complete schema, see `supabase/migrations/001_initial_schema.sql`**
