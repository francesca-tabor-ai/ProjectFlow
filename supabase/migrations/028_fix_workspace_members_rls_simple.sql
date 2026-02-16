-- ============================================================
-- SIMPLE FIX FOR INFINITE RECURSION IN workspace_members RLS
-- ============================================================
-- The original policy was:
--   workspace_id IN (SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid())
-- This causes infinite recursion because it queries workspace_members
-- while checking if you can query workspace_members.
-- ============================================================
-- Solution: Only check workspace ownership (no recursion)
-- Users can see members if they own the workspace OR are the member themselves
-- ============================================================

-- First, drop any existing problematic policies and functions
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;
DROP FUNCTION IF EXISTS public.check_workspace_membership(UUID, UUID);
DROP FUNCTION IF EXISTS public.user_is_workspace_member(UUID, UUID);

-- Create a simple policy that ONLY checks workspace ownership
-- This avoids recursion because it doesn't query workspace_members at all
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- Option 1: User owns the workspace (no recursion - direct check on workspaces table)
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
  OR
  -- Option 2: User is viewing their own membership record (direct field comparison)
  user_id = auth.uid()
);

-- This policy allows users to see:
-- 1. All members of workspaces they own
-- 2. Their own membership record in any workspace
--
-- This should be sufficient for the app to work. If users need to see
-- other members of workspaces they're members of (but don't own),
-- we can add them as workspace owners via the reassignment scripts.
