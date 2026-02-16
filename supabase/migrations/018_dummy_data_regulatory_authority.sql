-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR REGULATORY AUTHORITY AI TRANSFORMATION
-- AI Email Routing and Workflow Automation
-- Hierarchy: Profile > Workspace > Project > Sheet > Column > Row (with row_data JSONB)
-- ============================================================
-- Note: This uses our actual schema:
-- - profiles (not users) - extends auth.users
-- - row_data JSONB (not cells table)
-- - Proper UUIDs and foreign key references
-- ============================================================

-- ============================================================
-- 1. PROFILES (User must exist in auth.users first)
-- ============================================================
-- Note: In production, profiles are created automatically via trigger
-- when a user signs up. For dummy data, we'll insert directly.
-- The user must exist in auth.users first (created via Supabase Auth)

-- Assuming user 'regulatory.ai.lead@example.com' exists in auth.users with UUID
-- We'll use a placeholder UUID - replace with actual auth.users.id
DO $$
DECLARE
  v_user_id UUID := '00000000-0000-0000-0000-000000000016'::UUID;
BEGIN
  -- Insert profile (assuming user exists in auth.users)
  INSERT INTO profiles (id, name, email, color)
  VALUES (
    v_user_id,
    'AI Workflow Project Owner',
    'regulatory.ai.lead@example.com',
    '#10b981'
  )
  ON CONFLICT (id) DO NOTHING;
END $$;

-- ============================================================
-- 2. WORKSPACES
-- ============================================================
INSERT INTO workspaces (id, name, owner_id) VALUES
('00000000-0000-0000-0000-000000001500'::UUID, 'Regulatory Authority AI Transformation', '00000000-0000-0000-0000-000000000016'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001500'::UUID,
  '00000000-0000-0000-0000-000000000016'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001600'::UUID,
  '00000000-0000-0000-0000-000000001500'::UUID,
  '00000000-0000-0000-0000-000000000016'::UUID,
  'AI Email Routing and Workflow Automation',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001600'::UUID,
  '00000000-0000-0000-0000-000000000016'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001700'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'Project Tasks'),
('00000000-0000-0000-0000-000000001701'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001702'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'KPIs and Outcomes')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001700'::UUID
WHERE id = '00000000-0000-0000-0000-000000001600'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Project Tasks
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001800'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Task Name', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001801'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Category', 'dropdown', 250, 2, '["Leadership", "Data Science", "Data Engineering", "Platform Engineering", "Operations"]'::jsonb),
('00000000-0000-0000-0000-000000001802'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Owner', 'dropdown', 150, 3, '["Self", "Team", "Shared"]'::jsonb),
('00000000-0000-0000-0000-000000001803'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Status', 'dropdown', 150, 4, '["Completed", "In Progress", "Planned"]'::jsonb),
('00000000-0000-0000-0000-000000001804'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Impact Level', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001810'::UUID, '00000000-0000-0000-0000-000000001701'::UUID, 'Challenge', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001811'::UUID, '00000000-0000-0000-0000-000000001701'::UUID, 'Solution', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001812'::UUID, '00000000-0000-0000-0000-000000001701'::UUID, 'Severity', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001813'::UUID, '00000000-0000-0000-0000-000000001701'::UUID, 'Resolution Status', 'dropdown', 150, 4, '["Resolved", "Mitigated", "Monitoring"]'::jsonb),
('00000000-0000-0000-0000-000000001814'::UUID, '00000000-0000-0000-0000-000000001701'::UUID, 'Owner', 'dropdown', 150, 5, '["Self", "Team", "Shared"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: KPIs and Outcomes
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001820'::UUID, '00000000-0000-0000-0000-000000001702'::UUID, 'Metric Name', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001821'::UUID, '00000000-0000-0000-0000-000000001702'::UUID, 'Category', 'dropdown', 250, 2, '["Operational Efficiency", "Model Performance", "Workforce Impact", "Service Impact", "Strategic Outcome"]'::jsonb),
('00000000-0000-0000-0000-000000001822'::UUID, '00000000-0000-0000-0000-000000001702'::UUID, 'Value', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000001823'::UUID, '00000000-0000-0000-0000-000000001702'::UUID, 'Trend', 'dropdown', 150, 4, '["Improved", "Stable", "Degraded"]'::jsonb),
('00000000-0000-0000-0000-000000001824'::UUID, '00000000-0000-0000-0000-000000001702'::UUID, 'Impact Level', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Project Tasks
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001900'::UUID,
  '00000000-0000-0000-0000-000000001700'::UUID,
  '{
    "Task Name": "Define operational workflow and decision-support automation model",
    "Category": "Leadership",
    "Owner": "Self",
    "Status": "Completed",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001901'::UUID,
  '00000000-0000-0000-0000-000000001700'::UUID,
  '{
    "Task Name": "Define success metrics and deployment gating criteria",
    "Category": "Leadership",
    "Owner": "Self",
    "Status": "Completed",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001902'::UUID,
  '00000000-0000-0000-0000-000000001700'::UUID,
  '{
    "Task Name": "Develop NLP classification model using TF-IDF and ML algorithms",
    "Category": "Data Science",
    "Owner": "Team",
    "Status": "Completed",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001903'::UUID,
  '00000000-0000-0000-0000-000000001700'::UUID,
  '{
    "Task Name": "Build real-time email ingestion and processing pipelines",
    "Category": "Data Engineering",
    "Owner": "Team",
    "Status": "Completed",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001904'::UUID,
  '00000000-0000-0000-0000-000000001700'::UUID,
  '{
    "Task Name": "Deploy model, monitor performance, and automate retraining",
    "Category": "Platform Engineering",
    "Owner": "Team",
    "Status": "Completed",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001910'::UUID,
  '00000000-0000-0000-0000-000000001701'::UUID,
  '{
    "Challenge": "Inconsistent historical email labeling",
    "Solution": "Data cleaning, relabeling exercises, and confidence weighting during training",
    "Severity": "High",
    "Resolution Status": "Resolved",
    "Owner": "Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001911'::UUID,
  '00000000-0000-0000-0000-000000001701'::UUID,
  '{
    "Challenge": "Ambiguous or multi-topic emails",
    "Solution": "Multi-class probability scoring and fallback routing rules with manual review",
    "Severity": "High",
    "Resolution Status": "Mitigated",
    "Owner": "Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001912'::UUID,
  '00000000-0000-0000-0000-000000001701'::UUID,
  '{
    "Challenge": "Staff skepticism toward AI automation",
    "Solution": "Transparent dashboards, explainable routing, and human override capability",
    "Severity": "High",
    "Resolution Status": "Resolved",
    "Owner": "Self"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001913'::UUID,
  '00000000-0000-0000-0000-000000001701'::UUID,
  '{
    "Challenge": "Maintaining model performance over time",
    "Solution": "Continuous monitoring, scheduled retraining, and concept drift detection",
    "Severity": "Medium",
    "Resolution Status": "Monitoring",
    "Owner": "Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001914'::UUID,
  '00000000-0000-0000-0000-000000001701'::UUID,
  '{
    "Challenge": "Balancing automation coverage vs precision",
    "Solution": "Optimized for high-confidence routing instead of forcing automation",
    "Severity": "Medium",
    "Resolution Status": "Resolved",
    "Owner": "Self"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: KPIs and Outcomes
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001920'::UUID,
  '00000000-0000-0000-0000-000000001702'::UUID,
  '{
    "Metric Name": "Reduction in manual email routing time",
    "Category": "Operational Efficiency",
    "Value": "80 percent reduction",
    "Trend": "Improved",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001921'::UUID,
  '00000000-0000-0000-0000-000000001702'::UUID,
  '{
    "Metric Name": "Auto-routing coverage rate",
    "Category": "Operational Efficiency",
    "Value": "84 percent of incoming emails",
    "Trend": "Improved",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001922'::UUID,
  '00000000-0000-0000-0000-000000001702'::UUID,
  '{
    "Metric Name": "Routing accuracy rate",
    "Category": "Model Performance",
    "Value": "75 percent accuracy",
    "Trend": "Stable",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001923'::UUID,
  '00000000-0000-0000-0000-000000001702'::UUID,
  '{
    "Metric Name": "Employee productivity and satisfaction",
    "Category": "Workforce Impact",
    "Value": "Increased staff capacity and satisfaction",
    "Trend": "Improved",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001924'::UUID,
  '00000000-0000-0000-0000-000000001702'::UUID,
  '{
    "Metric Name": "Response time to inbound inquiries",
    "Category": "Service Impact",
    "Value": "Improved response times and reduced routing delays",
    "Trend": "Improved",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: regulatory.ai.lead@example.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000016' with the actual auth.users.id
--
-- 2. Data Structure:
--    - Uses row_data JSONB (not cells table) - matches our implementation
--    - Column values are stored as JSON keys matching column titles
--    - Dependencies array tracks task dependencies (empty for this dataset)
--
-- 3. To Use:
--    - Run this migration after 001_initial_schema.sql
--    - Update the user UUID to match your actual auth.users.id
--    - Or create the user first, then update this migration
--
-- 4. Project Details:
--    - Workspace: Regulatory Authority AI Transformation
--    - Project: AI Email Routing and Workflow Automation
--    - 3 Sheets: Project Tasks, Challenges, KPIs
--    - 15 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
