-- ============================================================
-- PROJECT PLANNER DUMMY DATA FOR ML OBSERVABILITY PLATFORM
-- Based on essay about AI Product Manager at 2021.ai
-- Hierarchy: Profile > Workspace > Project > Sheet > Column > Row (with row_data JSONB)
-- ============================================================
-- Note: This uses our actual schema:
-- - profiles (not users) - extends auth.users
-- - row_data JSONB (not cells table)
-- - Proper UUIDs and foreign key references
-- ============================================================

-- ============================================================
-- 1. PROFILES (User must exist in auth.users first)
-- ============================================================
-- Note: In production, profiles are created automatically via trigger
-- when a user signs up. For dummy data, we'll insert directly.
-- The user must exist in auth.users first (created via Supabase Auth)

-- Assuming user 'pm@2021.ai' exists in auth.users with UUID
-- We'll use a placeholder UUID - replace with actual auth.users.id
DO $$
DECLARE
  v_user_id UUID := '00000000-0000-0000-0000-000000000001'::UUID;
BEGIN
  -- Insert profile (assuming user exists in auth.users)
  INSERT INTO profiles (id, name, email, color)
  VALUES (
    v_user_id,
    'AI Product Manager',
    'pm@2021.ai',
    '#6366f1'
  )
  ON CONFLICT (id) DO NOTHING;
END $$;

-- ============================================================
-- 2. WORKSPACES
-- ============================================================
INSERT INTO workspaces (id, name, owner_id) VALUES
('00000000-0000-0000-0000-000000000010'::UUID, '2021.ai Observability Workspace', '00000000-0000-0000-0000-000000000001'::UUID)
ON CONFLICT (id) DO NOTHING;

-- Add workspace member
INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000010'::UUID,
  '00000000-0000-0000-0000-000000000001'::UUID,
  'Owner'
)
ON CONFLICT (workspace_id, user_id) DO NOTHING;

-- ============================================================
-- 3. PROJECTS
-- ============================================================
INSERT INTO projects (id, workspace_id, owner_id, name, active_sheet_id) VALUES
(
  '00000000-0000-0000-0000-000000000020'::UUID,
  '00000000-0000-0000-0000-000000000010'::UUID,
  '00000000-0000-0000-0000-000000000001'::UUID,
  'ML Observability Platform',
  NULL  -- Will be set after sheets are created
)
ON CONFLICT (id) DO NOTHING;

-- Add project member
INSERT INTO project_members (project_id, user_id, role)
VALUES (
  '00000000-0000-0000-0000-000000000020'::UUID,
  '00000000-0000-0000-0000-000000000001'::UUID,
  'Owner'
)
ON CONFLICT (project_id, user_id) DO NOTHING;

-- ============================================================
-- 4. SHEETS
-- ============================================================
INSERT INTO sheets (id, project_id, name) VALUES
('00000000-0000-0000-0000-000000000030'::UUID, '00000000-0000-0000-0000-000000000020'::UUID, 'Observability Roadmap'),
('00000000-0000-0000-0000-000000000031'::UUID, '00000000-0000-0000-0000-000000000020'::UUID, 'Platform Architecture'),
('00000000-0000-0000-0000-000000000032'::UUID, '00000000-0000-0000-0000-000000000020'::UUID, 'Product Success Metrics')
ON CONFLICT (id) DO NOTHING;

-- Update project with first sheet as active
UPDATE projects
SET active_sheet_id = '00000000-0000-0000-0000-000000000030'::UUID
WHERE id = '00000000-0000-0000-0000-000000000020'::UUID;

-- ============================================================
-- 5. COLUMNS
-- ============================================================

-- Columns for Observability Roadmap Sheet
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000040'::UUID, '00000000-0000-0000-0000-000000000030'::UUID, 'Phase', 'text', 150, 1, NULL),
('00000000-0000-0000-0000-000000000041'::UUID, '00000000-0000-0000-0000-000000000030'::UUID, 'Feature', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000000042'::UUID, '00000000-0000-0000-0000-000000000030'::UUID, 'Priority', 'dropdown', 150, 3, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000043'::UUID, '00000000-0000-0000-0000-000000000030'::UUID, 'Status', 'dropdown', 150, 4, '["Planned", "In Progress", "Completed"]'::jsonb),
('00000000-0000-0000-0000-000000000044'::UUID, '00000000-0000-0000-0000-000000000030'::UUID, 'Owner', 'text', 200, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Platform Architecture Sheet
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000050'::UUID, '00000000-0000-0000-0000-000000000031'::UUID, 'Layer Name', 'text', 200, 1, NULL),
('00000000-0000-0000-0000-000000000051'::UUID, '00000000-0000-0000-0000-000000000031'::UUID, 'Function', 'text', 300, 2, NULL),
('00000000-0000-0000-0000-000000000052'::UUID, '00000000-0000-0000-0000-000000000031'::UUID, 'Component Type', 'dropdown', 200, 3, '["Data", "Monitoring", "Storage", "Visualization", "Explainability"]'::jsonb),
('00000000-0000-0000-0000-000000000053'::UUID, '00000000-0000-0000-0000-000000000031'::UUID, 'Criticality', 'dropdown', 150, 4, '["High", "Medium", "Low"]'::jsonb),
('00000000-0000-0000-0000-000000000054'::UUID, '00000000-0000-0000-0000-000000000031'::UUID, 'Implemented', 'checkbox', 150, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- Columns for Product Success Metrics Sheet
INSERT INTO columns (id, sheet_id, title, type, width, display_order, options) VALUES
('00000000-0000-0000-0000-000000000060'::UUID, '00000000-0000-0000-0000-000000000032'::UUID, 'Metric Name', 'text', 250, 1, NULL),
('00000000-0000-0000-0000-000000000061'::UUID, '00000000-0000-0000-0000-000000000032'::UUID, 'Metric Category', 'dropdown', 200, 2, '["Technical", "User", "Business", "Governance"]'::jsonb),
('00000000-0000-0000-0000-000000000062'::UUID, '00000000-0000-0000-0000-000000000032'::UUID, 'Target Value', 'text', 150, 3, NULL),
('00000000-0000-0000-0000-000000000063'::UUID, '00000000-0000-0000-0000-000000000032'::UUID, 'Current Status', 'dropdown', 150, 4, '["On Track", "At Risk", "Behind"]'::jsonb),
('00000000-0000-0000-0000-000000000064'::UUID, '00000000-0000-0000-0000-000000000032'::UUID, 'Owner', 'text', 200, 5, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. ROWS (with row_data JSONB - not cells table)
-- ============================================================

-- Rows for Observability Roadmap Sheet
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000070'::UUID,
  '00000000-0000-0000-0000-000000000030'::UUID,
  '{
    "Phase": "Phase 1",
    "Feature": "Prediction Logging and Performance Metrics",
    "Priority": "High",
    "Status": "Completed",
    "Owner": "AI Product Manager"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000071'::UUID,
  '00000000-0000-0000-0000-000000000030'::UUID,
  '{
    "Phase": "Phase 2",
    "Feature": "Feature and Prediction Drift Detection",
    "Priority": "High",
    "Status": "In Progress",
    "Owner": "ML Engineering Team"
  }'::jsonb,
  ARRAY['00000000-0000-0000-0000-000000000070'::TEXT]  -- Depends on Phase 1
),
(
  '00000000-0000-0000-0000-000000000072'::UUID,
  '00000000-0000-0000-0000-000000000030'::UUID,
  '{
    "Phase": "Phase 3",
    "Feature": "Model Explainability and Feature Attribution",
    "Priority": "High",
    "Status": "Planned",
    "Owner": "ML Research Team"
  }'::jsonb,
  ARRAY['00000000-0000-0000-0000-000000000071'::TEXT]  -- Depends on Phase 2
),
(
  '00000000-0000-0000-0000-000000000073'::UUID,
  '00000000-0000-0000-0000-000000000030'::UUID,
  '{
    "Phase": "Phase 4",
    "Feature": "Audit Logs and Compliance Reporting",
    "Priority": "Medium",
    "Status": "Planned",
    "Owner": "Compliance Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000074'::UUID,
  '00000000-0000-0000-0000-000000000030'::UUID,
  '{
    "Phase": "Phase 5",
    "Feature": "Automated Retraining Triggers and Alerts",
    "Priority": "Medium",
    "Status": "Planned",
    "Owner": "Platform Engineering"
  }'::jsonb,
  ARRAY['00000000-0000-0000-0000-000000000072'::TEXT]  -- Depends on Phase 3
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Platform Architecture Sheet
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000080'::UUID,
  '00000000-0000-0000-0000-000000000031'::UUID,
  '{
    "Layer Name": "Data Ingestion Layer",
    "Function": "Collect model inputs, outputs, metadata, and ground truth",
    "Component Type": "Data",
    "Criticality": "High",
    "Implemented": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000081'::UUID,
  '00000000-0000-0000-0000-000000000031'::UUID,
  '{
    "Layer Name": "Monitoring Layer",
    "Function": "Compute statistical drift, performance, and data quality metrics",
    "Component Type": "Monitoring",
    "Criticality": "High",
    "Implemented": true
  }'::jsonb,
  ARRAY['00000000-0000-0000-0000-000000000080'::TEXT]  -- Depends on Data Ingestion
),
(
  '00000000-0000-0000-0000-000000000082'::UUID,
  '00000000-0000-0000-0000-000000000031'::UUID,
  '{
    "Layer Name": "Explainability Layer",
    "Function": "Provide feature attribution and model interpretability",
    "Component Type": "Explainability",
    "Criticality": "High",
    "Implemented": false
  }'::jsonb,
  ARRAY['00000000-0000-0000-0000-000000000081'::TEXT]  -- Depends on Monitoring
),
(
  '00000000-0000-0000-0000-000000000083'::UUID,
  '00000000-0000-0000-0000-000000000031'::UUID,
  '{
    "Layer Name": "Storage Layer",
    "Function": "Store historical observability and monitoring data",
    "Component Type": "Storage",
    "Criticality": "High",
    "Implemented": true
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000084'::UUID,
  '00000000-0000-0000-0000-000000000031'::UUID,
  '{
    "Layer Name": "Visualization Layer",
    "Function": "Provide dashboards, alerts, and reporting",
    "Component Type": "Visualization",
    "Criticality": "Medium",
    "Implemented": false
  }'::jsonb,
  ARRAY['00000000-0000-0000-0000-000000000081'::TEXT, '00000000-0000-0000-0000-000000000083'::TEXT]  -- Depends on Monitoring and Storage
)
ON CONFLICT (id) DO NOTHING;

-- Rows for Product Success Metrics Sheet
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  '00000000-0000-0000-0000-000000000090'::UUID,
  '00000000-0000-0000-0000-000000000032'::UUID,
  '{
    "Metric Name": "Model Drift Detection Latency",
    "Metric Category": "Technical",
    "Target Value": "< 5 minutes",
    "Current Status": "On Track",
    "Owner": "Engineering Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000091'::UUID,
  '00000000-0000-0000-0000-000000000032'::UUID,
  '{
    "Metric Name": "Dashboard Usage Frequency",
    "Metric Category": "User",
    "Target Value": "Daily Active Usage",
    "Current Status": "On Track",
    "Owner": "Product Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000092'::UUID,
  '00000000-0000-0000-0000-000000000032'::UUID,
  '{
    "Metric Name": "Customer Retention Rate",
    "Metric Category": "Business",
    "Target Value": "> 90%",
    "Current Status": "At Risk",
    "Owner": "Customer Success Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000093'::UUID,
  '00000000-0000-0000-0000-000000000032'::UUID,
  '{
    "Metric Name": "Compliance Readiness Score",
    "Metric Category": "Governance",
    "Target Value": "100% Auditability",
    "Current Status": "On Track",
    "Owner": "Compliance Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
),
(
  '00000000-0000-0000-0000-000000000094'::UUID,
  '00000000-0000-0000-0000-000000000032'::UUID,
  '{
    "Metric Name": "Platform Adoption Rate",
    "Metric Category": "Business",
    "Target Value": "> 75% Enterprise Adoption",
    "Current Status": "Behind",
    "Owner": "Executive Team"
  }'::jsonb,
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- NOTES
-- ============================================================
-- 1. User Setup:
--    - Before running this migration, create a user in Supabase Auth:
--      - Email: pm@2021.ai
--      - Password: (set via Supabase Auth)
--    - Replace the UUID '00000000-0000-0000-0000-000000000001' with the actual auth.users.id
--
-- 2. Data Structure:
--    - Uses row_data JSONB (not cells table) - matches our implementation
--    - Column values are stored as JSON keys matching column titles
--    - Dependencies array tracks task dependencies
--
-- 3. To Use:
--    - Run this migration after 001_initial_schema.sql
--    - Update the user UUID to match your actual auth.users.id
--    - Or create the user first, then update this migration
--
-- ============================================================
-- END OF DUMMY DATA
-- ============================================================
