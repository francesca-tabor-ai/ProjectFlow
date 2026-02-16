-- ============================================================
-- PROPER FIX FOR INFINITE RECURSION IN workspace_members RLS
-- ============================================================
-- Implements Option A: SECURITY DEFINER helper function
-- ============================================================

-- Step 1: Drop existing problematic policies and functions
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;
DROP FUNCTION IF EXISTS public.check_workspace_membership(UUID, UUID);
DROP FUNCTION IF EXISTS public.user_is_workspace_member(UUID, UUID);
DROP FUNCTION IF EXISTS public.is_workspace_member(UUID);

-- Step 2: Create a SECURITY DEFINER helper function
-- This function bypasses RLS, so it can check membership without recursion
CREATE OR REPLACE FUNCTION public.is_workspace_member(p_workspace_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
STABLE
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Get the current user ID
  v_user_id := auth.uid();
  
  -- If no user, return false
  IF v_user_id IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Check if user owns the workspace (fast path, no RLS)
  IF EXISTS (
    SELECT 1 FROM public.workspaces 
    WHERE id = p_workspace_id AND owner_id = v_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- Check membership directly (SECURITY DEFINER bypasses RLS)
  -- This is safe because the function runs with elevated privileges
  RETURN EXISTS (
    SELECT 1 FROM public.workspace_members
    WHERE workspace_id = p_workspace_id 
    AND user_id = v_user_id
  );
END;
$$;

-- Step 3: Create the RLS policy using the helper function
-- This avoids recursion because the function uses SECURITY DEFINER
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- Option 1: User owns the workspace (direct check, no recursion)
  EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = workspace_members.workspace_id 
    AND owner_id = auth.uid()
  )
  OR
  -- Option 2: User is viewing their own membership record
  user_id = auth.uid()
  OR
  -- Option 3: User is a member (using helper function to avoid recursion)
  public.is_workspace_member(workspace_members.workspace_id)
);

-- Step 4: Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.is_workspace_member(UUID) TO authenticated;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- After running this migration:
-- 1. The /projects?select=... request should return 200
-- 2. Users can see workspace_members for workspaces they own or are members of
-- 3. No infinite recursion errors
-- ============================================================
