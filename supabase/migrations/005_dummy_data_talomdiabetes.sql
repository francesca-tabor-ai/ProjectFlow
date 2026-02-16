-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR TAL OM DIABETES
-- GRACE AI Platform - Healthcare AI Project
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
-- when a user signs up. For dummy data, we'll create the user first,
-- then update the profile with specific details.

DO $$
DECLARE
  v_user_id UUID := '00000000-0000-0000-0000-000000000003'::UUID;
  v_email TEXT := 'owner@talomdiabetes.ai';
  v_user_exists BOOLEAN;
  v_instance_id UUID;
BEGIN
  -- Check if user exists in auth.users
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = v_user_id) INTO v_user_exists;
  
  -- If user doesn't exist, create it in auth.users
  -- The trigger will automatically create a profile
  IF NOT v_user_exists THEN
    -- Get instance_id from an existing user, or use a default
    SELECT COALESCE(
      (SELECT instance_id FROM auth.users LIMIT 1),
      '00000000-0000-0000-0000-000000000000'::UUID
    ) INTO v_instance_id;
    
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      email_change,
      email_change_token_new,
      recovery_token
    )
    VALUES (
      v_user_id,
      v_instance_id,
      v_email,
      crypt('dummy-password', gen_salt('bf')), -- Dummy password for test data
      NOW(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"name": "Tal om Diabetes Product Owner"}'::jsonb,
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    );
  END IF;

  -- Update the profile with specific name and color
  -- (The trigger may have created it with default values, or it might not exist yet)
  INSERT INTO profiles (id, name, email, color)
  VALUES (
    v_user_id,
    'Tal om Diabetes Product Owner',
    v_email,
    '#ec4899'
  )
  ON CONFLICT (id) DO UPDATE
  SET
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    color = EXCLUDED.color;
END $$;

-- ============================================================
-- 2. WORKSPACES
-- ============================================================
INSERT INTO workspaces (id, name, owner_id) VALUES
('00000000-0000-0000-0000-000000000200'::UUID, 'GRACE AI Platform - Healthcare AI', '00000000-0000-0000-0000-000000000003'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000200'::UUID,
  '00000000-0000-0000-0000-000000000003'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000300'::UUID,
  '00000000-0000-0000-0000-000000000200'::UUID,
  '00000000-0000-0000-0000-000000000003'::UUID,
  'Tal om Diabetes Conversational Health Data Platform',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000300'::UUID,
  '00000000-0000-0000-0000-000000000003'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000400'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Core Product Ownership'),
('00000000-0000-0000-0000-000000000401'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Architecture and Engineering Tasks'),
('00000000-0000-0000-0000-000000000402'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000000403'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'KPIs and Outcomes')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000400'::UUID
WHERE id = '00000000-0000-0000-0000-000000000300'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Core Product Ownership
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000500'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Task Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000501'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Category', 'dropdown', 200, 2, '["Product Strategy", "Governance", "Evaluation", "Deployment"]'::jsonb),
('00000000-0000-0000-0000-000000000502'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Priority', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000503'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Status', 'dropdown', 150, 4, '["Completed", "In Progress", "Planned"]'::jsonb),
('00000000-0000-0000-0000-000000000504'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Impact', 'dropdown', 150, 5, '["Critical", "High", "Moderate"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Architecture and Engineering Tasks
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000510'::UUID, '00000000-0000-0000-0000-000000000401'::UUID, 'Task Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000511'::UUID, '00000000-0000-0000-0000-000000000401'::UUID, 'Team', 'dropdown', 200, 2, '["AI Engineering", "Platform Engineering", "Data Science", "UX Design"]'::jsonb),
('00000000-0000-0000-0000-000000000512'::UUID, '00000000-0000-0000-0000-000000000401'::UUID, 'Complexity', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000513'::UUID, '00000000-0000-0000-0000-000000000401'::UUID, 'Status', 'dropdown', 150, 4, '["Completed", "In Progress", "Planned"]'::jsonb),
('00000000-0000-0000-0000-000000000514'::UUID, '00000000-0000-0000-0000-000000000401'::UUID, 'Risk Level', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000520'::UUID, '00000000-0000-0000-0000-000000000402'::UUID, 'Challenge', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000521'::UUID, '00000000-0000-0000-0000-000000000402'::UUID, 'Solution Approach', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000000522'::UUID, '00000000-0000-0000-0000-000000000402'::UUID, 'Severity', 'dropdown', 150, 3, '["Critical", "High", "Medium"]'::jsonb),
('00000000-0000-0000-0000-000000000523'::UUID, '00000000-0000-0000-0000-000000000402'::UUID, 'Status', 'dropdown', 150, 4, '["Resolved", "In Progress"]'::jsonb),
('00000000-0000-0000-0000-000000000524'::UUID, '00000000-0000-0000-0000-000000000402'::UUID, 'Impact Area', 'dropdown', 200, 5, '["Accuracy", "Trust", "Usability", "Safety"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: KPIs and Outcomes
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000530'::UUID, '00000000-0000-0000-0000-000000000403'::UUID, 'Metric Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000531'::UUID, '00000000-0000-0000-0000-000000000403'::UUID, 'Category', 'dropdown', 200, 2, '["Adoption", "Performance", "Trust", "Safety"]'::jsonb),
('00000000-0000-0000-0000-000000000532'::UUID, '00000000-0000-0000-0000-000000000403'::UUID, 'Value', 'text', 200, 3, NULL),
('00000000-0000-0000-0000-000000000533'::UUID, '00000000-0000-0000-0000-000000000403'::UUID, 'Impact Level', 'dropdown', 150, 4, '["Critical", "High", "Moderate"]'::jsonb),
('00000000-0000-0000-0000-000000000534'::UUID, '00000000-0000-0000-0000-000000000403'::UUID, 'Status', 'dropdown', 150, 5, '["Achieved", "Maintained"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Core Product Ownership
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000600'::UUID,
  '00000000-0000-0000-0000-000000000400'::UUID,
  '{
    "Task Name": "Define user problem and use case boundaries",
    "Category": "Product Strategy",
    "Priority": "High",
    "Status": "Completed",
    "Impact": "Critical"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000601'::UUID,
  '00000000-0000-0000-0000-000000000400'::UUID,
  '{
    "Task Name": "Design AI evaluation framework",
    "Category": "Evaluation",
    "Priority": "High",
    "Status": "Completed",
    "Impact": "Critical"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000602'::UUID,
  '00000000-0000-0000-0000-000000000400'::UUID,
  '{
    "Task Name": "Define governance and safe deployment policies",
    "Category": "Governance",
    "Priority": "High",
    "Status": "Completed",
    "Impact": "Critical"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000603'::UUID,
  '00000000-0000-0000-0000-000000000400'::UUID,
  '{
    "Task Name": "Coordinate rollout and adoption strategy",
    "Category": "Deployment",
    "Priority": "High",
    "Status": "Completed",
    "Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000604'::UUID,
  '00000000-0000-0000-0000-000000000400'::UUID,
  '{
    "Task Name": "Define allowed vs restricted answer domains",
    "Category": "Governance",
    "Priority": "High",
    "Status": "Completed",
    "Impact": "Critical"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Architecture and Engineering Tasks
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000610'::UUID,
  '00000000-0000-0000-0000-000000000401'::UUID,
  '{
    "Task Name": "Build retrieval layer from structured diabetes datasets",
    "Team": "Data Science",
    "Complexity": "High",
    "Status": "Completed",
    "Risk Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000611'::UUID,
  '00000000-0000-0000-0000-000000000401'::UUID,
  '{
    "Task Name": "Develop query-to-SQL reasoning pipeline",
    "Team": "AI Engineering",
    "Complexity": "High",
    "Status": "Completed",
    "Risk Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000612'::UUID,
  '00000000-0000-0000-0000-000000000401'::UUID,
  '{
    "Task Name": "Deploy model serving infrastructure",
    "Team": "Platform Engineering",
    "Complexity": "Medium",
    "Status": "Completed",
    "Risk Level": "Medium"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000613'::UUID,
  '00000000-0000-0000-0000-000000000401'::UUID,
  '{
    "Task Name": "Implement monitoring and logging systems",
    "Team": "Platform Engineering",
    "Complexity": "Medium",
    "Status": "Completed",
    "Risk Level": "Medium"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000614'::UUID,
  '00000000-0000-0000-0000-000000000401'::UUID,
  '{
    "Task Name": "Design conversational UX and explanation rendering",
    "Team": "UX Design",
    "Complexity": "Medium",
    "Status": "Completed",
    "Risk Level": "Low"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000620'::UUID,
  '00000000-0000-0000-0000-000000000402'::UUID,
  '{
    "Challenge": "Translating natural language into structured health queries",
    "Solution Approach": "Implemented multi-step interpretation pipeline with intent classification and dataset mapping",
    "Severity": "Critical",
    "Status": "Resolved",
    "Impact Area": "Accuracy"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000621'::UUID,
  '00000000-0000-0000-0000-000000000402'::UUID,
  '{
    "Challenge": "Preventing confidently wrong health insights",
    "Solution Approach": "Used strict retrieval-first architecture with safe fallback responses",
    "Severity": "Critical",
    "Status": "Resolved",
    "Impact Area": "Safety"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000622'::UUID,
  '00000000-0000-0000-0000-000000000402'::UUID,
  '{
    "Challenge": "Making complex data understandable for non-experts",
    "Solution Approach": "Implemented multi-layer explanation outputs with summaries and numeric explanations",
    "Severity": "High",
    "Status": "Resolved",
    "Impact Area": "Usability"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000623'::UUID,
  '00000000-0000-0000-0000-000000000402'::UUID,
  '{
    "Challenge": "Building trust with non-technical users",
    "Solution Approach": "Added visible citations, limitations, and consistent refusal behavior",
    "Severity": "High",
    "Status": "Resolved",
    "Impact Area": "Trust"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: KPIs and Outcomes
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000630'::UUID,
  '00000000-0000-0000-0000-000000000403'::UUID,
  '{
    "Metric Name": "Engagement increase vs static dashboards",
    "Category": "Adoption",
    "Value": "3x increase",
    "Impact Level": "High",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000631'::UUID,
  '00000000-0000-0000-0000-000000000403'::UUID,
  '{
    "Metric Name": "Session depth improvement",
    "Category": "Adoption",
    "Value": "2.5x increase",
    "Impact Level": "High",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000632'::UUID,
  '00000000-0000-0000-0000-000000000403'::UUID,
  '{
    "Metric Name": "Reduction in time to find diabetes statistics",
    "Category": "Performance",
    "Value": "60 percent reduction",
    "Impact Level": "Critical",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000633'::UUID,
  '00000000-0000-0000-0000-000000000403'::UUID,
  '{
    "Metric Name": "Factual accuracy rate",
    "Category": "Trust",
    "Value": "Greater than 95 percent accuracy",
    "Impact Level": "Critical",
    "Status": "Maintained"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000634'::UUID,
  '00000000-0000-0000-0000-000000000403'::UUID,
  '{
    "Metric Name": "Sensitive data exposure incidents",
    "Category": "Safety",
    "Value": "Zero incidents",
    "Impact Level": "Critical",
    "Status": "Maintained"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: owner@talomdiabetes.ai
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000003' with the actual auth.users.id
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
--    - Workspace: GRACE AI Platform - Healthcare AI
--    - Project: Tal om Diabetes Conversational Health Data Platform
--    - 4 Sheets: Core Product Ownership, Architecture Tasks, Challenges, KPIs
--    - 19 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
