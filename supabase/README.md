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
Loads sample data for testing:
- 1 user (AI Product Manager)
- 1 workspace (2021.ai Observability Workspace)
- 1 project (ML Observability Platform)
- 3 sheets with columns and rows
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
