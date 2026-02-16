-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR RIGSHOSPITALET AI VIRTUAL ASSISTANT
-- Healthcare AI Projects Workspace
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000008'::UUID;
  v_email TEXT := 'ai.engineer@example.com';
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
      '{"name": "Senior AI Engineer"}'::jsonb,
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
    'Senior AI Engineer',
    v_email,
    '#8b5cf6'
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
('00000000-0000-0000-0000-000000000700'::UUID, 'Healthcare AI Projects Workspace', '00000000-0000-0000-0000-000000000008'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000700'::UUID,
  '00000000-0000-0000-0000-000000000008'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000800'::UUID,
  '00000000-0000-0000-0000-000000000700'::UUID,
  '00000000-0000-0000-0000-000000000008'::UUID,
  'Rigshospitalet AI Virtual Assistant',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000800'::UUID,
  '00000000-0000-0000-0000-000000000008'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000900'::UUID, '00000000-0000-0000-0000-000000000800'::UUID, 'Project Objectives'),
('00000000-0000-0000-0000-000000000901'::UUID, '00000000-0000-0000-0000-000000000800'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000000902'::UUID, '00000000-0000-0000-0000-000000000800'::UUID, 'KPIs and Outcomes')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000900'::UUID
WHERE id = '00000000-0000-0000-0000-000000000800'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Project Objectives
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001000'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Objective Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001001'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Description', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001002'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Category', 'dropdown', 300, 3, '["Clinical Safety", "Operational Efficiency", "Patient Experience", "Trust and Governance"]'::jsonb),
('00000000-0000-0000-0000-000000001003'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Priority', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001004'::UUID, '00000000-0000-0000-0000-000000000900'::UUID, 'Owner', 'text', 200, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001010'::UUID, '00000000-0000-0000-0000-000000000901'::UUID, 'Challenge Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001011'::UUID, '00000000-0000-0000-0000-000000000901'::UUID, 'Challenge Description', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001012'::UUID, '00000000-0000-0000-0000-000000000901'::UUID, 'Solution Implemented', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001013'::UUID, '00000000-0000-0000-0000-000000000901'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001014'::UUID, '00000000-0000-0000-0000-000000000901'::UUID, 'Status', 'dropdown', 150, 5, '["Resolved", "In Progress", "Planned"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: KPIs and Outcomes
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001020'::UUID, '00000000-0000-0000-0000-000000000902'::UUID, 'KPI Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001021'::UUID, '00000000-0000-0000-0000-000000000902'::UUID, 'Metric Description', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001022'::UUID, '00000000-0000-0000-0000-000000000902'::UUID, 'Category', 'dropdown', 250, 3, '["Patient Experience", "Operational Efficiency", "AI Quality", "Adoption", "Strategic Outcome"]'::jsonb),
('00000000-0000-0000-0000-000000001023'::UUID, '00000000-0000-0000-0000-000000000902'::UUID, 'Result', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000001024'::UUID, '00000000-0000-0000-0000-000000000902'::UUID, 'Status', 'dropdown', 150, 5, '["Achieved", "Exceeded", "In Progress"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Project Objectives
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001100'::UUID,
  '00000000-0000-0000-0000-000000000900'::UUID,
  '{
    "Objective Name": "Improve Patient Understanding",
    "Description": "Provide accurate preoperative thyroid surgery preparation information",
    "Category": "Patient Experience",
    "Priority": "High",
    "Owner": "Senior AI Engineer"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001101'::UUID,
  '00000000-0000-0000-0000-000000000900'::UUID,
  '{
    "Objective Name": "Reduce Staff Workload",
    "Description": "Decrease repetitive patient information calls and administrative workload",
    "Category": "Operational Efficiency",
    "Priority": "High",
    "Owner": "Senior AI Engineer"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001102'::UUID,
  '00000000-0000-0000-0000-000000000900'::UUID,
  '{
    "Objective Name": "Ensure Clinical Safety",
    "Description": "Restrict assistant responses to approved clinical content only",
    "Category": "Clinical Safety",
    "Priority": "High",
    "Owner": "Senior AI Engineer"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001103'::UUID,
  '00000000-0000-0000-0000-000000000900'::UUID,
  '{
    "Objective Name": "Establish AI Governance",
    "Description": "Implement traceability, logging, and auditability standards",
    "Category": "Trust and Governance",
    "Priority": "High",
    "Owner": "Senior AI Engineer"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001104'::UUID,
  '00000000-0000-0000-0000-000000000900'::UUID,
  '{
    "Objective Name": "Increase Patient Trust",
    "Description": "Design assistant communication for clarity, accuracy, and reassurance",
    "Category": "Patient Experience",
    "Priority": "Medium",
    "Owner": "Senior AI Engineer"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001110'::UUID,
  '00000000-0000-0000-0000-000000000901'::UUID,
  '{
    "Challenge Name": "Prevent Medical Hallucinations",
    "Challenge Description": "AI generating medically unsafe or incorrect responses",
    "Solution Implemented": "Implemented strict retrieval-only architecture and source citation",
    "Impact Level": "High",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001111'::UUID,
  '00000000-0000-0000-0000-000000000901'::UUID,
  '{
    "Challenge Name": "Balance Accuracy and Comprehension",
    "Challenge Description": "Patients need understandable explanations while maintaining medical accuracy",
    "Solution Implemented": "Created multi-layer answer structure with summaries and references",
    "Impact Level": "High",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001112'::UUID,
  '00000000-0000-0000-0000-000000000901'::UUID,
  '{
    "Challenge Name": "Clinical Staff Trust",
    "Challenge Description": "Surgeons needed confidence in AI assistant reliability",
    "Solution Implemented": "Implemented surgeon-in-the-loop testing and answer comparisons",
    "Impact Level": "High",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001113'::UUID,
  '00000000-0000-0000-0000-000000000901'::UUID,
  '{
    "Challenge Name": "Patient Privacy Protection",
    "Challenge Description": "Prevent exposure or ingestion of patient personal data",
    "Solution Implemented": "Implemented PII detection, removal, and audit logging",
    "Impact Level": "High",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001114'::UUID,
  '00000000-0000-0000-0000-000000000901'::UUID,
  '{
    "Challenge Name": "Deployment vs Validation Speed",
    "Challenge Description": "Clinical validation slowed deployment timeline",
    "Solution Implemented": "Conducted multiple clinical review cycles before release",
    "Impact Level": "Medium",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: KPIs and Outcomes
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001120'::UUID,
  '00000000-0000-0000-0000-000000000902'::UUID,
  '{
    "KPI Name": "Clinical Accuracy Rate",
    "Metric Description": "Percentage of responses clinically accurate",
    "Category": "AI Quality",
    "Result": "Greater than 95 percent accuracy",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001121'::UUID,
  '00000000-0000-0000-0000-000000000902'::UUID,
  '{
    "KPI Name": "Hallucination Rate",
    "Metric Description": "Frequency of unsupported or fabricated responses",
    "Category": "AI Quality",
    "Result": "Near-zero hallucination rate",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001122'::UUID,
  '00000000-0000-0000-0000-000000000902'::UUID,
  '{
    "KPI Name": "Staff Call Reduction",
    "Metric Description": "Decrease in preoperative information calls",
    "Category": "Operational Efficiency",
    "Result": "Significant reduction observed",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001123'::UUID,
  '00000000-0000-0000-0000-000000000902'::UUID,
  '{
    "KPI Name": "Patient Preparedness Improvement",
    "Metric Description": "Increase in patient confidence and preparedness",
    "Category": "Patient Experience",
    "Result": "Improved patient-reported confidence",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001124'::UUID,
  '00000000-0000-0000-0000-000000000902'::UUID,
  '{
    "KPI Name": "Clinical Adoption",
    "Metric Description": "Usage and endorsement by clinical staff",
    "Category": "Adoption",
    "Result": "High clinical staff support and usage",
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
--      - Email: ai.engineer@example.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000008' with the actual auth.users.id
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
--    - Workspace: Healthcare AI Projects Workspace
--    - Project: Rigshospitalet AI Virtual Assistant
--    - 3 Sheets: Project Objectives, Challenges, KPIs
--    - 15 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
