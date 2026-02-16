# ProjectFlow Backend Documentation

Complete documentation for setting up and using the Supabase backend for ProjectFlow.

## 📚 Documentation Index

### Getting Started

1. **[Quick Start Guide](./QUICK_START.md)** ⚡
   - Get up and running in ~10 minutes
   - Step-by-step setup instructions
   - Testing checklist

2. **[Supabase Project Setup](./SUPABASE_PROJECT_SETUP.md)** 🆕
   - Sign up / log in to Supabase
   - Create new project (`project-planner`)
   - Get API keys and configuration
   - **[Project Creation Checklist](./PROJECT_CREATION_CHECKLIST.md)** - Step-by-step checklist
   - **[Provisioning Guide](./PROVISIONING_GUIDE.md)** - What happens during provisioning

3. **[Backend Setup Guide](./BACKEND_SETUP.md)** 📋
   - Complete setup instructions
   - Database schema overview
   - Deployment guide

### Understanding Supabase

3. **[Supabase Backend Guide](./SUPABASE_BACKEND_GUIDE.md)** 🎓
   - **Start here to understand how Supabase works**
   - Explains PostgreSQL, Authentication, APIs, and Real-time
   - Architecture diagrams and flow charts
   - How all components work together

### Code Examples

4. **[API Usage Examples](./API_USAGE_EXAMPLES.md)** 💻
   - Practical code examples
   - Authentication flows
   - Real-time subscriptions
   - Error handling patterns

4a. **[CRUD Operations](./CRUD_OPERATIONS.md)** 📝
   - Complete CRUD guide for all tables
   - Create, Read, Update, Delete examples
   - Workspaces, Projects, Sheets, Columns, Rows
   - Best practices and common patterns

4b. **[Real-time Collaboration](./REALTIME_COLLABORATION.md)** 🔴
   - Real-time subscriptions and WebSocket updates
   - Live cursor indicators
   - Simultaneous editing
   - Presence system
   - Best practices for real-time features

5. **[Vercel Deployment](./VERCEL_DEPLOYMENT.md)** 🚀
   - Deploy Vite + React frontend to Vercel
   - Environment variables setup
   - Continuous deployment from Git
   - Troubleshooting and best practices

6. **[Next Steps](./NEXT_STEPS.md)** 📋
   - Frontend component implementation
   - RLS policy refinement
   - Supabase Functions exploration
   - Implementation priority and roadmap

4b. **[Supabase API Interaction](./SUPABASE_API_INTERACTION.md)** 🔌
   - How auto-generated APIs work
   - Using JavaScript client vs HTTP requests
   - Query examples and best practices
   - Accessing API documentation

4c. **[Authentication Guide](./AUTHENTICATION_GUIDE.md)** 🔐
   - Complete authentication guide
   - Sign up, sign in, sign out
   - JWT tokens and session management
   - Protected routes and best practices

### Data Model

5. **[Data Model Documentation](./DATA_MODEL.md)** 📊
   - Authentication architecture (auth.users vs profiles)
   - Complete schema explanation
   - PRD mapping
   - Why we use Supabase Auth instead of custom users table

6. **[Schema Reference](./SCHEMA_REFERENCE.md)** 📋
   - Quick reference for all tables
   - Relationships diagram
   - Indexes and triggers

7. **[Schema Comparison](./SCHEMA_COMPARISON.md)** 🔄
   - PRD schema vs our implementation
   - Key differences explained
   - Migration guide from PRD schema

8. **[Workspaces Schema](./WORKSPACES_SCHEMA.md)** 🏢
   - Complete workspaces table documentation
   - RLS policies explained
   - Usage examples and best practices

9. **[Projects Schema](./PROJECTS_SCHEMA.md)** 📁
   - Complete projects table documentation
   - Project ownership model
   - RLS policies and member management
   - Comparison with PRD specification

10. **[Sheets Schema](./SHEETS_SCHEMA.md)** 📊
    - Complete sheets table documentation
    - Performance optimizations
    - RLS policies explained
    - Comparison with PRD specification

11. **[Columns Schema](./COLUMNS_SCHEMA.md)** 📋
    - Complete columns table documentation
    - Type system (ENUM vs CHECK constraint)
    - Performance optimizations (5-10x faster)
    - Additional fields (width, permissions)
    - Comparison with PRD specification

12. **[Rows Schema](./ROWS_SCHEMA.md)** 📝
    - Complete rows table documentation
    - JSONB data storage (flexible schema)
    - Task dependencies support
    - Performance optimizations (5-10x faster)
    - Critical: PRD missing row_data field!
    - Comparison with PRD specification

13. **[Cells vs JSONB](./CELLS_VS_JSONB.md)** 🔄
    - Why we use JSONB instead of cells table
    - Performance comparison (10-20x faster)
    - Trade-offs and when to use each approach
    - Migration guide between approaches

14. **[Tasks Data Model](./TASKS_DATA_MODEL.md)** ✅
    - How task data is stored (no separate tasks table needed)
    - Task fields in JSONB (aligns with PRD intent)
    - When to add a tasks table (if needed later)
    - Examples and best practices

## 🗂️ File Structure

```
docs/
├── README.md                    # This file
├── QUICK_START.md              # Quick setup guide
├── BACKEND_SETUP.md            # Complete setup guide
├── SUPABASE_BACKEND_GUIDE.md  # How Supabase works
└── API_USAGE_EXAMPLES.md      # Code examples

supabase/
├── migrations/
│   ├── 001_initial_schema.sql      # Core database tables
│   └── 002_storage_and_functions.sql  # Helper functions
└── README.md                       # Migration instructions

services/
├── supabaseService.ts          # Supabase client setup
├── projectService.ts           # Project CRUD operations
└── workspaceService.ts        # Workspace CRUD operations
```

## 🚀 Quick Navigation

### I want to...

- **Create or access Supabase project** → [SUPABASE_PROJECT_SETUP.md](./SUPABASE_PROJECT_SETUP.md)
- **Understand how Supabase works** → [SUPABASE_BACKEND_GUIDE.md](./SUPABASE_BACKEND_GUIDE.md)
- **Set up the database quickly** → [QUICK_START.md](./QUICK_START.md)
- **See code examples** → [API_USAGE_EXAMPLES.md](./API_USAGE_EXAMPLES.md)
- **Read complete setup guide** → [BACKEND_SETUP.md](./BACKEND_SETUP.md)
- **Run database migrations** → [supabase/README.md](../supabase/README.md)

## 📖 Key Concepts

### Supabase as Your Backend

Supabase provides everything you need for a backend:

```
┌─────────────────────────────────────┐
│         Your React App              │
│         (Frontend)                   │
└──────────────┬──────────────────────┘
               │
               │ HTTP/WebSocket
               │
┌──────────────▼──────────────────────┐
│         Supabase Backend            │
│                                     │
│  ✅ PostgreSQL Database             │
│  ✅ Auto-generated REST APIs        │
│  ✅ Authentication                  │
│  ✅ Real-time Subscriptions         │
│  ✅ File Storage                    │
│  ✅ Row Level Security              │
└─────────────────────────────────────┘
```

**No backend code required!** Your database schema automatically becomes your API.

### How It Works

1. **Define Schema**: Create tables in PostgreSQL
2. **Auto-generate API**: Supabase creates REST endpoints automatically
3. **Use in Frontend**: Call APIs via Supabase JavaScript client
4. **Real-time Updates**: Subscribe to changes via WebSocket

See [SUPABASE_BACKEND_GUIDE.md](./SUPABASE_BACKEND_GUIDE.md) for detailed explanation.

## 🎯 Recommended Reading Order

1. **First Time Setup?**
   - Start with [SUPABASE_PROJECT_SETUP.md](./SUPABASE_PROJECT_SETUP.md) to create/access your project
   - Then follow [QUICK_START.md](./QUICK_START.md) for database setup
   - Read [SUPABASE_BACKEND_GUIDE.md](./SUPABASE_BACKEND_GUIDE.md) to understand how it works

2. **Want to Understand Supabase?**
   - Read [SUPABASE_BACKEND_GUIDE.md](./SUPABASE_BACKEND_GUIDE.md) first
   - Then check [API_USAGE_EXAMPLES.md](./API_USAGE_EXAMPLES.md) for code

3. **Ready to Code?**
   - Review [API_USAGE_EXAMPLES.md](./API_USAGE_EXAMPLES.md)
   - Reference [BACKEND_SETUP.md](./BACKEND_SETUP.md) for details

## 🔗 External Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [PostgreSQL JSONB Guide](https://www.postgresql.org/docs/current/datatype-json.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

## 💡 Tips

- **Always check RLS policies** if you get permission errors
- **Use TypeScript** for type safety with Supabase client
- **Test real-time subscriptions** in development
- **Monitor Supabase dashboard** for API usage and errors
- **Use service layer pattern** (see `services/` directory)

---

**Happy coding!** 🚀
