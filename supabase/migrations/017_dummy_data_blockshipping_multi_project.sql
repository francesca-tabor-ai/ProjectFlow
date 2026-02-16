-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR BLOCKSHIPPING AI OPTIMIZATION
-- Multi-Project Workspace: AI Import Dwell-Time Prediction and Related Projects
-- Hierarchy: Profile > Workspace > Projects > Sheets > Columns > Row (with row_data JSONB)
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000015'::UUID;
  v_email TEXT := 'candidate@blockshipping.ai';
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
      '{"name": "AI Product Lead"}'::jsonb,
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
    'AI Product Lead',
    v_email,
    '#3b82f6'
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
('00000000-0000-0000-0000-000000001400'::UUID, 'Blockshipping AI Optimization Workspace', '00000000-0000-0000-0000-000000000015'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000000015'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001500'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000000015'::UUID,
  'AI Import Dwell-Time Prediction',
  NULL  -- Will be set after sheets are created
),
(
  '00000000-0000-0000-0000-000000001501'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000000015'::UUID,
  'Operational Integration and Value Modeling',
  NULL
),
(
  '00000000-0000-0000-0000-000000001502'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000000015'::UUID,
  'Platform Deployment and Scaling',
  NULL
),
(
  '00000000-0000-0000-0000-000000001503'::UUID,
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000000015'::UUID,
  'Future Improvements and Strategic Enhancements',
  NULL
)
ON CONFLICT (id) DO NOTHING;

-- Add project members
INSERT INTO project_members (project_id, user_id, role)
VALUES
  ('00000000-0000-0000-0000-000000001500'::UUID, '00000000-0000-0000-0000-000000000015'::UUID, 'Owner'),
  ('00000000-0000-0000-0000-000000001501'::UUID, '00000000-0000-0000-0000-000000000015'::UUID, 'Owner'),
  ('00000000-0000-0000-0000-000000001502'::UUID, '00000000-0000-0000-0000-000000000015'::UUID, 'Owner'),
  ('00000000-0000-0000-0000-000000001503'::UUID, '00000000-0000-0000-0000-000000000015'::UUID, 'Owner')
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001600'::UUID, '00000000-0000-0000-0000-000000001500'::UUID, 'Project Goals and Success Metrics'),
('00000000-0000-0000-0000-000000001601'::UUID, '00000000-0000-0000-0000-000000001501'::UUID, 'Key Challenges and Solutions'),
('00000000-0000-0000-0000-000000001602'::UUID, '00000000-0000-0000-0000-000000001502'::UUID, 'Achievements and KPIs'),
('00000000-0000-0000-0000-000000001603'::UUID, '00000000-0000-0000-0000-000000001503'::UUID, 'Future Improvements Roadmap')
ON CONFLICT (id) DO NOTHING;

-- Update projects with their first sheets as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001600'::UUID
WHERE id = '00000000-0000-0000-0000-000000001500'::UUID;

UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001601'::UUID
WHERE id = '00000000-0000-0000-0000-000000001501'::UUID;

UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001602'::UUID
WHERE id = '00000000-0000-0000-0000-000000001502'::UUID;

UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001603'::UUID
WHERE id = '00000000-0000-0000-0000-000000001503'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Project Goals and Success Metrics (Project 1)
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001700'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'Goal', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001701'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'Description', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001702'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'Impact Area', 'dropdown', 250, 3, '["Operational Efficiency", "Financial Impact", "Sustainability", "Platform"]'::jsonb),
('00000000-0000-0000-0000-000000001703'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'Priority', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001704'::UUID, '00000000-0000-0000-0000-000000001600'::UUID, 'Status', 'dropdown', 150, 5, '["Planned", "In Progress", "Completed"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Key Challenges and Solutions (Project 2)
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001710'::UUID, '00000000-0000-0000-0000-000000001601'::UUID, 'Challenge', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001711'::UUID, '00000000-0000-0000-0000-000000001601'::UUID, 'Root Cause', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001712'::UUID, '00000000-0000-0000-0000-000000001601'::UUID, 'Solution', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001713'::UUID, '00000000-0000-0000-0000-000000001601'::UUID, 'Category', 'dropdown', 200, 4, '["Data", "Model", "Operations", "Platform"]'::jsonb),
('00000000-0000-0000-0000-000000001714'::UUID, '00000000-0000-0000-0000-000000001601'::UUID, 'Status', 'dropdown', 150, 5, '["Identified", "Mitigated", "Resolved"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Achievements and KPIs (Project 3)
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001720'::UUID, '00000000-0000-0000-0000-000000001602'::UUID, 'Metric', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001721'::UUID, '00000000-0000-0000-0000-000000001602'::UUID, 'Description', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001722'::UUID, '00000000-0000-0000-0000-000000001602'::UUID, 'Value', 'text', 200, 3, NULL),
('00000000-0000-0000-0000-000000001723'::UUID, '00000000-0000-0000-0000-000000001602'::UUID, 'Impact Area', 'dropdown', 200, 4, '["Operational", "Financial", "Sustainability", "Platform"]'::jsonb),
('00000000-0000-0000-0000-000000001724'::UUID, '00000000-0000-0000-0000-000000001602'::UUID, 'Achieved', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: Future Improvements Roadmap (Project 4)
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001730'::UUID, '00000000-0000-0000-0000-000000001603'::UUID, 'Improvement', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001731'::UUID, '00000000-0000-0000-0000-000000001603'::UUID, 'Description', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001732'::UUID, '00000000-0000-0000-0000-000000001603'::UUID, 'Expected Benefit', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001733'::UUID, '00000000-0000-0000-0000-000000001603'::UUID, 'Priority', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000001734'::UUID, '00000000-0000-0000-0000-000000001603'::UUID, 'Status', 'dropdown', 150, 5, '["Planned", "In Progress", "Completed"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Project Goals and Success Metrics
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001800'::UUID,
  '00000000-0000-0000-0000-000000001600'::UUID,
  '{
    "Goal": "Improve dwell time prediction accuracy",
    "Description": "Develop AI model to predict container pickup timing before discharge",
    "Impact Area": "Operational Efficiency",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001801'::UUID,
  '00000000-0000-0000-0000-000000001600'::UUID,
  '{
    "Goal": "Reduce yard reshuffling moves",
    "Description": "Use predictions to optimize stacking and reduce unnecessary moves",
    "Impact Area": "Financial Impact",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001802'::UUID,
  '00000000-0000-0000-0000-000000001600'::UUID,
  '{
    "Goal": "Improve terminal throughput capacity",
    "Description": "Enable better yard planning to maximize operational efficiency",
    "Impact Area": "Operational Efficiency",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001803'::UUID,
  '00000000-0000-0000-0000-000000001600'::UUID,
  '{
    "Goal": "Reduce CO2 emissions",
    "Description": "Decrease fuel consumption and unnecessary equipment usage",
    "Impact Area": "Sustainability",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001804'::UUID,
  '00000000-0000-0000-0000-000000001600'::UUID,
  '{
    "Goal": "Enable scalable deployment across terminals",
    "Description": "Build TOS-agnostic AI system for multi-terminal deployment",
    "Impact Area": "Platform",
    "Priority": "High",
    "Status": "Completed"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Key Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001810'::UUID,
  '00000000-0000-0000-0000-000000001601'::UUID,
  '{
    "Challenge": "Highly variable pickup behavior",
    "Root Cause": "Customs clearance, trucking availability, and importer scheduling variability",
    "Solution": "Behavioral segmentation models and continuous retraining",
    "Category": "Model",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001811'::UUID,
  '00000000-0000-0000-0000-000000001601'::UUID,
  '{
    "Challenge": "Data quality variability across terminals",
    "Root Cause": "Different terminal systems and inconsistent data recording",
    "Solution": "Automated data quality scoring and standardized schemas",
    "Category": "Data",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001812'::UUID,
  '00000000-0000-0000-0000-000000001601'::UUID,
  '{
    "Challenge": "Translating ML predictions into operational decisions",
    "Root Cause": "Operational teams needed clear stacking recommendations",
    "Solution": "Decision layer mapping predictions to stacking zones",
    "Category": "Operations",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001813'::UUID,
  '00000000-0000-0000-0000-000000001601'::UUID,
  '{
    "Challenge": "Proving ROI to conservative operators",
    "Root Cause": "Industrial stakeholders required financial justification",
    "Solution": "Simulation modeling and cost per avoided move analysis",
    "Category": "Operations",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001814'::UUID,
  '00000000-0000-0000-0000-000000001601'::UUID,
  '{
    "Challenge": "Balancing prediction accuracy with operational usability",
    "Root Cause": "Complex models reduced operational interpretability",
    "Solution": "Optimized for stable prediction ranges and explainability",
    "Category": "Model",
    "Status": "Resolved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001820'::UUID,
  '00000000-0000-0000-0000-000000001602'::UUID,
  '{
    "Metric": "Reduction in reshuffling moves",
    "Description": "Decrease in unnecessary container repositioning",
    "Value": "30%",
    "Impact Area": "Operational",
    "Achieved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001821'::UUID,
  '00000000-0000-0000-0000-000000001602'::UUID,
  '{
    "Metric": "Truck turn time improvement",
    "Description": "Reduction in average truck waiting and turnaround time",
    "Value": "25%",
    "Impact Area": "Operational",
    "Achieved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001822'::UUID,
  '00000000-0000-0000-0000-000000001602'::UUID,
  '{
    "Metric": "CO2 emissions reduction potential",
    "Description": "Annual reduction from optimized yard operations",
    "Value": "2500 tonnes per year",
    "Impact Area": "Sustainability",
    "Achieved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001823'::UUID,
  '00000000-0000-0000-0000-000000001602'::UUID,
  '{
    "Metric": "Operational cost reduction",
    "Description": "Reduced equipment usage and yard move costs",
    "Value": "Significant cost savings",
    "Impact Area": "Financial",
    "Achieved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001824'::UUID,
  '00000000-0000-0000-0000-000000001602'::UUID,
  '{
    "Metric": "Scalable platform deployment",
    "Description": "Deployment across multiple terminal customers",
    "Value": "Multi-terminal deployment enabled",
    "Impact Area": "Platform",
    "Achieved": true
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: Future Improvements Roadmap
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001830'::UUID,
  '00000000-0000-0000-0000-000000001603'::UUID,
  '{
    "Improvement": "Reinforcement learning integration",
    "Description": "Use RL for automated stacking optimization",
    "Expected Benefit": "Improved stacking efficiency and automation",
    "Priority": "High",
    "Status": "Planned"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001831'::UUID,
  '00000000-0000-0000-0000-000000001603'::UUID,
  '{
    "Improvement": "Digital twin simulation environment",
    "Description": "Simulate terminal operations for testing optimization strategies",
    "Expected Benefit": "Improved model validation and operational testing",
    "Priority": "High",
    "Status": "Planned"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001832'::UUID,
  '00000000-0000-0000-0000-000000001603'::UUID,
  '{
    "Improvement": "Integration with vessel arrival forecasting",
    "Description": "Combine arrival predictions with dwell predictions",
    "Expected Benefit": "Improved overall yard planning accuracy",
    "Priority": "High",
    "Status": "Planned"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001833'::UUID,
  '00000000-0000-0000-0000-000000001603'::UUID,
  '{
    "Improvement": "Enhanced explainability features",
    "Description": "Improve transparency of AI decisions for operators",
    "Expected Benefit": "Higher operator trust and adoption",
    "Priority": "Medium",
    "Status": "Planned"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001834'::UUID,
  '00000000-0000-0000-0000-000000001603'::UUID,
  '{
    "Improvement": "Automated continuous learning pipelines",
    "Description": "Automate model retraining using real-time operational data",
    "Expected Benefit": "Sustained prediction accuracy over time",
    "Priority": "Medium",
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
--      - Email: candidate@blockshipping.ai
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000015' with the actual auth.users.id
--
-- 2. Data Structure:
--    - Uses row_data JSONB (not cells table) - matches our implementation
--    - Column values are stored as JSON keys matching column titles
--    - Dependencies array tracks task dependencies (empty for this dataset)
--    - Note: Achieved is stored as boolean in JSONB
--
-- 3. To Use:
--    - Run this migration after 001_initial_schema.sql
--    - Update the user UUID to match your actual auth.users.id
--    - Or create the user first, then update this migration
--
-- 4. Project Details:
--    - Workspace: Blockshipping AI Optimization Workspace
--    - 4 Projects:
--      * AI Import Dwell-Time Prediction
--      * Operational Integration and Value Modeling
--      * Platform Deployment and Scaling
--      * Future Improvements and Strategic Enhancements
--    - 4 Sheets (one per project)
--    - 20 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
