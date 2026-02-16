-- ============================================================
-- AI SURGERY ASSISTANT IMPLEMENTATION ROADMAP
-- Project tracking structure for discovery → production
-- ============================================================
-- This project tracks delivery stages with owners, dates, and progress
-- ============================================================

DO $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT := 'francesca.tabor.ai@gmail.com';
  v_user_uuid UUID := '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID;
  v_workspace_id UUID;
  v_project_id UUID;
  v_sheet_id UUID;
BEGIN
  -- Find Francesca's user ID
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE id = v_user_uuid 
     OR email = v_user_email
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    v_user_id := v_user_uuid;
  END IF;
  
  -- Ensure profile exists
  INSERT INTO profiles (id, name, email, color)
  VALUES (v_user_id, 'Francesca Tabor', v_user_email, '#f59e0b')
  ON CONFLICT (id) DO UPDATE
  SET name = EXCLUDED.name, email = EXCLUDED.email, color = EXCLUDED.color;
  
  -- Create workspace
  v_workspace_id := '00000000-0000-0000-0000-000000002000'::UUID;
  INSERT INTO workspaces (id, name, owner_id) VALUES
  (v_workspace_id, 'AI Surgery Assistant Workspace', v_user_id)
  ON CONFLICT (id) DO NOTHING;
  
  -- Add workspace member
  INSERT INTO workspace_members (workspace_id, user_id, role)
  VALUES (v_workspace_id, v_user_id, 'Owner')
  ON CONFLICT (workspace_id, user_id) DO NOTHING;
  
  -- Create project
  v_project_id := '00000000-0000-0000-0000-000000002100'::UUID;
  INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
  (
    v_project_id,
    v_workspace_id,
    v_user_id,
    'AI Surgery Assistant Implementation Roadmap',
    NULL  -- Will be set after sheets are created
  )
  ON CONFLICT (id) DO NOTHING;
  
  -- Add project member
  INSERT INTO project_members (project_id, user_id, role)
  VALUES (v_project_id, v_user_id, 'Owner')
  ON CONFLICT (project_id, user_id) DO NOTHING;
  
  -- Create main tracking sheet
  v_sheet_id := '00000000-0000-0000-0000-000000002200'::UUID;
  INSERT INTO sheets (id, project_id, name) VALUES
  (v_sheet_id, v_project_id, 'Implementation Stages')
  ON CONFLICT (id) DO NOTHING;
  
  -- Update project with active sheet
  UPDATE projects
  SET active_sheet_id = v_sheet_id
  WHERE id = v_project_id;
  
  -- Create columns for the Implementation Roadmap
  INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
  -- Implementation Stage
  ('00000000-0000-0000-0000-000000002300'::UUID, v_sheet_id, 'Implementation Stage', 'text', 350, 1, NULL),
  -- Lead SME
  ('00000000-0000-0000-0000-000000002301'::UUID, v_sheet_id, 'Lead SME', 'text', 200, 2, NULL),
  -- Status
  ('00000000-0000-0000-0000-000000002302'::UUID, v_sheet_id, 'Status', 'dropdown', 150, 3, '["Discovery", "Validation", "Pilot", "Production"]'::jsonb),
  -- Start Date
  ('00000000-0000-0000-0000-000000002303'::UUID, v_sheet_id, 'Start Date', 'date', 120, 4, NULL),
  -- To Date
  ('00000000-0000-0000-0000-000000002304'::UUID, v_sheet_id, 'To Date', 'date', 120, 5, NULL),
  -- % Complete
  ('00000000-0000-0000-0000-000000002305'::UUID, v_sheet_id, '% Complete', 'number', 120, 6, NULL),
  -- Notes
  ('00000000-0000-0000-0000-000000002306'::UUID, v_sheet_id, 'Notes', 'text', 400, 7, NULL)
  ON CONFLICT (id) DO NOTHING;
  
  -- Add example rows with instructions
  INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
  (
    '00000000-0000-0000-0000-000000002400'::UUID,
    v_sheet_id,
    '{
      "Implementation Stage": "Clinical Scope Definition (Thyroid)",
      "Lead SME": "Dr. Smith",
      "Status": "Discovery",
      "Start Date": "2024-01-15",
      "To Date": "2024-02-15",
      "% Complete": 25,
      "Notes": "Requirements and stakeholders identified"
    }'::jsonb,
    ARRAY[]::TEXT[]
  ),
  (
    '00000000-0000-0000-0000-000000002401'::UUID,
    v_sheet_id,
    '{
      "Implementation Stage": "Safety Validation Protocol",
      "Lead SME": "Dr. Jones",
      "Status": "Validation",
      "Start Date": "2024-02-01",
      "To Date": "2024-03-15",
      "% Complete": 50,
      "Notes": "Safety checks in progress"
    }'::jsonb,
    ARRAY[]::TEXT[]
  ),
  (
    '00000000-0000-0000-0000-000000002402'::UUID,
    v_sheet_id,
    '{
      "Implementation Stage": "Pilot Deployment (OR #3)",
      "Lead SME": "Nurse Manager",
      "Status": "Pilot",
      "Start Date": "2024-03-20",
      "To Date": "2024-05-01",
      "% Complete": 0,
      "Notes": "Scheduled for Q2"
    }'::jsonb,
    ARRAY[]::TEXT[]
  )
  ON CONFLICT (id) DO NOTHING;
  
END $$;

-- ============================================================
-- NOTES
-- ============================================================
-- This project structure includes:
-- 1. Implementation Stage: Short, action-based title
-- 2. Lead SME: One accountable owner
-- 3. Status: Discovery / Validation / Pilot / Production
-- 4. Start Date / To Date: YYYY-MM-DD format
-- 5. % Complete: 0-100, updated weekly
-- 6. Notes: Additional context and updates
--
-- Progress rules:
-- 0-10%: Defined scope, success criteria drafted
-- 25%: Plan and stakeholders aligned
-- 50%: Work in progress; first usable outputs exist
-- 75%: Testing/validation underway; issues tracked
-- 90%: Final checks + sign-offs pending
-- 100%: Delivered, documented, and handed over
--
-- Update cadence: Every Friday
-- ============================================================
