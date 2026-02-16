-- ============================================================
-- VERIFICATION SCRIPT FOR DUMMY DATA
-- Run this to check if the dummy data is properly set up
-- ============================================================

-- Check if user exists in auth.users
SELECT 
  'User in auth.users' as check_type,
  CASE 
    WHEN EXISTS(SELECT 1 FROM auth.users WHERE id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID) 
    THEN '✓ EXISTS' 
    ELSE '✗ MISSING' 
  END as status,
  (SELECT email FROM auth.users WHERE id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID) as email;

-- Check if profile exists
SELECT 
  'Profile exists' as check_type,
  CASE 
    WHEN EXISTS(SELECT 1 FROM profiles WHERE id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID) 
    THEN '✓ EXISTS' 
    ELSE '✗ MISSING' 
  END as status,
  (SELECT name FROM profiles WHERE id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID) as name;

-- Check if workspace exists
SELECT 
  'Workspace exists' as check_type,
  CASE 
    WHEN EXISTS(SELECT 1 FROM workspaces WHERE id = '00000000-0000-0000-0000-000000001700'::UUID) 
    THEN '✓ EXISTS' 
    ELSE '✗ MISSING' 
  END as status,
  (SELECT name FROM workspaces WHERE id = '00000000-0000-0000-0000-000000001700'::UUID) as name;

-- Check if workspace member exists
SELECT 
  'Workspace member exists' as check_type,
  CASE 
    WHEN EXISTS(
      SELECT 1 FROM workspace_members 
      WHERE workspace_id = '00000000-0000-0000-0000-000000001700'::UUID 
      AND user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID
    ) 
    THEN '✓ EXISTS' 
    ELSE '✗ MISSING' 
  END as status,
  (SELECT role FROM workspace_members 
   WHERE workspace_id = '00000000-0000-0000-0000-000000001700'::UUID 
   AND user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID) as role;

-- Check if project exists
SELECT 
  'Project exists' as check_type,
  CASE 
    WHEN EXISTS(SELECT 1 FROM projects WHERE id = '00000000-0000-0000-0000-000000001800'::UUID) 
    THEN '✓ EXISTS' 
    ELSE '✗ MISSING' 
  END as status,
  (SELECT name FROM projects WHERE id = '00000000-0000-0000-0000-000000001800'::UUID) as name;

-- Check if project member exists
SELECT 
  'Project member exists' as check_type,
  CASE 
    WHEN EXISTS(
      SELECT 1 FROM project_members 
      WHERE project_id = '00000000-0000-0000-0000-000000001800'::UUID 
      AND user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID
    ) 
    THEN '✓ EXISTS' 
    ELSE '✗ MISSING' 
  END as status,
  (SELECT role FROM project_members 
   WHERE project_id = '00000000-0000-0000-0000-000000001800'::UUID 
   AND user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID) as role;

-- Count sheets
SELECT 
  'Sheets count' as check_type,
  COUNT(*)::text as status,
  NULL as name
FROM sheets 
WHERE project_id = '00000000-0000-0000-0000-000000001800'::UUID;

-- Count rows
SELECT 
  'Rows count' as check_type,
  COUNT(*)::text as status,
  NULL as name
FROM rows 
WHERE sheet_id IN (
  SELECT id FROM sheets WHERE project_id = '00000000-0000-0000-0000-000000001800'::UUID
);

-- ============================================================
-- FIX SCRIPT: If user is logged in with a different UUID,
-- run this to link your current user to the workspace
-- ============================================================
-- Replace 'YOUR_CURRENT_USER_ID' with your actual auth.uid()
-- You can get it by running: SELECT auth.uid();

/*
DO $$
DECLARE
  v_current_user_id UUID := auth.uid(); -- Your logged-in user ID
  v_dummy_user_id UUID := '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID;
BEGIN
  -- If you're logged in with a different UUID, link yourself to the workspace
  IF v_current_user_id IS NOT NULL AND v_current_user_id != v_dummy_user_id THEN
    -- Add yourself to workspace_members
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (
      '00000000-0000-0000-0000-000000001700'::UUID,
      v_current_user_id,
      'Owner'
    )
    ON CONFLICT (workspace_id, user_id) DO UPDATE
    SET role = 'Owner';
    
    -- Add yourself to project_members
    INSERT INTO project_members (project_id, user_id, role)
    VALUES (
      '00000000-0000-0000-0000-000000001800'::UUID,
      v_current_user_id,
      'Owner'
    )
    ON CONFLICT (project_id, user_id) DO UPDATE
    SET role = 'Owner';
    
    RAISE NOTICE 'Linked user % to workspace and project', v_current_user_id;
  END IF;
END $$;
*/
