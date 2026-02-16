-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR RAIL TRANSPORT AI INTELLIGENCE
-- Customer Churn Prediction and Retention Intelligence
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

-- Assuming user 'rail.ai.lead@example.com' exists in auth.users with UUID
-- We'll use a placeholder UUID - replace with actual auth.users.id
DO $$
DECLARE
  v_user_id UUID := '00000000-0000-0000-0000-000000000017'::UUID;
BEGIN
  -- Insert profile (assuming user exists in auth.users)
  INSERT INTO profiles (id, name, email, color)
  VALUES (
    v_user_id,
    'AI Retention Lead',
    'rail.ai.lead@example.com',
    '#06b6d4'
  )
  ON CONFLICT (id) DO NOTHING;
END $$;

-- ============================================================
-- 2. WORKSPACES
-- ============================================================
INSERT INTO workspaces (id, name, owner_id) VALUES
('00000000-0000-0000-0000-000000001600'::UUID, 'Rail Transport AI Intelligence Workspace', '00000000-0000-0000-0000-000000000017'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001600'::UUID,
  '00000000-0000-0000-0000-000000000017'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001700'::UUID,
  '00000000-0000-0000-0000-000000001600'::UUID,
  '00000000-0000-0000-0000-000000000017'::UUID,
  'Customer Churn Prediction and Retention Intelligence',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001700'::UUID,
  '00000000-0000-0000-0000-000000000017'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001800'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Project Objectives'),
('00000000-0000-0000-0000-000000001801'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Team Responsibilities'),
('00000000-0000-0000-0000-000000001802'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001803'::UUID, '00000000-0000-0000-0000-000000001700'::UUID, 'Achievements and KPIs')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001800'::UUID
WHERE id = '00000000-0000-0000-0000-000000001700'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Project Objectives
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001900'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Objective Name', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001901'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Category', 'dropdown', 200, 2, '["Prediction", "Insight", "Operational", "Strategic"]'::jsonb),
('00000000-0000-0000-0000-000000001902'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Business Impact', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001903'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Priority', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001904'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Status', 'dropdown', 150, 5, '["Completed", "In Progress", "Planned"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Team Responsibilities
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001910'::UUID, '00000000-0000-0000-0000-000000001801'::UUID, 'Team', 'dropdown', 250, 1, '["Data Science", "Data Engineering", "Platform Engineering", "Commercial", "Leadership"]'::jsonb),
('00000000-0000-0000-0000-000000001911'::UUID, '00000000-0000-0000-0000-000000001801'::UUID, 'Responsibility', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001912'::UUID, '00000000-0000-0000-0000-000000001801'::UUID, 'Outcome', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001913'::UUID, '00000000-0000-0000-0000-000000001801'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001914'::UUID, '00000000-0000-0000-0000-000000001801'::UUID, 'Completed', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001920'::UUID, '00000000-0000-0000-0000-000000001802'::UUID, 'Challenge', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001921'::UUID, '00000000-0000-0000-0000-000000001802'::UUID, 'Solution', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001922'::UUID, '00000000-0000-0000-0000-000000001802'::UUID, 'Category', 'dropdown', 200, 3, '["Data", "Modeling", "Business", "Organizational"]'::jsonb),
('00000000-0000-0000-0000-000000001923'::UUID, '00000000-0000-0000-0000-000000001802'::UUID, 'Difficulty', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001924'::UUID, '00000000-0000-0000-0000-000000001802'::UUID, 'Resolved', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001930'::UUID, '00000000-0000-0000-0000-000000001803'::UUID, 'Achievement', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001931'::UUID, '00000000-0000-0000-0000-000000001803'::UUID, 'Impact Area', 'dropdown', 200, 2, '["Customer Insight", "Commercial", "Strategic", "Platform"]'::jsonb),
('00000000-0000-0000-0000-000000001932'::UUID, '00000000-0000-0000-0000-000000001803'::UUID, 'Business Value', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001933'::UUID, '00000000-0000-0000-0000-000000001803'::UUID, 'Strategic Importance', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001934'::UUID, '00000000-0000-0000-0000-000000001803'::UUID, 'Completed', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Project Objectives
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002000'::UUID,
  '00000000-0000-0000-0000-000000001800'::UUID,
  '{
    "Objective Name": "Predict customer churn risk",
    "Category": "Prediction",
    "Business Impact": "Enable proactive retention targeting",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002001'::UUID,
  '00000000-0000-0000-0000-000000001800'::UUID,
  '{
    "Objective Name": "Identify churn drivers",
    "Category": "Insight",
    "Business Impact": "Provide actionable retention insights",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002002'::UUID,
  '00000000-0000-0000-0000-000000001800'::UUID,
  '{
    "Objective Name": "Enable targeted retention interventions",
    "Category": "Operational",
    "Business Impact": "Improve retention campaign effectiveness",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002003'::UUID,
  '00000000-0000-0000-0000-000000001800'::UUID,
  '{
    "Objective Name": "Create reusable customer intelligence platform",
    "Category": "Strategic",
    "Business Impact": "Enable long-term predictive analytics capability",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002004'::UUID,
  '00000000-0000-0000-0000-000000001800'::UUID,
  '{
    "Objective Name": "Integrate churn intelligence into decision workflows",
    "Category": "Operational",
    "Business Impact": "Drive business adoption and commercial planning",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Team Responsibilities
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002010'::UUID,
  '00000000-0000-0000-0000-000000001801'::UUID,
  '{
    "Team": "Leadership",
    "Responsibility": "Business problem framing and deployment strategy",
    "Outcome": "Aligned AI with business retention decisions",
    "Impact Level": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002011'::UUID,
  '00000000-0000-0000-0000-000000001801'::UUID,
  '{
    "Team": "Data Science",
    "Responsibility": "Churn model development and segmentation",
    "Outcome": "Accurate churn risk prediction",
    "Impact Level": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002012'::UUID,
  '00000000-0000-0000-0000-000000001801'::UUID,
  '{
    "Team": "Data Engineering",
    "Responsibility": "Customer data integration pipelines",
    "Outcome": "Unified historical and behavioral data",
    "Impact Level": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002013'::UUID,
  '00000000-0000-0000-0000-000000001801'::UUID,
  '{
    "Team": "Platform Engineering",
    "Responsibility": "Model deployment and monitoring",
    "Outcome": "Operational AI deployment infrastructure",
    "Impact Level": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002014'::UUID,
  '00000000-0000-0000-0000-000000001801'::UUID,
  '{
    "Team": "Commercial",
    "Responsibility": "Retention campaign design",
    "Outcome": "Targeted retention actions",
    "Impact Level": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002020'::UUID,
  '00000000-0000-0000-0000-000000001802'::UUID,
  '{
    "Challenge": "Limited historical behavioral instrumentation",
    "Solution": "Combined proxy signals like ticket frequency and subscription duration",
    "Category": "Data",
    "Difficulty": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002021'::UUID,
  '00000000-0000-0000-0000-000000001802'::UUID,
  '{
    "Challenge": "Separating correlation from true churn drivers",
    "Solution": "Causal testing and feature importance stability monitoring",
    "Category": "Modeling",
    "Difficulty": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002022'::UUID,
  '00000000-0000-0000-0000-000000001802'::UUID,
  '{
    "Challenge": "Turning predictions into business action",
    "Solution": "Segment-specific retention recommendations and dashboards",
    "Category": "Business",
    "Difficulty": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002023'::UUID,
  '00000000-0000-0000-0000-000000001802'::UUID,
  '{
    "Challenge": "Organizational shift to data-driven decision making",
    "Solution": "Executive reporting and commercial team training",
    "Category": "Organizational",
    "Difficulty": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002030'::UUID,
  '00000000-0000-0000-0000-000000001803'::UUID,
  '{
    "Achievement": "Delivered churn risk visibility across commuter segments",
    "Impact Area": "Customer Insight",
    "Business Value": "Enabled early risk detection",
    "Strategic Importance": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002031'::UUID,
  '00000000-0000-0000-0000-000000001803'::UUID,
  '{
    "Achievement": "Enabled targeted retention strategies",
    "Impact Area": "Commercial",
    "Business Value": "Improved retention investment prioritization",
    "Strategic Importance": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002032'::UUID,
  '00000000-0000-0000-0000-000000001803'::UUID,
  '{
    "Achievement": "Identified strongest retention drivers",
    "Impact Area": "Strategic",
    "Business Value": "Improved lifecycle management strategy",
    "Strategic Importance": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002033'::UUID,
  '00000000-0000-0000-0000-000000001803'::UUID,
  '{
    "Achievement": "Created reusable prediction infrastructure",
    "Impact Area": "Platform",
    "Business Value": "Enabled scalable AI deployment",
    "Strategic Importance": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002034'::UUID,
  '00000000-0000-0000-0000-000000001803'::UUID,
  '{
    "Achievement": "Established proactive retention strategy foundation",
    "Impact Area": "Strategic",
    "Business Value": "Enabled long-term customer intelligence capability",
    "Strategic Importance": "High",
    "Completed": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: rail.ai.lead@example.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000017' with the actual auth.users.id
--
-- 2. Data Structure:
--    - Uses row_data JSONB (not cells table) - matches our implementation
--    - Column values are stored as JSON keys matching column titles
--    - Dependencies array tracks task dependencies (empty for this dataset)
--    - Note: Completed and Resolved are stored as booleans in JSONB
--
-- 3. To Use:
--    - Run this migration after 001_initial_schema.sql
--    - Update the user UUID to match your actual auth.users.id
--    - Or create the user first, then update this migration
--
-- 4. Project Details:
--    - Workspace: Rail Transport AI Intelligence Workspace
--    - Project: Customer Churn Prediction and Retention Intelligence
--    - 4 Sheets: Project Objectives, Team Responsibilities, Challenges, KPIs
--    - 19 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
