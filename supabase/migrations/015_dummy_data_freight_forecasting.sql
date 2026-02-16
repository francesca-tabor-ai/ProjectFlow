-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR FREIGHT MARKET FORECASTING
-- Freight Market Price Forecasting and Fleet Positioning Optimization
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000013'::UUID;
  v_email TEXT := 'engineer@example.com';
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
      '{"name": "Senior Data Engineer"}'::jsonb,
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
    'Senior Data Engineer',
    v_email,
    '#0891b2'
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
('00000000-0000-0000-0000-000000001200'::UUID, 'Freight Market Forecasting Workspace', '00000000-0000-0000-0000-000000000013'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001200'::UUID,
  '00000000-0000-0000-0000-000000000013'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001300'::UUID,
  '00000000-0000-0000-0000-000000001200'::UUID,
  '00000000-0000-0000-0000-000000000013'::UUID,
  'Freight Market Price Forecasting and Fleet Positioning Optimization',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001300'::UUID,
  '00000000-0000-0000-0000-000000000013'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001400'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Ownership Areas'),
('00000000-0000-0000-0000-000000001401'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001402'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Achievements and KPIs'),
('00000000-0000-0000-0000-000000001403'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Future Improvements')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001400'::UUID
WHERE id = '00000000-0000-0000-0000-000000001300'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Ownership Areas
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001500'::UUID, '00000000-0000-0000-0000-000000001400'::UUID, 'Ownership Area', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001501'::UUID, '00000000-0000-0000-0000-000000001400'::UUID, 'Category', 'dropdown', 150, 2, '["Personal", "Team"]'::jsonb),
('00000000-0000-0000-0000-000000001502'::UUID, '00000000-0000-0000-0000-000000001400'::UUID, 'Description', 'text', 500, 3, NULL),
('00000000-0000-0000-0000-000000001503'::UUID, '00000000-0000-0000-0000-000000001400'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001510'::UUID, '00000000-0000-0000-0000-000000001401'::UUID, 'Challenge', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001511'::UUID, '00000000-0000-0000-0000-000000001401'::UUID, 'Solution', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001512'::UUID, '00000000-0000-0000-0000-000000001401'::UUID, 'Priority', 'dropdown', 150, 3, '["Critical", "High", "Medium"]'::jsonb),
('00000000-0000-0000-0000-000000001513'::UUID, '00000000-0000-0000-0000-000000001401'::UUID, 'Status', 'dropdown', 150, 4, '["Resolved", "In Progress", "Planned"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001520'::UUID, '00000000-0000-0000-0000-000000001402'::UUID, 'KPI Name', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001521'::UUID, '00000000-0000-0000-0000-000000001402'::UUID, 'Category', 'dropdown', 200, 2, '["Forecasting", "Commercial", "Operational", "Platform"]'::jsonb),
('00000000-0000-0000-0000-000000001522'::UUID, '00000000-0000-0000-0000-000000001402'::UUID, 'Result', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001523'::UUID, '00000000-0000-0000-0000-000000001402'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Future Improvements
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001530'::UUID, '00000000-0000-0000-0000-000000001403'::UUID, 'Improvement Area', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001531'::UUID, '00000000-0000-0000-0000-000000001403'::UUID, 'Description', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001532'::UUID, '00000000-0000-0000-0000-000000001403'::UUID, 'Priority', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001533'::UUID, '00000000-0000-0000-0000-000000001403'::UUID, 'Status', 'dropdown', 150, 4, '["Planned", "In Progress", "Completed"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Ownership Areas
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001600'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '{
    "Ownership Area": "Business Framing and Value Targeting",
    "Category": "Personal",
    "Description": "Translated forecasting improvements into operational vessel positioning and contract decisions",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001601'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '{
    "Ownership Area": "Model Evaluation and Benchmarking",
    "Category": "Personal",
    "Description": "Defined rigorous baseline comparison framework to validate model improvements",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001602'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '{
    "Ownership Area": "Data Strategy Expansion",
    "Category": "Personal",
    "Description": "Prioritized new external macro shipping indicators and behavioral data sources",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001603'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '{
    "Ownership Area": "Deployment and Production Gating",
    "Category": "Personal",
    "Description": "Defined production readiness criteria, fallback scenarios, and confidence thresholds",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001604'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '{
    "Ownership Area": "Cross-Functional Execution",
    "Category": "Team",
    "Description": "Coordinated execution across commercial, data science, data engineering, and platform teams",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001610'::UUID,
  '00000000-0000-0000-0000-000000001401'::UUID,
  '{
    "Challenge": "Extreme Market Volatility",
    "Solution": "Implemented rolling retraining windows, regime shift detection, and confidence band forecasting",
    "Priority": "Critical",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001611'::UUID,
  '00000000-0000-0000-0000-000000001401'::UUID,
  '{
    "Challenge": "Sparse and Noisy Market Signals",
    "Solution": "Applied multi-source signal blending, feature importance monitoring, and signal weighting",
    "Priority": "High",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001612'::UUID,
  '00000000-0000-0000-0000-000000001401'::UUID,
  '{
    "Challenge": "Making Forecasts Actionable for Traders",
    "Solution": "Created probability-based forecasts, confidence intervals, and scenario forecasts",
    "Priority": "Critical",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001613'::UUID,
  '00000000-0000-0000-0000-000000001401'::UUID,
  '{
    "Challenge": "Aligning Data Science Speed with Commercial Trust",
    "Solution": "Built transparent dashboards, explainability summaries, and validation workshops",
    "Priority": "High",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001620'::UUID,
  '00000000-0000-0000-0000-000000001402'::UUID,
  '{
    "KPI Name": "Forecast Accuracy Improvement",
    "Category": "Forecasting",
    "Result": "Improved freight price forecasting accuracy by approximately 20 percent",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001621'::UUID,
  '00000000-0000-0000-0000-000000001402'::UUID,
  '{
    "KPI Name": "Revenue Opportunity Capture",
    "Category": "Commercial",
    "Result": "Enabled earlier vessel positioning and higher-paying routes",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001622'::UUID,
  '00000000-0000-0000-0000-000000001402'::UUID,
  '{
    "KPI Name": "Operational Scalability",
    "Category": "Operational",
    "Result": "Enabled scalable forecasting across more than 20 freight market segments",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001623'::UUID,
  '00000000-0000-0000-0000-000000001402'::UUID,
  '{
    "KPI Name": "Manual Effort Reduction",
    "Category": "Operational",
    "Result": "Reduced manual analysis effort for chartering teams",
    "Impact Level": "Medium"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001624'::UUID,
  '00000000-0000-0000-0000-000000001402'::UUID,
  '{
    "KPI Name": "Reusable Forecasting Platform",
    "Category": "Platform",
    "Result": "Established reusable forecasting workflows and predictive infrastructure",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Future Improvements
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001630'::UUID,
  '00000000-0000-0000-0000-000000001403'::UUID,
  '{
    "Improvement Area": "Scenario Simulation Integration",
    "Description": "Integrate geopolitical shock simulations earlier in forecasting pipeline",
    "Priority": "High",
    "Status": "Planned"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001631'::UUID,
  '00000000-0000-0000-0000-000000001403'::UUID,
  '{
    "Improvement Area": "Reinforcement Learning Route Optimization",
    "Description": "Explore reinforcement learning to optimize vessel routing decisions",
    "Priority": "Medium",
    "Status": "Planned"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001632'::UUID,
  '00000000-0000-0000-0000-000000001403'::UUID,
  '{
    "Improvement Area": "Confidence and Risk Visualization Tools",
    "Description": "Develop user-facing tools for forecast confidence and risk interpretation",
    "Priority": "High",
    "Status": "Planned"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: engineer@example.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000013' with the actual auth.users.id
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
--    - Workspace: Freight Market Forecasting Workspace
--    - Project: Freight Market Price Forecasting and Fleet Positioning Optimization
--    - 4 Sheets: Ownership Areas, Challenges, KPIs, Future Improvements
--    - 17 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
