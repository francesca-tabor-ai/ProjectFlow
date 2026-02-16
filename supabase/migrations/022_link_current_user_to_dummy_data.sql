-- ============================================================
-- LINK USER TO DUMMY DATA
-- This script links Francesca Tabor to the workspace and project
-- ============================================================
-- Run this in Supabase SQL Editor as postgres role
-- It will link the user by email or UUID
-- ============================================================

DO $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT := 'francesca.tabor.ai@gmail.com';
  v_user_uuid UUID := '60b5a8e6-4700-4143-b0ec-4f445ee04d61'::UUID;
  v_workspace_id UUID := '00000000-0000-0000-0000-000000001700'::UUID;
  v_project_id UUID := '00000000-0000-0000-0000-000000001800'::UUID;
BEGIN
  -- Try to find user by UUID first, then by email
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE id = v_user_uuid 
     OR email = v_user_email
  LIMIT 1;
  
  -- If not found, try to use auth.uid() (works if running as authenticated user)
  IF v_user_id IS NULL THEN
    v_user_id := auth.uid();
  END IF;
  
  -- If still not found, use the provided UUID (assume it exists)
  IF v_user_id IS NULL THEN
    v_user_id := v_user_uuid;
    RAISE NOTICE 'Using provided UUID: %', v_user_id;
  ELSE
    RAISE NOTICE 'Found user ID: %', v_user_id;
  END IF;
  
  -- Ensure profile exists for user
  INSERT INTO profiles (id, name, email, color)
  SELECT 
    v_user_id,
    COALESCE((SELECT name FROM profiles WHERE id = v_user_id), 'Francesca Tabor'),
    COALESCE((SELECT email FROM profiles WHERE id = v_user_id), (SELECT email FROM auth.users WHERE id = v_user_id), v_user_email),
    '#f59e0b'
  WHERE NOT EXISTS (SELECT 1 FROM profiles WHERE id = v_user_id)
  ON CONFLICT (id) DO UPDATE
  SET 
    name = COALESCE(EXCLUDED.name, profiles.name),
    email = COALESCE(EXCLUDED.email, profiles.email),
    color = COALESCE(EXCLUDED.color, profiles.color);
  
  RAISE NOTICE 'Profile ensured for user %', v_user_id;
  
  -- Add user to workspace_members if not already there
  INSERT INTO workspace_members (workspace_id, user_id, role)
  VALUES (v_workspace_id, v_user_id, 'Owner')
  ON CONFLICT (workspace_id, user_id) DO UPDATE
  SET role = 'Owner';
  
  RAISE NOTICE 'Added user to workspace members';
  
  -- Add user to project_members if not already there
  INSERT INTO project_members (project_id, user_id, role)
  VALUES (v_project_id, v_user_id, 'Owner')
  ON CONFLICT (project_id, user_id) DO UPDATE
  SET role = 'Owner';
  
  RAISE NOTICE 'Added user to project members';
  
  RAISE NOTICE 'Successfully linked user % to workspace and project', v_user_id;
END $$;
