-- ============================================================
-- DIAGNOSE AND FIX PROJECT VISIBILITY ISSUES
-- This script checks why projects aren't showing and fixes it
-- ============================================================

-- Step 1: Check Francesca's user account
SELECT 
  'Francesca User Check' as check_type,
  id as user_id,
  email,
  CASE 
    WHEN id IS NOT NULL THEN '✓ EXISTS'
    ELSE '✗ MISSING'
  END as status
FROM auth.users 
WHERE id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID
   OR email = 'francesca.tabor.ai@gmail.com'
LIMIT 1;

-- Step 2: Check all workspaces and their owners
SELECT 
  'Workspaces' as check_type,
  id as workspace_id,
  name,
  owner_id,
  CASE 
    WHEN owner_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID THEN '✓ Owned by Francesca'
    ELSE '✗ Not owned by Francesca'
  END as ownership_status
FROM workspaces
ORDER BY created_at DESC;

-- Step 3: Check workspace memberships for Francesca
SELECT 
  'Workspace Memberships' as check_type,
  wm.workspace_id,
  w.name as workspace_name,
  wm.user_id,
  wm.role,
  CASE 
    WHEN wm.user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID THEN '✓ Francesca is member'
    ELSE '✗ Francesca NOT a member'
  END as membership_status
FROM workspace_members wm
JOIN workspaces w ON w.id = wm.workspace_id
WHERE wm.user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID
ORDER BY w.created_at DESC;

-- Step 4: Check all projects and their workspaces
SELECT 
  'Projects' as check_type,
  p.id as project_id,
  p.name as project_name,
  p.workspace_id,
  w.name as workspace_name,
  p.owner_id,
  CASE 
    WHEN p.owner_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID THEN '✓ Owned by Francesca'
    ELSE '✗ Not owned by Francesca'
  END as ownership_status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM workspace_members wm 
      WHERE wm.workspace_id = p.workspace_id 
      AND wm.user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID
    ) THEN '✓ Francesca can see (in workspace_members)'
    ELSE '✗ Francesca CANNOT see (not in workspace_members)'
  END as visibility_status
FROM projects p
LEFT JOIN workspaces w ON w.id = p.workspace_id
ORDER BY p.created_at DESC;

-- ============================================================
-- FIX SCRIPT: Ensure Francesca can see all projects
-- ============================================================

DO $$
DECLARE
  v_francesca_id UUID := '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID;
  v_francesca_email TEXT := 'francesca.tabor.ai@gmail.com';
  v_workspace_id UUID;
  v_project_id UUID;
  v_fixed_workspaces INTEGER := 0;
  v_fixed_projects INTEGER := 0;
BEGIN
  -- Find Francesca's actual user ID
  SELECT id INTO v_francesca_id 
  FROM auth.users 
  WHERE id = v_francesca_id 
     OR email = v_francesca_email
  LIMIT 1;
  
  IF v_francesca_id IS NULL THEN
    RAISE EXCEPTION 'Francesca user not found. Please check the user ID or email.';
  END IF;
  
  RAISE NOTICE 'Using Francesca user ID: %', v_francesca_id;
  
  -- Ensure profile exists
  INSERT INTO profiles (id, name, email, color)
  VALUES (v_francesca_id, 'Francesca Tabor', v_francesca_email, '#f59e0b')
  ON CONFLICT (id) DO UPDATE
  SET name = EXCLUDED.name, email = EXCLUDED.email, color = EXCLUDED.color;
  
  -- Fix all workspaces: ensure Francesca is owner and member
  FOR v_workspace_id IN SELECT id FROM workspaces
  LOOP
    -- Update owner
    UPDATE workspaces SET owner_id = v_francesca_id WHERE id = v_workspace_id;
    
    -- Add to workspace_members
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_francesca_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'Owner';
    
    v_fixed_workspaces := v_fixed_workspaces + 1;
  END LOOP;
  
  RAISE NOTICE 'Fixed % workspaces', v_fixed_workspaces;
  
  -- Fix all projects: ensure Francesca is owner and member
  FOR v_project_id IN SELECT id FROM projects
  LOOP
    -- Update owner
    UPDATE projects SET owner_id = v_francesca_id WHERE id = v_project_id;
    
    -- Get workspace for this project
    SELECT workspace_id INTO v_workspace_id FROM projects WHERE id = v_project_id;
    
    -- Ensure Francesca is in workspace_members (critical for RLS!)
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_francesca_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'Owner';
    
    -- Add to project_members
    INSERT INTO project_members (project_id, user_id, role)
    VALUES (v_project_id, v_francesca_id, 'Owner')
    ON CONFLICT (project_id, user_id) DO UPDATE SET role = 'Owner';
    
    v_fixed_projects := v_fixed_projects + 1;
  END LOOP;
  
  RAISE NOTICE 'Fixed % projects', v_fixed_projects;
  RAISE NOTICE 'SUCCESS! Francesca should now see all % workspaces and % projects', v_fixed_workspaces, v_fixed_projects;
END $$;

-- Step 5: Verify the fix - check what Francesca can see
SELECT 
  'VERIFICATION: Projects Francesca can see' as check_type,
  p.id as project_id,
  p.name as project_name,
  w.name as workspace_name,
  '✓ VISIBLE' as status
FROM projects p
JOIN workspaces w ON w.id = p.workspace_id
WHERE p.workspace_id IN (
  SELECT workspace_id FROM workspace_members 
  WHERE user_id = '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID
)
ORDER BY p.created_at DESC;
