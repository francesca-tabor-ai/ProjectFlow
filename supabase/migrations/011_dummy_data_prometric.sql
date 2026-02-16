-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR PROMETRIC AI
-- AI-Powered Proctoring and Responsible AI Monitoring
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000009'::UUID;
  v_email TEXT := 'owner@prometric-ai.com';
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
      '{"name": "AI Product Owner"}'::jsonb,
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
    'AI Product Owner',
    v_email,
    '#ef4444'
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
('00000000-0000-0000-0000-000000000800'::UUID, 'Prometric Responsible AI Workspace', '00000000-0000-0000-0000-000000000009'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000800'::UUID,
  '00000000-0000-0000-0000-000000000009'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000900'::UUID,
  '00000000-0000-0000-0000-000000000800'::UUID,
  '00000000-0000-0000-0000-000000000009'::UUID,
  'AI-Powered Proctoring and Responsible AI Monitoring',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000900'::UUID,
  '00000000-0000-0000-0000-000000000009'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001000'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Core Responsibilities'),
('00000000-0000-0000-0000-000000001001'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001002'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Achievements and KPIs')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001000'::UUID
WHERE id = '00000000-0000-0000-0000-000000000900'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Core Responsibilities
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001100'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Area', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000001101'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Responsibility', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001102'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Owner', 'dropdown', 150, 3, '["Self", "Team"]'::jsonb),
('00000000-0000-0000-0000-000000001103'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Impact', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000001104'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Priority', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001110'::UUID, '00000000-0000-0000-0000-000000001001'::UUID, 'Challenge', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001111'::UUID, '00000000-0000-0000-0000-000000001001'::UUID, 'Description', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001112'::UUID, '00000000-0000-0000-0000-000000001001'::UUID, 'Solution', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001113'::UUID, '00000000-0000-0000-0000-000000001001'::UUID, 'Impact', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000001114'::UUID, '00000000-0000-0000-0000-000000001001'::UUID, 'Status', 'dropdown', 150, 5, '["Resolved", "Improved", "Monitoring"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001120'::UUID, '00000000-0000-0000-0000-000000001002'::UUID, 'Category', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000001121'::UUID, '00000000-0000-0000-0000-000000001002'::UUID, 'Metric', 'text', 350, 2, NULL),
('00000000-0000-0000-0000-000000001122'::UUID, '00000000-0000-0000-0000-000000001002'::UUID, 'Improvement', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000001123'::UUID, '00000000-0000-0000-0000-000000001002'::UUID, 'Business Impact', 'text', 350, 4, NULL),
('00000000-0000-0000-0000-000000001124'::UUID, '00000000-0000-0000-0000-000000001002'::UUID, 'Success Level', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Core Responsibilities
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001200'::UUID,
  '00000000-0000-0000-0000-000000001000'::UUID,
  '{
    "Area": "Product Definition",
    "Responsibility": "Defined AI-assisted flagging boundaries ensuring human proctors retain final decision authority",
    "Owner": "Self",
    "Impact": "Ensured fairness, legal defensibility, and trust",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001201'::UUID,
  '00000000-0000-0000-0000-000000001000'::UUID,
  '{
    "Area": "Responsible AI Governance",
    "Responsibility": "Designed governance covering explainability, audit trails, bias monitoring, and retention rules",
    "Owner": "Self",
    "Impact": "Ensured regulatory compliance and auditability",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001202'::UUID,
  '00000000-0000-0000-0000-000000001000'::UUID,
  '{
    "Area": "AI Evaluation Strategy",
    "Responsibility": "Defined performance metrics for detection accuracy, fairness, and operational efficiency",
    "Owner": "Self",
    "Impact": "Improved measurable AI performance and fairness",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001203'::UUID,
  '00000000-0000-0000-0000-000000001000'::UUID,
  '{
    "Area": "Model Development",
    "Responsibility": "Developed computer vision models for suspicious behavior and identity verification",
    "Owner": "Team",
    "Impact": "Improved suspicious behavior detection accuracy",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001204'::UUID,
  '00000000-0000-0000-0000-000000001000'::UUID,
  '{
    "Area": "Infrastructure and Platform",
    "Responsibility": "Built real-time video inference infrastructure and secure streaming pipelines",
    "Owner": "Team",
    "Impact": "Enabled scalable global proctoring",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001210'::UUID,
  '00000000-0000-0000-0000-000000001001'::UUID,
  '{
    "Challenge": "High False Positive Rates",
    "Description": "Early models flagged too many legitimate candidates incorrectly",
    "Solution": "Implemented multi-signal confirmation and human-reviewed training loop",
    "Impact": "Improved precision and reduced unnecessary candidate flags",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001211'::UUID,
  '00000000-0000-0000-0000-000000001001'::UUID,
  '{
    "Challenge": "Global Fairness and Bias Risk",
    "Description": "Risk of bias across demographics and geographic regions",
    "Solution": "Balanced datasets and implemented continuous fairness monitoring dashboards",
    "Impact": "Improved fairness and regulatory compliance",
    "Status": "Monitoring"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001212'::UUID,
  '00000000-0000-0000-0000-000000001001'::UUID,
  '{
    "Challenge": "Real-Time Processing at Scale",
    "Description": "Need to process global video streams reliably and quickly",
    "Solution": "Implemented edge inference optimization and regional routing",
    "Impact": "Improved real-time reliability and system scalability",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001213'::UUID,
  '00000000-0000-0000-0000-000000001001'::UUID,
  '{
    "Challenge": "Sensitive Data and Privacy",
    "Description": "Handling highly sensitive candidate video and identity data",
    "Solution": "Implemented encryption, strict retention policies, and anonymized training",
    "Impact": "Ensured privacy protection and regulatory compliance",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001220'::UUID,
  '00000000-0000-0000-0000-000000001002'::UUID,
  '{
    "Category": "Detection Quality",
    "Metric": "Reduced false positive suspicious behavior flags",
    "Improvement": "Significant reduction in false positives",
    "Business Impact": "Improved detection trust and proctor efficiency",
    "Success Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001221'::UUID,
  '00000000-0000-0000-0000-000000001002'::UUID,
  '{
    "Category": "Operational Efficiency",
    "Metric": "Increased candidates monitored per proctor",
    "Improvement": "Higher monitoring capacity without staffing increase",
    "Business Impact": "Improved operational scalability",
    "Success Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001222'::UUID,
  '00000000-0000-0000-0000-000000001002'::UUID,
  '{
    "Category": "Candidate Experience",
    "Metric": "Reduced unnecessary candidate interruptions",
    "Improvement": "Improved candidate satisfaction",
    "Business Impact": "Improved candidate trust and experience",
    "Success Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001223'::UUID,
  '00000000-0000-0000-0000-000000001002'::UUID,
  '{
    "Category": "Platform Scalability",
    "Metric": "Supported growing global exam volume",
    "Improvement": "Handled scale without proportional staffing increase",
    "Business Impact": "Enabled global platform growth",
    "Success Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001224'::UUID,
  '00000000-0000-0000-0000-000000001002'::UUID,
  '{
    "Category": "Governance and Compliance",
    "Metric": "Implemented full audit traceability",
    "Improvement": "Achieved regulatory compliance across regions",
    "Business Impact": "Enabled trusted and explainable AI deployment",
    "Success Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: owner@prometric-ai.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000009' with the actual auth.users.id
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
--    - Workspace: Prometric Responsible AI Workspace
--    - Project: AI-Powered Proctoring and Responsible AI Monitoring
--    - 3 Sheets: Core Responsibilities, Challenges, KPIs
--    - 14 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
