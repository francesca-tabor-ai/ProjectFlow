-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR PLESNER ENTERPRISE AI
-- Enterprise LLM Assistant and Responsible AI Platform Rollout
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000010'::UUID;
  v_email TEXT := 'ai.lead@plesner.com';
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
      '{"name": "Enterprise AI Lead"}'::jsonb,
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
    'Enterprise AI Lead',
    v_email,
    '#14b8a6'
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
('00000000-0000-0000-0000-000000000900'::UUID, 'Plesner Enterprise AI Transformation', '00000000-0000-0000-0000-000000000010'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000900'::UUID,
  '00000000-0000-0000-0000-000000000010'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001000'::UUID,
  '00000000-0000-0000-0000-000000000900'::UUID,
  '00000000-0000-0000-0000-000000000010'::UUID,
  'Enterprise LLM Assistant and Responsible AI Platform Rollout',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001000'::UUID,
  '00000000-0000-0000-0000-000000000010'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001100'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Strategic Objectives'),
('00000000-0000-0000-0000-000000001101'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Trade-Off Decisions'),
('00000000-0000-0000-0000-000000001102'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001103'::UUID, '00000000-0000-0000-0000-000000001000'::UUID, 'Achievements and KPIs')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001100'::UUID
WHERE id = '00000000-0000-0000-0000-000000001000'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Strategic Objectives
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001200'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Objective Name', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001201'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Category', 'dropdown', 200, 2, '["Governance", "Adoption", "Architecture", "Compliance", "Platform"]'::jsonb),
('00000000-0000-0000-0000-000000001202'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Priority', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001203'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Status', 'dropdown', 150, 4, '["Completed", "In Progress", "Planned"]'::jsonb),
('00000000-0000-0000-0000-000000001204'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Impact Description', 'text', 400, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Trade-Off Decisions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001210'::UUID, '00000000-0000-0000-0000-000000001101'::UUID, 'Decision Title', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001211'::UUID, '00000000-0000-0000-0000-000000001101'::UUID, 'Option Chosen', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000001212'::UUID, '00000000-0000-0000-0000-000000001101'::UUID, 'Benefit', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000001213'::UUID, '00000000-0000-0000-0000-000000001101'::UUID, 'Sacrifice', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000001214'::UUID, '00000000-0000-0000-0000-000000001101'::UUID, 'Decision Impact', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001220'::UUID, '00000000-0000-0000-0000-000000001102'::UUID, 'Challenge Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001221'::UUID, '00000000-0000-0000-0000-000000001102'::UUID, 'Risk Level', 'dropdown', 150, 2, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001222'::UUID, '00000000-0000-0000-0000-000000001102'::UUID, 'Solution Implemented', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001223'::UUID, '00000000-0000-0000-0000-000000001102'::UUID, 'Outcome', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000001224'::UUID, '00000000-0000-0000-0000-000000001102'::UUID, 'Status', 'dropdown', 150, 5, '["Resolved", "Monitoring", "Ongoing"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001230'::UUID, '00000000-0000-0000-0000-000000001103'::UUID, 'Metric Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001231'::UUID, '00000000-0000-0000-0000-000000001103'::UUID, 'Category', 'dropdown', 200, 2, '["Adoption", "Productivity", "Risk", "Platform"]'::jsonb),
('00000000-0000-0000-0000-000000001232'::UUID, '00000000-0000-0000-0000-000000001103'::UUID, 'Result', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000001233'::UUID, '00000000-0000-0000-0000-000000001103'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001234'::UUID, '00000000-0000-0000-0000-000000001103'::UUID, 'Measured Outcome', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Strategic Objectives
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001300'::UUID,
  '00000000-0000-0000-0000-000000001100'::UUID,
  '{
    "Objective Name": "Enterprise AI Operating Model",
    "Category": "Governance",
    "Priority": "High",
    "Status": "Completed",
    "Impact Description": "Established controlled AI environment for enterprise usage"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001301'::UUID,
  '00000000-0000-0000-0000-000000001100'::UUID,
  '{
    "Objective Name": "Multi-Model Platform Architecture",
    "Category": "Architecture",
    "Priority": "High",
    "Status": "Completed",
    "Impact Description": "Enabled flexibility and vendor independence"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001302'::UUID,
  '00000000-0000-0000-0000-000000001100'::UUID,
  '{
    "Objective Name": "LLM Governance Framework",
    "Category": "Governance",
    "Priority": "High",
    "Status": "Completed",
    "Impact Description": "Defined policies for safe and compliant model usage"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001303'::UUID,
  '00000000-0000-0000-0000-000000001100'::UUID,
  '{
    "Objective Name": "Employee Adoption and Training",
    "Category": "Adoption",
    "Priority": "High",
    "Status": "Completed",
    "Impact Description": "Improved trust and confidence in AI tools"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001304'::UUID,
  '00000000-0000-0000-0000-000000001100'::UUID,
  '{
    "Objective Name": "Risk and Compliance Alignment",
    "Category": "Compliance",
    "Priority": "High",
    "Status": "Completed",
    "Impact Description": "Ensured secure and compliant enterprise AI deployment"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Trade-Off Decisions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001310'::UUID,
  '00000000-0000-0000-0000-000000001101'::UUID,
  '{
    "Decision Title": "Single Model vs Multi-Model Architecture",
    "Option Chosen": "Multi-Model Architecture",
    "Benefit": "Vendor resilience and future adaptability",
    "Sacrifice": "Higher platform complexity",
    "Decision Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001311'::UUID,
  '00000000-0000-0000-0000-000000001101'::UUID,
  '{
    "Decision Title": "Open Access vs Controlled Access",
    "Option Chosen": "Controlled Access",
    "Benefit": "Increased trust and safe adoption",
    "Sacrifice": "Reduced flexibility for users",
    "Decision Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001312'::UUID,
  '00000000-0000-0000-0000-000000001101'::UUID,
  '{
    "Decision Title": "Fast Adoption vs Safe Adoption",
    "Option Chosen": "Safe Adoption",
    "Benefit": "Higher long-term trust and usage",
    "Sacrifice": "Slower initial rollout",
    "Decision Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001320'::UUID,
  '00000000-0000-0000-0000-000000001102'::UUID,
  '{
    "Challenge Name": "Lawyer Trust and Data Leakage Risk",
    "Risk Level": "High",
    "Solution Implemented": "Implemented data isolation and audit trails",
    "Outcome": "Increased user confidence",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001321'::UUID,
  '00000000-0000-0000-0000-000000001102'::UUID,
  '{
    "Challenge Name": "Hallucinated Legal Citations",
    "Risk Level": "High",
    "Solution Implemented": "Implemented RAG workflows and citation enforcement",
    "Outcome": "Improved factual reliability",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001322'::UUID,
  '00000000-0000-0000-0000-000000001102'::UUID,
  '{
    "Challenge Name": "Rapid Vendor Landscape Changes",
    "Risk Level": "Medium",
    "Solution Implemented": "Built model abstraction layer",
    "Outcome": "Improved platform adaptability",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001323'::UUID,
  '00000000-0000-0000-0000-000000001102'::UUID,
  '{
    "Challenge Name": "Shadow AI Usage",
    "Risk Level": "High",
    "Solution Implemented": "Provided internal AI alternative and monitoring",
    "Outcome": "Reduced external tool usage",
    "Status": "Monitoring"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001330'::UUID,
  '00000000-0000-0000-0000-000000001103'::UUID,
  '{
    "Metric Name": "Internal Adoption Rate",
    "Category": "Adoption",
    "Result": "High adoption across legal teams",
    "Impact Level": "High",
    "Measured Outcome": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001331'::UUID,
  '00000000-0000-0000-0000-000000001103'::UUID,
  '{
    "Metric Name": "Document Drafting Time Reduction",
    "Category": "Productivity",
    "Result": "Reduced drafting time significantly",
    "Impact Level": "High",
    "Measured Outcome": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001332'::UUID,
  '00000000-0000-0000-0000-000000001103'::UUID,
  '{
    "Metric Name": "Client Data Leakage Incidents",
    "Category": "Risk",
    "Result": "Zero incidents reported",
    "Impact Level": "High",
    "Measured Outcome": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001333'::UUID,
  '00000000-0000-0000-0000-000000001103'::UUID,
  '{
    "Metric Name": "Foundation for Future AI Automation",
    "Category": "Platform",
    "Result": "Established reusable AI governance and platform",
    "Impact Level": "High",
    "Measured Outcome": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: ai.lead@plesner.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000010' with the actual auth.users.id
--
-- 2. Data Structure:
--    - Uses row_data JSONB (not cells table) - matches our implementation
--    - Column values are stored as JSON keys matching column titles
--    - Dependencies array tracks task dependencies (empty for this dataset)
--    - Note: Measured Outcome is stored as boolean in JSONB
--
-- 3. To Use:
--    - Run this migration after 001_initial_schema.sql
--    - Update the user UUID to match your actual auth.users.id
--    - Or create the user first, then update this migration
--
-- 4. Project Details:
--    - Workspace: Plesner Enterprise AI Transformation
--    - Project: Enterprise LLM Assistant and Responsible AI Platform Rollout
--    - 4 Sheets: Strategic Objectives, Trade-Offs, Challenges, KPIs
--    - 16 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
