-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR BLOCKSHIPPING AI TERMINAL OPTIMIZATION
-- AI Import Dwell-Time Prediction for Container Terminal Optimization
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000014'::UUID;
  v_email TEXT := 'owner@blockshipping.ai';
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
      '{"name": "Blockshipping Project Owner"}'::jsonb,
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
    'Blockshipping Project Owner',
    v_email,
    '#0ea5e9'
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
('00000000-0000-0000-0000-000000001300'::UUID, 'AI Terminal Optimization Workspace', '00000000-0000-0000-0000-000000000014'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001300'::UUID,
  '00000000-0000-0000-0000-000000000014'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000001300'::UUID,
  '00000000-0000-0000-0000-000000000014'::UUID,
  'AI Import Dwell-Time Prediction for Container Terminal Optimization',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001400'::UUID,
  '00000000-0000-0000-0000-000000000014'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001500'::UUID, '00000000-0000-0000-0000-000000001400'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001501'::UUID, '00000000-0000-0000-0000-000000001400'::UUID, 'Trade-Off Decisions'),
('00000000-0000-0000-0000-000000001502'::UUID, '00000000-0000-0000-0000-000000001400'::UUID, 'Achievements and KPIs')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001500'::UUID
WHERE id = '00000000-0000-0000-0000-000000001400'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001600'::UUID, '00000000-0000-0000-0000-000000001500'::UUID, 'Challenge', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001601'::UUID, '00000000-0000-0000-0000-000000001500'::UUID, 'Solution', 'text', 500, 2, NULL),
('00000000-0000-0000-0000-000000001602'::UUID, '00000000-0000-0000-0000-000000001500'::UUID, 'Impact Area', 'dropdown', 200, 3, '["Operational", "Data Quality", "Decision Making", "Financial"]'::jsonb),
('00000000-0000-0000-0000-000000001603'::UUID, '00000000-0000-0000-0000-000000001500'::UUID, 'Status', 'dropdown', 150, 4, '["Resolved", "Ongoing", "Planned"]'::jsonb),
('00000000-0000-0000-0000-000000001604'::UUID, '00000000-0000-0000-0000-000000001500'::UUID, 'Priority', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Trade-Off Decisions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001610'::UUID, '00000000-0000-0000-0000-000000001501'::UUID, 'Trade-Off', 'text', 400, 1, NULL),
('00000000-0000-0000-0000-000000001611'::UUID, '00000000-0000-0000-0000-000000001501'::UUID, 'Decision', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001612'::UUID, '00000000-0000-0000-0000-000000001501'::UUID, 'Reason', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001613'::UUID, '00000000-0000-0000-0000-000000001501'::UUID, 'Outcome', 'dropdown', 150, 4, '["Positive", "Neutral", "Negative"]'::jsonb),
('00000000-0000-0000-0000-000000001614'::UUID, '00000000-0000-0000-0000-000000001501'::UUID, 'Scalability Impact', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Achievements and KPIs
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001620'::UUID, '00000000-0000-0000-0000-000000001502'::UUID, 'KPI Name', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001621'::UUID, '00000000-0000-0000-0000-000000001502'::UUID, 'Metric Value', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000001622'::UUID, '00000000-0000-0000-0000-000000001502'::UUID, 'Category', 'dropdown', 250, 3, '["Operational Efficiency", "Financial Impact", "Sustainability Impact", "Platform Impact"]'::jsonb),
('00000000-0000-0000-0000-000000001623'::UUID, '00000000-0000-0000-0000-000000001502'::UUID, 'Measurement Type', 'dropdown', 200, 4, '["Percentage", "Absolute", "Qualitative"]'::jsonb),
('00000000-0000-0000-0000-000000001624'::UUID, '00000000-0000-0000-0000-000000001502'::UUID, 'Status', 'dropdown', 150, 5, '["Achieved", "In Progress", "Projected"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001700'::UUID,
  '00000000-0000-0000-0000-000000001500'::UUID,
  '{
    "Challenge": "Highly variable container pickup behavior",
    "Solution": "Behavioral segmentation models and time-window prediction bands",
    "Impact Area": "Operational",
    "Status": "Resolved",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001701'::UUID,
  '00000000-0000-0000-0000-000000001500'::UUID,
  '{
    "Challenge": "Data quality variability across terminals",
    "Solution": "Automated data quality scoring and fallback prediction logic",
    "Impact Area": "Data Quality",
    "Status": "Resolved",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001702'::UUID,
  '00000000-0000-0000-0000-000000001500'::UUID,
  '{
    "Challenge": "Translating ML output into terminal stacking decisions",
    "Solution": "Operational decision layer mapping predictions to stacking zones",
    "Impact Area": "Decision Making",
    "Status": "Resolved",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001703'::UUID,
  '00000000-0000-0000-0000-000000001500'::UUID,
  '{
    "Challenge": "Proving ROI to conservative industrial operators",
    "Solution": "Move reduction simulation and cost per avoided move modeling",
    "Impact Area": "Financial",
    "Status": "Resolved",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Trade-Off Decisions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001710'::UUID,
  '00000000-0000-0000-0000-000000001501'::UUID,
  '{
    "Trade-Off": "Prediction precision vs operational robustness",
    "Decision": "Optimized for stable prediction ranges",
    "Reason": "Terminal operators prefer reliable ranges over volatile predictions",
    "Outcome": "Positive",
    "Scalability Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001711'::UUID,
  '00000000-0000-0000-0000-000000001501'::UUID,
  '{
    "Trade-Off": "Custom terminal models vs scalable platform model",
    "Decision": "Built configurable core model with terminal-specific tuning",
    "Reason": "Enabled scalability while preserving local accuracy",
    "Outcome": "Positive",
    "Scalability Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001712'::UUID,
  '00000000-0000-0000-0000-000000001501'::UUID,
  '{
    "Trade-Off": "Maximum model complexity vs real-time usability",
    "Decision": "Balanced modeling complexity with inference speed",
    "Reason": "Ensured operational usability and explainability",
    "Outcome": "Positive",
    "Scalability Impact": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Achievements and KPIs
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001720'::UUID,
  '00000000-0000-0000-0000-000000001502'::UUID,
  '{
    "KPI Name": "Container reshuffling move reduction",
    "Metric Value": "30 percent reduction",
    "Category": "Operational Efficiency",
    "Measurement Type": "Percentage",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001721'::UUID,
  '00000000-0000-0000-0000-000000001502'::UUID,
  '{
    "KPI Name": "Truck turn time reduction",
    "Metric Value": "25 percent reduction",
    "Category": "Operational Efficiency",
    "Measurement Type": "Percentage",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001722'::UUID,
  '00000000-0000-0000-0000-000000001502'::UUID,
  '{
    "KPI Name": "Operational cost reduction",
    "Metric Value": "Reduced yard operation costs",
    "Category": "Financial Impact",
    "Measurement Type": "Qualitative",
    "Status": "Achieved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001723'::UUID,
  '00000000-0000-0000-0000-000000001502'::UUID,
  '{
    "KPI Name": "CO2 reduction potential",
    "Metric Value": "2500 tonnes per year reduction potential",
    "Category": "Sustainability Impact",
    "Measurement Type": "Absolute",
    "Status": "Projected"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001724'::UUID,
  '00000000-0000-0000-0000-000000001502'::UUID,
  '{
    "KPI Name": "Multi-terminal scalable deployment",
    "Metric Value": "Enabled cross-terminal AI deployment",
    "Category": "Platform Impact",
    "Measurement Type": "Qualitative",
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
--      - Email: owner@blockshipping.ai
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000014' with the actual auth.users.id
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
--    - Workspace: AI Terminal Optimization Workspace
--    - Project: AI Import Dwell-Time Prediction for Container Terminal Optimization
--    - 3 Sheets: Challenges, Trade-Offs, KPIs
--    - 12 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
