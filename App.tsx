
import React, { useState, useEffect, useMemo, useRef, useCallback } from 'react';
import Sidebar from './components/Sidebar';
import Toolbar, { SaveStatus } from './components/Toolbar';
import SheetGrid from './components/SheetGrid';
import KanbanBoard from './components/KanbanBoard';
import GanttChart from './components/GanttChart';
import CalendarView from './components/CalendarView';
import AIAssistant from './components/AIAssistant';
import AuthPage from './components/AuthPage';
import AuthCallback from './components/AuthCallback';
import UserProfileModal from './components/UserProfileModal';
import { supabase } from './lib/supabaseClient';
import { getAllProjects } from './services/projectService';
import { getWorkspaces } from './services/workspaceService';
import { generateProjectPlan } from './services/geminiService';
import ShareModal from './components/ShareModal';
import CommentsPanel from './components/CommentsPanel';
import ActivityLogPage from './components/ActivityLogPanel';
import AutomationsPage from './components/AutomationModal';
import NotificationStack from './components/NotificationStack';
import TemplateGalleryModal from './components/TemplateGalleryModal';
import PermissionsModal from './components/PermissionsModal';
import IntegrationsPage from './components/IntegrationsModal';
import GooglePickerMock from './components/GooglePickerMock';
import AIReliabilityPage from './components/AIReliabilityDashboard';
import AIRetrainingPage from './components/AIRetrainingDashboard';
import AIAdvancedPage from './components/AIAdvancedGovernance';
import TeamMembersPage from './components/TeamMembersPage';
import WorkspaceSettings from './components/WorkspaceSettings';
import { Project, ViewMode, RowData, User, Workspace, Sheet, Column, SortConfig, SyncEvent, RemoteCursor, Collaborator, Role, Member, Comment, ActivityEntry, FilterConfig, SavedView, AutomationRule, AppNotification, Template, FileAttachment, PermissionConfig, IntegrationSettings, AICommandResult, AIMetric, RetrainingJob, RetrainingConfig, AppPage, RoleDefinition } from './types';
import { INITIAL_SHEET, DEFAULT_COLUMNS } from './constants';
import { computeSheetData } from './services/formulaEngine';

const STORAGE_KEYS = {
  USER: 'projectflow_user',
  WORKSPACES: 'projectflow_workspaces',
  PROJECTS: 'projectflow_projects',
  ACTIVE_WS: 'projectflow_active_ws',
  ACTIVE_PROJ: 'projectflow_active_proj',
  AI_METRICS: 'projectflow_ai_metrics',
  AI_RE_JOBS: 'projectflow_ai_retraining_jobs',
  AI_RE_CONFIG: 'projectflow_ai_retraining_config',
  CURRENT_PAGE: 'projectflow_current_page'
};

const DEFAULT_ROLES: RoleDefinition[] = [
  { id: 'role-owner', name: 'Owner', description: 'Full workspace and billing management access.', color: '#1e293b', baseRole: 'Owner', isSystem: true },
  { id: 'role-editor', name: 'Editor', description: 'Can create and edit all project data.', color: '#6366f1', baseRole: 'Editor', isSystem: true },
  { id: 'role-viewer', name: 'Viewer', description: 'Read-only access to sheets and dashboards.', color: '#94a3b8', baseRole: 'Viewer', isSystem: true },
];

const COLLABORATION_CHANNEL = 'projectflow_collaboration_v1';

const DEFAULT_FILTERS: FilterConfig = {
  owners: [],
  statuses: [],
  dateRange: 'all'
};

const App: React.FC = () => {
  const channel = useMemo(() => new BroadcastChannel(COLLABORATION_CHANNEL), []);
  const userColor = useMemo(() => {
    const colors = ['#6366f1', '#a855f7', '#ec4899', '#f97316', '#10b981', '#06b6d4'];
    return colors[Math.floor(Math.random() * colors.length)];
  }, []);

  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem(STORAGE_KEYS.USER);
    if (saved) {
      const u = JSON.parse(saved);
      return { ...u, color: userColor };
    }
    return null;
  });

  const [workspaces, setWorkspaces] = useState<Workspace[]>(() => {
    const saved = localStorage.getItem(STORAGE_KEYS.WORKSPACES);
    if (saved) return JSON.parse(saved);
    return [{ 
      id: 'ws-1', 
      name: 'General', 
      ownerId: 'guest', 
      members: [
        { userId: 'guest', name: 'Guest User', email: 'guest@example.com', role: 'Owner' }
      ],
      roles: DEFAULT_ROLES
    }];
  });

  const [activeWorkspaceId, setActiveWorkspaceId] = useState<string>(() => localStorage.getItem(STORAGE_KEYS.ACTIVE_WS) || 'ws-1');
  
  const [projects, setProjects] = useState<Project[]>(() => {
    const saved = localStorage.getItem(STORAGE_KEYS.PROJECTS);
    if (saved) return JSON.parse(saved);
    
    // Default Projects including the Rigshospitalet case study
    return [
      {
        id: 'proj-rigs',
        name: 'Rigshospitalet: AI Surgery Assistant',
        workspaceId: 'ws-1',
        sheets: [
          {
            id: 'rigs-lifecycle',
            name: '1. Implementation Roadmap',
            columns: [
              { id: 'task', title: 'Implementation Stage', type: 'text', width: 300 },
              { id: 'owner', title: 'Lead SME', type: 'text', width: 140 },
              { id: 'status', title: 'Status', type: 'dropdown', width: 130, options: ['Discovery', 'Validation', 'Pilot', 'Production'] },
              { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
              { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
              { id: 'progress', title: '% Complete', type: 'number', width: 100 },
            ],
            rows: [
              { id: 'rh1', task: 'Clinical Scope Definition (Thyroid)', owner: 'Lead Surgeon', status: 'Production', progress: 100, startDate: '2024-01-01', dueDate: '2024-01-15' },
              { id: 'rh2', task: 'Medical Hallucination Safety Testing', owner: 'AI Lead', status: 'Production', progress: 100, startDate: '2024-01-16', dueDate: '2024-02-01' },
              { id: 'rh3', task: 'Patient Comprehension UX Review', owner: 'UX Researcher', status: 'Validation', progress: 85, startDate: '2024-02-02', dueDate: '2024-03-15' },
              { id: 'rh4', task: 'Operational Call-Volume Benchmarking', owner: 'Nursing Head', status: 'Pilot', progress: 45, startDate: '2024-03-16', dueDate: '2024-05-01' },
              { id: 'rh5', task: 'Multilingual Integration Phase', owner: 'Platform Eng', status: 'Discovery', progress: 10, startDate: '2024-05-02', dueDate: '2024-07-20' },
            ]
          },
          {
            id: 'rigs-safety',
            name: '2. Reliability Guardrails',
            columns: [
              { id: 'task', title: 'Safety mechanism', type: 'text', width: 280 },
              { id: 'type', title: 'Strategy', type: 'text', width: 180 },
              { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
              { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
              { id: 'threshold', title: 'Conf. Threshold', type: 'number', width: 140 },
              { id: 'status', title: 'System Status', type: 'dropdown', width: 140, options: ['Active', 'In Tuning', 'Disabled'] },
            ],
            rows: [
              { id: 'sg1', task: 'Medical Scope Containment', type: 'RAG Architecture', startDate: '2024-01-01', dueDate: '2024-12-31', threshold: 0.95, status: 'Active' },
              { id: 'sg2', task: 'No Diagnosis Refusal', type: 'Prompt Constraint', startDate: '2024-01-01', dueDate: '2024-12-31', threshold: 1.0, status: 'Active' },
              { id: 'sg3', task: 'Source Citation Fact-check', type: 'Verification Layer', startDate: '2024-02-01', dueDate: '2024-04-30', threshold: 0.9, status: 'In Tuning' },
              { id: 'sg4', task: 'PII Scrubbing (Compliance)', type: 'Data Sanitation', startDate: '2024-01-01', dueDate: '2024-12-31', threshold: 1.0, status: 'Active' },
            ]
          }
        ],
        activeSheetId: 'rigs-lifecycle',
        ownerId: 'guest',
        members: [
          { userId: 'm1', name: 'Chief Surgeon', email: 'surgeon@rigshospitalet.dk', role: 'Owner' },
          { userId: 'm2', name: 'AI Safety Engineer', email: 'safety@2021.ai', role: 'Editor' },
          { userId: 'm3', name: 'Patient Advocate', email: 'info@patient.org', role: 'Viewer' }
        ],
        activityLog: [
          { id: 'l1', userId: 'm1', userName: 'Chief Surgeon', action: 'Approved clinical boundary for thyroid surgery prep', timestamp: Date.now() - 86400000 },
          { id: 'l2', userId: 'm2', userName: 'AI Safety Engineer', action: 'Deployed RAG verification layer v2.1', timestamp: Date.now() - 3600000 }
        ],
        savedViews: [],
        automations: [],
        integrations: { googleDriveConnected: true, apiKeys: [] }
      },
      {
        id: 'proj-sov',
        name: 'Tech Sovereignty Ecosystem',
        workspaceId: 'ws-1',
        sheets: [
          {
            id: 'sheet-sov-1',
            name: 'Roadmap Blueprint',
            columns: DEFAULT_COLUMNS,
            rows: [
              { id: 'ts1', task: 'Phase 1: Knowledge Directory (MVP)', owner: 'Product Manager', status: 'Done', priority: 'High', startDate: '2024-04-01', dueDate: '2024-05-15', progress: 100 },
              { id: 'ts2', task: 'Wiki & Implementation Guides', owner: 'Data Engineer', status: 'Done', priority: 'Medium', startDate: '2024-04-15', dueDate: '2024-05-30', progress: 100 },
              { id: 'ts3', task: 'News Ingestion Workers', owner: 'Data Engineer', status: 'In Progress', priority: 'Medium', startDate: '2024-05-01', dueDate: '2024-06-01', progress: 65 },
              { id: 'ts4', task: 'Phase 2: Vector Embeddings Pipeline', owner: 'Data Scientist', status: 'In Progress', priority: 'High', startDate: '2024-05-20', dueDate: '2024-06-20', progress: 25 },
              { id: 'ts5', task: 'RAG Conversational Service', owner: 'AI Engineer', status: 'To Do', priority: 'High', startDate: '2024-06-01', dueDate: '2024-07-15', progress: 0 },
            ]
          }
        ],
        activeSheetId: 'sheet-sov-1',
        ownerId: 'guest',
        members: [],
        activityLog: [],
        savedViews: [],
        automations: [],
        integrations: { googleDriveConnected: false, apiKeys: [] }
      }
    ];
  });

  const [activeProjectId, setActiveProjectId] = useState<string>(() => localStorage.getItem(STORAGE_KEYS.ACTIVE_PROJ) || 'proj-rigs');
  const [currentPage, setCurrentPage] = useState<AppPage>(() => (localStorage.getItem(STORAGE_KEYS.CURRENT_PAGE) as AppPage) || 'project');
  
  const [collaborators, setCollaborators] = useState<Collaborator[]>([]);
  const [remoteCursors, setRemoteCursors] = useState<Record<string, RemoteCursor>>({});
  const [viewMode, setViewMode] = useState<ViewMode>('grid');
  
  const [isAIShowing, setIsAIShowing] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [isShareOpen, setIsShareOpen] = useState(false);
  const [isTemplateGalleryOpen, setIsTemplateGalleryOpen] = useState(false);
  const [googlePickerState, setGooglePickerState] = useState<{ rowId: string } | null>(null);
  const [permissionsModal, setPermissionsModal] = useState<{ type: 'sheet' | 'column', id: string, name: string } | null>(null);
  const [rowActivityFilter, setRowActivityFilter] = useState<string | null>(null);
  const [activeRowComments, setActiveRowComments] = useState<string | null>(null);
  const [sortConfig, setSortConfig] = useState<SortConfig>({ columnId: '', direction: null });
  const [saveStatus, setSaveStatus] = useState<SaveStatus>('idle');
  const [activeFilters, setActiveFilters] = useState<FilterConfig>(DEFAULT_FILTERS);
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  
  const [isHandlingCallback, setIsHandlingCallback] = useState(false);

  const [aiMetrics, setAiMetrics] = useState<AIMetric[]>(() => {
    const saved = localStorage.getItem(STORAGE_KEYS.AI_METRICS);
    return saved ? JSON.parse(saved) : [
      { id: 'm-1', timestamp: Date.now() - 120000, latency: 145, model: 'gemini-3-pro', success: true, confidence: 0.98, taskType: 'planner', consensusScore: 0.95 },
      { id: 'm-2', timestamp: Date.now() - 60000, latency: 42, model: 'gemini-3-flash', success: true, confidence: 0.92, taskType: 'insight', consensusScore: 0.88 }
    ];
  });

  const [retrainingJobs, setRetrainingJobs] = useState<RetrainingJob[]>(() => {
    const saved = localStorage.getItem(STORAGE_KEYS.AI_RE_JOBS);
    return saved ? JSON.parse(saved) : [
      { id: 'job-init', startTime: Date.now() - 604800000, endTime: Date.now() - 604700000, status: 'success', trigger: 'schedule', baseVersion: 'v1.4.0', newVersion: 'v1.4.1-stable', accuracyGain: 2.1 }
    ];
  });

  const [retrainingConfig, setRetrainingConfig] = useState<RetrainingConfig>(() => {
    const saved = localStorage.getItem(STORAGE_KEYS.AI_RE_CONFIG);
    return saved ? JSON.parse(saved) : { enabled: true, schedule: 'weekly', driftThreshold: 20, performanceThreshold: 5 };
  });

  const saveTimeoutRef = useRef<number | null>(null);

  // Check for OAuth callback in URL (Supabase uses hash fragments for SPAs)
  useEffect(() => {
    const hashParams = new URLSearchParams(window.location.hash.substring(1));
    const accessToken = hashParams.get('access_token');
    const error = hashParams.get('error');
    
    if (accessToken || error) {
      setIsHandlingCallback(true);
      // Clean up URL after Supabase processes it
      setTimeout(() => {
        window.history.replaceState({}, document.title, window.location.pathname);
      }, 100);
    }
  }, []);

  // Initialize Supabase session on mount
  useEffect(() => {
    async function initSession() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) {
          const supabaseUser = {
            id: session.user.id,
            name: session.user.user_metadata?.full_name || session.user.user_metadata?.name || session.user.email?.split('@')[0] || 'User',
            email: session.user.email || ''
          };
          setUser({ ...supabaseUser, color: userColor });
          localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(supabaseUser));
        }
      } catch (err) {
        console.error('Error initializing session:', err);
      }
    }
    initSession();
  }, [userColor]);

  // Auth state listener
  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      console.log('Auth event:', event, session);
      
      if (event === 'SIGNED_IN' && session?.user) {
        const supabaseUser = {
          id: session.user.id,
          name: session.user.user_metadata?.full_name || session.user.user_metadata?.name || session.user.email?.split('@')[0] || 'User',
          email: session.user.email || ''
        };
        setUser({ ...supabaseUser, color: userColor });
        localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(supabaseUser));
        setIsHandlingCallback(false);
      } else if (event === 'SIGNED_OUT') {
        setUser(null);
        localStorage.removeItem(STORAGE_KEYS.USER);
        setIsHandlingCallback(false);
      } else if (event === 'TOKEN_REFRESHED' && session?.user) {
        // Update user if needed
        const supabaseUser = {
          id: session.user.id,
          name: session.user.user_metadata?.full_name || session.user.user_metadata?.name || session.user.email?.split('@')[0] || 'User',
          email: session.user.email || ''
        };
        setUser({ ...supabaseUser, color: userColor });
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, [userColor]);

  // Load projects and workspaces from database when user is authenticated
  useEffect(() => {
    async function loadDataFromDatabase() {
      if (!user) return;
      
      try {
        // Load all projects from database
        const dbProjects = await getAllProjects();
        if (dbProjects.length > 0) {
          console.log(`Loaded ${dbProjects.length} projects from database`);
          setProjects(dbProjects);
          
          // Automatically generate AI plans for user-owned projects that don't have data
          const userOwnedProjects = dbProjects.filter(p => (p.ownerId === user.id || p.ownerId === 'guest') && p.sheets.length > 0);
          for (const project of userOwnedProjects) {
            const firstSheet = project.sheets[0];
            if (firstSheet && firstSheet.rows.length === 0) {
              // Generate plan in background
              generateProjectPlan(project.name).then(plan => {
                setProjects(prev => prev.map(p => {
                  if (p.id !== project.id) return p;
                  const updatedSheets = p.sheets.map((s, idx) => {
                    if (idx === 0) {
                      return { ...s, rows: plan.tasks };
                    }
                    return s;
                  });
                  return { ...p, sheets: updatedSheets };
                }));
                // Log activity for the project
                setProjects(prev => prev.map(p => {
                  if (p.id !== project.id) return p;
                  const entry: ActivityEntry = { 
                    id: `act-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`, 
                    userId: user.id, 
                    userName: user.name, 
                    action: `AI generated project plan for "${project.name}"`, 
                    timestamp: Date.now() 
                  };
                  return { ...p, activityLog: [...(p.activityLog || []), entry] };
                }));
              }).catch(error => {
                console.error(`Error generating plan for ${project.name}:`, error);
              });
            }
          }
        }
        
        // Load workspaces from database
        const dbWorkspaces = await getWorkspaces();
        if (dbWorkspaces.length > 0) {
          console.log(`Loaded ${dbWorkspaces.length} workspaces from database`);
          setWorkspaces(dbWorkspaces);
          
          // Set active workspace to first one if current one doesn't exist
          const workspaceExists = dbWorkspaces.some(ws => ws.id === activeWorkspaceId);
          if (!workspaceExists && dbWorkspaces.length > 0) {
            setActiveWorkspaceId(dbWorkspaces[0].id);
          }
        }
      } catch (error) {
        console.error('Error loading data from database:', error);
        // Don't show error to user if database is not available, just use localStorage
      }
    }
    
    loadDataFromDatabase();
  }, [user, activeWorkspaceId]);

  const addNotification = useCallback((title: string, message: string, type: 'info' | 'success' | 'warning' = 'info') => {
    const newNotif: AppNotification = { id: `notif-${Date.now()}-${Math.random()}`, title, message, type, timestamp: Date.now() };
    setNotifications(prev => [newNotif, ...prev].slice(0, 5));
  }, []);

  // Autosave logic
  useEffect(() => {
    if (!user) return;
    setSaveStatus('saving');
    if (saveTimeoutRef.current) clearTimeout(saveTimeoutRef.current);
    saveTimeoutRef.current = window.setTimeout(() => {
      try {
        localStorage.setItem(STORAGE_KEYS.WORKSPACES, JSON.stringify(workspaces));
        localStorage.setItem(STORAGE_KEYS.PROJECTS, JSON.stringify(projects));
        localStorage.setItem(STORAGE_KEYS.ACTIVE_WS, activeWorkspaceId);
        localStorage.setItem(STORAGE_KEYS.ACTIVE_PROJ, activeProjectId);
        localStorage.setItem(STORAGE_KEYS.AI_METRICS, JSON.stringify(aiMetrics));
        localStorage.setItem(STORAGE_KEYS.AI_RE_JOBS, JSON.stringify(retrainingJobs));
        localStorage.setItem(STORAGE_KEYS.AI_RE_CONFIG, JSON.stringify(retrainingConfig));
        localStorage.setItem(STORAGE_KEYS.CURRENT_PAGE, currentPage);
        setSaveStatus('saved');
        channel.postMessage({ type: 'data-update', projects, workspaces } as SyncEvent);
        setTimeout(() => setSaveStatus('idle'), 3000);
      } catch (err) {
        setSaveStatus('error');
      }
    }, 1000);
    return () => { if (saveTimeoutRef.current) clearTimeout(saveTimeoutRef.current); };
  }, [workspaces, projects, activeWorkspaceId, activeProjectId, user, channel, aiMetrics, retrainingJobs, retrainingConfig, currentPage]);

  // Sync / Real-time logic
  useEffect(() => {
    if (!user) return;
    channel.postMessage({ type: 'presence', user } as SyncEvent);
    const handleMessage = (event: MessageEvent<SyncEvent>) => {
      const msg = event.data;
      switch (msg.type) {
        case 'presence':
          setCollaborators(prev => {
            const exists = prev.find(c => c.id === msg.user.id);
            if (exists) return prev.map(c => c.id === msg.user.id ? { ...msg.user, lastActive: Date.now() } : c);
            return [...prev, { ...msg.user, lastActive: Date.now() }];
          });
          channel.postMessage({ type: 'presence', user } as SyncEvent);
          break;
        case 'cursor-move':
          setRemoteCursors(prev => ({ ...prev, [msg.userId]: { rowId: msg.rowId, colId: msg.colId, userName: msg.userName, color: msg.color } }));
          break;
        case 'data-update':
          setProjects(msg.projects);
          setWorkspaces(msg.workspaces);
          break;
      }
    };
    channel.onmessage = handleMessage;
    const cleanup = setInterval(() => setCollaborators(prev => prev.filter(c => Date.now() - c.lastActive < 10000)), 5000);
    return () => { channel.onmessage = null; clearInterval(cleanup); };
  }, [user, channel]);

  const activeWorkspace = useMemo(() => workspaces.find(ws => ws.id === activeWorkspaceId) || workspaces[0], [workspaces, activeWorkspaceId]);
  // Filter projects to show only user-owned projects
  const userOwnedProjects = useMemo(() => {
    if (!user) return [];
    return projects.filter(p => p.ownerId === user.id || p.ownerId === 'guest');
  }, [projects, user]);
  const workspaceProjects = useMemo(() => userOwnedProjects, [userOwnedProjects]);
  const activeProject = useMemo(() => projects.find(p => p.id === activeProjectId) || workspaceProjects[0] || null, [projects, activeProjectId, workspaceProjects]);

  const currentUserRole = useMemo(() => {
    if (!user || !activeProject) return 'Viewer';
    if (activeProject.ownerId === user.id || activeProject.ownerId === 'guest') return 'Owner';
    const member = activeProject.members?.find(m => m.userId === user.id);
    if (member) {
      // Find base permissions for this role in the workspace
      const roleDef = activeWorkspace.roles.find(r => r.name === member.role);
      return roleDef?.baseRole || 'Viewer';
    }
    return 'Viewer';
  }, [user, activeProject, activeWorkspace.roles]);

  const checkPermission = useCallback((config: PermissionConfig | undefined, action: 'view' | 'edit') => {
    if (currentUserRole === 'Owner') return true;
    if (!config) return currentUserRole !== 'Viewer' || action === 'view';
    const list = action === 'view' ? config.viewers : config.editors;
    if (list.includes('*')) return true;
    return list.includes(user?.id || '');
  }, [currentUserRole, user?.id]);

  const visibleSheets = useMemo(() => {
    if (!activeProject) return [];
    return activeProject.sheets.filter(s => checkPermission(s.permissions, 'view'));
  }, [activeProject, checkPermission]);

  const activeSheet = useMemo(() => {
    const s = activeProject?.sheets.find(s => s.id === activeProject.activeSheetId) || visibleSheets[0] || INITIAL_SHEET;
    return s;
  }, [activeProject, visibleSheets]);

  const visibleColumns = useMemo(() => activeSheet.columns.filter(c => checkPermission(c.permissions, 'view')), [activeSheet, checkPermission]);

  const computedSheetRows = useMemo(() => {
    if (!activeSheet) return [];
    return computeSheetData({ rows: activeSheet.rows, columns: activeSheet.columns });
  }, [activeSheet]);

  const activeRow = useMemo(() => computedSheetRows.find(r => r.id === activeRowComments), [computedSheetRows, activeRowComments]);

  const logActivity = useCallback((action: string, rowId?: string, details?: string) => {
    if (!user || !activeProject) return;
    const entry: ActivityEntry = { id: `act-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`, userId: user.id, userName: user.name, action, timestamp: Date.now(), rowId, details };
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, activityLog: [...(p.activityLog || []), entry] } : p));
  }, [user, activeProject, activeProjectId]);

  const triggerAutomation = useCallback((rule: AutomationRule, row: RowData) => {
    const title = `Automation: ${rule.name}`;
    const message = `Task "${row.task}" is ${rule.trigger.type === 'status_change' ? 'now ' + row.status : 'due in ' + rule.trigger.daysBefore + ' days'}.`;
    if (rule.action.channel === 'in_app') addNotification(title, message, 'info');
    if (rule.action.channel === 'slack' && activeProject?.integrations?.slackWebhook) {
      logActivity(`Slack Notification Triggered`, row.id, `Sent to channel via webhook`);
      addNotification("Slack Sent", `Notification sent for "${row.task}"`, "success");
    }
  }, [activeProject?.integrations?.slackWebhook, addNotification, logActivity]);

  const handleUpdateCell = useCallback((rowId: string, columnId: string, value: any) => {
    if (!activeProject) return;
    const col = activeSheet.columns.find(c => c.id === columnId);
    if (!checkPermission(activeSheet.permissions, 'edit') || !checkPermission(col?.permissions, 'edit')) {
      addNotification("Permission Denied", "You don't have edit access to this field.", "warning");
      return;
    }
    const oldRow = activeSheet.rows.find(r => r.id === rowId);
    if (oldRow?.[columnId] === value) return;
    
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { 
      ...p, 
      sheets: p.sheets.map(s => s.id === p.activeSheetId ? { 
        ...s, 
        rows: s.rows.map(r => r.id === rowId ? { ...r, [columnId]: value } : r) 
      } : s) 
    } : p));
    
    if (columnId === 'status' && activeProject.automations) {
      activeProject.automations.filter(a => a.enabled && a.trigger.type === 'status_change' && a.trigger.value === value).forEach(rule => triggerAutomation(rule, { ...oldRow!, [columnId]: value }));
    }
    
    logActivity(`Updated ${col?.title || columnId}`, rowId, `Changed from "${oldRow?.[columnId] ?? ''}" to "${value}"`);
  }, [activeProject, activeProjectId, activeSheet, checkPermission, addNotification, logActivity, triggerAutomation]);

  const handleUpdatePermissions = useCallback((type: 'sheet' | 'column', id: string, config: PermissionConfig) => {
    if (!activeProject || currentUserRole !== 'Owner') return;
    setProjects(prev => prev.map(p => {
      if (p.id !== activeProjectId) return p;
      if (type === 'sheet') {
        return { ...p, sheets: p.sheets.map(s => s.id === id ? { ...s, permissions: config } : s) };
      } else {
        return { ...p, sheets: p.sheets.map(s => ({ ...s, columns: s.columns.map(c => c.id === id ? { ...c, permissions: config } : c) })) };
      }
    }));
    logActivity(`Updated permissions for ${type} ${id}`);
    setPermissionsModal(null);
  }, [activeProject, activeProjectId, currentUserRole, logActivity]);

  const handleUpdateIntegrations = useCallback((updates: Partial<IntegrationSettings>) => {
    if (!activeProject) return;
    setProjects(prev => prev.map(p => 
      p.id === activeProjectId ? { ...p, integrations: { ...p.integrations!, ...updates } } : p
    ));
    logActivity(`Updated integration settings`);
  }, [activeProject, activeProjectId, logActivity]);

  const handleAddRow = useCallback((initialData: Partial<RowData> = {}) => {
    if (!activeProject || !checkPermission(activeSheet.permissions, 'edit')) return;
    const newRowId = `row-${Date.now()}`;
    const newRow: RowData = { id: newRowId, task: '', owner: user?.name || '', status: 'To Do', priority: 'Medium', startDate: new Date().toISOString().split('T')[0], dueDate: new Date().toISOString().split('T')[0], progress: 0, comments: [], attachments: [], dependencies: [], ...initialData };
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => s.id === p.activeSheetId ? { ...s, rows: [...s.rows, newRow] } : s) } : p));
    logActivity('Added new record', newRowId);
    return newRowId;
  }, [activeProject, activeProjectId, activeSheet.permissions, checkPermission, user?.name, logActivity]);

  const handleDeleteRow = useCallback((rowId: string) => {
    if (!activeProject || !checkPermission(activeSheet.permissions, 'edit')) return;
    const taskName = activeSheet.rows.find(r => r.id === rowId)?.task || 'Task';
    if (!confirm(`Are you sure you want to delete task "${taskName}"?`)) return;
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => s.id === p.activeSheetId ? { ...s, rows: s.rows.filter(r => r.id !== rowId) } : s) } : p));
    logActivity(`Deleted task "${taskName}"`);
    addNotification("Task Deleted", `Removed task: ${taskName}`, "info");
  }, [activeProject, activeProjectId, activeSheet, checkPermission, logActivity, addNotification]);

  const handleImportCSV = useCallback((file: File) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const text = e.target?.result as string;
      const lines = text.split(/\r?\n/).filter(line => line.trim() !== '');
      if (lines.length < 2) {
        addNotification("Import Failed", "CSV file must contain a header row and at least one data row.", "warning");
        return;
      }
      
      const headers = lines[0].split(',').map(h => h.trim().toLowerCase());
      const dataRows = lines.slice(1);
      
      const newRows: RowData[] = dataRows.map((line, idx) => {
        const values = line.split(',').map(v => v.trim());
        const row: RowData = { 
          id: `row-csv-${Date.now()}-${idx}-${Math.random().toString(36).substr(2, 5)}`,
          status: 'To Do',
          priority: 'Medium',
          progress: 0,
          startDate: new Date().toISOString().split('T')[0],
          dueDate: new Date().toISOString().split('T')[0],
          comments: [],
          attachments: [],
          dependencies: []
        };
        
        headers.forEach((header, colIdx) => {
          const val = values[colIdx];
          if (!val) return;
          
          if (header.includes('task') || header.includes('name') || header.includes('title')) row.task = val;
          else if (header.includes('owner') || header.includes('assignee')) row.owner = val;
          else if (header.includes('status')) row.status = val;
          else if (header.includes('priority')) row.priority = val;
          else if (header.includes('start')) row.startDate = val;
          else if (header.includes('to') || header.includes('due') || header.includes('end')) row.dueDate = val;
          else if (header.includes('progress') || header.includes('complete')) row.progress = parseInt(val) || 0;
        });
        return row;
      }).filter(r => r.task);

      if (newRows.length === 0) {
        addNotification("Import Canceled", "No valid tasks found in CSV. Check column headers.", "warning");
        return;
      }

      setProjects(prev => prev.map(p => p.id === activeProjectId ? { 
        ...p, 
        sheets: p.sheets.map(s => s.id === p.activeSheetId ? { ...s, rows: [...s.rows, ...newRows] } : s) 
      } : p));
      
      addNotification("Import Successful", `Added ${newRows.length} records from CSV.`, "success");
      logActivity(`Bulk imported ${newRows.length} records via CSV`);
    };
    reader.readAsText(file);
  }, [activeProjectId, addNotification, logActivity]);

  const handleAddColumn = useCallback(() => {
    if (!activeProject || currentUserRole === 'Viewer') return;
    const title = prompt('Column Title:');
    if (!title) return;
    const newCol: Column = { id: `col-${Date.now()}`, title, type: 'text', width: 150 };
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => s.id === p.activeSheetId ? { ...s, columns: [...s.columns, newCol] } : s) } : p));
    logActivity(`Added column "${title}"`);
  }, [activeProject, activeProjectId, currentUserRole, logActivity]);

  const handleUpdateColumn = useCallback((id: string, updates: Partial<Column>) => {
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => s.id === p.activeSheetId ? { ...s, columns: s.columns.map(c => c.id === id ? { ...c, ...updates } : c) } : s) } : p));
  }, [activeProjectId]);

  const handleDeleteColumn = useCallback((id: string) => {
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => s.id === p.activeSheetId ? { ...s, columns: s.columns.filter(c => c.id !== id) } : s) } : p));
  }, [activeProjectId]);

  const handleAICommand = useCallback((result: AICommandResult) => {
    if (result.confidence < 0.6) {
       addNotification("Low Confidence Command", "This command was flagged for Human Review due to low confidence.", "warning");
       return;
    }
    if (result.action === 'UPDATE_CELL') {
      handleUpdateCell(result.payload.rowId, result.payload.columnId, result.payload.value);
      addNotification("AI Command", `Updated task ${result.payload.rowId}`, "success");
    } else if (result.action === 'FILTER') {
      const type = result.payload.filterType === 'owner' ? 'owners' : 'statuses';
      setActiveFilters(prev => ({ ...prev, [type]: [result.payload.value] }));
      addNotification("AI Command", `Filtering by ${result.payload.value}`, "info");
    } else if (result.action === 'ADD_ROW') {
      const newId = handleAddRow({ task: result.payload.task });
      addNotification("AI Command", `Added task: ${result.payload.task}`, "success");
    } else {
      addNotification("AI Assistant", "I couldn't quite understand that command.", "warning");
    }
  }, [handleUpdateCell, handleAddRow, addNotification]);

  const handleStartRetraining = useCallback(() => {
    const jobId = `job-${Date.now()}`;
    const newJob: RetrainingJob = { id: jobId, startTime: Date.now(), status: 'running', trigger: 'performance', baseVersion: 'v1.4.1' };
    setRetrainingJobs(prev => [...prev, newJob]);
    setTimeout(() => {
       setRetrainingJobs(prev => prev.map(j => j.id === jobId ? { ...j, status: 'validating' } : j));
       setTimeout(() => {
          setRetrainingJobs(prev => prev.map(j => j.id === jobId ? { ...j, status: 'success', endTime: Date.now(), newVersion: 'v1.4.2-stable', accuracyGain: 1.4 } : j));
          addNotification("Retraining Complete", "Model v1.4.2 successfully promoted to production.", "success");
       }, 3000);
    }, 4000);
  }, [addNotification]);

  const handleInvite = useCallback((email: string, role: Role) => {
    if (!activeProject) return;
    const newMember: Member = { userId: `user-${Date.now()}`, email, name: email.split('@')[0], role };
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, members: [...(p.members || []), newMember] } : p));
    logActivity(`Invited ${email} as ${role}`);
  }, [activeProject, activeProjectId, logActivity]);

  const handleUpdateMemberRole = useCallback((userId: string, role: Role) => {
    if (!activeProject) return;
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, members: p.members.map(m => m.userId === userId ? { ...m, role } : m) } : p));
    logActivity(`Changed role of ${userId} to ${role}`);
  }, [activeProject, activeProjectId, logActivity]);

  const handleRemoveMember = useCallback((userId: string) => {
    if (!activeProject) return;
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, members: p.members.filter(m => m.userId !== userId) } : p));
    logActivity(`Removed ${userId} from project`);
  }, [activeProject, activeProjectId, logActivity]);

  // Workspace-level CRUD handlers for Users and Roles
  const handleCreateRole = useCallback((role: Omit<RoleDefinition, 'id'>) => {
    const newRole: RoleDefinition = { ...role, id: `role-${Date.now()}` };
    setWorkspaces(prev => prev.map(ws => ws.id === activeWorkspaceId ? { ...ws, roles: [...ws.roles, newRole] } : ws));
    addNotification("Role Created", `Successfully defined role: ${role.name}`, "success");
  }, [activeWorkspaceId, addNotification]);

  const handleUpdateRole = useCallback((roleId: string, updates: Partial<RoleDefinition>) => {
    setWorkspaces(prev => prev.map(ws => ws.id === activeWorkspaceId ? { ...ws, roles: ws.roles.map(r => r.id === roleId ? { ...r, ...updates } : r) } : ws));
  }, [activeWorkspaceId]);

  const handleDeleteRole = useCallback((roleId: string) => {
    const role = activeWorkspace.roles.find(r => r.id === roleId);
    if (!role || role.isSystem) return;
    if (!confirm(`Are you sure you want to delete the "${role.name}" role?`)) return;
    setWorkspaces(prev => prev.map(ws => ws.id === activeWorkspaceId ? { ...ws, roles: ws.roles.filter(r => r.id !== roleId) } : ws));
    addNotification("Role Deleted", `Successfully removed ${role.name}`, "info");
  }, [activeWorkspace, activeWorkspaceId, addNotification]);

  const handleAddWorkspaceMember = useCallback((email: string, role: string) => {
    const newMember: Member = { userId: `u-${Date.now()}`, email, name: email.split('@')[0], role };
    setWorkspaces(prev => prev.map(ws => ws.id === activeWorkspaceId ? { ...ws, members: [...ws.members, newMember] } : ws));
    addNotification("Member Added", `Successfully invited ${email} to the workspace.`, "success");
  }, [activeWorkspaceId, addNotification]);

  const handleUpdateWorkspaceMember = useCallback((userId: string, updates: Partial<Member>) => {
    setWorkspaces(prev => prev.map(ws => ws.id === activeWorkspaceId ? { ...ws, members: ws.members.map(m => m.userId === userId ? { ...m, ...updates } : m) } : ws));
  }, [activeWorkspaceId]);

  const handleDeleteWorkspaceMember = useCallback((userId: string) => {
    const member = activeWorkspace.members.find(m => m.userId === userId);
    if (!member) return;
    if (!confirm(`Are you sure you want to remove ${member.name} from the workspace?`)) return;
    setWorkspaces(prev => prev.map(ws => ws.id === activeWorkspaceId ? { ...ws, members: ws.members.filter(m => m.userId !== userId) } : ws));
    addNotification("Member Removed", `Successfully removed ${member.name} from the workspace.`, "info");
  }, [activeWorkspace, activeWorkspaceId, addNotification]);

  const handleAuthSuccess = (authUser: User) => { 
    setUser({ ...authUser, color: userColor }); 
    localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(authUser)); 
    setIsHandlingCallback(false);
  };
  const handleLogout = async () => { 
    await supabase.auth.signOut();
    setUser(null); 
    localStorage.removeItem(STORAGE_KEYS.USER); 
    setIsProfileOpen(false); 
  };
  const handleAuthError = () => {
    setIsHandlingCallback(false);
  };
  const handleUpdateProfile = (updatedUser: User) => { setUser({ ...updatedUser, color: userColor }); localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(updatedUser)); };

  const handleSelectWorkspace = (id: string) => { setActiveWorkspaceId(id); const wsProj = projects.find(p => p.workspaceId === id); if (wsProj) setActiveProjectId(wsProj.id); };
  const handleSelectProject = (id: string) => { setActiveProjectId(id); setCurrentPage('project'); };
  const handleSelectSheet = (id: string) => { if (!activeProject) return; setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, activeSheetId: id } : p)); };
  
  const handleCreateWorkspace = () => { 
    const name = prompt('Workspace Name:'); 
    if (!name || !user) return; 
    const newWs: Workspace = { 
      id: `ws-${Date.now()}`, 
      name, 
      ownerId: user.id, 
      members: [{ userId: user.id, email: user.email, name: user.name, role: 'Owner' }],
      roles: DEFAULT_ROLES
    }; 
    setWorkspaces(prev => [...prev, newWs]); handleSelectWorkspace(newWs.id); 
  };

  const handleCreateProject = async (name: string, template?: Template) => {
    if (!user) return;
    let initialSheets: Sheet[] = [{ ...INITIAL_SHEET, id: `sheet-${Date.now()}`, name: 'New Sheet', rows: [] }];
    let automations: AutomationRule[] = [];
    if (template) { initialSheets = template.sheets.map(s => ({ ...s, id: `sheet-${Date.now()}-${Math.random()}` })); automations = template.automations || []; }
    const newProj: Project = { id: `proj-${Date.now()}`, name, workspaceId: activeWorkspaceId, sheets: initialSheets, activeSheetId: initialSheets[0].id, ownerId: user.id, members: [{ userId: user.id, email: user.email, name: user.name, role: 'Owner' }], activityLog: [{ id: 'init', userId: user.id, userName: user.name, action: `Created project ${template ? 'from template ' + template.name : ''}`, timestamp: Date.now() }], savedViews: [], automations, integrations: { googleDriveConnected: false, apiKeys: [] } };
    setProjects(prev => [...prev, newProj]); setActiveProjectId(newProj.id); setCurrentPage('project'); setIsTemplateGalleryOpen(false);
    
    // Automatically generate AI project plan if not using a template
    if (!template) {
      try {
        addNotification("AI Plan Generation", `Generating plan for "${name}"...`, "info");
        const plan = await generateProjectPlan(name);
        
        // Update the project with the generated plan
        setProjects(prev => prev.map(p => {
          if (p.id !== newProj.id) return p;
          const updatedSheets = p.sheets.map((s, idx) => {
            if (idx === 0) {
              // Add generated tasks to the first sheet
              return { ...s, rows: plan.tasks };
            }
            return s;
          });
          return { ...p, sheets: updatedSheets };
        }));
        
        logActivity(`AI generated project plan for "${name}"`);
        addNotification("Plan Generated", `AI plan created for "${name}"`, "success");
      } catch (error) {
        console.error(`Error generating plan for ${name}:`, error);
        addNotification("Generation Error", `Failed to generate plan for "${name}"`, "warning");
      }
    }
  };

  const handleRenameProject = useCallback((id: string, name: string) => {
    setProjects(prev => prev.map(p => p.id === id ? { ...p, name } : p));
    logActivity(`Renamed project to "${name}"`);
  }, [logActivity]);

  const handleDeleteProject = useCallback((id: string) => {
    if (currentUserRole !== 'Owner') return;
    const projName = projects.find(p => p.id === id)?.name || 'Project';
    if (!confirm(`Are you sure you want to delete project "${projName}"? All data will be permanently lost.`)) return;
    setProjects(prev => prev.filter(p => p.id !== id));
    if (activeProjectId === id) setActiveProjectId('');
    logActivity(`Deleted project "${projName}"`);
    addNotification("Project Deleted", `Successfully removed ${projName}`, "info");
  }, [projects, activeProjectId, currentUserRole, logActivity, addNotification]);

  const handleRenameSheet = useCallback((projectId: string, sheetId: string, name: string) => {
    setProjects(prev => prev.map(p => p.id === projectId ? { ...p, sheets: p.sheets.map(s => s.id === sheetId ? { ...s, name } : s) } : p));
    logActivity(`Renamed sheet to "${name}"`);
  }, [logActivity]);

  const handleDeleteSheet = useCallback((projectId: string, sheetId: string) => {
    if (currentUserRole === 'Viewer') return;
    const proj = projects.find(p => p.id === projectId);
    const sheetName = proj?.sheets.find(s => s.id === sheetId)?.name || 'Sheet';
    if (!confirm(`Delete sheet "${sheetName}"?`)) return;
    
    setProjects(prev => prev.map(p => {
      if (p.id !== projectId) return p;
      const newSheets = p.sheets.filter(s => s.id !== sheetId);
      const newActiveSheetId = p.activeSheetId === sheetId ? (newSheets[0]?.id || '') : p.activeSheetId;
      return { ...p, sheets: newSheets, activeSheetId: newActiveSheetId };
    }));
    logActivity(`Deleted sheet "${sheetName}"`);
    addNotification("Sheet Deleted", `Successfully removed ${sheetName}`, "info");
  }, [projects, currentUserRole, logActivity, addNotification]);

  const handleAddSheet = () => {
    if (!activeProject || currentUserRole === 'Viewer') return;
    const name = prompt('Sheet Name:'); if (!name) return;
    const newSheet: Sheet = { id: `sheet-${Date.now()}`, name, columns: DEFAULT_COLUMNS, rows: [] };
    setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: [...p.sheets, newSheet], activeSheetId: newSheet.id } : p));
    logActivity(`Created sheet "${name}"`);
    setCurrentPage('project');
  };

  const handleGeneratePlansForAllProjects = useCallback(async () => {
    if (!user) return;
    
    const ownedProjects = projects.filter(p => p.ownerId === user.id || p.ownerId === 'guest');
    if (ownedProjects.length === 0) {
      addNotification("No Projects", "You don't own any projects to generate plans for.", "info");
      return;
    }

    addNotification("AI Plan Generation", `Generating plans for ${ownedProjects.length} project(s)...`, "info");
    
    for (const project of ownedProjects) {
      try {
        // Check if project already has rows in the first sheet
        const firstSheet = project.sheets[0];
        if (firstSheet && firstSheet.rows.length > 0) {
          // Skip projects that already have data
          continue;
        }

        // Generate plan using project name as objective
        const plan = await generateProjectPlan(project.name);
        
        // Update the project with the generated plan
        setProjects(prev => prev.map(p => {
          if (p.id !== project.id) return p;
          const updatedSheets = p.sheets.map((s, idx) => {
            if (idx === 0) {
              // Add generated tasks to the first sheet
              return { ...s, rows: plan.tasks };
            }
            return s;
          });
          return { ...p, sheets: updatedSheets };
        }));
        
        logActivity(`AI generated project plan for "${project.name}"`);
      } catch (error) {
        console.error(`Error generating plan for ${project.name}:`, error);
        addNotification("Generation Error", `Failed to generate plan for "${project.name}"`, "warning");
      }
    }
    
    addNotification("Plan Generation Complete", `Successfully generated plans for your projects.`, "success");
  }, [user, projects, addNotification, logActivity]);

  const handleApplySavedView = useCallback((view: SavedView) => { setActiveFilters(view.filters); logActivity(`Applied view: ${view.name}`); }, [logActivity]);
  const removeNotification = useCallback((id: string) => setNotifications(prev => prev.filter(n => n.id !== id)), []);

  const filteredRows = useMemo(() => {
    let baseRows = computedSheetRows;
    if (activeFilters.owners.length > 0) baseRows = baseRows.filter(r => activeFilters.owners.includes(String(r.owner)));
    if (activeFilters.statuses.length > 0) baseRows = baseRows.filter(r => activeFilters.statuses.includes(String(r.status)));
    if (activeFilters.dateRange !== 'all') {
      const now = new Date(); now.setHours(0,0,0,0);
      baseRows = baseRows.filter(r => {
        if (!r.dueDate) return false;
        const due = new Date(String(r.dueDate)); due.setHours(0,0,0,0);
        switch(activeFilters.dateRange) {
          case 'today': return due.getTime() === now.getTime();
          case 'this-week': const weekEnd = new Date(now); weekEnd.setDate(now.getDate() + 7); return due >= now && due <= weekEnd;
          case 'overdue': return due < now && r.status !== 'Done';
          default: return true;
        }
      });
    }
    return baseRows;
  }, [computedSheetRows, activeFilters]);

  const sortedRows = useMemo(() => {
    if (!sortConfig.columnId || !sortConfig.direction) return filteredRows;
    return [...filteredRows].sort((a, b) => {
      const aVal = a[sortConfig.columnId]; const bVal = b[sortConfig.columnId];
      if (aVal === bVal) return 0;
      if (aVal === null || aVal === undefined) return 1;
      if (bVal === null || bVal === undefined) return -1;
      return sortConfig.direction === 'asc' ? (aVal < bVal ? -1 : 1) : (aVal < bVal ? 1 : -1);
    });
  }, [filteredRows, sortConfig]);

  if (isHandlingCallback) {
    return <AuthCallback onAuthSuccess={handleAuthSuccess} onAuthError={handleAuthError} />;
  }

  if (!user) return <AuthPage onAuthSuccess={handleAuthSuccess} />;

  const uniqueOwners = Array.from(new Set(computedSheetRows.map(r => String(r.owner || '')))).filter(Boolean);
  const uniqueStatuses = activeSheet.columns.find(c => c.id === 'status')?.options || ['To Do', 'In Progress', 'Done', 'Blocked'];

  const renderCurrentPage = () => {
    if (!activeProject && currentPage !== 'workspace-settings') return (
      <div className="flex-1 flex items-center justify-center bg-[#f7f8f9]">
        <div className="text-center">
          <h2 className="text-lg font-bold text-[#1a1f36]">No project selected</h2>
          <button onClick={() => setIsTemplateGalleryOpen(true)} className="mt-4 px-4 py-2 bg-[#6366f1] text-white rounded-md text-sm font-bold shadow-sm">Create Project</button>
        </div>
      </div>
    );

    switch (currentPage) {
      case 'activity':
        return <ActivityLogPage logs={activeProject?.activityLog || []} entityName={activeProject?.name || ''} filterRowId={rowActivityFilter} />;
      case 'automations':
        return <AutomationsPage rules={activeProject?.automations || []} onCreate={rule => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, automations: [...(p.automations || []), rule] } : p))} onUpdate={(id, up) => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, automations: p.automations?.map(a => a.id === id ? { ...a, ...up } : a) } : p))} onDelete={id => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, automations: p.automations?.filter(a => a.id !== id) } : p))} statuses={uniqueStatuses} />;
      case 'integrations':
        return <IntegrationsPage settings={activeProject?.integrations!} onUpdate={handleUpdateIntegrations} />;
      case 'ai-reliability':
        return <AIReliabilityPage metrics={aiMetrics} />;
      case 'ai-retraining':
        return <AIRetrainingPage jobs={retrainingJobs} config={retrainingConfig} onUpdateConfig={setRetrainingConfig} onStartManualJob={handleStartRetraining} />;
      case 'ai-advanced':
        return <AIAdvancedPage metrics={aiMetrics} />;
      case 'team':
        return <TeamMembersPage members={activeProject?.members || []} onInvite={handleInvite} onUpdateRole={handleUpdateMemberRole} onRemove={handleRemoveMember} currentUserId={user.id} projectName={activeProject?.name || ''} userRole={currentUserRole} />;
      case 'workspace-settings':
        return <WorkspaceSettings 
          workspace={activeWorkspace} 
          currentUser={user} 
          onAddMember={handleAddWorkspaceMember} 
          onUpdateMember={handleUpdateWorkspaceMember} 
          onDeleteMember={handleDeleteWorkspaceMember} 
          onCreateRole={handleCreateRole} 
          onUpdateRole={handleUpdateRole} 
          onDeleteRole={handleDeleteRole} 
        />;
      case 'project':
      default:
        if (!activeProject) return null;
        return (
          <div className="flex flex-col h-full overflow-hidden">
            <Toolbar 
              activeView={viewMode} onViewChange={setViewMode} onAISuggestion={() => setIsAIShowing(true)} onShare={() => setIsShareOpen(true)}
              sheetName={activeSheet.name} activeProjectName={activeProject.name} saveStatus={saveStatus} collaborators={collaborators} currentUser={user} userRole={currentUserRole}
              activeFilters={activeFilters} onUpdateFilters={setActiveFilters} owners={uniqueOwners} statuses={uniqueStatuses} savedViews={activeProject.savedViews || []}
              onSaveView={(name) => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, savedViews: [...(p.savedViews || []), { id: `view-${Date.now()}`, name, filters: { ...activeFilters } }] } : p))}
              onApplySavedView={handleApplySavedView} onDeleteView={(id) => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, savedViews: (p.savedViews || []).filter(v => v.id !== id) } : p))}
              onRenameProject={(name) => handleRenameProject(activeProject.id, name)}
              onRenameSheet={(name) => handleRenameSheet(activeProject.id, activeSheet.id, name)}
              onImportCSV={handleImportCSV}
            />
            <div className="flex-1 overflow-hidden relative">
              {viewMode === 'grid' && (
                <SheetGrid 
                  columns={visibleColumns} rows={sortedRows} sortConfig={sortConfig} remoteCursors={remoteCursors} onUpdateCell={handleUpdateCell}
                  onAddRow={handleAddRow} onDeleteRow={handleDeleteRow} onUpdateColumn={handleUpdateColumn} onAddColumn={handleAddColumn} onDeleteColumn={handleDeleteColumn}
                  onSort={id => setSortConfig(prev => prev.columnId === id ? { columnId: id, direction: prev.direction === 'asc' ? 'desc' : null } : { columnId: id, direction: 'asc' })}
                  onReorderRow={(id, dir) => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => { if (s.id !== p.activeSheetId) return s; const idx = s.rows.findIndex(r => r.id === id); const newRows = [...s.rows]; const targetIdx = dir === 'up' ? idx - 1 : idx + 1; if (targetIdx >= 0 && targetIdx < newRows.length) [newRows[idx], newRows[targetIdx]] = [newRows[targetIdx], newRows[idx]]; return { ...s, rows: newRows }; }) } : p))}
                  onCellFocus={(rowId, colId) => channel.postMessage({ type: 'cursor-move', userId: user?.id, rowId, colId, userName: user?.name, color: user?.color } as SyncEvent)}
                  onOpenComments={setActiveRowComments} onOpenRowActivity={id => { setRowActivityFilter(id); setCurrentPage('activity'); }}
                  userRole={currentUserRole} rawRows={activeSheet.rows}
                  onOpenColumnPermissions={(id, name) => setPermissionsModal({ type: 'column', id, name })}
                  isSheetEditable={checkPermission(activeSheet.permissions, 'edit')}
                />
              )}
              {viewMode === 'kanban' && <KanbanBoard rows={sortedRows} columns={visibleColumns} onUpdateCell={handleUpdateCell} onAddRow={handleAddRow} onDeleteRow={handleDeleteRow} userRole={currentUserRole} onOpenComments={setActiveRowComments} onOpenRowActivity={id => { setRowActivityFilter(id); setCurrentPage('activity'); }} />}
              {viewMode === 'gantt' && <GanttChart rows={sortedRows} userRole={currentUserRole} onUpdateCell={handleUpdateCell} onAddRow={handleAddRow} onDeleteRow={handleDeleteRow} />}
              {viewMode === 'calendar' && <CalendarView rows={sortedRows} onUpdateCell={handleUpdateCell} userRole={currentUserRole} onOpenComments={setActiveRowComments} onAddRow={handleAddRow} onDeleteRow={handleDeleteRow} />}
            </div>
          </div>
        );
    }
  };

  return (
    <div className="flex h-screen w-full overflow-hidden bg-white animate-in fade-in duration-500">
      <Sidebar 
        workspaces={workspaces} activeWorkspace={activeWorkspace} projects={workspaceProjects} activeProject={activeProject} user={user} userRole={currentUserRole}
        currentPage={currentPage} onSelectWorkspace={handleSelectWorkspace} onSelectProject={handleSelectProject} onSelectSheet={handleSelectSheet} onOpenProfile={() => setIsProfileOpen(true)}
        onCreateWorkspace={handleCreateWorkspace} onCreateProject={() => setIsTemplateGalleryOpen(true)} onAddSheet={handleAddSheet}
        onNavigate={(p) => { setRowActivityFilter(null); setCurrentPage(p); }}
        onOpenSheetPermissions={(id, name) => setPermissionsModal({ type: 'sheet', id, name })}
        onRenameProject={handleRenameProject}
        onDeleteProject={handleDeleteProject}
        onRenameSheet={handleRenameSheet}
        onDeleteSheet={handleDeleteSheet}
        onGeneratePlansForAllProjects={handleGeneratePlansForAllProjects}
      />
      <main className="flex-1 flex flex-col min-w-0 h-full overflow-hidden relative">
        {renderCurrentPage()}
      </main>

      {isAIShowing && activeProject && (
        <AIAssistant 
          onClose={() => setIsAIShowing(false)} 
          onApplyPlan={tasks => {
             setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => s.id === p.activeSheetId ? { ...s, rows: tasks } : s) } : p));
          }} 
          activeRows={activeSheet.rows} members={activeProject.members} onCommand={handleAICommand}
        />
      )}
      {isProfileOpen && <UserProfileModal user={user} onClose={() => setIsProfileOpen(false)} onUpdate={handleUpdateProfile} onLogout={handleLogout} />}
      {isShareOpen && activeProject && <ShareModal onClose={() => setIsShareOpen(false)} members={activeProject.members || []} onInvite={handleInvite} onUpdateRole={handleUpdateMemberRole} onRemove={handleRemoveMember} currentUserId={user.id} entityName={activeProject.name} />}
      {activeRowComments && activeRow && activeProject && (
        <CommentsPanel 
          rowId={activeRow.id} rowName={String(activeRow.task || 'Row')} comments={activeRow.comments || []} attachments={activeRow.attachments || []} members={activeProject.members || []} currentUser={user} onClose={() => setActiveRowComments(null)} 
          onAddComment={(id, text) => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => ({ ...s, rows: s.rows.map(r => r.id === id ? { ...r, comments: [...(r.comments || []), { id: `c-${Date.now()}`, userId: user.id, userName: user.name, text, timestamp: Date.now() }] } : r) })) } : p))} 
          onAddAttachment={(id, a) => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => ({ ...s, rows: s.rows.map(r => r.id === id ? { ...r, attachments: [...(r.attachments || []), a] } : r) })) } : p))} 
          onDeleteAttachment={(id, aid) => setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => ({ ...s, rows: s.rows.map(r => r.id === id ? { ...r, attachments: (r.attachments || []).filter(at => at.id !== aid) } : r) })) } : p))} 
          onGoogleDrive={() => setGooglePickerState({ rowId: activeRow.id })}
          isGoogleConnected={activeProject.integrations?.googleDriveConnected || false}
        />
      )}
      {googlePickerState && (
        <GooglePickerMock 
          onClose={() => setGooglePickerState(null)}
          onSelect={(file) => {
            const rowId = googlePickerState.rowId;
            setProjects(prev => prev.map(p => p.id === activeProjectId ? { ...p, sheets: p.sheets.map(s => ({ ...s, rows: s.rows.map(r => r.id === rowId ? { ...r, attachments: [...(r.attachments || []), { ...file, timestamp: Date.now(), provider: 'google_drive' }] } : r) })) } : p));
            logActivity("Attached from Google Drive", rowId, file.name);
            setGooglePickerState(null);
          }}
        />
      )}
      {isTemplateGalleryOpen && <TemplateGalleryModal onClose={() => setIsTemplateGalleryOpen(false)} onCreate={handleCreateProject} />}
      {permissionsModal && activeProject && (
        <PermissionsModal
          onClose={() => setPermissionsModal(null)}
          onUpdate={handleUpdatePermissions}
          members={activeProject.members}
          entityId={permissionsModal.id}
          entityType={permissionsModal.type}
          entityName={permissionsModal.name}
          initialConfig={
            permissionsModal.type === 'sheet' 
            ? activeProject.sheets.find(s => s.id === permissionsModal.id)?.permissions 
            : activeSheet.columns.find(c => c.id === permissionsModal.id)?.permissions
          }
        />
      )}
      <NotificationStack notifications={notifications} onRemove={removeNotification} />
    </div>
  );
};

export default App;
