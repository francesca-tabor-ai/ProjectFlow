-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR AI CREDIT RISK PLATFORM
-- Real-Time AI Credit Risk Prediction
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000011'::UUID;
  v_email TEXT := 'risk.ai.owner@example.com';
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
      '{"name": "AI Risk Product Owner"}'::jsonb,
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
    'AI Risk Product Owner',
    v_email,
    '#dc2626'
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
('00000000-0000-0000-0000-000000001000'::UUID, 'AI Credit Risk Platform Workspace', '00000000-0000-0000-0000-000000000011'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001000'::UUID,
  '00000000-0000-0000-0000-000000000011'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001100'::UUID,
  '00000000-0000-0000-0000-000000001000'::UUID,
  '00000000-0000-0000-0000-000000000011'::UUID,
  'Real-Time AI Credit Risk Prediction',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001100'::UUID,
  '00000000-0000-0000-0000-000000000011'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001200'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Objectives and KPIs'),
('00000000-0000-0000-0000-000000001201'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001202'::UUID, '00000000-0000-0000-0000-000000001100'::UUID, 'Trade-offs and Decisions')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001200'::UUID
WHERE id = '00000000-0000-0000-0000-000000001100'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Objectives and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001300'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Objective', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001301'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Category', 'dropdown', 200, 2, '["Performance", "Financial", "Operational", "Compliance", "Strategic"]'::jsonb),
('00000000-0000-0000-0000-000000001302'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Metric', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000001303'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Result', 'text', 350, 4, NULL),
('00000000-0000-0000-0000-000000001304'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Status', 'dropdown', 150, 5, '["Planned", "In Progress", "Completed"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001310'::UUID, '00000000-0000-0000-0000-000000001201'::UUID, 'Challenge', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001311'::UUID, '00000000-0000-0000-0000-000000001201'::UUID, 'Impact Level', 'dropdown', 150, 2, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001312'::UUID, '00000000-0000-0000-0000-000000001201'::UUID, 'Solution', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001313'::UUID, '00000000-0000-0000-0000-000000001201'::UUID, 'Owner', 'text', 250, 4, NULL),
('00000000-0000-0000-0000-000000001314'::UUID, '00000000-0000-0000-0000-000000001201'::UUID, 'Status', 'dropdown', 150, 5, '["Open", "Mitigated", "Resolved"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Trade-offs and Decisions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001320'::UUID, '00000000-0000-0000-0000-000000001202'::UUID, 'Decision Area', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001321'::UUID, '00000000-0000-0000-0000-000000001202'::UUID, 'Option Chosen', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000001322'::UUID, '00000000-0000-0000-0000-000000001202'::UUID, 'Benefit', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000001323'::UUID, '00000000-0000-0000-0000-000000001202'::UUID, 'Trade-Off Cost', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000001324'::UUID, '00000000-0000-0000-0000-000000001202'::UUID, 'Status', 'dropdown', 150, 5, '["Planned", "Implemented"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Objectives and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000001200'::UUID,
  '{
    "Objective": "Improve repayment prediction accuracy",
    "Category": "Performance",
    "Metric": "Classification accuracy",
    "Result": "Approximately 80 percent achieved",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001401'::UUID,
  '00000000-0000-0000-0000-000000001200'::UUID,
  '{
    "Objective": "Reduce loan default exposure",
    "Category": "Financial",
    "Metric": "Default rate reduction",
    "Result": "Annual cost savings estimated at 1–2 million DKK",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001402'::UUID,
  '00000000-0000-0000-0000-000000001200'::UUID,
  '{
    "Objective": "Enable real-time automated loan decisions",
    "Category": "Operational",
    "Metric": "Decision latency",
    "Result": "Real-time approvals enabled",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001403'::UUID,
  '00000000-0000-0000-0000-000000001200'::UUID,
  '{
    "Objective": "Ensure regulatory explainability",
    "Category": "Compliance",
    "Metric": "Explainability coverage",
    "Result": "Full audit-ready decision traceability delivered",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001404'::UUID,
  '00000000-0000-0000-0000-000000001200'::UUID,
  '{
    "Objective": "Enable future AI-driven credit risk models",
    "Category": "Strategic",
    "Metric": "Platform readiness",
    "Result": "Reusable ML decisioning platform established",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001410'::UUID,
  '00000000-0000-0000-0000-000000001201'::UUID,
  '{
    "Challenge": "Balancing model accuracy with fair lending requirements",
    "Impact Level": "High",
    "Solution": "Fairness monitoring, feature sensitivity testing, and risk committee review",
    "Owner": "Risk and Product Owner",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001411'::UUID,
  '00000000-0000-0000-0000-000000001201'::UUID,
  '{
    "Challenge": "Real-time data quality variability",
    "Impact Level": "High",
    "Solution": "Real-time validation checks and fallback scoring mechanisms",
    "Owner": "Data Engineering",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001412'::UUID,
  '00000000-0000-0000-0000-000000001201'::UUID,
  '{
    "Challenge": "Model drift due to economic changes",
    "Impact Level": "High",
    "Solution": "Continuous monitoring, scheduled retraining, and economic regime segmentation",
    "Owner": "Data Science and Platform Engineering",
    "Status": "Mitigated"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001413'::UUID,
  '00000000-0000-0000-0000-000000001201'::UUID,
  '{
    "Challenge": "Building cross-team trust in AI model",
    "Impact Level": "Medium",
    "Solution": "Explanation dashboards and governance review processes",
    "Owner": "Product Owner and Compliance",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001414'::UUID,
  '00000000-0000-0000-0000-000000001201'::UUID,
  '{
    "Challenge": "Regulatory explainability vs maximum model accuracy",
    "Impact Level": "Medium",
    "Solution": "Used interpretable ensemble models with explainable feature contributions",
    "Owner": "Data Science and Compliance",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Trade-offs and Decisions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001420'::UUID,
  '00000000-0000-0000-0000-000000001202'::UUID,
  '{
    "Decision Area": "Model architecture",
    "Option Chosen": "Interpretable ensemble models",
    "Benefit": "Regulatory explainability and adoption",
    "Trade-Off Cost": "Slight reduction in theoretical predictive accuracy",
    "Status": "Implemented"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001421'::UUID,
  '00000000-0000-0000-0000-000000001202'::UUID,
  '{
    "Decision Area": "Inference latency optimization",
    "Option Chosen": "Optimized ensemble depth",
    "Benefit": "Real-time loan approval capability",
    "Trade-Off Cost": "Limited model complexity",
    "Status": "Implemented"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001422'::UUID,
  '00000000-0000-0000-0000-000000001202'::UUID,
  '{
    "Decision Area": "Feature selection strategy",
    "Option Chosen": "Privacy-safe behavioral features",
    "Benefit": "Reduced fairness and regulatory risk",
    "Trade-Off Cost": "Excluded some predictive signals",
    "Status": "Implemented"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001423'::UUID,
  '00000000-0000-0000-0000-000000001202'::UUID,
  '{
    "Decision Area": "Deployment rollout strategy",
    "Option Chosen": "Staged rollout with monitoring",
    "Benefit": "Reduced risk exposure during deployment",
    "Trade-Off Cost": "Slower rollout timeline",
    "Status": "Implemented"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001424'::UUID,
  '00000000-0000-0000-0000-000000001202'::UUID,
  '{
    "Decision Area": "Monitoring and retraining",
    "Option Chosen": "Automated retraining pipelines",
    "Benefit": "Stable performance across economic changes",
    "Trade-Off Cost": "Higher infrastructure complexity",
    "Status": "Implemented"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: risk.ai.owner@example.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000011' with the actual auth.users.id
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
--    - Workspace: AI Credit Risk Platform Workspace
--    - Project: Real-Time AI Credit Risk Prediction
--    - 3 Sheets: Objectives and KPIs, Challenges, Trade-offs
--    - 15 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
