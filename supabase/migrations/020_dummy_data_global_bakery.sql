-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR GLOBAL BAKERY AI TRANSFORMATION
-- Real-Time AI Sales Prediction and Recommendation Engine
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000018'::UUID;
  v_email TEXT := 'sales.ai.owner@example.com';
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
      '{"name": "AI Sales Platform Owner"}'::jsonb,
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
    'AI Sales Platform Owner',
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
('00000000-0000-0000-0000-000000001700'::UUID, 'Global Bakery AI Transformation Workspace', '00000000-0000-0000-0000-000000000018'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001700'::UUID,
  '00000000-0000-0000-0000-000000000018'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001800'::UUID,
  '00000000-0000-0000-0000-000000001700'::UUID,
  '00000000-0000-0000-0000-000000000018'::UUID,
  'Real-Time AI Sales Prediction and Recommendation Engine',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001800'::UUID,
  '00000000-0000-0000-0000-000000000018'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001900'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Project Objectives and Strategy'),
('00000000-0000-0000-0000-000000001901'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001902'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Achievements and KPIs'),
('00000000-0000-0000-0000-000000001903'::UUID, '00000000-0000-0000-0000-000000001800'::UUID, 'Trade-Off Decisions')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001900'::UUID
WHERE id = '00000000-0000-0000-0000-000000001800'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Project Objectives and Strategy
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000002000'::UUID, '00000000-0000-0000-0000-000000001900'::UUID, 'Objective', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000002001'::UUID, '00000000-0000-0000-0000-000000001900'::UUID, 'Description', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000002002'::UUID, '00000000-0000-0000-0000-000000001900'::UUID, 'Category', 'dropdown', 250, 3, '["Vision", "Prediction Strategy", "Workflow Integration", "Architecture", "Evaluation"]'::jsonb),
('00000000-0000-0000-0000-000000002003'::UUID, '00000000-0000-0000-0000-000000001900'::UUID, 'Priority', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000002004'::UUID, '00000000-0000-0000-0000-000000001900'::UUID, 'Status', 'dropdown', 150, 5, '["Planned", "In Progress", "Completed"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000002010'::UUID, '00000000-0000-0000-0000-000000001901'::UUID, 'Challenge', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000002011'::UUID, '00000000-0000-0000-0000-000000001901'::UUID, 'Solution', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000002012'::UUID, '00000000-0000-0000-0000-000000001901'::UUID, 'Impact Area', 'dropdown', 250, 3, '["Data Quality", "Trust", "Model Performance", "Commercial Actionability"]'::jsonb),
('00000000-0000-0000-0000-000000002013'::UUID, '00000000-0000-0000-0000-000000001901'::UUID, 'Complexity', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000002014'::UUID, '00000000-0000-0000-0000-000000001901'::UUID, 'Resolved', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000002020'::UUID, '00000000-0000-0000-0000-000000001902'::UUID, 'Achievement', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000002021'::UUID, '00000000-0000-0000-0000-000000001902'::UUID, 'Category', 'dropdown', 250, 2, '["Sales Enablement", "Commercial Performance", "Platform Strategy", "Adoption"]'::jsonb),
('00000000-0000-0000-0000-000000002022'::UUID, '00000000-0000-0000-0000-000000001902'::UUID, 'Impact Level', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000002023'::UUID, '00000000-0000-0000-0000-000000001902'::UUID, 'Region', 'text', 200, 4, NULL),
('00000000-0000-0000-0000-000000002024'::UUID, '00000000-0000-0000-0000-000000001902'::UUID, 'Verified', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Trade-Off Decisions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000002030'::UUID, '00000000-0000-0000-0000-000000001903'::UUID, 'Decision', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000002031'::UUID, '00000000-0000-0000-0000-000000001903'::UUID, 'Chosen Approach', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000002032'::UUID, '00000000-0000-0000-0000-000000001903'::UUID, 'Benefit', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000002033'::UUID, '00000000-0000-0000-0000-000000001903'::UUID, 'Sacrifice', 'text', 400, 4, NULL),
('00000000-0000-0000-0000-000000002034'::UUID, '00000000-0000-0000-0000-000000001903'::UUID, 'Strategic Impact', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Project Objectives and Strategy
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002100'::UUID,
  '00000000-0000-0000-0000-000000001900'::UUID,
  '{
    "Objective": "Define product vision",
    "Description": "Shift from BI dashboards to operational predictive decision engine",
    "Category": "Vision",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002101'::UUID,
  '00000000-0000-0000-0000-000000001900'::UUID,
  '{
    "Objective": "Build multi-model prediction strategy",
    "Description": "Combine forecasting, collaborative filtering, and classification",
    "Category": "Prediction Strategy",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002102'::UUID,
  '00000000-0000-0000-0000-000000001900'::UUID,
  '{
    "Objective": "Integrate into sales workflows",
    "Description": "Embed recommendations into sales dashboards and decision processes",
    "Category": "Workflow Integration",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002103'::UUID,
  '00000000-0000-0000-0000-000000001900'::UUID,
  '{
    "Objective": "Define scalable architecture",
    "Description": "Ensure solution can scale across multiple countries",
    "Category": "Architecture",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002104'::UUID,
  '00000000-0000-0000-0000-000000001900'::UUID,
  '{
    "Objective": "Establish evaluation metrics",
    "Description": "Measure sales behavior change and quota performance impact",
    "Category": "Evaluation",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002110'::UUID,
  '00000000-0000-0000-0000-000000001901'::UUID,
  '{
    "Challenge": "Fragmented customer and product data",
    "Solution": "Unified feature schema and data quality scoring pipelines",
    "Impact Area": "Data Quality",
    "Complexity": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002111'::UUID,
  '00000000-0000-0000-0000-000000001901'::UUID,
  '{
    "Challenge": "Sales team trust in AI recommendations",
    "Solution": "Explainable recommendation reasoning and dashboard integration",
    "Impact Area": "Trust",
    "Complexity": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002112'::UUID,
  '00000000-0000-0000-0000-000000001901'::UUID,
  '{
    "Challenge": "Cold start for new products",
    "Solution": "Product similarity modeling and hybrid ML bootstrapping",
    "Impact Area": "Model Performance",
    "Complexity": "Medium",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002113'::UUID,
  '00000000-0000-0000-0000-000000001901'::UUID,
  '{
    "Challenge": "Turning predictions into sales action",
    "Solution": "Provide recommended products and expected uplift probabilities",
    "Impact Area": "Commercial Actionability",
    "Complexity": "High",
    "Resolved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002120'::UUID,
  '00000000-0000-0000-0000-000000001902'::UUID,
  '{
    "Achievement": "Increased data-driven decision making",
    "Category": "Sales Enablement",
    "Impact Level": "High",
    "Region": "Norway",
    "Verified": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002121'::UUID,
  '00000000-0000-0000-0000-000000001902'::UUID,
  '{
    "Achievement": "Improved customer-product match quality",
    "Category": "Commercial Performance",
    "Impact Level": "High",
    "Region": "Norway",
    "Verified": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002122'::UUID,
  '00000000-0000-0000-0000-000000001902'::UUID,
  '{
    "Achievement": "Established scalable predictive sales architecture",
    "Category": "Platform Strategy",
    "Impact Level": "High",
    "Region": "Global",
    "Verified": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002123'::UUID,
  '00000000-0000-0000-0000-000000001902'::UUID,
  '{
    "Achievement": "Strong daily usage by sales teams",
    "Category": "Adoption",
    "Impact Level": "High",
    "Region": "Norway",
    "Verified": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002124'::UUID,
  '00000000-0000-0000-0000-000000001902'::UUID,
  '{
    "Achievement": "Improved sales planning confidence",
    "Category": "Commercial Performance",
    "Impact Level": "Medium",
    "Region": "Global",
    "Verified": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Trade-Off Decisions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000002130'::UUID,
  '00000000-0000-0000-0000-000000001903'::UUID,
  '{
    "Decision": "Unified model vs multi-model ensemble",
    "Chosen Approach": "Multi-model ensemble",
    "Benefit": "Better prediction robustness and explainability",
    "Sacrifice": "Increased system complexity",
    "Strategic Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002131'::UUID,
  '00000000-0000-0000-0000-000000001903'::UUID,
  '{
    "Decision": "Automated decisions vs sales rep control",
    "Chosen Approach": "Recommendation support",
    "Benefit": "Improved adoption and preserved sales ownership",
    "Sacrifice": "Less full automation",
    "Strategic Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000002132'::UUID,
  '00000000-0000-0000-0000-000000001903'::UUID,
  '{
    "Decision": "Global rollout speed vs local accuracy",
    "Chosen Approach": "Optimize Norway first",
    "Benefit": "Commercial validation and higher accuracy",
    "Sacrifice": "Slower global rollout",
    "Strategic Impact": "Medium"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: sales.ai.owner@example.com
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000018' with the actual auth.users.id
--
-- 2. Data Structure:
--    - Uses row_data JSONB (not cells table) - matches our implementation
--    - Column values are stored as JSON keys matching column titles
--    - Dependencies array tracks task dependencies (empty for this dataset)
--    - Note: Resolved and Verified are stored as booleans in JSONB
--
-- 3. To Use:
--    - Run this migration after 001_initial_schema.sql
--    - Update the user UUID to match your actual auth.users.id
--    - Or create the user first, then update this migration
--
-- 4. Project Details:
--    - Workspace: Global Bakery AI Transformation Workspace
--    - Project: Real-Time AI Sales Prediction and Recommendation Engine
--    - 4 Sheets: Project Objectives, Challenges, KPIs, Trade-Offs
--    - 17 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
