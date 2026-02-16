# Quick Start Guide: ProjectFlow Backend Setup

This is a quick reference guide to get your ProjectFlow backend up and running with Supabase.

## Prerequisites

- ✅ **Supabase account** - [Sign up/Log in](https://supabase.com/) if needed
  - See [SUPABASE_PROJECT_SETUP.md](./SUPABASE_PROJECT_SETUP.md) for detailed instructions
- ✅ **Supabase project** - Your project is already created (`woigtfojjixtmwaoamap`)
- ✅ **Environment variables** - Configured in `.env` file
- ✅ **Supabase client** - Installed (`@supabase/supabase-js`)

> **Don't have a Supabase project yet?**  
> Follow [SUPABASE_PROJECT_SETUP.md](./SUPABASE_PROJECT_SETUP.md) first to create or access your project.

## Step 1: Run Database Migrations (5 minutes)

1. **Open Supabase Dashboard**
   ```
   https://supabase.com/dashboard
   → Select project: woigtfojjixtmwaoamap
   → SQL Editor
   ```

2. **Run First Migration**
   - Open `supabase/migrations/001_initial_schema.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click **Run** (or Cmd/Ctrl + Enter)
   - Wait for "Success" message

3. **Run Second Migration**
   - Open `supabase/migrations/002_storage_and_functions.sql`
   - Copy entire contents
   - Paste into SQL Editor
   - Click **Run**

4. **Verify Tables Created**
   - Go to **Table Editor**
   - You should see ~20 tables created
   - Check that RLS is enabled (lock icon on each table)

## Step 2: Set Up Storage (2 minutes)

1. **Create Bucket**
   - Go to **Storage** → **Buckets**
   - Click **New bucket**
   - Name: `attachments`
   - Public: **No**
   - Click **Create bucket**

2. **Set Storage Policies**
   - Go to **SQL Editor**
   - Copy storage policies from `supabase/README.md` (Storage Policies section)
   - Paste and run

## Step 3: Test the Setup (3 minutes)

### Test 1: Create a Workspace

```typescript
import { createWorkspace } from './services/workspaceService';
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();
const { data: { user } } = await supabase.auth.getUser();

if (user) {
  const workspace = await createWorkspace('My First Workspace', user.id);
  console.log('✅ Workspace created:', workspace);
}
```

### Test 2: Create a Project

```typescript
import { createProject, createSheet, createColumn } from './services/projectService';

const project = await createProject(workspaceId, 'My First Project', userId);
const sheet = await createSheet(project.id, 'Main Sheet');

await createColumn(sheet.id, {
  title: 'Task',
  type: 'text',
  width: 300
});

console.log('✅ Project and sheet created');
```

### Test 3: Create a Row

```typescript
import { createRow } from './services/projectService';

const row = await createRow(sheetId, {
  task: 'Test Task',
  status: 'To Do',
  owner: 'John Doe'
});

console.log('✅ Row created:', row);
```

## Step 4: Verify Real-time (Optional)

```typescript
import { getSupabaseClient } from './services/supabaseService';

const supabase = getSupabaseClient();

const subscription = supabase
  .channel('test-channel')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'rows'
  }, (payload) => {
    console.log('✅ Real-time update received:', payload);
  })
  .subscribe();

// Make a change to a row, you should see the update in console
```

## Common Issues & Solutions

### Issue: "Permission denied" errors

**Solution**: Check that:
1. User is authenticated: `await supabase.auth.getUser()`
2. User is a member of the workspace
3. RLS policies are correctly set up

### Issue: Tables not found

**Solution**: 
1. Verify migrations ran successfully
2. Check Table Editor to see if tables exist
3. Re-run migrations if needed

### Issue: Storage upload fails

**Solution**:
1. Verify bucket `attachments` exists
2. Check storage policies are set
3. Verify file size is under 50MB

### Issue: Profile not created on signup

**Solution**:
1. Check that trigger `on_auth_user_created` exists
2. Verify function `handle_new_user()` exists
3. Check Supabase logs for errors

## Next Steps

1. **Read Full Documentation**
   - `docs/BACKEND_SETUP.md` - Complete setup guide
   - `docs/API_USAGE_EXAMPLES.md` - Code examples

2. **Integrate with Frontend**
   - Replace localStorage with Supabase calls
   - Add real-time subscriptions
   - Implement authentication

3. **Deploy to Vercel**
   - Push code to GitHub
   - Connect to Vercel
   - Add environment variables
   - Deploy!

## File Structure

```
ProjectFlow/
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql    # Core tables
│   │   └── 002_storage_and_functions.sql  # Functions & views
│   └── README.md                      # Migration guide
├── services/
│   ├── supabaseService.ts            # Client initialization
│   ├── projectService.ts             # Project CRUD
│   └── workspaceService.ts           # Workspace CRUD
└── docs/
    ├── BACKEND_SETUP.md              # Complete guide
    ├── API_USAGE_EXAMPLES.md         # Code examples
    └── QUICK_START.md                # This file
```

## Support

- **Supabase Dashboard**: https://supabase.com/dashboard
- **Supabase Docs**: https://supabase.com/docs
- **Project Issues**: Check error messages in browser console and Supabase logs

## Checklist

- [ ] Migrations run successfully
- [ ] All tables created
- [ ] Storage bucket created
- [ ] Storage policies set
- [ ] Can create workspace
- [ ] Can create project
- [ ] Can create row
- [ ] Real-time updates working (optional)
- [ ] Ready to integrate with frontend!

---

**Estimated Total Time**: ~10 minutes

Once complete, you'll have a fully functional backend ready to power your ProjectFlow application! 🚀
