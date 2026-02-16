# Supabase Database Setup

This directory contains SQL migration files for setting up the ProjectFlow database schema in Supabase.

## Quick Start

1. **Open Supabase Dashboard**
   - Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Select your project: `woigtfojjixtmwaoamap`
   - Navigate to **SQL Editor**

2. **Run Migrations**
   - Copy the contents of `migrations/001_initial_schema.sql`
   - Paste into SQL Editor
   - Click **Run**
   - Repeat for `migrations/002_storage_and_functions.sql`

3. **Set Up Storage**
   - Navigate to **Storage** in Supabase Dashboard
   - Create a new bucket named `attachments`
   - Set it to **Private**
   - Configure policies (see below)

4. **Verify Setup**
   - Navigate to **Table Editor**
   - Verify all tables were created
   - Check that RLS is enabled on all tables

## Migration Files

### `001_initial_schema.sql`
Creates all core tables:
- `profiles` - User profiles
- `workspaces` - Workspace containers
- `workspace_members` - Workspace membership
- `role_definitions` - Custom roles
- `projects` - Projects
- `project_members` - Project membership
- `sheets` - Sheets
- `columns` - Column definitions
- `rows` - Row data (JSONB)
- `comments` - Comments on rows
- `file_attachments` - File attachments
- `activity_log` - Activity audit trail
- `automations` - Automation rules
- `saved_views` - Saved views
- `integrations` - Integration settings
- `ai_metrics` - AI performance metrics
- `retraining_jobs` - Retraining job history
- `retraining_config` - Retraining configuration
- `templates` - Project templates

### `002_storage_and_functions.sql`
Creates:
- Helper functions (profile creation, activity logging, etc.)
- Database views
- Triggers for automatic profile creation

### `003_dummy_data.sql` (Optional)
Loads sample data for ML Observability Platform:
- 1 user (AI Product Manager - pm@2021.ai)
- 1 workspace (2021.ai Observability Workspace)
- 1 project (ML Observability Platform)
- 3 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `004_dummy_data_nordjylland.sql` (Optional)
Loads sample data for North Denmark Region AI Transformation:
- 1 user (AI Product Owner - owner@nordjylland.dk)
- 1 workspace (North Denmark Region AI Transformation)
- 1 project (Generative AI Platform Deployment)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `005_dummy_data_talomdiabetes.sql` (Optional)
Loads sample data for Tal om Diabetes Healthcare AI Platform:
- 1 user (Tal om Diabetes Product Owner - owner@talomdiabetes.ai)
- 1 workspace (GRACE AI Platform - Healthcare AI)
- 1 project (Tal om Diabetes Conversational Health Data Platform)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `006_dummy_data_lif2.sql` (Optional)
Loads sample data for LIF2.0 Real-Time COVID Intelligence Platform:
- 1 user (Eureka Project Owner - eureka.owner@example.com)
- 1 workspace (LIF2.0 Real-Time Intelligence Workspace)
- 1 project (LIF2.0 Real-Time COVID Intelligence Platform)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `007_dummy_data_stockholm.sql` (Optional)
Loads sample data for Stockholm County Social Services AI:
- 1 user (AI Governance Lead - owner@stockholm-ai-project.com)
- 1 workspace (Stockholm County Social Services AI Workspace)
- 1 project (AI-Assisted Case Prioritization)
- 3 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `008_dummy_data_linkgrc.sql` (Optional)
Loads sample data for LinkGRC AI Compliance:
- 1 user (Product Owner - Regulatory Monitoring - product.owner@linkgrc.com)
- 1 workspace (LinkGRC AI Compliance Workspace)
- 1 project (AI-Powered Regulatory Monitoring Pipeline)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `009_dummy_data_nuvve.sql` (Optional)
Loads sample data for Nuvve Energy Optimization:
- 1 user (Energy AI Product Owner - owner@nuvve.com)
- 1 workspace (Nuvve Energy Optimization Workspace)
- 1 project (AI Forecasting and Market Optimization Platform)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `010_dummy_data_rigshospitalet.sql` (Optional)
Loads sample data for Rigshospitalet AI Virtual Assistant:
- 1 user (Senior AI Engineer - ai.engineer@example.com)
- 1 workspace (Healthcare AI Projects Workspace)
- 1 project (Rigshospitalet AI Virtual Assistant)
- 3 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `011_dummy_data_prometric.sql` (Optional)
Loads sample data for Prometric AI Proctoring:
- 1 user (AI Product Owner - owner@prometric-ai.com)
- 1 workspace (Prometric Responsible AI Workspace)
- 1 project (AI-Powered Proctoring and Responsible AI Monitoring)
- 3 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `012_dummy_data_plesner.sql` (Optional)
Loads sample data for Plesner Enterprise AI:
- 1 user (Enterprise AI Lead - ai.lead@plesner.com)
- 1 workspace (Plesner Enterprise AI Transformation)
- 1 project (Enterprise LLM Assistant and Responsible AI Platform Rollout)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `013_dummy_data_credit_risk.sql` (Optional)
Loads sample data for AI Credit Risk Platform:
- 1 user (AI Risk Product Owner - risk.ai.owner@example.com)
- 1 workspace (AI Credit Risk Platform Workspace)
- 1 project (Real-Time AI Credit Risk Prediction)
- 3 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `014_dummy_data_betternow.sql` (Optional)
Loads sample data for BetterNow AI Fundraising:
- 1 user (AI Product Manager - pm@betternow.ai)
- 1 workspace (BetterNow AI Fundraising Workspace)
- 1 project (AI Personalization and Recommendation Engine)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `015_dummy_data_freight_forecasting.sql` (Optional)
Loads sample data for Freight Market Forecasting:
- 1 user (Senior Data Engineer - engineer@example.com)
- 1 workspace (Freight Market Forecasting Workspace)
- 1 project (Freight Market Price Forecasting and Fleet Positioning Optimization)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `016_dummy_data_blockshipping.sql` (Optional)
Loads sample data for Blockshipping AI Terminal Optimization:
- 1 user (Blockshipping Project Owner - owner@blockshipping.ai)
- 1 workspace (AI Terminal Optimization Workspace)
- 1 project (AI Import Dwell-Time Prediction for Container Terminal Optimization)
- 3 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `017_dummy_data_blockshipping_multi_project.sql` (Optional)
Loads sample data for Blockshipping AI Optimization (multi-project workspace):
- 1 user (AI Product Lead - candidate@blockshipping.ai)
- 1 workspace (Blockshipping AI Optimization Workspace)
- 4 projects with 4 sheets total
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `018_dummy_data_regulatory_authority.sql` (Optional)
Loads sample data for Regulatory Authority AI Transformation:
- 1 user (AI Workflow Project Owner - regulatory.ai.lead@example.com)
- 1 workspace (Regulatory Authority AI Transformation)
- 1 project (AI Email Routing and Workflow Automation)
- 3 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `019_dummy_data_rail_transport.sql` (Optional)
Loads sample data for Rail Transport AI Intelligence:
- 1 user (AI Retention Lead - rail.ai.lead@example.com)
- 1 workspace (Rail Transport AI Intelligence Workspace)
- 1 project (Customer Churn Prediction and Retention Intelligence)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

### `020_dummy_data_global_bakery.sql` (Optional)
Loads sample data for Global Bakery AI Transformation:
- 1 user (AI Sales Platform Owner - sales.ai.owner@example.com)
- 1 workspace (Global Bakery AI Transformation Workspace)
- 1 project (Real-Time AI Sales Prediction and Recommendation Engine)
- 4 sheets with columns and rows
- See [DUMMY_DATA_GUIDE.md](../docs/DUMMY_DATA_GUIDE.md) for details

## Storage Setup

### Create Bucket

1. Go to **Storage** → **Buckets**
2. Click **New bucket**
3. Name: `attachments`
4. Public: **No** (private bucket)
5. File size limit: 50MB
6. Allowed MIME types: Leave empty (all types allowed)

### Storage Policies

Run these in SQL Editor after creating the bucket:

```sql
-- Policy: Users can upload files to their row attachments
CREATE POLICY "Users can upload attachments"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'attachments' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy: Users can view attachments if they can view the row
CREATE POLICY "Users can view attachments"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'attachments' AND
  EXISTS (
    SELECT 1 FROM rows r
    WHERE r.id::text = (storage.foldername(name))[1]
    AND r.sheet_id IN (
      SELECT id FROM sheets WHERE project_id IN (
        SELECT id FROM projects WHERE workspace_id IN (
          SELECT workspace_id FROM workspace_members
          WHERE user_id = auth.uid()
        )
      )
    )
  )
);

-- Policy: Users can delete attachments if they can edit the row
CREATE POLICY "Users can delete attachments"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'attachments' AND
  EXISTS (
    SELECT 1 FROM rows r
    WHERE r.id::text = (storage.foldername(name))[1]
    AND r.sheet_id IN (
      SELECT id FROM sheets WHERE project_id IN (
        SELECT id FROM projects WHERE workspace_id IN (
          SELECT workspace_id FROM workspace_members
          WHERE user_id = auth.uid() AND role IN ('Owner', 'Editor')
        )
      )
    )
  )
);
```

## Row Level Security (RLS)

All tables have RLS enabled with policies that:
- Allow users to view data in workspaces/projects they belong to
- Allow Editors/Owners to create/update/delete
- Restrict access based on workspace membership

## Testing the Setup

### 1. Test Profile Creation

```sql
-- This should automatically create a profile when a user signs up
-- Test by signing up a new user in your app
```

### 2. Test Workspace Creation

```typescript
// In your app
import { createWorkspace } from './services/workspaceService';

const workspace = await createWorkspace('Test Workspace', userId);
console.log('Workspace created:', workspace);
```

### 3. Test Project Creation

```typescript
import { createProject } from './services/projectService';

const project = await createProject(workspaceId, 'Test Project', userId);
console.log('Project created:', project);
```

## Troubleshooting

### Migration Errors

If you encounter errors:
1. Check that you're running migrations in order
2. Verify you have the correct permissions
3. Check Supabase logs for detailed error messages

### RLS Issues

If you can't access data:
1. Verify RLS is enabled: `SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';`
2. Check policies: `SELECT * FROM pg_policies WHERE tablename = 'your_table';`
3. Verify user is authenticated: `SELECT auth.uid();`

### Storage Issues

If file uploads fail:
1. Verify bucket exists and is named `attachments`
2. Check storage policies are set correctly
3. Verify file size is under limit
4. Check CORS settings if uploading from browser

## Next Steps

1. **Set up authentication** in Supabase Dashboard
2. **Configure email templates** for auth emails
3. **Set up OAuth providers** (Google, GitHub, etc.) if needed
4. **Review API documentation** in Supabase Dashboard
5. **Test real-time subscriptions** in your app

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL JSONB Guide](https://www.postgresql.org/docs/current/datatype-json.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Policies](https://supabase.com/docs/guides/storage/policies)
