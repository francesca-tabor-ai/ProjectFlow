-- ============================================================
-- FIX LOGGED-IN USER ACCESS TO PROJECTS
-- This script links the currently logged-in user to all workspaces
-- ============================================================
-- The issue: RLS uses auth.uid() which is the logged-in user's ID
-- If you're logged in with a different ID than Francesca's database ID,
-- you won't see the projects even though Francesca "owns" them
-- ============================================================

-- First, let's see what user you're actually logged in as
-- Run this query while logged into the app to see your auth.uid()
SELECT 
  'Your logged-in user ID' as info,
  auth.uid() as your_user_id,
  (SELECT email FROM auth.users WHERE id = auth.uid()) as your_email;

-- If auth.uid() is NULL (running as postgres), we'll find Francesca by email
DO $$
DECLARE
  v_logged_in_user_id UUID;
  v_francesca_id UUID;
  v_francesca_email TEXT := 'francesca.tabor.ai@gmail.com';
  v_francesca_uuid UUID := '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID;
  v_workspace_id UUID;
  v_project_id UUID;
  v_workspaces_fixed INTEGER := 0;
  v_projects_fixed INTEGER := 0;
BEGIN
  -- Try to get the logged-in user ID
  v_logged_in_user_id := auth.uid();
  
  -- If not logged in (running as postgres), find Francesca by email/UUID
  IF v_logged_in_user_id IS NULL THEN
    SELECT id INTO v_logged_in_user_id
    FROM auth.users
    WHERE id = v_francesca_uuid
       OR email = v_francesca_email
    LIMIT 1;
    
    IF v_logged_in_user_id IS NULL THEN
      RAISE EXCEPTION 'Could not find Francesca user. Please ensure you are logged in or the user exists.';
    END IF;
    
    RAISE NOTICE 'Running as postgres role. Using Francesca user ID: %', v_logged_in_user_id;
  ELSE
    RAISE NOTICE 'Detected logged-in user ID: %', v_logged_in_user_id;
    
    -- Check if this is Francesca
    IF v_logged_in_user_id = v_francesca_uuid THEN
      RAISE NOTICE 'Confirmed: This is Francesca!';
    ELSE
      RAISE NOTICE 'NOTE: Logged-in user (%) is different from Francesca (%). Linking both users to all workspaces.', 
        v_logged_in_user_id, v_francesca_uuid;
      
      -- Also get Francesca's ID for linking
      SELECT id INTO v_francesca_id
      FROM auth.users
      WHERE id = v_francesca_uuid
         OR email = v_francesca_email
      LIMIT 1;
    END IF;
  END IF;
  
  -- Ensure profile exists for logged-in user
  INSERT INTO profiles (id, name, email, color)
  SELECT 
    v_logged_in_user_id,
    COALESCE((SELECT name FROM profiles WHERE id = v_logged_in_user_id), 'User'),
    COALESCE((SELECT email FROM profiles WHERE id = v_logged_in_user_id), (SELECT email FROM auth.users WHERE id = v_logged_in_user_id)),
    '#f59e0b'
  WHERE NOT EXISTS (SELECT 1 FROM profiles WHERE id = v_logged_in_user_id)
  ON CONFLICT (id) DO NOTHING;
  
  -- Link logged-in user to ALL workspaces
  FOR v_workspace_id IN SELECT id FROM workspaces
  LOOP
    -- Add to workspace_members (this is what RLS checks!)
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_logged_in_user_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'Owner';
    
    v_workspaces_fixed := v_workspaces_fixed + 1;
  END LOOP;
  
  RAISE NOTICE 'Added logged-in user to % workspaces', v_workspaces_fixed;
  
  -- Link logged-in user to ALL projects
  FOR v_project_id IN SELECT id FROM projects
  LOOP
    -- Get workspace for this project
    SELECT workspace_id INTO v_workspace_id FROM projects WHERE id = v_project_id;
    
    -- Ensure user is in workspace_members (critical for RLS)
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_logged_in_user_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'Owner';
    
    -- Add to project_members
    INSERT INTO project_members (project_id, user_id, role)
    VALUES (v_project_id, v_logged_in_user_id, 'Owner')
    ON CONFLICT (project_id, user_id) DO UPDATE SET role = 'Owner';
    
    v_projects_fixed := v_projects_fixed + 1;
  END LOOP;
  
  RAISE NOTICE 'Added logged-in user to % projects', v_projects_fixed;
  
  -- If logged-in user is different from Francesca, also ensure Francesca is linked
  IF v_francesca_id IS NOT NULL AND v_logged_in_user_id != v_francesca_id THEN
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
    
    RAISE NOTICE 'Francesca also has access to all workspaces and projects';
  END IF;
  
  RAISE NOTICE 'SUCCESS! You should now see all % projects on your dashboard', v_projects_fixed;
  RAISE NOTICE 'Please refresh your browser to see the changes.';
END $$;

-- Verification: Check what projects the logged-in user can see
-- (This will show NULL if running as postgres, but will work when logged in)
SELECT 
  'VERIFICATION: Projects you can see' as check_type,
  p.id as project_id,
  p.name as project_name,
  w.name as workspace_name,
  CASE 
    WHEN auth.uid() IS NULL THEN 'Run this while logged into the app'
    WHEN EXISTS (
      SELECT 1 FROM workspace_members wm 
      WHERE wm.workspace_id = p.workspace_id 
      AND wm.user_id = auth.uid()
    ) THEN '✓ VISIBLE'
    ELSE '✗ NOT VISIBLE'
  END as status
FROM projects p
JOIN workspaces w ON w.id = p.workspace_id
ORDER BY p.created_at DESC;
