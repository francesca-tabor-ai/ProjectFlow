-- ============================================================
-- MINIMAL FIX FOR INFINITE RECURSION IN workspace_members RLS
-- ============================================================
-- Following the recommended pattern: minimal SELECT policy
-- ============================================================

-- Step 1: Drop all existing problematic policies and functions
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;
DROP FUNCTION IF EXISTS public.is_workspace_member(UUID);
DROP FUNCTION IF EXISTS public.check_workspace_membership(UUID, UUID);
DROP FUNCTION IF EXISTS public.user_is_workspace_member(UUID, UUID);

-- Step 2: Create minimal SELECT policy
-- This policy avoids recursion by:
-- 1. Allowing users to see their own membership row (direct field comparison)
-- 2. Allowing workspace owners to see all members (queries workspaces, not workspace_members)
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- Option 1: User is viewing their own membership (no query, direct comparison)
  user_id = auth.uid()
  OR
  -- Option 2: User owns the workspace (queries workspaces table, not workspace_members)
  EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = workspace_members.workspace_id 
    AND owner_id = auth.uid()
  )
);

-- ============================================================
-- VERIFICATION
-- ============================================================
-- This policy allows:
-- 1. Users to see their own membership row (user_id = auth.uid())
-- 2. Workspace owners to see all members of their workspaces
--
-- This avoids recursion because:
-- - It never queries workspace_members within the policy
-- - It only checks workspace ownership (workspaces table)
-- - It uses direct field comparison for self-membership
--
-- The projects policy will work because:
-- - It checks: workspace_id IN (SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid())
-- - Users can see their own workspace_members row, so this query will work
-- - Workspace owners can see all members, so they'll see all projects
-- ============================================================
