# Project Creation Checklist

Use this checklist when creating your Supabase project for ProjectFlow.

## Pre-Creation Checklist

- [ ] Have a Supabase account (sign up at [supabase.com](https://supabase.com/))
- [ ] Know your target user region (for selecting database region)
- [ ] Have a password manager ready (to store database password securely)

## Project Creation Steps

### Step 1: Navigate to Supabase

- [ ] Go to [https://supabase.com/](https://supabase.com/)
- [ ] Click **"New project"** button
- [ ] Select or create an organization

### Step 2: Fill in Project Details

- [ ] **Name**: Enter `project-planner`
- [ ] **Database Password**: 
  - [ ] Create a strong password (min 8 characters, mixed case, numbers, symbols)
  - [ ] Save password in password manager
  - [ ] Verify password is saved securely
- [ ] **Region**: Select region closest to your users
  - [ ] US East (N. Virginia) - US East Coast
  - [ ] US West (Oregon) - US West Coast
  - [ ] EU West (Ireland) - Europe
  - [ ] EU Central (Frankfurt) - Central Europe
  - [ ] Asia Pacific (Singapore) - Asia
  - [ ] Asia Pacific (Tokyo) - Japan
- [ ] **Pricing Plan**: Select **Free plan**

### Step 3: Create Project

- [ ] Review all details are correct
- [ ] Click **"Create new project"**
- [ ] **Wait for Project Provisioning** (1-3 minutes)
  - [ ] Keep browser tab open
  - [ ] Don't refresh the page
  - [ ] Watch for progress indicators
  - [ ] Wait for "Project created successfully" message
- [ ] Verify project dashboard loads successfully
- [ ] See [PROVISIONING_GUIDE.md](./PROVISIONING_GUIDE.md) for details about what happens during provisioning

### Step 4: Save Project Information

- [ ] Copy **Project URL** (format: `https://[ref].supabase.co`)
- [ ] Copy **Project ID** (visible in URL or settings)
- [ ] Save both in a secure location

### Step 5: Get API Keys

- [ ] Navigate to **Settings** → **API**
- [ ] Copy **Project URL**
- [ ] Copy **anon public** key (click eye icon to reveal)
- [ ] Copy **service_role** key (click eye icon to reveal)
  - ⚠️ **Keep service_role key secret!**

### Step 6: Configure Environment Variables

- [ ] Create `.env` file in project root (if not exists)
- [ ] Add `VITE_SUPABASE_URL=[your-project-url]`
- [ ] Add `VITE_SUPABASE_ANON_KEY=[your-anon-key]`
- [ ] Add `VITE_SUPABASE_SERVICE_ROLE_KEY=[your-service-role-key]`
- [ ] Verify `.env` is in `.gitignore` (never commit!)

### Step 7: Verify Setup

- [ ] Test connection using Supabase client
- [ ] Verify you can access SQL Editor
- [ ] Verify you can access Table Editor
- [ ] Check that API keys work

## Post-Creation Next Steps

- [ ] Run database migrations (see `supabase/migrations/`)
- [ ] Create storage bucket for attachments
- [ ] Set up storage policies
- [ ] Test authentication flow
- [ ] Review Row Level Security policies

## Important Reminders

- ✅ **Database Password**: Save securely - you'll need it for migrations
- ✅ **Service Role Key**: Never expose in client-side code
- ✅ **Anon Key**: Safe to use in client-side code
- ✅ **Free Plan**: Sufficient for development, upgrade later if needed

## Troubleshooting

If you encounter issues:

- [ ] Check Supabase status: [status.supabase.com](https://status.supabase.com)
- [ ] Verify you're logged in with correct account
- [ ] Check organization permissions
- [ ] Review error messages in dashboard
- [ ] Consult [SUPABASE_PROJECT_SETUP.md](./SUPABASE_PROJECT_SETUP.md) for detailed help

---

**Once complete, proceed to [QUICK_START.md](./QUICK_START.md) to set up your database!** 🚀
