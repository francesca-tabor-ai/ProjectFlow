-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR NORTH DENMARK REGION AI TRANSFORMATION
-- Generative AI Platform Deployment Project
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000002'::UUID;
  v_email TEXT := 'owner@nordjylland.dk';
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
    '#a855f7'
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
('00000000-0000-0000-0000-000000000100'::UUID, 'North Denmark Region AI Transformation', '00000000-0000-0000-0000-000000000002'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000100'::UUID,
  '00000000-0000-0000-0000-000000000002'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000200'::UUID,
  '00000000-0000-0000-0000-000000000100'::UUID,
  '00000000-0000-0000-0000-000000000002'::UUID,
  'Generative AI Platform Deployment',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000200'::UUID,
  '00000000-0000-0000-0000-000000000002'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000300'::UUID, '00000000-0000-0000-0000-000000000200'::UUID, 'Ownership and Responsibilities'),
('00000000-0000-0000-0000-000000000301'::UUID, '00000000-0000-0000-0000-000000000200'::UUID, 'Architecture Trade-Offs'),
('00000000-0000-0000-0000-000000000302'::UUID, '00000000-0000-0000-0000-000000000200'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000000303'::UUID, '00000000-0000-0000-0000-000000000200'::UUID, 'KPIs and Outcomes')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000300'::UUID
WHERE id = '00000000-0000-0000-0000-000000000200'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Ownership and Responsibilities
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000400'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Area', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000000401'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Ownership Type', 'dropdown', 150, 2, '["Personal", "Team"]'::jsonb),
('00000000-0000-0000-0000-000000000402'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Description', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000000403'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Stakeholders', 'text', 250, 4, NULL),
('00000000-0000-0000-0000-000000000404'::UUID, '00000000-0000-0000-0000-000000000300'::UUID, 'Impact Level', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Architecture Trade-Offs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000410'::UUID, '00000000-0000-0000-0000-000000000301'::UUID, 'Trade-Off Name', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000000411'::UUID, '00000000-0000-0000-0000-000000000301'::UUID, 'Option Chosen', 'text', 250, 2, NULL),
('00000000-0000-0000-0000-000000000412'::UUID, '00000000-0000-0000-0000-000000000301'::UUID, 'Benefit', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000000413'::UUID, '00000000-0000-0000-0000-000000000301'::UUID, 'Cost or Risk', 'text', 250, 4, NULL),
('00000000-0000-0000-0000-000000000414'::UUID, '00000000-0000-0000-0000-000000000301'::UUID, 'Outcome', 'dropdown', 150, 5, '["Positive", "Neutral", "Negative"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000420'::UUID, '00000000-0000-0000-0000-000000000302'::UUID, 'Challenge', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000000421'::UUID, '00000000-0000-0000-0000-000000000302'::UUID, 'Root Cause', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000000422'::UUID, '00000000-0000-0000-0000-000000000302'::UUID, 'Solution', 'text', 350, 3, NULL),
('00000000-0000-0000-0000-000000000423'::UUID, '00000000-0000-0000-0000-000000000302'::UUID, 'Result', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000000424'::UUID, '00000000-0000-0000-0000-000000000302'::UUID, 'Resolution Status', 'dropdown', 150, 5, '["Resolved", "In Progress", "Planned"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: KPIs and Outcomes
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000430'::UUID, '00000000-0000-0000-0000-000000000303'::UUID, 'Metric Name', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000000431'::UUID, '00000000-0000-0000-0000-000000000303'::UUID, 'Category', 'dropdown', 200, 2, '["Adoption", "Productivity", "Safety", "Efficiency", "Strategic"]'::jsonb),
('00000000-0000-0000-0000-000000000432'::UUID, '00000000-0000-0000-0000-000000000303'::UUID, 'Baseline', 'text', 200, 3, NULL),
('00000000-0000-0000-0000-000000000433'::UUID, '00000000-0000-0000-0000-000000000303'::UUID, 'Result', 'text', 250, 4, NULL),
('00000000-0000-0000-0000-000000000434'::UUID, '00000000-0000-0000-0000-000000000303'::UUID, 'Impact Level', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Ownership and Responsibilities
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000500'::UUID,
  '00000000-0000-0000-0000-000000000300'::UUID,
  '{
    "Area": "Product and Deployment Strategy",
    "Ownership Type": "Personal",
    "Description": "Defined generative AI usage in workflows including drafting, summarization, and knowledge search",
    "Stakeholders": "Agency leadership, platform teams",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000501'::UUID,
  '00000000-0000-0000-0000-000000000300'::UUID,
  '{
    "Area": "AI Evaluation Framework",
    "Ownership Type": "Personal",
    "Description": "Defined success metrics, rollout gating criteria, and risk thresholds",
    "Stakeholders": "Security, compliance, platform teams",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000502'::UUID,
  '00000000-0000-0000-0000-000000000300'::UUID,
  '{
    "Area": "Platform Engineering",
    "Ownership Type": "Team",
    "Description": "Built GPU infrastructure, model serving, and orchestration layer",
    "Stakeholders": "Infrastructure teams",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000503'::UUID,
  '00000000-0000-0000-0000-000000000300'::UUID,
  '{
    "Area": "Applied AI Engineering",
    "Ownership Type": "Team",
    "Description": "Model selection, fine-tuning, retrieval pipelines, and evaluation dataset creation",
    "Stakeholders": "ML engineers, platform teams",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000504'::UUID,
  '00000000-0000-0000-0000-000000000300'::UUID,
  '{
    "Area": "Security and Compliance",
    "Ownership Type": "Team",
    "Description": "Threat modeling, audit logging, GDPR compliance, and access policies",
    "Stakeholders": "Security, compliance, legal",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Architecture Trade-Offs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000510'::UUID,
  '00000000-0000-0000-0000-000000000301'::UUID,
  '{
    "Trade-Off Name": "Open Source vs Hosted Models",
    "Option Chosen": "Open-source on-prem models",
    "Benefit": "Full data sovereignty, regulatory confidence, cost control",
    "Cost or Risk": "Lower model capability initially",
    "Outcome": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000511'::UUID,
  '00000000-0000-0000-0000-000000000301'::UUID,
  '{
    "Trade-Off Name": "Speed vs Trust",
    "Option Chosen": "Phased rollout approach",
    "Benefit": "Improved adoption and reduced shadow AI usage",
    "Cost or Risk": "Slower initial deployment",
    "Outcome": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000512'::UUID,
  '00000000-0000-0000-0000-000000000301'::UUID,
  '{
    "Trade-Off Name": "Capability vs Safety",
    "Option Chosen": "Restricted high-risk generative behaviors",
    "Benefit": "Increased trust and safer production deployment",
    "Cost or Risk": "Reduced wow factor",
    "Outcome": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000513'::UUID,
  '00000000-0000-0000-0000-000000000301'::UUID,
  '{
    "Trade-Off Name": "Security vs Usability",
    "Option Chosen": "Risk-tiered access controls",
    "Benefit": "Maintained usability while ensuring security",
    "Cost or Risk": "Increased policy complexity",
    "Outcome": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000520'::UUID,
  '00000000-0000-0000-0000-000000000302'::UUID,
  '{
    "Challenge": "Transition from Pilot to Production",
    "Root Cause": "Lack of structured rollout and readiness framework",
    "Solution": "Introduced production readiness framework and rollout guardrails",
    "Result": "Enabled operational AI deployment",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000521'::UUID,
  '00000000-0000-0000-0000-000000000302'::UUID,
  '{
    "Challenge": "Employee Trust and Adoption",
    "Root Cause": "Fear of data leakage and misuse",
    "Solution": "Implemented guardrails, training, and auditability",
    "Result": "Increased employee adoption",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000522'::UUID,
  '00000000-0000-0000-0000-000000000302'::UUID,
  '{
    "Challenge": "Model Performance Gap",
    "Root Cause": "Open-source models weaker than frontier cloud models",
    "Solution": "Implemented retrieval pipelines, prompt scaffolding, domain grounding",
    "Result": "Improved model quality and reliability",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000523'::UUID,
  '00000000-0000-0000-0000-000000000302'::UUID,
  '{
    "Challenge": "Security and Usability Balance",
    "Root Cause": "Strict controls reduced usability",
    "Solution": "Implemented risk-tiered security controls",
    "Result": "Maintained usability and security balance",
    "Resolution Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: KPIs and Outcomes
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000530'::UUID,
  '00000000-0000-0000-0000-000000000303'::UUID,
  '{
    "Metric Name": "Active Monthly Usage",
    "Category": "Adoption",
    "Baseline": "0 percent",
    "Result": "75 percent adoption within six months",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000531'::UUID,
  '00000000-0000-0000-0000-000000000303'::UUID,
  '{
    "Metric Name": "Document Drafting Time",
    "Category": "Productivity",
    "Baseline": "Baseline drafting time",
    "Result": "Reduced by 35 percent",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000532'::UUID,
  '00000000-0000-0000-0000-000000000303'::UUID,
  '{
    "Metric Name": "Policy Research Time",
    "Category": "Productivity",
    "Baseline": "Baseline research time",
    "Result": "Reduced by 40 percent",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000533'::UUID,
  '00000000-0000-0000-0000-000000000303'::UUID,
  '{
    "Metric Name": "Hallucination Rate",
    "Category": "Safety",
    "Baseline": "Higher hallucination rate",
    "Result": "Reduced by 50 percent",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000534'::UUID,
  '00000000-0000-0000-0000-000000000303'::UUID,
  '{
    "Metric Name": "Support Ticket Volume",
    "Category": "Efficiency",
    "Baseline": "Baseline support volume",
    "Result": "Reduced by 20 percent",
    "Impact Level": "Medium"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: owner@nordjylland.dk
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000002' with the actual auth.users.id
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
--    - Workspace: North Denmark Region AI Transformation
--    - Project: Generative AI Platform Deployment
--    - 4 Sheets: Ownership, Trade-Offs, Challenges, KPIs
--    - 18 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
