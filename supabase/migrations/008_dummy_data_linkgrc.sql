-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR LINKGRC AI COMPLIANCE
-- AI-Powered Regulatory Monitoring Pipeline Project
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000006'::UUID;
  v_email TEXT := 'product.owner@linkgrc.com';
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
      '{"name": "Product Owner - Regulatory Monitoring"}'::jsonb,
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
    'Product Owner - Regulatory Monitoring',
    v_email,
    '#06b6d4'
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
('00000000-0000-0000-0000-000000000500'::UUID, 'LinkGRC AI Compliance Workspace', '00000000-0000-0000-0000-000000000006'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000500'::UUID,
  '00000000-0000-0000-0000-000000000006'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000600'::UUID,
  '00000000-0000-0000-0000-000000000500'::UUID,
  '00000000-0000-0000-0000-000000000006'::UUID,
  'AI-Powered Regulatory Monitoring Pipeline',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000600'::UUID,
  '00000000-0000-0000-0000-000000000006'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000700'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000000701'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Key Trade-Off Decisions'),
('00000000-0000-0000-0000-000000000702'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'KPIs and Outcomes'),
('00000000-0000-0000-0000-000000000703'::UUID, '00000000-0000-0000-0000-000000000600'::UUID, 'Team Responsibilities')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000700'::UUID
WHERE id = '00000000-0000-0000-0000-000000000600'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000800'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Challenge Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000801'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Description', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000000802'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Solution Approach', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000000803'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000804'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Resolved', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Key Trade-Off Decisions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000810'::UUID, '00000000-0000-0000-0000-000000000701'::UUID, 'Trade-Off Title', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000811'::UUID, '00000000-0000-0000-0000-000000000701'::UUID, 'Decision Made', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000000812'::UUID, '00000000-0000-0000-0000-000000000701'::UUID, 'Benefit', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000000813'::UUID, '00000000-0000-0000-0000-000000000701'::UUID, 'Sacrifice', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000000814'::UUID, '00000000-0000-0000-0000-000000000701'::UUID, 'Priority', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: KPIs and Outcomes
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000820'::UUID, '00000000-0000-0000-0000-000000000702'::UUID, 'Metric Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000821'::UUID, '00000000-0000-0000-0000-000000000702'::UUID, 'Category', 'dropdown', 200, 2, '["Efficiency", "Risk Reduction", "Reliability", "Customer Impact"]'::jsonb),
('00000000-0000-0000-0000-000000000822'::UUID, '00000000-0000-0000-0000-000000000702'::UUID, 'Result', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000000823'::UUID, '00000000-0000-0000-0000-000000000702'::UUID, 'Improvement Percentage', 'number', 200, 4, NULL),
('00000000-0000-0000-0000-000000000824'::UUID, '00000000-0000-0000-0000-000000000702'::UUID, 'Status', 'dropdown', 150, 5, '["Achieved", "In Progress", "Planned"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Team Responsibilities
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000830'::UUID, '00000000-0000-0000-0000-000000000703'::UUID, 'Team Name', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000000831'::UUID, '00000000-0000-0000-0000-000000000703'::UUID, 'Responsibility', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000000832'::UUID, '00000000-0000-0000-0000-000000000703'::UUID, 'Area Type', 'dropdown', 200, 3, '["Engineering", "ML", "Platform", "Domain"]'::jsonb),
('00000000-0000-0000-0000-000000000833'::UUID, '00000000-0000-0000-0000-000000000703'::UUID, 'Criticality', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000834'::UUID, '00000000-0000-0000-0000-000000000703'::UUID, 'Owned by Product', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000900'::UUID,
  '00000000-0000-0000-0000-000000000700'::UUID,
  '{
    "Challenge Name": "Website Structure Changes",
    "Description": "Scraping pipelines breaking due to source HTML changes",
    "Solution Approach": "Relative selector scraping and automated schema change alerts",
    "Impact Level": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000901'::UUID,
  '00000000-0000-0000-0000-000000000700'::UUID,
  '{
    "Challenge Name": "False Regulatory Signals",
    "Description": "Incorrect regulatory event classification risk",
    "Solution Approach": "Multi-stage filtering with classification and confidence scoring",
    "Impact Level": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000902'::UUID,
  '00000000-0000-0000-0000-000000000700'::UUID,
  '{
    "Challenge Name": "Multi-Jurisdiction Language Variation",
    "Description": "Regulatory differences across languages and jurisdictions",
    "Solution Approach": "Domain ontology and cross-lingual NLP normalization",
    "Impact Level": "Medium",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000903'::UUID,
  '00000000-0000-0000-0000-000000000700'::UUID,
  '{
    "Challenge Name": "Silent Pipeline Failures",
    "Description": "Missing regulatory data due to unnoticed failures",
    "Solution Approach": "Pipeline health monitoring and cadence alerting",
    "Impact Level": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Key Trade-Off Decisions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000910'::UUID,
  '00000000-0000-0000-0000-000000000701'::UUID,
  '{
    "Trade-Off Title": "Coverage vs Reliability",
    "Decision Made": "Prioritized robust ingestion for high-value sources",
    "Benefit": "Higher reliability and enterprise trust",
    "Sacrifice": "Slower expansion to new portals",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000911'::UUID,
  '00000000-0000-0000-0000-000000000701'::UUID,
  '{
    "Trade-Off Title": "Automation vs Validation",
    "Decision Made": "Automation-first with human visibility",
    "Benefit": "Increased trust and adoption",
    "Sacrifice": "More complex system design",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000912'::UUID,
  '00000000-0000-0000-0000-000000000701'::UUID,
  '{
    "Trade-Off Title": "Model Complexity vs Explainability",
    "Decision Made": "Explainable models prioritized",
    "Benefit": "Audit-ready decisions",
    "Sacrifice": "Lower potential maximum accuracy",
    "Priority": "Medium"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: KPIs and Outcomes
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000920'::UUID,
  '00000000-0000-0000-0000-000000000702'::UUID,
  '{
    "Metric Name": "Manual Monitoring Reduction",
    "Category": "Efficiency",
    "Result": "Manual workload reduced significantly",
    "Improvement Percentage": 70,
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000921'::UUID,
  '00000000-0000-0000-0000-000000000702'::UUID,
  '{
    "Metric Name": "Missed Regulatory Update Risk Reduction",
    "Category": "Risk Reduction",
    "Result": "Missed update risk reduced significantly",
    "Improvement Percentage": 80,
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000922'::UUID,
  '00000000-0000-0000-0000-000000000702'::UUID,
  '{
    "Metric Name": "Tagging Precision",
    "Category": "Reliability",
    "Result": "High precision regulatory tagging",
    "Improvement Percentage": 94,
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000923'::UUID,
  '00000000-0000-0000-0000-000000000702'::UUID,
  '{
    "Metric Name": "Pipeline Uptime",
    "Category": "Reliability",
    "Result": "High ingestion pipeline uptime",
    "Improvement Percentage": 99,
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000924'::UUID,
  '00000000-0000-0000-0000-000000000702'::UUID,
  '{
    "Metric Name": "Feature Usage Growth",
    "Category": "Customer Impact",
    "Result": "Increased regulatory monitoring usage",
    "Improvement Percentage": 250,
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Team Responsibilities
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000930'::UUID,
  '00000000-0000-0000-0000-000000000703'::UUID,
  '{
    "Team Name": "Data Engineering",
    "Responsibility": "Scraping pipelines and ETL normalization",
    "Area Type": "Engineering",
    "Criticality": "High",
    "Owned by Product": false
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000931'::UUID,
  '00000000-0000-0000-0000-000000000703'::UUID,
  '{
    "Team Name": "ML and NLP Team",
    "Responsibility": "Document classification and regulatory tagging",
    "Area Type": "ML",
    "Criticality": "High",
    "Owned by Product": false
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000932'::UUID,
  '00000000-0000-0000-0000-000000000703'::UUID,
  '{
    "Team Name": "Platform Engineering",
    "Responsibility": "Deployment, monitoring, and audit logging",
    "Area Type": "Platform",
    "Criticality": "High",
    "Owned by Product": false
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000933'::UUID,
  '00000000-0000-0000-0000-000000000703'::UUID,
  '{
    "Team Name": "Product Owner",
    "Responsibility": "Product definition, trust design, and workflow integration",
    "Area Type": "Domain",
    "Criticality": "High",
    "Owned by Product": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: product.owner@linkgrc.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000006' with the actual auth.users.id
--
-- 2. Data Structure:
--    - Uses row_data JSONB (not cells table) - matches our implementation
--    - Column values are stored as JSON keys matching column titles
--    - Dependencies array tracks task dependencies (empty for this dataset)
--    - Note: Improvement Percentage is stored as number in JSONB
--
-- 3. To Use:
--    - Run this migration after 001_initial_schema.sql
--    - Update the user UUID to match your actual auth.users.id
--    - Or create the user first, then update this migration
--
-- 4. Project Details:
--    - Workspace: LinkGRC AI Compliance Workspace
--    - Project: AI-Powered Regulatory Monitoring Pipeline
--    - 4 Sheets: Challenges, Trade-Offs, KPIs, Team Responsibilities
--    - 16 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
