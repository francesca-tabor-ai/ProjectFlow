-- ============================================================
-- REASSIGN ALL EXISTING PROJECTS TO FRANCESCA TABOR
-- This script finds all existing projects and associates them
-- with francesca.tabor.ai@gmail.com
-- ============================================================
-- New users will have blank dashboards (no projects)
-- Only Francesca will see all the existing projects
-- ============================================================

DO $$
DECLARE
  v_francesca_id UUID;
  v_francesca_email TEXT := 'francesca.tabor.ai@gmail.com';
  v_francesca_uuid UUID := '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID;
  v_workspace_id UUID;
  v_project_id UUID;
  v_project_count INTEGER := 0;
  v_workspace_count INTEGER := 0;
BEGIN
  -- Find Francesca's user ID
  SELECT id INTO v_francesca_id 
  FROM auth.users 
  WHERE id = v_francesca_uuid 
     OR email = v_francesca_email
  LIMIT 1;
  
  -- If not found, use the provided UUID
  IF v_francesca_id IS NULL THEN
    v_francesca_id := v_francesca_uuid;
    RAISE NOTICE 'Using provided UUID: %', v_francesca_id;
  ELSE
    RAISE NOTICE 'Found Francesca user ID: %', v_francesca_id;
  END IF;
  
  -- Ensure Francesca's profile exists
  INSERT INTO profiles (id, name, email, color)
  SELECT 
    v_francesca_id,
    'Francesca Tabor',
    v_francesca_email,
    '#f59e0b'
  WHERE NOT EXISTS (SELECT 1 FROM profiles WHERE id = v_francesca_id)
  ON CONFLICT (id) DO UPDATE
  SET 
    name = COALESCE(EXCLUDED.name, profiles.name),
    email = COALESCE(EXCLUDED.email, profiles.email),
    color = COALESCE(EXCLUDED.color, profiles.color);
  
  RAISE NOTICE 'Profile ensured for Francesca';
  
  -- Loop through all workspaces and reassign to Francesca
  FOR v_workspace_id IN 
    SELECT id FROM workspaces
  LOOP
    -- Update workspace owner to Francesca
    UPDATE workspaces
    SET owner_id = v_francesca_id
    WHERE id = v_workspace_id;
    
    -- Add Francesca to workspace_members if not already there
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_francesca_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) DO UPDATE
    SET role = 'Owner';
    
    v_workspace_count := v_workspace_count + 1;
  END LOOP;
  
  RAISE NOTICE 'Reassigned % workspaces to Francesca', v_workspace_count;
  
  -- Loop through all projects and reassign to Francesca
  FOR v_project_id IN 
    SELECT id FROM projects
  LOOP
    -- Update project owner to Francesca
    UPDATE projects
    SET owner_id = v_francesca_id
    WHERE id = v_project_id;
    
    -- Get the workspace_id for this project
    SELECT workspace_id INTO v_workspace_id
    FROM projects
    WHERE id = v_project_id;
    
    -- Ensure Francesca is in the workspace (in case project's workspace wasn't updated)
    INSERT INTO workspace_members (workspace_id, user_id, role)
    VALUES (v_workspace_id, v_francesca_id, 'Owner')
    ON CONFLICT (workspace_id, user_id) DO UPDATE
    SET role = 'Owner';
    
    -- Add Francesca to project_members if not already there
    INSERT INTO project_members (project_id, user_id, role)
    VALUES (v_project_id, v_francesca_id, 'Owner')
    ON CONFLICT (project_id, user_id) DO UPDATE
    SET role = 'Owner';
    
    v_project_count := v_project_count + 1;
  END LOOP;
  
  RAISE NOTICE 'Reassigned % projects to Francesca', v_project_count;
  RAISE NOTICE 'Successfully completed! Francesca now owns all % workspaces and % projects', v_workspace_count, v_project_count;
END $$;
