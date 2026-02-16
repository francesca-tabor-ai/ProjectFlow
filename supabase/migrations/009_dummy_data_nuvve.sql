-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR NUVVE ENERGY OPTIMIZATION
-- AI Forecasting and Market Optimization Platform
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000007'::UUID;
  v_email TEXT := 'owner@nuvve.com';
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
      '{"name": "Energy AI Product Owner"}'::jsonb,
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
    'Energy AI Product Owner',
    v_email,
    '#f59e0b'
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
('00000000-0000-0000-0000-000000000600'::UUID, 'Nuvve Energy Optimization Workspace', '00000000-0000-0000-0000-000000000007'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000600'::UUID,
  '00000000-0000-0000-0000-000000000007'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000700'::UUID,
  '00000000-0000-0000-0000-000000000600'::UUID,
  '00000000-0000-0000-0000-000000000007'::UUID,
  'AI Forecasting and Market Optimization Platform',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000700'::UUID,
  '00000000-0000-0000-0000-000000000007'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000800'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Strategy Ownership'),
('00000000-0000-0000-0000-000000000801'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000000802'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Achievements and KPIs'),
('00000000-0000-0000-0000-000000000803'::UUID, '00000000-0000-0000-0000-000000000700'::UUID, 'Trade-Off Decisions')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000800'::UUID
WHERE id = '00000000-0000-0000-0000-000000000700'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Strategy Ownership
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000900'::UUID, '00000000-0000-0000-0000-000000000800'::UUID, 'Strategy Area', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000901'::UUID, '00000000-0000-0000-0000-000000000800'::UUID, 'Description', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000000902'::UUID, '00000000-0000-0000-0000-000000000800'::UUID, 'Impact Level', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000903'::UUID, '00000000-0000-0000-0000-000000000800'::UUID, 'Ownership Type', 'dropdown', 150, 4, '["Personal", "Team"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000910'::UUID, '00000000-0000-0000-0000-000000000801'::UUID, 'Challenge Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000911'::UUID, '00000000-0000-0000-0000-000000000801'::UUID, 'Root Cause', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000000912'::UUID, '00000000-0000-0000-0000-000000000801'::UUID, 'Solution Implemented', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000000913'::UUID, '00000000-0000-0000-0000-000000000801'::UUID, 'Outcome Effectiveness', 'dropdown', 200, 4, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000920'::UUID, '00000000-0000-0000-0000-000000000802'::UUID, 'KPI Category', 'dropdown', 250, 1, '["Forecasting", "Business Impact", "Operational Efficiency", "Data Quality", "Strategic Value"]'::jsonb),
('00000000-0000-0000-0000-000000000921'::UUID, '00000000-0000-0000-0000-000000000802'::UUID, 'Metric Name', 'text', 350, 2, NULL),
('00000000-0000-0000-0000-000000000922'::UUID, '00000000-0000-0000-0000-000000000802'::UUID, 'Improvement Percentage', 'number', 200, 3, NULL),
('00000000-0000-0000-0000-000000000923'::UUID, '00000000-0000-0000-0000-000000000802'::UUID, 'Business Impact Description', 'text', 400, 4, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Trade-Off Decisions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000930'::UUID, '00000000-0000-0000-0000-000000000803'::UUID, 'Trade-Off Decision', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000000931'::UUID, '00000000-0000-0000-0000-000000000803'::UUID, 'Option Chosen', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000000932'::UUID, '00000000-0000-0000-0000-000000000803'::UUID, 'Benefit Gained', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000000933'::UUID, '00000000-0000-0000-0000-000000000803'::UUID, 'Cost or Sacrifice', 'text', 300, 4, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Strategy Ownership
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001000'::UUID,
  '00000000-0000-0000-0000-000000000800'::UUID,
  '{
    "Strategy Area": "Platform Strategy Evolution",
    "Description": "Expanded POC charging prediction into full energy intelligence platform including tariffs and bidding optimization",
    "Impact Level": "High",
    "Ownership Type": "Personal"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001001'::UUID,
  '00000000-0000-0000-0000-000000000800'::UUID,
  '{
    "Strategy Area": "Forecasting Product Strategy",
    "Description": "Defined forecasting priorities including charging behavior, price forecasting, solar generation, and fleet demand",
    "Impact Level": "High",
    "Ownership Type": "Personal"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001002'::UUID,
  '00000000-0000-0000-0000-000000000800'::UUID,
  '{
    "Strategy Area": "Data Architecture and Quality",
    "Description": "Owned data warehouse migration quality requirements and ensured forecasting data reliability",
    "Impact Level": "High",
    "Ownership Type": "Personal"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001003'::UUID,
  '00000000-0000-0000-0000-000000000800'::UUID,
  '{
    "Strategy Area": "Market Participation Optimization",
    "Description": "Led bidding optimization strategy and V2G capacity forecasting capabilities",
    "Impact Level": "High",
    "Ownership Type": "Personal"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001004'::UUID,
  '00000000-0000-0000-0000-000000000800'::UUID,
  '{
    "Strategy Area": "Cross-Stakeholder Coordination",
    "Description": "Coordinated between data science, grid operations, energy market specialists, and platform engineering",
    "Impact Level": "High",
    "Ownership Type": "Personal"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001010'::UUID,
  '00000000-0000-0000-0000-000000000801'::UUID,
  '{
    "Challenge Name": "Volatile Charging Behavior",
    "Root Cause": "Charging influenced by weather, pricing, fleet scheduling, and behavior shifts",
    "Solution Implemented": "Implemented continuous retraining pipelines and behavioral segmentation modeling",
    "Outcome Effectiveness": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001011'::UUID,
  '00000000-0000-0000-0000-000000000801'::UUID,
  '{
    "Challenge Name": "Energy Market Signal Integration",
    "Root Cause": "Market prices influenced by external signals like weather, grid load, and supply-demand",
    "Solution Implemented": "Built multi-signal price forecasting models with external data integrations",
    "Outcome Effectiveness": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001012'::UUID,
  '00000000-0000-0000-0000-000000000801'::UUID,
  '{
    "Challenge Name": "Data Quality During Migration",
    "Root Cause": "Data drift and inconsistency risks during warehouse migration",
    "Solution Implemented": "Established parallel validation pipelines and automated data drift monitoring",
    "Outcome Effectiveness": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001013'::UUID,
  '00000000-0000-0000-0000-000000000801'::UUID,
  '{
    "Challenge Name": "Forecast Actionability for Operators",
    "Root Cause": "Forecast outputs difficult for non-data stakeholders to interpret",
    "Solution Implemented": "Built dashboards with charging windows, bid recommendations, and capacity forecasts",
    "Outcome Effectiveness": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001020'::UUID,
  '00000000-0000-0000-0000-000000000802'::UUID,
  '{
    "KPI Category": "Forecasting",
    "Metric Name": "Charging plug-in/out prediction accuracy improvement",
    "Improvement Percentage": 25,
    "Business Impact Description": "Improved forecasting reliability compared to baseline heuristics"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001021'::UUID,
  '00000000-0000-0000-0000-000000000802'::UUID,
  '{
    "KPI Category": "Business Impact",
    "Metric Name": "Market bid profitability increase",
    "Improvement Percentage": 15,
    "Business Impact Description": "Improved profitability and successful market participation windows"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001022'::UUID,
  '00000000-0000-0000-0000-000000000802'::UUID,
  '{
    "KPI Category": "Operational Efficiency",
    "Metric Name": "Manual tariff analysis reduction",
    "Improvement Percentage": 60,
    "Business Impact Description": "Reduced manual operational workload"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001023'::UUID,
  '00000000-0000-0000-0000-000000000802'::UUID,
  '{
    "KPI Category": "Data Quality",
    "Metric Name": "Data-related forecasting incidents reduction",
    "Improvement Percentage": 40,
    "Business Impact Description": "Improved system stability and reliability"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001024'::UUID,
  '00000000-0000-0000-0000-000000000802'::UUID,
  '{
    "KPI Category": "Strategic Value",
    "Metric Name": "Expansion into energy markets",
    "Improvement Percentage": 100,
    "Business Impact Description": "Enabled scalable multi-market EV and renewable energy optimization"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Trade-Off Decisions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001030'::UUID,
  '00000000-0000-0000-0000-000000000803'::UUID,
  '{
    "Trade-Off Decision": "Forecast Accuracy vs Interpretability",
    "Option Chosen": "Hybrid statistical and ML models",
    "Benefit Gained": "Improved operator trust and easier debugging",
    "Cost or Sacrifice": "Potential marginal accuracy loss"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001031'::UUID,
  '00000000-0000-0000-0000-000000000803'::UUID,
  '{
    "Trade-Off Decision": "Market Coverage Speed vs Data Verification Quality",
    "Option Chosen": "Slower expansion with verified tariffs",
    "Benefit Gained": "Reduced financial risk from incorrect tariff assumptions",
    "Cost or Sacrifice": "Slower entry into new markets"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001032'::UUID,
  '00000000-0000-0000-0000-000000000803'::UUID,
  '{
    "Trade-Off Decision": "Central Forecast Engine vs Market-Specific Models",
    "Option Chosen": "Core engine with regional adaptation layers",
    "Benefit Gained": "Achieved scalability while preserving local precision",
    "Cost or Sacrifice": "Increased architectural complexity"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: owner@nuvve.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000007' with the actual auth.users.id
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
--    - Workspace: Nuvve Energy Optimization Workspace
--    - Project: AI Forecasting and Market Optimization Platform
--    - 4 Sheets: Strategy Ownership, Challenges, KPIs, Trade-Offs
--    - 17 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
