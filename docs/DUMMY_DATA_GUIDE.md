# Dummy Data Guide

Guide for loading sample data into ProjectFlow for testing and development.

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Loading Dummy Data](#3-loading-dummy-data)
4. [Data Structure](#4-data-structure)
5. [Customizing Data](#5-customizing-data)

---

## 1. Overview

The dummy data migration (`003_dummy_data.sql`) creates sample data for an ML Observability Platform project, including:

- ✅ **1 User** (AI Product Manager)
- ✅ **1 Workspace** (2021.ai Observability Workspace)
- ✅ **1 Project** (ML Observability Platform)
- ✅ **3 Sheets** (Roadmap, Architecture, Metrics)
- ✅ **15 Columns** (5 per sheet)
- ✅ **15 Rows** (5 per sheet with JSONB data)

### Data Hierarchy

```
Profile (AI Product Manager)
  └── Workspace (2021.ai Observability Workspace)
      └── Project (ML Observability Platform)
          ├── Sheet 1: Observability Roadmap
          │   ├── 5 Columns (Phase, Feature, Priority, Status, Owner)
          │   └── 5 Rows (Phases 1-5 with task data)
          ├── Sheet 2: Platform Architecture
          │   ├── 5 Columns (Layer Name, Function, Component Type, Criticality, Implemented)
          │   └── 5 Rows (Architecture layers)
          └── Sheet 3: Product Success Metrics
              ├── 5 Columns (Metric Name, Category, Target Value, Status, Owner)
              └── 5 Rows (Success metrics)
```

---

## 2. Prerequisites

### Before Loading Dummy Data

1. ✅ **Run initial schema migration**
   - Execute `001_initial_schema.sql` first
   - Execute `002_storage_and_functions.sql` if needed

2. ✅ **Create user in Supabase Auth**
   - Email: `pm@2021.ai`
   - Password: (your choice)
   - This user will own the workspace and project

3. ✅ **Get user UUID**
   - After creating the user, get their UUID from Supabase Dashboard
   - Or use Supabase SQL Editor: `SELECT id FROM auth.users WHERE email = 'pm@2021.ai';`

---

## 3. Loading Dummy Data

### Step 1: Update User UUID

**Important**: The migration uses a placeholder UUID. You must update it with your actual user ID.

1. **Get your user UUID:**
   ```sql
   SELECT id FROM auth.users WHERE email = 'pm@2021.ai';
   ```

2. **Update the migration file:**
   - Open `supabase/migrations/003_dummy_data.sql`
   - Replace all instances of `'00000000-0000-0000-0000-000000000001'::UUID` with your actual user UUID
   - Or use a variable at the top of the file

### Step 2: Run Migration

**Option A: Via Supabase Dashboard**

1. Go to Supabase Dashboard → **SQL Editor**
2. Open `supabase/migrations/003_dummy_data.sql`
3. Update the user UUID (see Step 1)
4. Click **Run** to execute

**Option B: Via Supabase CLI**

```bash
# Make sure you're linked to your project
supabase link --project-ref woigtfojjixtmwaoamap

# Run migration
supabase db push
```

### Step 3: Verify Data

```sql
-- Check profile
SELECT * FROM profiles WHERE email = 'pm@2021.ai';

-- Check workspace
SELECT * FROM workspaces;

-- Check project
SELECT * FROM projects;

-- Check sheets
SELECT * FROM sheets;

-- Check columns
SELECT * FROM columns;

-- Check rows
SELECT id, sheet_id, row_data FROM rows LIMIT 5;
```

---

## 4. Data Structure

### 4.1 Row Data Format

**Our implementation uses JSONB** (not a cells table):

```json
{
  "Phase": "Phase 1",
  "Feature": "Prediction Logging and Performance Metrics",
  "Priority": "High",
  "Status": "Completed",
  "Owner": "AI Product Manager"
}
```

**Column mapping:**
- Column title → JSONB key
- Column value → JSONB value
- All cell data stored in `row_data` JSONB field

### 4.2 Dependencies

Rows can have dependencies (for task management):

```sql
dependencies: ARRAY['00000000-0000-0000-0000-000000000070'::TEXT]
```

This indicates the row depends on another row (task dependencies).

### 4.3 Sample Data

#### Sheet 1: Observability Roadmap

| Phase | Feature | Priority | Status | Owner |
|-------|---------|----------|--------|-------|
| Phase 1 | Prediction Logging and Performance Metrics | High | Completed | AI Product Manager |
| Phase 2 | Feature and Prediction Drift Detection | High | In Progress | ML Engineering Team |
| Phase 3 | Model Explainability and Feature Attribution | High | Planned | ML Research Team |
| Phase 4 | Audit Logs and Compliance Reporting | Medium | Planned | Compliance Team |
| Phase 5 | Automated Retraining Triggers and Alerts | Medium | Planned | Platform Engineering |

#### Sheet 2: Platform Architecture

| Layer Name | Function | Component Type | Criticality | Implemented |
|------------|----------|----------------|-------------|-------------|
| Data Ingestion Layer | Collect model inputs, outputs, metadata, and ground truth | Data | High | ✅ |
| Monitoring Layer | Compute statistical drift, performance, and data quality metrics | Monitoring | High | ✅ |
| Explainability Layer | Provide feature attribution and model interpretability | Explainability | High | ❌ |
| Storage Layer | Store historical observability and monitoring data | Storage | High | ✅ |
| Visualization Layer | Provide dashboards, alerts, and reporting | Visualization | Medium | ❌ |

#### Sheet 3: Product Success Metrics

| Metric Name | Metric Category | Target Value | Current Status | Owner |
|-------------|-----------------|--------------|----------------|-------|
| Model Drift Detection Latency | Technical | < 5 minutes | On Track | Engineering Team |
| Dashboard Usage Frequency | User | Daily Active Usage | On Track | Product Team |
| Customer Retention Rate | Business | > 90% | At Risk | Customer Success Team |
| Compliance Readiness Score | Governance | 100% Auditability | On Track | Compliance Team |
| Platform Adoption Rate | Business | > 75% Enterprise Adoption | Behind | Executive Team |

---

## 5. Customizing Data

### 5.1 Add More Users

```sql
-- Create user in Supabase Auth first, then:
INSERT INTO profiles (id, name, email, color)
VALUES (
  'your-user-uuid'::UUID,
  'User Name',
  'user@example.com',
  '#a855f7'
);
```

### 5.2 Add More Workspaces

```sql
INSERT INTO workspaces (id, name, owner_id) VALUES
('new-workspace-uuid'::UUID, 'New Workspace', 'user-uuid'::UUID);

INSERT INTO workspace_members (workspace_id, user_id, role)
VALUES ('new-workspace-uuid'::UUID, 'user-uuid'::UUID, 'Owner');
```

### 5.3 Add More Rows

```sql
INSERT INTO rows (id, sheet_id, row_data, dependencies) VALUES
(
  'new-row-uuid'::UUID,
  'sheet-uuid'::UUID,
  '{
    "Column1": "Value1",
    "Column2": "Value2",
    "Status": "In Progress"
  }'::jsonb,
  ARRAY[]::TEXT[]
);
```

### 5.4 Update Row Data

```sql
UPDATE rows
SET row_data = jsonb_set(
  row_data,
  '{Status}',
  '"Completed"'
)
WHERE id = 'row-uuid'::UUID;
```

---

## 6. Troubleshooting

### Error: Foreign Key Violation

**Problem**: User doesn't exist in `auth.users`

**Solution**:
1. Create user in Supabase Auth first
2. Get the user UUID
3. Update the migration with correct UUID

### Error: Duplicate Key

**Problem**: Data already exists

**Solution**:
- The migration uses `ON CONFLICT DO NOTHING` - safe to run multiple times
- Or delete existing data first:
  ```sql
  DELETE FROM rows;
  DELETE FROM columns;
  DELETE FROM sheets;
  DELETE FROM projects;
  DELETE FROM workspace_members;
  DELETE FROM workspaces;
  DELETE FROM profiles WHERE email = 'pm@2021.ai';
  ```

### Error: JSONB Format

**Problem**: Invalid JSONB syntax

**Solution**:
- Ensure JSON is valid
- Use `'{"key": "value"}'::jsonb` format
- Check for proper escaping of quotes

---

## 7. Querying Dummy Data

### Get All Rows with Data

```sql
SELECT 
  s.name as sheet_name,
  r.id,
  r.row_data
FROM rows r
JOIN sheets s ON r.sheet_id = s.id
ORDER BY s.name, r.created_at;
```

### Get Rows by Status

```sql
SELECT *
FROM rows
WHERE row_data->>'Status' = 'In Progress';
```

### Get Rows with Dependencies

```sql
SELECT 
  id,
  row_data->>'Feature' as feature,
  dependencies
FROM rows
WHERE array_length(dependencies, 1) > 0;
```

### Get Project Summary

```sql
SELECT 
  p.name as project_name,
  COUNT(DISTINCT s.id) as sheet_count,
  COUNT(DISTINCT c.id) as column_count,
  COUNT(DISTINCT r.id) as row_count
FROM projects p
LEFT JOIN sheets s ON s.project_id = p.id
LEFT JOIN columns c ON c.sheet_id = s.id
LEFT JOIN rows r ON r.sheet_id = s.id
GROUP BY p.id, p.name;
```

---

## 8. Summary

### Key Points

1. ✅ **Update user UUID** before running migration
2. ✅ **Uses JSONB** (not cells table) - matches our implementation
3. ✅ **Safe to run multiple times** - uses `ON CONFLICT DO NOTHING`
4. ✅ **Includes dependencies** - for task management features

### Quick Start

```bash
# 1. Create user in Supabase Auth (pm@2021.ai)
# 2. Get user UUID
# 3. Update migration file with user UUID
# 4. Run migration in Supabase SQL Editor
# 5. Verify data loaded correctly
```

---

**Dummy data is ready to use for testing and development!** 🚀
