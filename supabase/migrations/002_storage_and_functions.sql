-- ============================================================================
-- Storage Buckets and Helper Functions
-- ============================================================================

-- ============================================================================
-- STORAGE BUCKET: attachments
-- For file attachments to rows
-- ============================================================================

-- Note: Storage buckets must be created via Supabase Dashboard or API
-- This is a reference for what needs to be created:
-- Bucket name: "attachments"
-- Public: false (private bucket)
-- File size limit: 50MB
-- Allowed MIME types: All

-- Storage policies will be set up via Supabase Dashboard:
-- 1. Users can upload files to attachments/{row_id}/*
-- 2. Users can view files in attachments/{row_id}/* if they can view the row
-- 3. Users can delete files in attachments/{row_id}/* if they can edit the row

-- ============================================================================
-- FUNCTION: Create profile on user signup
-- Automatically creates a profile when a new user signs up
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, color)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    NEW.email,
    -- Assign a random color from predefined palette
    (ARRAY['#6366f1', '#a855f7', '#ec4899', '#f97316', '#10b981', '#06b6d4'])[
      floor(random() * 6 + 1)
    ]
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call function on new user
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- FUNCTION: Log activity
-- Helper function to log user activity
-- ============================================================================

CREATE OR REPLACE FUNCTION public.log_activity(
  p_project_id UUID,
  p_user_id UUID,
  p_user_name TEXT,
  p_action TEXT,
  p_row_id UUID DEFAULT NULL,
  p_details TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_activity_id UUID;
BEGIN
  INSERT INTO activity_log (
    project_id,
    user_id,
    user_name,
    action,
    row_id,
    details
  )
  VALUES (
    p_project_id,
    p_user_id,
    p_user_name,
    p_action,
    p_row_id,
    p_details
  )
  RETURNING id INTO v_activity_id;
  
  RETURN v_activity_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: Get user workspaces
-- Returns all workspaces a user is a member of
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_user_workspaces(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  name TEXT,
  owner_id UUID,
  role TEXT,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    w.id,
    w.name,
    w.owner_id,
    wm.role,
    w.created_at
  FROM workspaces w
  INNER JOIN workspace_members wm ON w.id = wm.workspace_id
  WHERE wm.user_id = p_user_id
  ORDER BY w.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: Get project with full data
-- Returns a project with all related data (sheets, columns, rows, etc.)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_project_full(p_project_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'id', p.id,
    'name', p.name,
    'workspace_id', p.workspace_id,
    'owner_id', p.owner_id,
    'active_sheet_id', p.active_sheet_id,
    'created_at', p.created_at,
    'updated_at', p.updated_at,
    'sheets', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', s.id,
          'name', s.name,
          'columns', (
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', c.id,
                'title', c.title,
                'type', c.type,
                'width', c.width,
                'options', c.options,
                'permissions', c.permissions,
                'display_order', c.display_order
              ) ORDER BY c.display_order
            )
            FROM columns c
            WHERE c.sheet_id = s.id
          ),
          'rows', (
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', r.id,
                'row_data', r.row_data,
                'dependencies', r.dependencies,
                'created_at', r.created_at,
                'updated_at', r.updated_at
              )
            )
            FROM rows r
            WHERE r.sheet_id = s.id
          )
        )
      )
      FROM sheets s
      WHERE s.project_id = p.id
    )
  )
  INTO v_result
  FROM projects p
  WHERE p.id = p_project_id;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: Search rows
-- Full-text search across row data
-- ============================================================================

CREATE OR REPLACE FUNCTION public.search_rows(
  p_sheet_id UUID,
  p_search_term TEXT
)
RETURNS TABLE (
  id UUID,
  row_data JSONB,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.row_data,
    ts_rank(
      to_tsvector('english', r.row_data::text),
      plainto_tsquery('english', p_search_term)
    ) AS rank
  FROM rows r
  WHERE r.sheet_id = p_sheet_id
    AND to_tsvector('english', r.row_data::text) @@ plainto_tsquery('english', p_search_term)
  ORDER BY rank DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VIEW: Workspace statistics
-- Aggregated statistics for workspaces
-- Note: This view depends on tables from migration 001
-- ============================================================================

-- Drop view if it exists (for idempotency)
DROP VIEW IF EXISTS workspace_stats;

CREATE VIEW workspace_stats AS
SELECT 
  w.id AS workspace_id,
  w.name AS workspace_name,
  COUNT(DISTINCT p.id) AS project_count,
  COUNT(DISTINCT wm.user_id) AS member_count,
  COUNT(DISTINCT s.id) AS sheet_count,
  COUNT(DISTINCT r.id) AS row_count
FROM workspaces w
LEFT JOIN projects p ON p.workspace_id = w.id
LEFT JOIN workspace_members wm ON wm.workspace_id = w.id
LEFT JOIN sheets s ON s.project_id = p.id
LEFT JOIN rows r ON r.sheet_id = s.id
GROUP BY w.id, w.name;

-- Grant access to view
GRANT SELECT ON workspace_stats TO authenticated;
