
export type ColumnType = 'text' | 'number' | 'date' | 'dropdown' | 'checkbox' | 'status';

export type Role = string; // Now a dynamic string (e.g. 'Owner', 'Editor', 'Admin', 'Guest')

export interface RoleDefinition {
  id: string;
  name: string;
  description: string;
  color: string;
  baseRole: 'Owner' | 'Editor' | 'Viewer'; // Permissions inheritance
  isSystem?: boolean; // Protect system roles like Owner
}

export interface PermissionConfig {
  viewers: string[]; // User IDs or '*' for everyone in project
  editors: string[]; // User IDs
}

export interface Member {
  userId: string;
  email: string;
  name: string;
  role: Role;
}

export interface Comment {
  id: string;
  userId: string;
  userName: string;
  text: string;
  timestamp: number;
}

export interface FileAttachment {
  id: string;
  name: string;
  type: string;
  size: number;
  url: string;
  timestamp: number;
  provider?: 'local' | 'google_drive';
}

export interface ActivityEntry {
  id: string;
  userId: string;
  userName: string;
  action: string;
  timestamp: number;
  rowId?: string;
  details?: string;
}

export interface IntegrationSettings {
  slackWebhook?: string;
  teamsWebhook?: string;
  googleDriveConnected: boolean;
  apiKeys: { id: string; name: string; key: string; createdAt: number }[];
}

export interface Column {
  id: string;
  title: string;
  type: ColumnType;
  width: number;
  options?: string[]; // For dropdowns
  permissions?: PermissionConfig;
}

export interface RowData {
  id: string;
  comments?: Comment[];
  attachments?: FileAttachment[];
  dependencies?: string[]; // IDs of rows this task depends on
  [key: string]: string | number | boolean | Comment[] | FileAttachment[] | string[] | undefined;
}

export interface FilterConfig {
  owners: string[];
  statuses: string[];
  dateRange: 'all' | 'today' | 'this-week' | 'overdue';
}

export interface SavedView {
  id: string;
  name: string;
  filters: FilterConfig;
}

export type TriggerType = 'status_change' | 'date_approaching';
export type ActionType = 'notify';
export type NotificationChannel = 'in_app' | 'email' | 'slack' | 'teams';

export interface AutomationRule {
  id: string;
  name: string;
  enabled: boolean;
  trigger: {
    type: TriggerType;
    value?: string; // e.g. "Blocked" for status_change
    daysBefore?: number; // for date_approaching
  };
  action: {
    type: ActionType;
    channel: NotificationChannel;
    recipient: 'owner' | 'all';
  };
}

export interface AppNotification {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning';
  timestamp: number;
}

export interface Sheet {
  id: string;
  name: string;
  columns: Column[];
  rows: RowData[];
  permissions?: PermissionConfig;
}

export interface Template {
  id: string;
  name: string;
  description: string;
  category: string;
  sheets: Sheet[];
  automations?: AutomationRule[];
}

export interface AIInsight {
  type: 'risk' | 'suggestion';
  rowId: string;
  message: string;
  confidence: number;
  reasoning?: string;
  version?: string;
  consensus?: number; // 0-1 agreement level
}

export interface Project {
  id: string;
  name: string;
  workspaceId: string;
  sheets: Sheet[];
  activeSheetId: string;
  ownerId: string;
  members: Member[];
  activityLog?: ActivityEntry[];
  savedViews?: SavedView[];
  automations?: AutomationRule[];
  integrations?: IntegrationSettings;
}

export interface Workspace {
  id: string;
  name: string;
  ownerId: string;
  members: Member[];
  roles: RoleDefinition[];
}

export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  color?: string; // Assigned color for cursor
}

export interface RemoteCursor {
  rowId: string;
  colId: string;
  userName: string;
  color: string;
}

export interface Collaborator extends User {
  lastActive: number;
}

export type ViewMode = 'grid' | 'gantt' | 'kanban' | 'calendar';

export type AppPage = 'project' | 'activity' | 'automations' | 'integrations' | 'ai-reliability' | 'ai-retraining' | 'ai-advanced' | 'team' | 'workspace-settings';

export interface SortConfig {
  columnId: string;
  direction: 'asc' | 'desc' | null;
}

export interface AIPlanRequest {
  objective: string;
}

export interface AICommandResult {
  action: 'UPDATE_CELL' | 'FILTER' | 'ADD_ROW' | 'UNKNOWN';
  payload: any;
  confidence: number;
  consensus?: number;
}

// Reliability & Retraining Types
export interface AIMetric {
  id: string;
  timestamp: number;
  latency: number;
  model: string;
  success: boolean;
  confidence: number;
  taskType: 'planner' | 'insight' | 'command';
  consensusScore?: number;
}

export type RetrainingTriggerType = 'drift' | 'performance' | 'schedule';
export type RetrainingStatus = 'idle' | 'running' | 'validating' | 'success' | 'failed';

export interface RetrainingJob {
  id: string;
  startTime: number;
  endTime?: number;
  status: RetrainingStatus;
  trigger: RetrainingTriggerType;
  baseVersion: string;
  newVersion?: string;
  accuracyGain?: number;
  log?: string[];
}

export interface RetrainingConfig {
  enabled: boolean;
  schedule: 'daily' | 'weekly' | 'monthly';
  driftThreshold: number;
  performanceThreshold: number;
}

// Advanced Reliability Types
export type SelfHealingStatus = 'healthy' | 'warning' | 'healing' | 'recovered';

export interface SelfHealingAction {
  id: string;
  timestamp: number;
  trigger: string;
  action: string;
  status: 'completed' | 'failed';
  result?: string;
}

export interface AIAdvancedState {
  reliabilityScore: number; // 0-100
  selfHealingStatus: SelfHealingStatus;
  ensembleAgreement: number; // 0-100
  activeHealings: SelfHealingAction[];
}

export interface ReviewTask {
  id: string;
  type: 'insight' | 'command' | 'plan';
  originalInput: string;
  aiOutput: any;
  confidence: number;
  status: 'pending' | 'approved' | 'rejected' | 'corrected';
  timestamp: number;
}

// Collaboration Events
export type SyncEvent = 
  | { type: 'presence'; user: User }
  | { type: 'cursor-move'; userId: string; rowId: string; colId: string; userName: string; color: string }
  | { type: 'data-update'; projects: Project[]; workspaces: Workspace[] };
