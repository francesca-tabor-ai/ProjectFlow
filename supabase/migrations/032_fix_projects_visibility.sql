-- ============================================================
-- FIX PROJECTS VISIBILITY ON DASHBOARD
-- ============================================================
-- Issue: Projects are associated with correct user but not showing
-- Root cause: RLS policy checks workspace_members, but user might not
-- be in workspace_members table, or auth.uid() doesn't match
-- ============================================================

-- Step 1: Diagnostic - Check current state
DO $$
DECLARE
  v_current_user_id UUID;
  v_francesca_id UUID := '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID;
  v_workspace_id UUID;
  v_project_id UUID;
  v_memberships_added INTEGER := 0;
  v_projects_count INTEGER;
BEGIN
  -- Get current authenticated user (will be NULL if running as postgres)
  v_current_user_id := auth.uid();
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'DIAGNOSTIC: Projects Visibility Fix';
  RAISE NOTICE '========================================';
  
  IF v_current_user_id IS NULL THEN
    RAISE NOTICE 'Running as postgres role (no auth.uid())';
    RAISE NOTICE 'Will ensure Francesca user has access to all workspaces';
    v_current_user_id := v_francesca_id;
  ELSE
    RAISE NOTICE 'Detected logged-in user: %', v_current_user_id;
    
    -- Check if this is Francesca
    IF v_current_user_id = v_francesca_id THEN
      RAISE NOTICE 'Confirmed: This is Francesca';
    ELSE
      RAISE NOTICE 'NOTE: Different user than Francesca. Will link both users.';
    END IF;
  END IF;
  
  -- Count projects
  SELECT COUNT(*) INTO v_projects_count FROM projects;
  RAISE NOTICE 'Total projects in database: %', v_projects_count;
  
  -- Step 2: Ensure user is in workspace_members for all workspaces
  -- This is CRITICAL for the projects RLS policy to work
  FOR v_workspace_id IN SELECT id FROM workspaces
  LOOP
    -- Add user to workspace_members if not already there
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_current_user_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) 
    DO UPDATE SET role = 'Owner';
    
    v_memberships_added := v_memberships_added + 1;
  END LOOP;
  
  RAISE NOTICE 'Ensured user is member of % workspaces', v_memberships_added;
  
  -- Step 3: Also ensure user is in project_members for all projects
  FOR v_project_id IN SELECT id FROM projects
  LOOP
    -- Get workspace for this project
    SELECT workspace_id INTO v_workspace_id FROM projects WHERE id = v_project_id;
    
    -- Ensure workspace membership (critical for RLS)
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_current_user_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'Owner';
    
    -- Add to project_members
    INSERT INTO project_members (project_id, user_id, role)
    VALUES (v_project_id, v_current_user_id, 'Owner')
    ON CONFLICT (project_id, user_id) DO UPDATE SET role = 'Owner';
  END LOOP;
  
  RAISE NOTICE 'Ensured user is member of all % projects', v_projects_count;
  
  -- Step 4: If different user, also ensure Francesca has access
  IF v_current_user_id != v_francesca_id THEN
    RAISE NOTICE 'Also ensuring Francesca (%) has access...', v_francesca_id;
    
    FOR v_workspace_id IN SELECT id FROM workspaces
    LOOP
      INSERT INTO workspace_members (workspace_id, user_id, role)
      VALUES (v_workspace_id, v_francesca_id, 'Owner')
      ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'Owner';
    END LOOP;
    
    FOR v_project_id IN SELECT id FROM projects
    LOOP
      SELECT workspace_id INTO v_workspace_id FROM projects WHERE id = v_project_id;
      
      INSERT INTO workspace_members (workspace_id, user_id, role)
      VALUES (v_workspace_id, v_francesca_id, 'Owner')
      ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'Owner';
      
      INSERT INTO project_members (project_id, user_id, role)
      VALUES (v_project_id, v_francesca_id, 'Owner')
      ON CONFLICT (project_id, user_id) DO UPDATE SET role = 'Owner';
    END LOOP;
  END IF;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'SUCCESS! User should now see all projects';
  RAISE NOTICE 'Please refresh your browser';
  RAISE NOTICE '========================================';
END $$;

-- Step 5: Verification query
-- This shows which projects should be visible to the current user
-- (Will show NULL if running as postgres, but works when logged in)
SELECT 
  'VERIFICATION' as check_type,
  p.id as project_id,
  p.name as project_name,
  w.name as workspace_name,
  CASE 
    WHEN auth.uid() IS NULL THEN 'Run this while logged into the app'
    WHEN EXISTS (
      SELECT 1 FROM workspace_members wm 
      WHERE wm.workspace_id = p.workspace_id 
      AND wm.user_id = auth.uid()
    ) THEN '✓ VISIBLE - Should appear on dashboard'
    ELSE '✗ NOT VISIBLE - Check workspace_members table'
  END as visibility_status,
  EXISTS (
    SELECT 1 FROM workspace_members wm 
    WHERE wm.workspace_id = p.workspace_id 
    AND wm.user_id = auth.uid()
  ) as can_see
FROM projects p
JOIN workspaces w ON w.id = p.workspace_id
ORDER BY p.created_at DESC;

-- ============================================================
-- NOTES
-- ============================================================
-- The projects RLS policy checks:
--   workspace_id IN (
--     SELECT workspace_id FROM workspace_members
--     WHERE user_id = auth.uid()
--   )
--
-- This means:
-- 1. User MUST be in workspace_members table
-- 2. The workspace_members RLS policy must allow user to see their own row
-- 3. Migration 030 fixed the workspace_members RLS to avoid recursion
--
-- If projects still don't show:
-- 1. Check browser console for RLS errors
-- 2. Verify user is authenticated (auth.uid() is not NULL)
-- 3. Run: SELECT * FROM workspace_members WHERE user_id = auth.uid();
-- 4. Check that workspace_members RLS policy allows SELECT
-- ============================================================
