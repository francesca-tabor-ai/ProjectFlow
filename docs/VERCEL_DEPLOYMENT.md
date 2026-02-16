# Vercel Deployment Guide

Complete guide to deploying ProjectFlow frontend to Vercel.

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Environment Variables](#3-environment-variables)
4. [Deployment Steps](#4-deployment-steps)
5. [Vercel Configuration](#5-vercel-configuration)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Overview

### What is Vercel?

Vercel is an excellent platform for deploying frontend applications. It offers:
- ✅ **Automatic deployments** from Git
- ✅ **Preview deployments** for pull requests
- ✅ **Edge network** for fast global delivery
- ✅ **Zero configuration** for most frameworks
- ✅ **Free tier** for personal projects

### ProjectFlow Stack

**Note**: ProjectFlow uses **Vite + React** (not Next.js), but Vercel supports Vite perfectly!

```
Frontend: Vite + React
Backend: Supabase
Deployment: Vercel
```

---

## 2. Prerequisites

### Before You Start

1. ✅ **Supabase project** set up and configured
2. ✅ **Git repository** with your code
3. ✅ **Vercel account** (sign up at [vercel.com](https://vercel.com))
4. ✅ **Environment variables** ready

### Required Information

- Supabase Project URL
- Supabase Anon Key
- Supabase Service Role Key (optional, for server-side operations)

---

## 3. Environment Variables

### For Vite Projects (ProjectFlow)

**Important**: ProjectFlow uses **Vite**, not Next.js, so environment variables use `VITE_` prefix:

```env
# .env.local (for local development)
VITE_SUPABASE_URL=https://woigtfojjixtmwaoamap.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
VITE_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here  # Optional
```

### Finding Your Supabase Credentials

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **Settings** → **API**
4. Copy:
   - **Project URL** → `VITE_SUPABASE_URL`
   - **anon public** key → `VITE_SUPABASE_ANON_KEY`
   - **service_role** key → `VITE_SUPABASE_SERVICE_ROLE_KEY` (optional)

### Environment Variable Reference

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_SUPABASE_URL` | Your Supabase project URL | ✅ Yes |
| `VITE_SUPABASE_ANON_KEY` | Public anon key for client-side | ✅ Yes |
| `VITE_SUPABASE_SERVICE_ROLE_KEY` | Service role key (server-side only) | ❌ Optional |

**Note**: In Next.js, you'd use `NEXT_PUBLIC_` prefix, but ProjectFlow uses Vite, so we use `VITE_` prefix.

---

## 4. Deployment Steps

### Step 1: Prepare Your Project

Ensure your project is ready:

```bash
# Check that build works locally
npm run build

# Test the preview
npm run preview
```

### Step 2: Push to Git

Make sure your code is in a Git repository:

```bash
# Initialize git if needed
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit"

# Push to GitHub/GitLab/Bitbucket
git remote add origin https://github.com/yourusername/projectflow.git
git push -u origin main
```

### Step 3: Deploy to Vercel

#### Option A: Deploy via Vercel Dashboard

1. **Sign up/Log in to Vercel**
   - Navigate to [Vercel](https://vercel.com/)
   - Create a new account or log in

2. **Import Git Repository**
   - Click "Add New Project" or "Import Project"
   - Connect your Git provider (GitHub, GitLab, Bitbucket)
   - Select your ProjectFlow repository
   - Click "Import"

3. **Configure Project**
   - **Framework Preset**: Vercel will usually auto-detect **Vite** (not Next.js)
     - If not detected, manually select "Vite"
   - **Root Directory**: `./` (or your frontend folder if monorepo)
   - **Build Command**: `npm run build` (default for Vite)
   - **Output Directory**: `dist` (default for Vite)
   - **Install Command**: `npm install` (default)

4. **Add Environment Variables**
   - Before deploying, click "Environment Variables" or go to Project Settings → Environment Variables
   - Add each variable for the correct environments:
     - **Variable Name**: `VITE_SUPABASE_URL`
       - **Value**: `https://woigtfojjixtmwaoamap.supabase.co`
       - **Environments**: ✅ Production, ✅ Preview, ✅ Development
     - **Variable Name**: `VITE_SUPABASE_ANON_KEY`
       - **Value**: `your_anon_key_here`
       - **Environments**: ✅ Production, ✅ Preview, ✅ Development
     - **Variable Name**: `VITE_SUPABASE_SERVICE_ROLE_KEY` (optional)
       - **Value**: `your_service_role_key_here`
       - **Environments**: ✅ Production (only, for security)
   
   **Important**: 
   - Use `VITE_` prefix (not `NEXT_PUBLIC_`) because ProjectFlow uses Vite, not Next.js
   - Make sure variables are available for the correct environments (Production, Preview, Development)

5. **Deploy**
   - Click "Deploy"
   - Vercel will build and deploy your application
   - Wait for build to complete (usually 1-3 minutes)
   - You'll get a deployment URL like: `https://projectflow.vercel.app`

#### Option B: Deploy via Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Follow prompts:
# - Set up and deploy? Yes
# - Which scope? Your account
# - Link to existing project? No
# - Project name? projectflow (or your choice)
# - Directory? ./
# - Override settings? No
```

### Step 4: Configure Environment Variables (CLI)

If using CLI, add environment variables:

```bash
# Add environment variables
vercel env add VITE_SUPABASE_URL
# Paste: https://woigtfojjixtmwaoamap.supabase.co

vercel env add VITE_SUPABASE_ANON_KEY
# Paste: your_anon_key

vercel env add VITE_SUPABASE_SERVICE_ROLE_KEY
# Paste: your_service_role_key (optional)
```

### Step 5: Verify Deployment

1. **Check deployment URL**
   - Vercel provides a URL like: `https://projectflow.vercel.app`
2. **Test the application**
   - Open the URL in browser
   - Test authentication
   - Test CRUD operations
3. **Check logs**
   - Go to Vercel Dashboard → Your Project → Deployments
   - Click on deployment → View Function Logs

---

## 5. Vercel Configuration

### vercel.json (Optional)

Create `vercel.json` for custom configuration:

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "vite",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

**Why rewrites?**
- Vite apps are Single Page Applications (SPAs)
- All routes should serve `index.html`
- Vercel handles client-side routing

### Custom Domain

1. **Go to Vercel Dashboard** → Your Project → Settings → Domains
2. **Add your domain**
3. **Follow DNS instructions**
4. **Vercel automatically provisions SSL**

### Environment Variables per Environment

Vercel supports different environments:

- **Production**: `vercel env add VITE_SUPABASE_URL production`
- **Preview**: `vercel env add VITE_SUPABASE_URL preview`
- **Development**: `vercel env add VITE_SUPABASE_URL development`

---

## 6. Continuous Deployment

### Automatic Deployments

**Subsequent pushes to your connected Git branch will trigger automatic redeployments:**

Vercel automatically deploys:
- ✅ **Push to main/master branch** → Production deployment
- ✅ **Pull requests** → Preview deployment with unique URL
- ✅ **Push to any branch** → Preview deployment
- ✅ **Every commit** → New deployment

**No manual deployment needed!** Just push to Git and Vercel handles the rest.

### Deployment Settings

1. **Go to Vercel Dashboard** → Your Project → Settings → Git
2. **Configure**:
   - **Production Branch**: `main` (or `master`)
   - **Preview Deployments**: Enabled (recommended)
   - **Automatic deployments**: Enabled (default)
   - **Ignore Build Step**: Leave empty (unless you need custom logic)

### Preview Deployments

Preview deployments are great for:
- ✅ Testing changes before merging
- ✅ Sharing work-in-progress with team
- ✅ Testing different environments
- ✅ Getting feedback on pull requests

Each preview gets a unique URL that you can share.

---

## 7. Build Configuration

### Vite Build Settings

Your `vite.config.ts` should already be configured:

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    sourcemap: false,  // Disable for production
  }
});
```

### Build Optimization

Vercel automatically:
- ✅ Optimizes assets
- ✅ Minifies code
- ✅ Enables compression
- ✅ Serves via CDN

---

## 8. Troubleshooting

### Build Fails

**Error**: `Environment variable not found`

**Solution**:
1. Check environment variables in Vercel Dashboard
2. Ensure variables start with `VITE_` prefix
3. Redeploy after adding variables

**Error**: `Module not found`

**Solution**:
1. Check `package.json` dependencies
2. Ensure `node_modules` is not in `.gitignore` (it shouldn't be)
3. Vercel installs dependencies automatically

### Runtime Errors

**Error**: `Supabase client not initialized`

**Solution**:
1. Check environment variables are set
2. Verify `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are correct
3. Check browser console for errors

**Error**: `CORS errors`

**Solution**:
1. Check Supabase project settings
2. Add Vercel domain to allowed origins (if needed)
3. Supabase should allow all origins by default

### Deployment Issues

**Issue**: Changes not reflecting

**Solution**:
1. Clear browser cache
2. Check deployment logs
3. Ensure latest code is pushed to Git
4. Trigger manual redeploy

**Issue**: Slow builds

**Solution**:
1. Check build logs for bottlenecks
2. Optimize dependencies
3. Use Vercel's build cache
4. Consider upgrading plan for faster builds

---

## 9. Best Practices

### 1. Never Commit Secrets

```bash
# ✅ Good: .env.local in .gitignore
.env.local
.env

# ❌ Bad: Committing secrets
# Never commit .env files with real keys
```

### 2. Use Environment-Specific Variables

```bash
# Production
VITE_SUPABASE_URL=https://prod-project.supabase.co

# Preview/Development
VITE_SUPABASE_URL=https://dev-project.supabase.co
```

### 3. Monitor Deployments

- Check deployment logs regularly
- Set up error tracking (Sentry, etc.)
- Monitor performance metrics

### 4. Test Before Deploying

```bash
# Test build locally
npm run build

# Test preview
npm run preview

# Fix any issues before pushing
```

---

## 10. Next.js vs Vite (Important Note)

### PRD Mentions Next.js

**The PRD mentions Next.js, but ProjectFlow uses Vite!**

| Aspect | Next.js (PRD) | Vite (ProjectFlow) |
|-------|---------------|-------------------|
| **Environment Variables** | `NEXT_PUBLIC_*` | `VITE_*` |
| **Build Output** | `.next` | `dist` |
| **Config File** | `next.config.js` | `vite.config.ts` |
| **Dev Server** | `next dev` | `vite` |
| **Build Command** | `next build` | `vite build` |
| **Framework Detection** | Auto-detects Next.js | Auto-detects Vite |

### Important Corrections

**PRD says:**
```env
# ❌ Wrong for ProjectFlow (Next.js format)
NEXT_PUBLIC_SUPABASE_URL=YOUR_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

**ProjectFlow uses:**
```env
# ✅ Correct for ProjectFlow (Vite format)
VITE_SUPABASE_URL=https://woigtfojjixtmwaoamap.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

**Vercel Configuration:**
- Vercel will auto-detect **Vite** (not Next.js)
- Framework Preset should be **Vite**
- Build Command: `npm run build`
- Output Directory: `dist`

### Why Vite?

- ✅ **Faster development** - Instant HMR
- ✅ **Simpler configuration** - Less boilerplate
- ✅ **Better for SPAs** - Optimized for React
- ✅ **Smaller bundle** - Tree-shaking by default
- ✅ **Works great with Vercel** - Full support

---

## 11. Deployment Checklist

Before deploying:

- [ ] **Supabase Setup**
  - [ ] Supabase project created and configured
  - [ ] Database schema migrated
  - [ ] RLS policies enabled and tested
  - [ ] Storage buckets created (if needed)

- [ ] **Local Development**
  - [ ] Environment variables documented
  - [ ] `.env.local` created (for local dev)
  - [ ] Build works locally (`npm run build`)
  - [ ] Preview works (`npm run preview`)
  - [ ] Application tested locally

- [ ] **Git Repository**
  - [ ] Code pushed to Git repository
  - [ ] Repository is public or Vercel has access
  - [ ] `.env` files in `.gitignore` (not committed)

- [ ] **Vercel Setup**
  - [ ] Vercel account created
  - [ ] Git provider connected (GitHub/GitLab/Bitbucket)
  - [ ] Repository imported to Vercel
  - [ ] Framework auto-detected as **Vite** (not Next.js)

- [ ] **Environment Variables**
  - [ ] `VITE_SUPABASE_URL` added to Vercel
  - [ ] `VITE_SUPABASE_ANON_KEY` added to Vercel
  - [ ] `VITE_SUPABASE_SERVICE_ROLE_KEY` added (optional)
  - [ ] Variables set for correct environments (Production, Preview, Development)

- [ ] **Deployment**
  - [ ] Initial deployment successful
  - [ ] Build logs checked (no errors)
  - [ ] Application tested on Vercel URL
  - [ ] Authentication works
  - [ ] CRUD operations work
  - [ ] Real-time features work (if implemented)

- [ ] **Post-Deployment**
  - [ ] Custom domain configured (optional)
  - [ ] Monitoring set up (optional)
  - [ ] Team members have access (if needed)

---

## 12. Summary

### Key Points

1. ✅ **Vite, not Next.js** - ProjectFlow uses Vite
2. ✅ **Environment variables** - Use `VITE_` prefix
3. ✅ **Automatic deployments** - From Git
4. ✅ **Preview deployments** - For pull requests
5. ✅ **Zero configuration** - Vercel detects Vite automatically

### Quick Reference

```bash
# Local development
npm run dev

# Build locally
npm run build

# Preview build
npm run preview

# Deploy to Vercel
vercel

# Add environment variable
vercel env add VITE_SUPABASE_URL
```

---

**Vercel makes deploying Vite apps effortless - just connect your Git repo!** 🚀
