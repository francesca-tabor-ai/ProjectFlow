# Project Provisioning Guide

This guide explains what happens during Supabase project provisioning and what to expect.

## What is Project Provisioning?

When you create a new Supabase project, the platform automatically sets up all the infrastructure and services needed to run your backend. This process is called **provisioning**.

## Provisioning Timeline

```
┌─────────────────────────────────────────────────┐
│           Provisioning Process                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  0:00 ──────────────────────────────────────── │
│        Click "Create new project"              │
│                                                 │
│  0:05 ──────────────────────────────────────── │
│        ✅ Organization verified                 │
│        ✅ Project details validated            │
│                                                 │
│  0:10 ──────────────────────────────────────── │
│        🔄 Creating PostgreSQL database...      │
│        - Allocating compute resources           │
│        - Setting up database instance          │
│        - Configuring connection pool            │
│                                                 │
│  0:30 ──────────────────────────────────────── │
│        🔄 Setting up API infrastructure...     │
│        - REST API gateway                      │
│        - Auto-generating endpoints             │
│        - Configuring CORS                      │
│                                                 │
│  0:45 ──────────────────────────────────────── │
│        🔄 Configuring Authentication...        │
│        - Auth service setup                    │
│        - JWT token system                      │
│        - Email templates                       │
│                                                 │
│  1:00 ──────────────────────────────────────── │
│        🔄 Initializing Storage...              │
│        - Storage buckets                       │
│        - CDN configuration                     │
│        - Access policies                      │
│                                                 │
│  1:15 ──────────────────────────────────────── │
│        🔄 Setting up Real-time...              │
│        - WebSocket infrastructure             │
│        - Replication system                    │
│        - Presence tracking                    │
│                                                 │
│  1:30 ──────────────────────────────────────── │
│        🔄 Generating API keys...               │
│        - Anon/public key                       │
│        - Service role key                      │
│        - Database connection string            │
│                                                 │
│  1:45 ──────────────────────────────────────── │
│        🔄 Creating dashboard...                │
│        - UI components                         │
│        - Monitoring setup                     │
│        - Logging configuration                 │
│                                                 │
│  2:00 ──────────────────────────────────────── │
│        ✅ Project ready!                       │
│        Redirecting to dashboard...            │
│                                                 │
└─────────────────────────────────────────────────┘

Total Time: ~1-3 minutes (varies by region and load)
```

## What Gets Provisioned

### 1. PostgreSQL Database

**What it is:**
- A fully managed PostgreSQL database instance
- Pre-configured with optimal settings
- Automatic backups enabled

**What you get:**
- Database connection string
- Direct database access (with password)
- pgAdmin access (optional)
- Database extensions support

**Size:**
- Free tier: 500 MB
- Pro tier: 8 GB+ (scales automatically)

### 2. Auto-generated REST API

**What it is:**
- RESTful API endpoints for every table
- Automatic OpenAPI documentation
- Built-in filtering, pagination, and sorting

**What you get:**
- REST endpoints: `GET`, `POST`, `PATCH`, `DELETE`
- Query parameters for filtering
- Relationship queries (joins)
- Bulk operations support

**Example endpoints created:**
```
GET    /rest/v1/projects
POST   /rest/v1/projects
PATCH  /rest/v1/projects?id=eq.123
DELETE /rest/v1/projects?id=eq.123
```

### 3. Authentication System

**What it is:**
- Complete user authentication service
- JWT token management
- Session handling

**What you get:**
- Email/password authentication
- OAuth providers (Google, GitHub, etc.)
- Magic link authentication
- User management UI
- Password reset flows

### 4. Storage (File Storage)

**What it is:**
- S3-compatible object storage
- CDN integration
- File upload/download APIs

**What you get:**
- Storage buckets
- File upload endpoints
- Public/private file access
- Image transformations (optional)

**Limits:**
- Free tier: 1 GB storage
- Pro tier: 100 GB+ storage

### 5. Real-time Infrastructure

**What it is:**
- WebSocket server for live updates
- Database change replication
- Presence tracking

**What you get:**
- Real-time subscriptions
- Database change notifications
- Presence/online status
- Broadcast channels

### 6. API Keys

**What it is:**
- Authentication tokens for API access
- Different keys for different security levels

**What you get:**
- **Anon/Public Key**: Safe for client-side use
- **Service Role Key**: Server-side only (admin access)
- **Database Connection String**: Direct DB access

## What to Do During Provisioning

### ✅ Do:

- **Wait patiently** - Process takes 1-3 minutes
- **Keep browser tab open** - Don't close or refresh
- **Watch the progress** - You'll see status updates
- **Prepare your notes** - Get ready to save API keys

### ❌ Don't:

- **Don't close the browser** - Let it complete
- **Don't refresh the page** - Wait for redirect
- **Don't click "Create" again** - One click is enough
- **Don't navigate away** - Stay on the page

## After Provisioning Completes

### Immediate Next Steps

1. **Save Your Credentials**
   ```
   - Project URL
   - Project ID
   - Anon Key
   - Service Role Key (keep secret!)
   - Database Password (you set this)
   ```

2. **Verify Dashboard Access**
   - Check that all sections load
   - Verify API keys are visible
   - Test SQL Editor access

3. **Add to Environment Variables**
   ```env
   VITE_SUPABASE_URL=https://[your-project].supabase.co
   VITE_SUPABASE_ANON_KEY=[your-anon-key]
   VITE_SUPABASE_SERVICE_ROLE_KEY=[your-service-key]
   ```

### What You Can Do Now

- ✅ **Run SQL queries** in SQL Editor
- ✅ **Create tables** via Table Editor or SQL
- ✅ **Test API endpoints** using API docs
- ✅ **Upload files** to storage buckets
- ✅ **Set up authentication** providers
- ✅ **Run database migrations** (see `supabase/migrations/`)

## Troubleshooting Provisioning Issues

### Provisioning Takes Too Long (>5 minutes)

**Possible causes:**
- High server load
- Network connectivity issues
- Regional service issues

**Solutions:**
1. Check [Supabase Status](https://status.supabase.com)
2. Wait a few more minutes
3. Refresh the page (project may already exist)
4. Check your project list - it might be there already
5. Contact Supabase support if persistent

### Provisioning Failed

**What to do:**
1. Check error message in dashboard
2. Verify all required fields were filled
3. Try creating project again
4. Check if project already exists with same name
5. Contact support with error details

### Can't Access Project After Provisioning

**What to do:**
1. Log out and log back in
2. Check you're in the correct organization
3. Search for project by name or ID
4. Check email for project creation confirmation
5. Verify you have access permissions

## Provisioning Status Indicators

### In Progress
```
🔄 Setting up your project...
   This may take a few minutes
```

### Almost Done
```
✅ Database ready
✅ API ready
🔄 Finalizing...
```

### Complete
```
✅ Project created successfully!
   Redirecting to dashboard...
```

## Regional Differences

Provisioning time can vary by region:

- **US Regions**: Typically 1-2 minutes
- **EU Regions**: Typically 1-2 minutes
- **Asia Pacific**: May take 2-3 minutes
- **Other regions**: Check Supabase status page

## Best Practices

1. **Create during off-peak hours** for faster provisioning
2. **Save credentials immediately** after provisioning
3. **Test connection** right away to verify setup
4. **Document your project ID** for future reference
5. **Set up monitoring** to track project health

## Next Steps

Once provisioning is complete:

1. ✅ Follow [QUICK_START.md](./QUICK_START.md) to set up your database
2. ✅ Review [SUPABASE_BACKEND_GUIDE.md](./SUPABASE_BACKEND_GUIDE.md) to understand the system
3. ✅ Run migrations from `supabase/migrations/`
4. ✅ Set up storage buckets
5. ✅ Start building your application!

---

**Your project is being provisioned - this is a one-time process that sets up everything you need!** ⏱️
