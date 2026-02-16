# Supabase Project Setup Guide

This guide walks you through creating a new Supabase project or accessing an existing one.

## Table of Contents

1. [Sign Up / Log In](#1-sign-up--log-in)
2. [Create a New Project](#2-create-a-new-project)
3. [Access Existing Project](#3-access-existing-project)
4. [Project Settings](#4-project-settings)
5. [Get API Keys](#5-get-api-keys)

---

## 1. Sign Up / Log In

### 1.1 Navigate to Supabase

1. Go to [https://supabase.com/](https://supabase.com/)
2. Click **Start your project** (if new) or **Sign in** (if you have an account)

### 1.2 Sign Up (New Users)

If you don't have an account:

1. Click **Start your project**
2. Choose a sign-up method:
   - **GitHub** (recommended for developers)
   - **Email** (use your email address)
   - **Google** (use Google account)
3. Complete the authentication process
4. You'll be redirected to the Supabase dashboard

### 1.3 Log In (Existing Users)

If you already have an account:

1. Click **Sign in** in the top right
2. Choose your sign-in method (GitHub, Email, or Google)
3. Complete authentication
4. You'll be redirected to your dashboard

---

## 2. Create a New Project

> **Note**: If you already have a Supabase project set up for ProjectFlow, skip to [Access Existing Project](#3-access-existing-project).

### 2.1 Start Project Creation

1. Once logged in, you'll see the Supabase dashboard
2. Click **New Project** button (usually in the top right or center of the dashboard)

### 2.2 Fill in Project Details

You'll be prompted to enter:

#### **Organization**
- Select an existing organization, or
- Create a new organization (if this is your first project)

#### **Project Details**

Fill in the following details:

- **Name**: `project-planner`
  - This will be your project identifier
  - You can change it later if needed

- **Database Password**: 
  - ⚠️ **Set a strong password and save it securely!**
  - Use a password manager to store it
  - This password is required for:
    - Direct database connections
    - Database migrations via CLI
    - pgAdmin or other database tools
  - **Password requirements:**
    - Minimum 8 characters
    - Mix of uppercase, lowercase, numbers, and symbols
    - Example: `MyPr0j3ct!P@ssw0rd` (don't use this exact one!)

- **Region**: Choose a region geographically close to your users
  - **Available regions:**
    - **US East** (N. Virginia) - Best for US East Coast users
    - **US West** (Oregon) - Best for US West Coast users
    - **EU West** (Ireland) - Best for European users
    - **EU Central** (Frankfurt) - Best for Central European users
    - **Asia Pacific** (Singapore) - Best for Asian users
    - **Asia Pacific** (Tokyo) - Best for Japanese users
  - **Recommendation**: Choose based on where most of your users will be located
  - Lower latency = better performance

#### **Pricing Plan**

- **Free Plan** (Recommended to start):
  - ✅ 500 MB database storage
  - ✅ 1 GB file storage
  - ✅ 2 GB bandwidth per month
  - ✅ Unlimited API requests
  - ✅ Perfect for development and small projects
  - ✅ No credit card required
  - **Select: Free plan**

- **Pro Plan**: 
  - More resources (8 GB database, 100 GB storage)
  - Better performance
  - Additional features
  - Upgrade later if needed

**For ProjectFlow, start with the Free plan. You can upgrade later as your project grows.**

### 2.3 Create Project

1. **Review all details:**
   - ✅ Name: `project-planner`
   - ✅ Database Password: [Your secure password - saved securely]
   - ✅ Region: [Your selected region]
   - ✅ Pricing Plan: Free

2. **Click "Create new project"** button

3. **Wait for Project Provisioning**

   Supabase will now provision your database and backend services. This process typically takes **1-3 minutes**.

   **What you'll see:**
   - A progress indicator showing "Setting up your project..."
   - Status updates as services are provisioned
   - A loading screen with your project name

   **What Supabase is setting up behind the scenes:**
   
   ```
   ┌─────────────────────────────────────────┐
   │      Provisioning Your Project          │
   ├─────────────────────────────────────────┤
   │                                         │
   │  ✅ Creating PostgreSQL database        │
   │     - Database instance                 │
   │     - Connection pool                   │
   │     - Backup configuration              │
   │                                         │
   │  ✅ Setting up API infrastructure       │
   │     - REST API endpoints                │
   │     - GraphQL API (if enabled)          │
   │     - API gateway                       │
   │                                         │
   │  ✅ Configuring Authentication          │
   │     - Auth service                      │
   │     - JWT token system                  │
   │     - Session management                │
   │                                         │
   │  ✅ Initializing Storage                │
   │     - Storage buckets                   │
   │     - CDN configuration                 │
   │                                         │
   │  ✅ Setting up Real-time                │
   │     - WebSocket infrastructure          │
   │     - Replication system               │
   │                                         │
   │  ✅ Generating API keys                 │
   │     - Anon/public key                   │
   │     - Service role key                  │
   │                                         │
   │  ✅ Creating project dashboard          │
   │     - UI components                     │
   │     - Monitoring tools                 │
   └─────────────────────────────────────────┘
   ```

   **During provisioning:**
   - ⏱️ **Don't close the browser tab** - Let the process complete
   - ⏱️ **Don't refresh the page** - Wait for automatic redirect
   - ⏱️ **Be patient** - This is a one-time setup process
   - ⏱️ **Typical time**: 1-3 minutes (can vary based on region and load)

   **If provisioning takes longer than 5 minutes:**
   - Check your internet connection
   - Check [Supabase Status](https://status.supabase.com) for service issues
   - Try refreshing the page (your project may already be created)
   - Contact Supabase support if issues persist

   > **📖 For detailed information about provisioning, see [PROVISIONING_GUIDE.md](./PROVISIONING_GUIDE.md)**

4. **Project is Ready**

   You'll know provisioning is complete when you see:
   - ✅ **"Project created successfully"** message or notification
   - ✅ **Dashboard loads** with your project overview
   - ✅ **API keys are visible** in Settings → API
   - ✅ **Table Editor** is accessible (shows empty state initially)
   - ✅ **SQL Editor** is ready to use

   **First things you'll see:**
   - Welcome message or quick start guide
   - Project overview dashboard
   - Links to documentation and examples
   - API keys in Settings

### 2.4 Project Ready

Once provisioning is complete, you'll see:
- ✅ Project dashboard
- ✅ API keys
- ✅ Database connection info
- ✅ Quick start guides

---

## 3. Access Existing Project

### 3.1 Your Current Project

**ProjectFlow is already set up with:**
- **Project URL**: `https://woigtfojjixtmwaoamap.supabase.co`
- **Project ID**: `woigtfojjixtmwaoamap`

### 3.2 Accessing Your Project

1. **Log in** to [Supabase Dashboard](https://supabase.com/dashboard)
2. You'll see a list of your projects
3. Click on your project (or search for `woigtfojjixtmwaoamap`)
4. You'll be taken to the project dashboard

### 3.3 Project Dashboard Overview

The dashboard provides access to:

- **Table Editor**: View and edit database tables
- **SQL Editor**: Run SQL queries and migrations
- **Authentication**: Manage users and auth settings
- **Storage**: Manage file buckets
- **API Docs**: Auto-generated API documentation
- **Settings**: Project configuration
- **Logs**: View application and database logs

---

## 4. Project Settings

### 4.1 Access Settings

1. In your project dashboard, click **Settings** (gear icon) in the left sidebar
2. Navigate to **General** or **API**

### 4.2 Important Settings

#### **Project URL**
- Your project's API endpoint
- Format: `https://[project-ref].supabase.co`
- Used in your `.env` file as `VITE_SUPABASE_URL`

#### **API Keys**
- **Anon/Public Key**: Safe to use in client-side code
- **Service Role Key**: **Never expose in client-side code!**
  - Has admin privileges
  - Bypasses Row Level Security
  - Only use in server-side code or environment variables

#### **Database Password**
- Set during project creation
- Used for direct database connections
- Can be reset in Settings → Database

---

## 5. Get API Keys

### 5.1 Access API Keys

1. Go to **Settings** → **API**
2. You'll see:

```
Project URL: https://woigtfojjixtmwaoamap.supabase.co
anon public: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 5.2 Copy Keys

1. **Project URL**: Copy the full URL
2. **anon public key**: Click the eye icon to reveal, then copy
3. **service_role key**: Click the eye icon to reveal, then copy
   - ⚠️ **Keep this secret!**

### 5.3 Add to Environment Variables

Add these to your `.env` file:

```env
VITE_SUPABASE_URL=https://woigtfojjixtmwaoamap.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> **Note**: Your keys are already configured in the project. See the main setup guide for details.

---

## 6. Next Steps

Once you have access to your Supabase project:

1. ✅ **Save Your Credentials**
   - Save database password securely
   - Add API keys to `.env` file
   - Verify `.env` is in `.gitignore`

2. ✅ **Run Database Migrations**
   - See [supabase/README.md](../supabase/README.md)
   - Execute SQL files in SQL Editor
   - Start with `001_initial_schema.sql`

3. ✅ **Set Up Storage**
   - Create `attachments` bucket
   - Configure storage policies
   - See storage setup in [supabase/README.md](../supabase/README.md)

4. ✅ **Test Connection**
   - Use the service functions in `services/`
   - Test API calls from your React app
   - Verify authentication works

5. ✅ **Continue Setup**
   - Follow [QUICK_START.md](./QUICK_START.md) for complete setup
   - Review [SUPABASE_BACKEND_GUIDE.md](./SUPABASE_BACKEND_GUIDE.md) to understand the system

---

## 7. Troubleshooting

### Can't Access Project

- **Check login**: Make sure you're logged in with the correct account
- **Check organization**: Project might be in a different organization
- **Contact support**: If project was created by someone else, ask for access

### Forgot Database Password

1. Go to **Settings** → **Database**
2. Click **Reset database password**
3. Enter new password
4. Save securely

### API Keys Not Working

- **Check environment variables**: Make sure keys are in `.env` file
- **Check key visibility**: Click eye icon to reveal hidden keys
- **Regenerate keys**: Settings → API → Regenerate (use with caution!)

### Project Not Loading

- **Check internet connection**
- **Try refreshing the page**
- **Check Supabase status**: [status.supabase.com](https://status.supabase.com)
- **Clear browser cache**

---

## 8. Resources

- [Supabase Dashboard](https://supabase.com/dashboard)
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Status](https://status.supabase.com)
- [Community Forum](https://github.com/supabase/supabase/discussions)

---

## Quick Reference

### Your Project Details

**For New Projects:**
```
Project Name: project-planner
Project URL: https://[your-project-ref].supabase.co
Project ID: [auto-generated]
Region: [Your selected region]
Plan: Free (recommended to start)
Database Password: [Your secure password - save this!]
```

**For Existing ProjectFlow Project:**
```
Project Name: [Your existing project name]
Project URL: https://woigtfojjixtmwaoamap.supabase.co
Project ID: woigtfojjixtmwaoamap
Region: [Your selected region]
Plan: Free / Pro
```

### Dashboard Links

- **Table Editor**: View/manage database tables
- **SQL Editor**: Run migrations and queries
- **Authentication**: Manage users
- **Storage**: File management
- **API Docs**: API reference
- **Settings**: Project configuration

---

**You're all set!** Your Supabase project is ready to power ProjectFlow. 🚀
