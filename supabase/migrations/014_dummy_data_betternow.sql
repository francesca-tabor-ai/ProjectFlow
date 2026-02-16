-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR BETTERNOW AI FUNDRAISING
-- AI Personalization and Recommendation Engine
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
  v_user_id UUID := '00000000-0000-0000-0000-000000000012'::UUID;
  v_email TEXT := 'pm@betternow.ai';
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
      '{"name": "AI Product Manager"}'::jsonb,
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
    'AI Product Manager',
    v_email,
    '#f43f5e'
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
('00000000-0000-0000-0000-000000001100'::UUID, 'BetterNow AI Fundraising Workspace', '00000000-0000-0000-0000-000000000012'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001100'::UUID,
  '00000000-0000-0000-0000-000000000012'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000001200'::UUID,
  '00000000-0000-0000-0000-000000001100'::UUID,
  '00000000-0000-0000-0000-000000000012'::UUID,
  'AI Personalization and Recommendation Engine',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000001200'::UUID,
  '00000000-0000-0000-0000-000000000012'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000001300'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Project Overview'),
('00000000-0000-0000-0000-000000001301'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Trade-Off Decisions'),
('00000000-0000-0000-0000-000000001302'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'Challenges and Solutions'),
('00000000-0000-0000-0000-000000001303'::UUID, '00000000-0000-0000-0000-000000001200'::UUID, 'KPIs and Achievements')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000001300'::UUID
WHERE id = '00000000-0000-0000-0000-000000001200'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Sheet 1: Project Overview
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001400'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Category', 'dropdown', 200, 1, '["Context", "Goal", "Ownership", "Strategic Outcome"]'::jsonb),
('00000000-0000-0000-0000-000000001401'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Topic', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000001402'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Description', 'text', 500, 3, NULL),
('00000000-0000-0000-0000-000000001403'::UUID, '00000000-0000-0000-0000-000000001300'::UUID, 'Impact Level', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 2: Trade-Off Decisions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001410'::UUID, '00000000-0000-0000-0000-000000001301'::UUID, 'Trade-Off', 'text', 350, 1, NULL),
('00000000-0000-0000-0000-000000001411'::UUID, '00000000-0000-0000-0000-000000001301'::UUID, 'Option A', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000001412'::UUID, '00000000-0000-0000-0000-000000001301'::UUID, 'Option B', 'text', 300, 3, NULL),
('00000000-0000-0000-0000-000000001413'::UUID, '00000000-0000-0000-0000-000000001301'::UUID, 'Decision', 'text', 300, 4, NULL),
('00000000-0000-0000-0000-000000001414'::UUID, '00000000-0000-0000-0000-000000001301'::UUID, 'Priority', 'dropdown', 150, 5, '["High", "Medium", "Low"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 3: Challenges and Solutions
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001420'::UUID, '00000000-0000-0000-0000-000000001302'::UUID, 'Challenge', 'text', 300, 1, NULL),
('00000000-0000-0000-0000-000000001421'::UUID, '00000000-0000-0000-0000-000000001302'::UUID, 'Root Cause', 'text', 400, 2, NULL),
('00000000-0000-0000-0000-000000001422'::UUID, '00000000-0000-0000-0000-000000001302'::UUID, 'Solution', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001423'::UUID, '00000000-0000-0000-0000-000000001302'::UUID, 'Status', 'dropdown', 150, 4, '["Solved", "Mitigated", "In Progress"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Columns for Sheet 4: KPIs and Achievements
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000001430'::UUID, '00000000-0000-0000-0000-000000001303'::UUID, 'Metric Category', 'dropdown', 250, 1, '["Performance", "Engagement", "Adoption", "Strategic Impact"]'::jsonb),
('00000000-0000-0000-0000-000000001431'::UUID, '00000000-0000-0000-0000-000000001303'::UUID, 'Metric Name', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000001432'::UUID, '00000000-0000-0000-0000-000000001303'::UUID, 'Result', 'text', 400, 3, NULL),
('00000000-0000-0000-0000-000000001433'::UUID, '00000000-0000-0000-0000-000000001303'::UUID, 'Trend', 'dropdown', 150, 4, '["Improved", "Increased", "Strong", "Positive"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Sheet 1: Project Overview
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001500'::UUID,
  '00000000-0000-0000-0000-000000001300'::UUID,
  '{
    "Category": "Context",
    "Topic": "Fundraising Platform Problem",
    "Description": "Campaign performance varied significantly with no systematic optimization guidance.",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001501'::UUID,
  '00000000-0000-0000-0000-000000001300'::UUID,
  '{
    "Category": "Goal",
    "Topic": "Real-Time Recommendations",
    "Description": "Deliver personalized recommendations to improve donation conversion and campaign performance.",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001502'::UUID,
  '00000000-0000-0000-0000-000000001300'::UUID,
  '{
    "Category": "Ownership",
    "Topic": "Recommendation Strategy",
    "Description": "Defined experimentation framework, recommendation types, and integration UX strategy.",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001503'::UUID,
  '00000000-0000-0000-0000-000000001300'::UUID,
  '{
    "Category": "Ownership",
    "Topic": "Ethical Guardrails",
    "Description": "Ensured recommendations were transparent, ethical, and preserved fundraiser trust.",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001504'::UUID,
  '00000000-0000-0000-0000-000000001300'::UUID,
  '{
    "Category": "Strategic Outcome",
    "Topic": "Platform Transformation",
    "Description": "Shifted BetterNow from passive platform to active campaign optimization platform.",
    "Impact Level": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 2: Trade-Off Decisions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001510'::UUID,
  '00000000-0000-0000-0000-000000001301'::UUID,
  '{
    "Trade-Off": "Prediction Accuracy vs Actionability",
    "Option A": "Predict campaign performance",
    "Option B": "Provide actionable recommendations",
    "Decision": "Prioritized actionable recommendations",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001511'::UUID,
  '00000000-0000-0000-0000-000000001301'::UUID,
  '{
    "Trade-Off": "Personalization Depth vs Explainability",
    "Option A": "Complex models with higher accuracy",
    "Option B": "Explainable recommendation models",
    "Decision": "Maintained explainability to preserve trust",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001512'::UUID,
  '00000000-0000-0000-0000-000000001301'::UUID,
  '{
    "Trade-Off": "Automation vs User Agency",
    "Option A": "Automatic campaign optimization",
    "Option B": "User-controlled recommendations",
    "Decision": "Chose user-controlled recommendations",
    "Priority": "High"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 3: Challenges and Solutions
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001520'::UUID,
  '00000000-0000-0000-0000-000000001302'::UUID,
  '{
    "Challenge": "High Noise in Performance Signals",
    "Root Cause": "External factors impacted campaign success variability",
    "Solution": "Segmented models and confidence-weighted ranking",
    "Status": "Solved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001521'::UUID,
  '00000000-0000-0000-0000-000000001302'::UUID,
  '{
    "Challenge": "ML Output Not Actionable",
    "Root Cause": "ML predictions did not directly translate into user actions",
    "Solution": "Designed action-first recommendations with impact messaging",
    "Status": "Solved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001522'::UUID,
  '00000000-0000-0000-0000-000000001302'::UUID,
  '{
    "Challenge": "Recommendation Fatigue",
    "Root Cause": "Too many recommendations reduced engagement",
    "Solution": "Limited recommendations to high-impact items",
    "Status": "Solved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001523'::UUID,
  '00000000-0000-0000-0000-000000001302'::UUID,
  '{
    "Challenge": "Cold Start for New Campaign Types",
    "Root Cause": "Insufficient historical data for new campaigns",
    "Solution": "Hybrid rules and ML bootstrapping approach",
    "Status": "Solved"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Sheet 4: KPIs and Achievements
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000001530'::UUID,
  '00000000-0000-0000-0000-000000001303'::UUID,
  '{
    "Metric Category": "Performance",
    "Metric Name": "Campaign Performance",
    "Result": "Improved average campaign performance by approximately 45 percent",
    "Trend": "Improved"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001531'::UUID,
  '00000000-0000-0000-0000-000000001303'::UUID,
  '{
    "Metric Category": "Performance",
    "Metric Name": "Donation Conversion Rate",
    "Result": "Increased average donation conversion rates",
    "Trend": "Increased"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001532'::UUID,
  '00000000-0000-0000-0000-000000001303'::UUID,
  '{
    "Metric Category": "Engagement",
    "Metric Name": "Platform Usage",
    "Result": "Higher repeat platform usage and optimization behavior",
    "Trend": "Increased"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001533'::UUID,
  '00000000-0000-0000-0000-000000001303'::UUID,
  '{
    "Metric Category": "Adoption",
    "Metric Name": "Recommendation Acceptance",
    "Result": "High recommendation acceptance rate among fundraisers",
    "Trend": "Strong"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000001534'::UUID,
  '00000000-0000-0000-0000-000000001303'::UUID,
  '{
    "Metric Category": "Strategic Impact",
    "Metric Name": "Platform Transformation",
    "Result": "Established AI-driven best-practice fundraising engine",
    "Trend": "Positive"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: pm@betternow.ai
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000012' with the actual auth.users.id
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
--    - Workspace: BetterNow AI Fundraising Workspace
--    - Project: AI Personalization and Recommendation Engine
--    - 4 Sheets: Project Overview, Trade-Offs, Challenges, KPIs
--    - 17 Rows total across all sheets
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
