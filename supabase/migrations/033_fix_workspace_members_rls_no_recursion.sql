-- ============================================================
-- FIX INFINITE RECURSION IN workspace_members RLS POLICY
-- ============================================================
-- Error: "infinite recursion detected in policy for relation workspace_members"
-- Code: 42P17
-- ============================================================
-- The problem: The original policy queries workspace_members
-- to check if you can query workspace_members (infinite loop)
-- ============================================================
-- Solution: Use ONLY direct field comparisons and workspace
-- ownership checks. Never query workspace_members within the policy.
-- ============================================================

-- Step 1: Drop ALL existing policies on workspace_members
-- This ensures we start clean
DROP POLICY IF EXISTS "Users can view workspace members" ON workspace_members;
DROP POLICY IF EXISTS "Owners can add workspace members" ON workspace_members;
DROP POLICY IF EXISTS "Owners can update workspace members" ON workspace_members;
DROP POLICY IF EXISTS "Owners can remove workspace members" ON workspace_members;

-- Step 2: Drop any helper functions that might cause issues
DROP FUNCTION IF EXISTS public.is_workspace_member(UUID);
DROP FUNCTION IF EXISTS public.check_workspace_membership(UUID, UUID);
DROP FUNCTION IF EXISTS public.user_is_workspace_member(UUID, UUID);

-- Step 3: Create a SAFE SELECT policy with NO recursion
-- This policy allows:
-- 1. Users to see their own membership row (direct field comparison - no query)
-- 2. Workspace owners to see all members (queries workspaces, NOT workspace_members)
CREATE POLICY "Users can view workspace members"
ON workspace_members FOR SELECT
USING (
  -- Option 1: User is viewing their own membership row
  -- Direct field comparison - NO query, NO recursion
  user_id = auth.uid()
  OR
  -- Option 2: User owns the workspace
  -- Queries workspaces table (safe, no recursion)
  EXISTS (
    SELECT 1 FROM workspaces 
    WHERE id = workspace_members.workspace_id 
    AND owner_id = auth.uid()
  )
);

-- Step 4: Create INSERT policy (for adding members)
-- Only workspace owners can add members
CREATE POLICY "Owners can add workspace members"
ON workspace_members FOR INSERT
WITH CHECK (
  -- Check workspace ownership (queries workspaces, safe)
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);

-- Step 5: Create UPDATE policy (for updating member roles)
-- Only workspace owners can update members
CREATE POLICY "Owners can update workspace members"
ON workspace_members FOR UPDATE
USING (
  -- Check workspace ownership (queries workspaces, safe)
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);

-- Step 6: Create DELETE policy (for removing members)
-- Only workspace owners can remove members
CREATE POLICY "Owners can remove workspace members"
ON workspace_members FOR DELETE
USING (
  -- Check workspace ownership (queries workspaces, safe)
  workspace_id IN (
    SELECT id FROM workspaces WHERE owner_id = auth.uid()
  )
);

-- ============================================================
-- VERIFICATION
-- ============================================================
-- This policy structure avoids recursion because:
--
-- 1. SELECT policy:
--    - user_id = auth.uid() → Direct comparison, no query
--    - EXISTS (SELECT FROM workspaces) → Queries workspaces, NOT workspace_members
--
-- 2. INSERT/UPDATE/DELETE policies:
--    - All query workspaces table only, never workspace_members
--
-- 3. The projects RLS policy will work because:
--    - It queries: SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
--    - Users can see their own membership row (user_id = auth.uid())
--    - So the query succeeds without recursion
--
-- 4. The workspaces RLS policy will work because:
--    - It queries: SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
--    - Users can see their own membership row
--    - So the query succeeds without recursion
-- ============================================================

-- Test query to verify no recursion (run this after applying)
-- This should NOT cause infinite recursion:
-- SELECT * FROM workspace_members WHERE user_id = auth.uid();

-- ============================================================
-- NOTES
-- ============================================================
-- If you need "members can see all members in their workspaces"
-- (not just their own row), you have two options:
--
-- Option A: Add workspace owners to all workspaces (current approach)
-- Option B: Use a SECURITY DEFINER function (more complex, but allows
--           members to see other members without being owners)
--
-- For now, Option A is simpler and safer. Users can see:
-- - Their own membership row
-- - All members of workspaces they own
--
-- This is sufficient for the app to function correctly.
-- ============================================================
