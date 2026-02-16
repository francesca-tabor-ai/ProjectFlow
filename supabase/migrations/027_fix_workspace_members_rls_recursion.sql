-- ============================================================
-- FIX INFINITE RECURSION IN workspace_members RLS POLICY
-- ============================================================
-- The issue: The policy queries workspace_members to check
-- if a user can view workspace_members, causing infinite recursion
-- ============================================================
-- Solution: Check workspace ownership directly instead
-- ============================================================

-- Drop the problematic policy
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;

-- Create a fixed policy that checks workspace ownership directly
-- This avoids recursion by querying workspaces instead of workspace_members
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- User can see members if they own the workspace
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
  OR
  -- OR if they are the member themselves (direct check, no recursion)
  user_id = auth.uid()
  OR
  -- OR if they are already a member (but we need to check this carefully)
  -- We'll use a function to break the recursion
  EXISTS (
    SELECT 1 FROM workspaces w
    WHERE w.id = workspace_members.workspace_id
    AND (
      w.owner_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM workspace_members wm2
        WHERE wm2.workspace_id = w.id
        AND wm2.user_id = auth.uid()
        -- Use a different approach: check if workspace is owned by user
        -- This breaks the recursion by checking ownership first
      )
    )
  )
);

-- Actually, the above is still complex. Let's use a simpler approach:
-- Allow users to see members of workspaces they own OR workspaces where they are members
-- But we need to break the recursion. The best way is to check workspace ownership first.

DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;

-- Simple fix: Check workspace ownership OR direct membership
-- We check ownership first (no recursion), then allow if user is the member themselves
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- Option 1: User owns the workspace (no recursion, direct check)
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
  OR
  -- Option 2: User is viewing their own membership record
  user_id = auth.uid()
);

-- However, this might be too restrictive. Let's also allow users to see
-- members of workspaces they're members of, but we need to do this safely.
-- The key is to use a SECURITY DEFINER function or check ownership first.

-- Better approach: Use a function that checks membership without recursion
CREATE OR REPLACE FUNCTION public.user_is_workspace_member(p_workspace_id UUID, p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  -- Check if user owns the workspace (fast path, no recursion)
  SELECT EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = p_workspace_id AND owner_id = p_user_id
  )
  OR
  -- Check direct membership (this is safe because the function is SECURITY DEFINER
  -- and doesn't trigger RLS policies)
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_id = p_workspace_id 
    AND user_id = p_user_id
  );
$$;

-- Now update the policy to use this function
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;

CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- User can see members if they own the workspace
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
  OR
  -- OR if they are viewing their own record
  user_id = auth.uid()
  OR
  -- OR if they are a member (using the function to avoid recursion)
  public.user_is_workspace_member(workspace_id, auth.uid())
);

-- Actually, wait - the function will still hit RLS on workspace_members.
-- Let's use a different approach: check workspace ownership OR allow
-- users to see members of workspaces they can access via the workspaces policy.

-- The cleanest solution: Since workspaces policy already checks membership,
-- we can allow users to see workspace_members if they can see the workspace.
-- But that might still cause issues.

-- Final solution: Use SECURITY DEFINER function to break recursion
-- This function bypasses RLS, so it can check membership without recursion
CREATE OR REPLACE FUNCTION public.check_workspace_membership(p_workspace_id UUID, p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  -- Check if user owns the workspace (fast path, no RLS on workspaces for this)
  IF EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = p_workspace_id AND owner_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- Check membership directly (SECURITY DEFINER bypasses RLS)
  RETURN EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_id = p_workspace_id 
    AND user_id = p_user_id
  );
END;
$$;

-- Now create the policy using the function
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;

CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- User owns the workspace
  EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = workspace_members.workspace_id 
    AND owner_id = auth.uid()
  )
  OR
  -- User is viewing their own membership
  user_id = auth.uid()
  OR
  -- User is a member (using function to avoid recursion)
  public.check_workspace_membership(workspace_id, auth.uid())
);
