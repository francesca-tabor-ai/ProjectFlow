-- ============================================================================
-- ProjectFlow Database Schema
-- Initial Migration: Core Tables and Relationships
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- ============================================================================
-- PROFILES
-- Extends Supabase Auth users with additional profile information
-- ============================================================================

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar TEXT,
  color TEXT, -- Assigned color for UI (cursor, etc.)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can view all profiles (for collaboration)
CREATE POLICY "Users can view profiles"
ON profiles FOR SELECT
USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- ============================================================================
-- WORKSPACES
-- Top-level organization containers
-- ============================================================================

CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- Users can view workspaces they're members of
CREATE POLICY "Users can view their workspaces"
ON workspaces FOR SELECT
USING (
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);

-- Owners can insert workspaces
CREATE POLICY "Users can create workspaces"
ON workspaces FOR INSERT
WITH CHECK (auth.uid() = owner_id);

-- Owners can update their workspaces
CREATE POLICY "Owners can update workspaces"
ON workspaces FOR UPDATE
USING (
  owner_id = auth.uid() OR
  id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role = 'Owner'
  )
);

-- Owners can delete their workspaces
CREATE POLICY "Owners can delete workspaces"
ON workspaces FOR DELETE
USING (owner_id = auth.uid());

-- ============================================================================
-- WORKSPACE MEMBERS
-- Many-to-many relationship between users and workspaces with roles
-- ============================================================================

CREATE TABLE workspace_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'Viewer', -- Owner, Editor, Viewer, or custom
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, user_id)
);

-- Enable RLS
ALTER TABLE workspace_members ENABLE ROW LEVEL SECURITY;

-- Users can view members of workspaces they belong to
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);

-- Workspace owners can add members
CREATE POLICY "Owners can add workspace members"
ON workspace_members FOR INSERT
WITH CHECK (
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);

-- Workspace owners can update members
CREATE POLICY "Owners can update workspace members"
ON workspace_members FOR UPDATE
USING (
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);

-- Workspace owners can remove members
CREATE POLICY "Owners can remove workspace members"
ON workspace_members FOR DELETE
USING (
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);

-- ============================================================================
-- ROLE DEFINITIONS
-- Custom role definitions for workspaces
-- ============================================================================

CREATE TABLE role_definitions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  base_role TEXT NOT NULL CHECK (base_role IN ('Owner', 'Editor', 'Viewer')),
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, name)
);

-- Enable RLS
ALTER TABLE role_definitions ENABLE ROW LEVEL SECURITY;

-- Users can view roles in workspaces they belong to
CREATE POLICY "Users can view role definitions"
ON role_definitions FOR SELECT
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);

-- Workspace owners can manage roles
CREATE POLICY "Owners can manage role definitions"
ON role_definitions FOR ALL
USING (
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);

-- ============================================================================
-- PROJECTS
-- Projects belong to workspaces and contain sheets
-- ============================================================================

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  active_sheet_id UUID, -- Reference to sheets table (set after sheets are created)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Users can view projects in workspaces they belong to
CREATE POLICY "Users can view projects"
ON projects FOR SELECT
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid()
  )
);

-- Users with Editor or Owner role can create projects
CREATE POLICY "Editors can create projects"
ON projects FOR INSERT
WITH CHECK (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
  ) AND auth.uid() = owner_id
);

-- Users with Editor or Owner role can update projects
CREATE POLICY "Editors can update projects"
ON projects FOR UPDATE
USING (
  workspace_id IN (
    SELECT workspace_id FROM workspace_members
    WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
  )
);

-- Project owners can delete projects
CREATE POLICY "Owners can delete projects"
ON projects FOR DELETE
USING (owner_id = auth.uid());

-- ============================================================================
-- PROJECT MEMBERS
-- Many-to-many relationship between users and projects with roles
-- ============================================================================

CREATE TABLE project_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'Viewer',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, user_id)
);

-- Enable RLS
ALTER TABLE project_members ENABLE ROW LEVEL SECURITY;

-- Users can view members of projects they belong to
CREATE POLICY "Users can view project members"
ON project_members FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);

-- Project owners can manage members
CREATE POLICY "Owners can manage project members"
ON project_members FOR ALL
USING (
  project_id IN (
    SELECT id FROM projects WHERE owner_id = auth.uid()
  )
);

-- ============================================================================
-- SHEETS
-- Sheets belong to projects and contain rows
-- ============================================================================

CREATE TABLE sheets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE sheets ENABLE ROW LEVEL SECURITY;

-- Users can view sheets in projects they have access to
CREATE POLICY "Users can view sheets"
ON sheets FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);

-- Users with Editor or Owner role can create sheets
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

-- Users with Editor or Owner role can update sheets
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

-- Users with Editor or Owner role can delete sheets
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

-- ============================================================================
-- COLUMNS
-- Column definitions for sheets (flexible schema)
-- ============================================================================

CREATE TABLE columns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sheet_id UUID NOT NULL REFERENCES sheets(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('text', 'number', 'date', 'dropdown', 'checkbox', 'status')),
  width INTEGER DEFAULT 150,
  options JSONB, -- For dropdowns: ["Option 1", "Option 2"]
  permissions JSONB, -- { viewers: [], editors: [] }
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE columns ENABLE ROW LEVEL SECURITY;

-- Users can view columns in sheets they have access to
CREATE POLICY "Users can view columns"
ON columns FOR SELECT
USING (
  sheet_id IN (
    SELECT id FROM sheets WHERE project_id IN (
      SELECT id FROM projects WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  )
);

-- Users with Editor or Owner role can manage columns
CREATE POLICY "Editors can manage columns"
ON columns FOR ALL
USING (
  sheet_id IN (
    SELECT id FROM sheets WHERE project_id IN (
      SELECT id FROM projects WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
      )
    )
  )
);

-- ============================================================================
-- ROWS
-- Row data stored as JSONB for flexibility
-- ============================================================================

CREATE TABLE rows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sheet_id UUID NOT NULL REFERENCES sheets(id) ON DELETE CASCADE,
  row_data JSONB NOT NULL DEFAULT '{}', -- Flexible column data
  dependencies TEXT[], -- Array of row IDs this task depends on
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for JSONB queries
CREATE INDEX idx_rows_row_data ON rows USING GIN (row_data);
CREATE INDEX idx_rows_sheet_id ON rows (sheet_id);

-- Enable RLS
ALTER TABLE rows ENABLE ROW LEVEL SECURITY;

-- Users can view rows in sheets they have access to
CREATE POLICY "Users can view rows"
ON rows FOR SELECT
USING (
  sheet_id IN (
    SELECT id FROM sheets WHERE project_id IN (
      SELECT id FROM projects WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  )
);

-- Users with Editor or Owner role can manage rows
CREATE POLICY "Editors can manage rows"
ON rows FOR ALL
USING (
  sheet_id IN (
    SELECT id FROM sheets WHERE project_id IN (
      SELECT id FROM projects WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members
        WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
      )
    )
  )
);

-- ============================================================================
-- COMMENTS
-- Comments attached to rows
-- ============================================================================

CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  row_id UUID NOT NULL REFERENCES rows(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Users can view comments on rows they can view
CREATE POLICY "Users can view comments"
ON comments FOR SELECT
USING (
  row_id IN (
    SELECT id FROM rows WHERE sheet_id IN (
      SELECT id FROM sheets WHERE project_id IN (
        SELECT id FROM projects WHERE workspace_id IN (
          SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
        )
      )
    )
  )
);

-- Users can create comments on rows they can view
CREATE POLICY "Users can create comments"
ON comments FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND
  row_id IN (
    SELECT id FROM rows WHERE sheet_id IN (
      SELECT id FROM sheets WHERE project_id IN (
        SELECT id FROM projects WHERE workspace_id IN (
          SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
        )
      )
    )
  )
);

-- Users can delete their own comments
CREATE POLICY "Users can delete own comments"
ON comments FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- FILE ATTACHMENTS
-- File attachments for rows
-- ============================================================================

CREATE TABLE file_attachments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  row_id UUID NOT NULL REFERENCES rows(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  size INTEGER NOT NULL,
  url TEXT NOT NULL,
  provider TEXT CHECK (provider IN ('local', 'google_drive')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE file_attachments ENABLE ROW LEVEL SECURITY;

-- Users can view attachments on rows they can view
CREATE POLICY "Users can view attachments"
ON file_attachments FOR SELECT
USING (
  row_id IN (
    SELECT id FROM rows WHERE sheet_id IN (
      SELECT id FROM sheets WHERE project_id IN (
        SELECT id FROM projects WHERE workspace_id IN (
          SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
        )
      )
    )
  )
);

-- Users with Editor or Owner role can manage attachments
CREATE POLICY "Editors can manage attachments"
ON file_attachments FOR ALL
USING (
  row_id IN (
    SELECT id FROM rows WHERE sheet_id IN (
      SELECT id FROM sheets WHERE project_id IN (
        SELECT id FROM projects WHERE workspace_id IN (
          SELECT workspace_id FROM workspace_members
          WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
        )
      )
    )
  )
);

-- ============================================================================
-- ACTIVITY LOG
-- Audit trail of user actions
-- ============================================================================

CREATE TABLE activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  action TEXT NOT NULL,
  row_id UUID REFERENCES rows(id) ON DELETE SET NULL,
  details TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_activity_log_project_id ON activity_log (project_id);
CREATE INDEX idx_activity_log_created_at ON activity_log (created_at DESC);

-- Enable RLS
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- Users can view activity in projects they have access to
CREATE POLICY "Users can view activity log"
ON activity_log FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);

-- System can insert activity (via service role)
CREATE POLICY "System can insert activity"
ON activity_log FOR INSERT
WITH CHECK (true);

-- ============================================================================
-- AUTOMATIONS
-- Automation rules for projects
-- ============================================================================

CREATE TABLE automations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  enabled BOOLEAN DEFAULT true,
  trigger_type TEXT NOT NULL CHECK (trigger_type IN ('status_change', 'date_approaching')),
  trigger_value TEXT, -- e.g., "Blocked" for status_change
  trigger_days_before INTEGER, -- for date_approaching
  action_type TEXT NOT NULL CHECK (action_type = 'notify'),
  action_channel TEXT NOT NULL CHECK (action_channel IN ('in_app', 'email', 'slack', 'teams')),
  action_recipient TEXT NOT NULL CHECK (action_recipient IN ('owner', 'all')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE automations ENABLE ROW LEVEL SECURITY;

-- Users can view automations in projects they have access to
CREATE POLICY "Users can view automations"
ON automations FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);

-- Users with Editor or Owner role can manage automations
CREATE POLICY "Editors can manage automations"
ON automations FOR ALL
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members
      WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
    )
  )
);

-- ============================================================================
-- SAVED VIEWS
-- Saved filter/view configurations
-- ============================================================================

CREATE TABLE saved_views (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  filters JSONB NOT NULL DEFAULT '{}', -- { owners: [], statuses: [], dateRange: 'all' }
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE saved_views ENABLE ROW LEVEL SECURITY;

-- Users can view their own saved views
CREATE POLICY "Users can view own saved views"
ON saved_views FOR SELECT
USING (auth.uid() = user_id);

-- Users can manage their own saved views
CREATE POLICY "Users can manage own saved views"
ON saved_views FOR ALL
USING (auth.uid() = user_id);

-- ============================================================================
-- INTEGRATIONS
-- Integration settings for projects
-- ============================================================================

CREATE TABLE integrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  slack_webhook TEXT,
  teams_webhook TEXT,
  google_drive_connected BOOLEAN DEFAULT false,
  api_keys JSONB DEFAULT '[]', -- [{ id, name, key, createdAt }]
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id)
);

-- Enable RLS
ALTER TABLE integrations ENABLE ROW LEVEL SECURITY;

-- Users can view integrations in projects they have access to
CREATE POLICY "Users can view integrations"
ON integrations FOR SELECT
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  )
);

-- Users with Editor or Owner role can manage integrations
CREATE POLICY "Editors can manage integrations"
ON integrations FOR ALL
USING (
  project_id IN (
    SELECT id FROM projects WHERE workspace_id IN (
      SELECT workspace_id FROM workspace_members
      WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
    )
  )
);

-- ============================================================================
-- AI METRICS
-- AI performance metrics
-- ============================================================================

CREATE TABLE ai_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  timestamp BIGINT NOT NULL,
  latency INTEGER NOT NULL, -- milliseconds
  model TEXT NOT NULL,
  success BOOLEAN NOT NULL,
  confidence NUMERIC(3, 2) NOT NULL, -- 0.00 to 1.00
  task_type TEXT NOT NULL CHECK (task_type IN ('planner', 'insight', 'command')),
  consensus_score NUMERIC(3, 2), -- 0.00 to 1.00
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_ai_metrics_timestamp ON ai_metrics (timestamp DESC);
CREATE INDEX idx_ai_metrics_task_type ON ai_metrics (task_type);

-- Enable RLS
ALTER TABLE ai_metrics ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view AI metrics (for dashboard)
CREATE POLICY "Users can view AI metrics"
ON ai_metrics FOR SELECT
USING (auth.role() = 'authenticated');

-- System can insert metrics (via service role)
CREATE POLICY "System can insert AI metrics"
ON ai_metrics FOR INSERT
WITH CHECK (true);

-- ============================================================================
-- RETRAINING JOBS
-- AI model retraining job history
-- ============================================================================

CREATE TABLE retraining_jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  start_time BIGINT NOT NULL,
  end_time BIGINT,
  status TEXT NOT NULL CHECK (status IN ('idle', 'running', 'validating', 'success', 'failed')),
  trigger_type TEXT NOT NULL CHECK (trigger_type IN ('drift', 'performance', 'schedule')),
  base_version TEXT NOT NULL,
  new_version TEXT,
  accuracy_gain NUMERIC(5, 2),
  log JSONB DEFAULT '[]', -- Array of log messages
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE retraining_jobs ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view retraining jobs
CREATE POLICY "Users can view retraining jobs"
ON retraining_jobs FOR SELECT
USING (auth.role() = 'authenticated');

-- System can manage retraining jobs (via service role)
CREATE POLICY "System can manage retraining jobs"
ON retraining_jobs FOR ALL
WITH CHECK (true);

-- ============================================================================
-- RETRAINING CONFIG
-- Retraining configuration
-- ============================================================================

CREATE TABLE retraining_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  enabled BOOLEAN DEFAULT false,
  schedule TEXT CHECK (schedule IN ('daily', 'weekly', 'monthly')),
  drift_threshold NUMERIC(3, 2) DEFAULT 0.1,
  performance_threshold NUMERIC(3, 2) DEFAULT 0.8,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(id) -- Single global config
);

-- Enable RLS
ALTER TABLE retraining_config ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view config
CREATE POLICY "Users can view retraining config"
ON retraining_config FOR SELECT
USING (auth.role() = 'authenticated');

-- Only service role can update config
CREATE POLICY "Service can update retraining config"
ON retraining_config FOR ALL
WITH CHECK (auth.role() = 'service_role');

-- ============================================================================
-- TEMPLATES
-- Project templates
-- ============================================================================

CREATE TABLE templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  template_data JSONB NOT NULL, -- Full template structure
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view templates
CREATE POLICY "Users can view templates"
ON templates FOR SELECT
USING (auth.role() = 'authenticated');

-- Only service role can manage templates (or add policy for admins)
CREATE POLICY "Service can manage templates"
ON templates FOR ALL
WITH CHECK (auth.role() = 'service_role');

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workspaces_updated_at BEFORE UPDATE ON workspaces
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sheets_updated_at BEFORE UPDATE ON sheets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_columns_updated_at BEFORE UPDATE ON columns
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rows_updated_at BEFORE UPDATE ON rows
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_automations_updated_at BEFORE UPDATE ON automations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saved_views_updated_at BEFORE UPDATE ON saved_views
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_integrations_updated_at BEFORE UPDATE ON integrations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_retraining_jobs_updated_at BEFORE UPDATE ON retraining_jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_retraining_config_updated_at BEFORE UPDATE ON retraining_config
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_templates_updated_at BEFORE UPDATE ON templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- INITIAL DATA
-- ============================================================================

-- Insert default retraining config
INSERT INTO retraining_config (id, enabled, schedule, drift_threshold, performance_threshold)
VALUES (uuid_generate_v4(), false, 'weekly', 0.1, 0.8)
ON CONFLICT (id) DO NOTHING;
