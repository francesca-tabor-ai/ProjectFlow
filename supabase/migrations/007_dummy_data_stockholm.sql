-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR STOCKHOLM COUNTY SOCIAL SERVICES AI
-- AI-Assisted Case Prioritization Project
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000005'::UUID;
  v_email TEXT := 'owner@stockholm-ai-project.com';
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
      '{"name": "AI Governance Lead"}'::jsonb,
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
    'AI Governance Lead',
    v_email,
    '#10b981'
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
('00000000-0000-0000-0000-000000000400'::UUID, 'Stockholm County Social Services AI Workspace', '00000000-0000-0000-0000-000000000005'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000400'::UUID,
  '00000000-0000-0000-0000-000000000005'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000500'::UUID,
  '00000000-0000-0000-0000-000000000400'::UUID,
  '00000000-0000-0000-0000-000000000005'::UUID,
  'AI-Assisted Case Prioritization',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000500'::UUID,
  '00000000-0000-0000-0000-000000000005'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000600'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'Project Responsibilities'),
('00000000-0000-0000-0000-000000000601'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000000602'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'KPIs and Outcomes')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000600'::UUID
WHERE id = '00000000-0000-0000-0000-000000000500'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Project Responsibilities
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000700'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Responsibility Area', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000701'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Owner', 'dropdown', 150, 2, '["Personal", "Team"]'::jsonb),
('00000000-0000-0000-0000-000000000702'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Category', 'dropdown', 250, 3, '["Governance", "Data Science", "Platform Engineering", "Integration", "Change Management"]'::jsonb),
('00000000-0000-0000-0000-000000000703'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Description', 'text', 400, 4, NULL),
('00000000-0000-0000-0000-000000000704'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Priority', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000710'::UUID, '00000000-0000-0000-0000-000000000601'::UUID, 'Challenge', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000711'::UUID, '00000000-0000-0000-0000-000000000601'::UUID, 'Impact Level', 'dropdown', 150, 2, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000712'::UUID, '00000000-0000-0000-0000-000000000601'::UUID, 'Solution', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000000713'::UUID, '00000000-0000-0000-0000-000000000601'::UUID, 'Category', 'dropdown', 200, 4, '["Technical", "Governance", "Organizational", "Data Quality"]'::jsonb),
('00000000-0000-0000-0000-000000000714'::UUID, '00000000-0000-0000-0000-000000000601'::UUID, 'Resolved', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: KPIs and Outcomes
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000720'::UUID, '00000000-0000-0000-0000-000000000602'::UUID, 'KPI Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000721'::UUID, '00000000-0000-0000-0000-000000000602'::UUID, 'Category', 'dropdown', 200, 2, '["Efficiency", "Citizen Impact", "AI Quality", "Adoption"]'::jsonb),
('00000000-0000-0000-0000-000000000722'::UUID, '00000000-0000-0000-0000-000000000602'::UUID, 'Metric Value', 'text', 200, 3, NULL),
('00000000-0000-0000-0000-000000000723'::UUID, '00000000-0000-0000-0000-000000000602'::UUID, 'Measurement Period', 'text', 200, 4, NULL),
('00000000-0000-0000-0000-000000000724'::UUID, '00000000-0000-0000-0000-000000000602'::UUID, 'Status', 'dropdown', 150, 5, '["Achieved", "In Progress", "At Risk"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Project Responsibilities
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000800'::UUID,
  '00000000-0000-0000-0000-000000000600'::UUID,
  '{
    "Responsibility Area": "Use Case Definition and Risk Boundary Setting",
    "Owner": "Personal",
    "Category": "Governance",
    "Description": "Defined prioritization-only support and prevented automated decision making",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000801'::UUID,
  '00000000-0000-0000-0000-000000000600'::UUID,
  '{
    "Responsibility Area": "AI Governance and Compliance Design",
    "Owner": "Personal",
    "Category": "Governance",
    "Description": "Defined audit requirements, explainability standards, and acceptable model behaviors",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000802'::UUID,
  '00000000-0000-0000-0000-000000000600'::UUID,
  '{
    "Responsibility Area": "Model Training and Validation",
    "Owner": "Team",
    "Category": "Data Science",
    "Description": "Developed classification models, feature engineering, and bias testing",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000803'::UUID,
  '00000000-0000-0000-0000-000000000600'::UUID,
  '{
    "Responsibility Area": "Platform Deployment and Audit Logging",
    "Owner": "Team",
    "Category": "Platform Engineering",
    "Description": "Deployed GRACE platform and implemented audit logging and version tracking",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000804'::UUID,
  '00000000-0000-0000-0000-000000000600'::UUID,
  '{
    "Responsibility Area": "Staff Onboarding and Change Management",
    "Owner": "Team",
    "Category": "Change Management",
    "Description": "Civil servant onboarding, training, and feedback loop implementation",
    "Priority": "Medium"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000810'::UUID,
  '00000000-0000-0000-0000-000000000601'::UUID,
  '{
    "Challenge": "Staff fear of algorithmic bias or replacement",
    "Impact Level": "High",
    "Solution": "Implemented transparent model explanations and human override controls",
    "Category": "Organizational",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000811'::UUID,
  '00000000-0000-0000-0000-000000000601'::UUID,
  '{
    "Challenge": "Historical data quality and bias issues",
    "Impact Level": "High",
    "Solution": "Introduced data quality scoring, bias detection, and human review datasets",
    "Category": "Data Quality",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000812'::UUID,
  '00000000-0000-0000-0000-000000000601'::UUID,
  '{
    "Challenge": "Governance of model lifecycle and evolution",
    "Impact Level": "High",
    "Solution": "Implemented audit trail, dataset versioning, and performance tracking",
    "Category": "Governance",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000813'::UUID,
  '00000000-0000-0000-0000-000000000601'::UUID,
  '{
    "Challenge": "Integration with legacy case management systems",
    "Impact Level": "Medium",
    "Solution": "Developed API abstraction layer and event-driven scoring architecture",
    "Category": "Technical",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000814'::UUID,
  '00000000-0000-0000-0000-000000000601'::UUID,
  '{
    "Challenge": "Privacy risks from PII in training data",
    "Impact Level": "High",
    "Solution": "Implemented PII detection, redaction, and privacy-safe pipelines",
    "Category": "Governance",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: KPIs and Outcomes
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000820'::UUID,
  '00000000-0000-0000-0000-000000000602'::UUID,
  '{
    "KPI Name": "Manual Case Triage Time Reduction",
    "Category": "Efficiency",
    "Metric Value": "40 percent reduction",
    "Measurement Period": "Post deployment",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000821'::UUID,
  '00000000-0000-0000-0000-000000000602'::UUID,
  '{
    "KPI Name": "Increase in Cases Assessed Per Staff Member",
    "Category": "Efficiency",
    "Metric Value": "30 percent increase",
    "Measurement Period": "Post deployment",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000822'::UUID,
  '00000000-0000-0000-0000-000000000602'::UUID,
  '{
    "KPI Name": "Reduction in Time to First Action for High Priority Cases",
    "Category": "Citizen Impact",
    "Metric Value": "25 percent reduction",
    "Measurement Period": "Post deployment",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000823'::UUID,
  '00000000-0000-0000-0000-000000000602'::UUID,
  '{
    "KPI Name": "Classification Precision for High Risk Cases",
    "Category": "AI Quality",
    "Metric Value": "92 percent precision",
    "Measurement Period": "Model evaluation period",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000824'::UUID,
  '00000000-0000-0000-0000-000000000602'::UUID,
  '{
    "KPI Name": "Staff Active Usage Rate",
    "Category": "Adoption",
    "Metric Value": "80 percent usage within six months",
    "Measurement Period": "First six months",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: owner@stockholm-ai-project.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000005' with the actual auth.users.id
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
--    - Workspace: Stockholm County Social Services AI Workspace
--    - Project: AI-Assisted Case Prioritization
--    - 3 Sheets: Project Responsibilities, Challenges, KPIs
--    - 15 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
