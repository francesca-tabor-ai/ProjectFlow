-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR LIF2.0 REAL-TIME COVID INTELLIGENCE PLATFORM
-- LIF2.0 Real-Time Intelligence Workspace
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000004'::UUID;
  v_email TEXT := 'eureka.owner@example.com';
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
      '{"name": "Eureka Project Owner"}'::jsonb,
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
    'Eureka Project Owner',
    v_email,
    '#f97316'
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
('00000000-0000-0000-0000-000000000300'::UUID, 'LIF2.0 Real-Time Intelligence Workspace', '00000000-0000-0000-0000-000000000004'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000300'::UUID,
  '00000000-0000-0000-0000-000000000004'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000400'::UUID,
  '00000000-0000-0000-0000-000000000300'::UUID,
  '00000000-0000-0000-0000-000000000004'::UUID,
  'LIF2.0 Real-Time COVID Intelligence Platform',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000400'::UUID,
  '00000000-0000-0000-0000-000000000004'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000500'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Core Responsibilities'),
('00000000-0000-0000-0000-000000000501'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000000502'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Achievements and KPIs'),
('00000000-0000-0000-0000-000000000503'::UUID, '00000000-0000-0000-0000-000000000400'::UUID, 'Strategic Trade-Offs')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000500'::UUID
WHERE id = '00000000-0000-0000-0000-000000000400'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Core Responsibilities
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000600'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'Responsibility Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000601'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'Category', 'dropdown', 250, 2, '["Product Strategy", "Data Trust", "AI Evaluation", "Delivery Alignment"]'::jsonb),
('00000000-0000-0000-0000-000000000602'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'Owner', 'dropdown', 150, 3, '["Self", "Team", "Shared"]'::jsonb),
('00000000-0000-0000-0000-000000000603'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000604'::UUID, '00000000-0000-0000-0000-000000000500'::UUID, 'Status', 'dropdown', 150, 5, '["Completed", "In Progress", "Planned"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000610'::UUID, '00000000-0000-0000-0000-000000000501'::UUID, 'Challenge Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000611'::UUID, '00000000-0000-0000-0000-000000000501'::UUID, 'Challenge Category', 'dropdown', 250, 2, '["Data Integration", "Privacy", "AI Reliability", "Data Standards"]'::jsonb),
('00000000-0000-0000-0000-000000000612'::UUID, '00000000-0000-0000-0000-000000000501'::UUID, 'Solution Implemented', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000000613'::UUID, '00000000-0000-0000-0000-000000000501'::UUID, 'Severity', 'dropdown', 150, 4, '["Critical", "High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000614'::UUID, '00000000-0000-0000-0000-000000000501'::UUID, 'Resolution Status', 'dropdown', 200, 5, '["Resolved", "Partially Resolved", "Ongoing"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000620'::UUID, '00000000-0000-0000-0000-000000000502'::UUID, 'KPI Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000621'::UUID, '00000000-0000-0000-0000-000000000502'::UUID, 'Category', 'dropdown', 200, 2, '["Adoption", "Efficiency", "Data Quality", "Decision Impact"]'::jsonb),
('00000000-0000-0000-0000-000000000622'::UUID, '00000000-0000-0000-0000-000000000502'::UUID, 'Metric Value', 'text', 250, 3, NULL),
('00000000-0000-0000-0000-000000000623'::UUID, '00000000-0000-0000-0000-000000000502'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000624'::UUID, '00000000-0000-0000-0000-000000000502'::UUID, 'Validated', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Strategic Trade-Offs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000630'::UUID, '00000000-0000-0000-0000-000000000503'::UUID, 'Trade-Off Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000631'::UUID, '00000000-0000-0000-0000-000000000503'::UUID, 'Option Prioritized', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000000632'::UUID, '00000000-0000-0000-0000-000000000503'::UUID, 'Option Sacrificed', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000000633'::UUID, '00000000-0000-0000-0000-000000000503'::UUID, 'Reason', 'text', 350, 4, NULL),
('00000000-0000-0000-0000-000000000634'::UUID, '00000000-0000-0000-0000-000000000503'::UUID, 'Outcome', 'dropdown', 150, 5, '["Positive", "Neutral", "Negative"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Core Responsibilities
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000700'::UUID,
  '00000000-0000-0000-0000-000000000500'::UUID,
  '{
    "Responsibility Name": "Product Strategy and Use Case Definition",
    "Category": "Product Strategy",
    "Owner": "Self",
    "Impact Level": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000701'::UUID,
  '00000000-0000-0000-0000-000000000500'::UUID,
  '{
    "Responsibility Name": "Data Trust and Source Acceptance Framework",
    "Category": "Data Trust",
    "Owner": "Self",
    "Impact Level": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000702'::UUID,
  '00000000-0000-0000-0000-000000000500'::UUID,
  '{
    "Responsibility Name": "AI Evaluation and Insight Validation Strategy",
    "Category": "AI Evaluation",
    "Owner": "Self",
    "Impact Level": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000703'::UUID,
  '00000000-0000-0000-0000-000000000500'::UUID,
  '{
    "Responsibility Name": "Cross-Partner Delivery Alignment",
    "Category": "Delivery Alignment",
    "Owner": "Self",
    "Impact Level": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000710'::UUID,
  '00000000-0000-0000-0000-000000000501'::UUID,
  '{
    "Challenge Name": "Harmonizing Cross-Country Data Standards",
    "Challenge Category": "Data Standards",
    "Solution Implemented": "Canonical schema mapping and confidence weighting",
    "Severity": "Critical",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000711'::UUID,
  '00000000-0000-0000-0000-000000000501'::UUID,
  '{
    "Challenge Name": "Preventing Insight Drift From Mixed Data Types",
    "Challenge Category": "AI Reliability",
    "Solution Implemented": "Multi-layer signal classification and confidence scoring",
    "Severity": "High",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000712'::UUID,
  '00000000-0000-0000-0000-000000000501'::UUID,
  '{
    "Challenge Name": "GDPR and Cross-Border Privacy Compliance",
    "Challenge Category": "Privacy",
    "Solution Implemented": "Aggregation-first architecture and audit logging",
    "Severity": "Critical",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000713'::UUID,
  '00000000-0000-0000-0000-000000000501'::UUID,
  '{
    "Challenge Name": "Real-Time Insight Without False Alerts",
    "Challenge Category": "AI Reliability",
    "Solution Implemented": "Multi-source confirmation thresholds and human-in-loop review",
    "Severity": "Critical",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000720'::UUID,
  '00000000-0000-0000-0000-000000000502'::UUID,
  '{
    "KPI Name": "Insight Report Generation Speed",
    "Category": "Efficiency",
    "Metric Value": "Reduced from days to under one hour",
    "Impact Level": "High",
    "Validated": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000721'::UUID,
  '00000000-0000-0000-0000-000000000502'::UUID,
  '{
    "KPI Name": "Manual Data Aggregation Reduction",
    "Category": "Efficiency",
    "Metric Value": "Reduced workload by approximately 70 percent",
    "Impact Level": "High",
    "Validated": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000722'::UUID,
  '00000000-0000-0000-0000-000000000502'::UUID,
  '{
    "KPI Name": "Data Trust Score",
    "Category": "Data Quality",
    "Metric Value": "Maintained greater than 98 percent trust score",
    "Impact Level": "High",
    "Validated": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000723'::UUID,
  '00000000-0000-0000-0000-000000000502'::UUID,
  '{
    "KPI Name": "GDPR Compliance Incidents",
    "Category": "Data Quality",
    "Metric Value": "Zero incidents recorded",
    "Impact Level": "High",
    "Validated": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Strategic Trade-Offs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000730'::UUID,
  '00000000-0000-0000-0000-000000000503'::UUID,
  '{
    "Trade-Off Name": "Speed vs Data Trustworthiness",
    "Option Prioritized": "Trusted validated sources",
    "Option Sacrificed": "Maximum data coverage and early signal speed",
    "Reason": "Ensure regulatory acceptance and high confidence insights",
    "Outcome": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000731'::UUID,
  '00000000-0000-0000-0000-000000000503'::UUID,
  '{
    "Trade-Off Name": "Explainability vs Model Complexity",
    "Option Prioritized": "Interpretable statistical and hybrid AI models",
    "Option Sacrificed": "Fully opaque deep learning models",
    "Reason": "Improve stakeholder trust and regulatory approval",
    "Outcome": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000732'::UUID,
  '00000000-0000-0000-0000-000000000503'::UUID,
  '{
    "Trade-Off Name": "Centralized Platform vs Country Customization",
    "Option Prioritized": "Shared intelligence core with configurable layers",
    "Option Sacrificed": "Fully separate country-specific platforms",
    "Reason": "Enable scalability across EU partners",
    "Outcome": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: eureka.owner@example.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000004' with the actual auth.users.id
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
--    - Workspace: LIF2.0 Real-Time Intelligence Workspace
--    - Project: LIF2.0 Real-Time COVID Intelligence Platform
--    - 4 Sheets: Core Responsibilities, Challenges, Achievements, Trade-Offs
--    - 15 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
