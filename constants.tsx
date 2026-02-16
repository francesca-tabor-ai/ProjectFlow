
import { Column, RowData, Sheet, Template } from './types';

export const DEFAULT_COLUMNS: Column[] = [
  { id: 'task', title: 'Task Name', type: 'text', width: 250 },
  { id: 'owner', title: 'Owner', type: 'text', width: 120 },
  { id: 'status', title: 'Status', type: 'dropdown', width: 120, options: ['To Do', 'In Progress', 'Done', 'Blocked'] },
  { id: 'priority', title: 'Priority', type: 'dropdown', width: 100, options: ['Low', 'Medium', 'High'] },
  { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
  { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
  { id: 'progress', title: '% Complete', type: 'number', width: 100 },
];

export const INITIAL_ROWS: RowData[] = [
  { id: '1', task: 'Project Kickoff', owner: 'Alice', status: 'Done', priority: 'High', startDate: '2024-05-01', dueDate: '2024-05-02', progress: 100 },
  { id: '2', task: 'Market Analysis', owner: 'Bob', status: 'In Progress', priority: 'Medium', startDate: '2024-05-03', dueDate: '2024-05-10', progress: 45 },
  { id: '3', task: 'Design Prototypes', owner: 'Charlie', status: 'To Do', priority: 'High', startDate: '2024-05-11', dueDate: '2024-05-20', progress: 0 },
  { id: '4', task: 'Stakeholder Review', owner: 'Alice', status: 'Blocked', priority: 'High', startDate: '2024-05-21', dueDate: '2024-05-22', progress: 0 },
];

export const INITIAL_SHEET: Sheet = {
  id: 'sheet-1',
  name: 'Main Planning',
  columns: DEFAULT_COLUMNS,
  rows: INITIAL_ROWS,
};

export const TEMPLATE_GALLERY: Template[] = [
  // AI Development - MASTER TEMPLATE
  {
    id: 'tpl-ai-development-master',
    name: 'AI Development Template: Project Planner',
    description: 'A comprehensive guide for the development, deployment, and management of AI features, covering lifecycle, MLOps, and reliability guardrails.',
    category: 'AI Development',
    sheets: [
      {
        id: 'sheet-ai-lifecycle',
        name: '1. Lifecycle & Stages',
        columns: [
          { id: 'task', title: 'Lifecycle Phase', type: 'text', width: 300 },
          { id: 'owner', title: 'Lead Role', type: 'dropdown', width: 150, options: ['AI Engineer', 'Data Scientist', 'Product Manager', 'Data Engineer'] },
          { id: 'status', title: 'Status', type: 'dropdown', width: 120, options: ['Ideation', 'In Prep', 'Testing', 'In Prod', 'Maintenance'] },
          { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
          { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
          { id: 'output', title: 'Key Output', type: 'text', width: 250 },
        ],
        rows: [
          { id: 'l1', task: '2.1 Problem Definition & Ideation', owner: 'Product Manager', status: 'Ideation', startDate: '2024-01-01', dueDate: '2024-01-10', output: 'Initial AI Feature Spec' },
          { id: 'l2', task: '2.2 Data Collection & Preparation', owner: 'Data Engineer', status: 'In Prep', startDate: '2024-01-11', dueDate: '2024-01-25', output: 'Versioned Dataset (DVC)' },
          { id: 'l3', task: '2.3 Model Experimentation', owner: 'Data Scientist', status: 'Testing', startDate: '2024-01-26', dueDate: '2024-02-15', output: 'Trained Artifacts' },
          { id: 'l4', task: '2.4 Deployment & Integration', owner: 'AI Engineer', status: 'In Prod', startDate: '2024-02-16', dueDate: '2024-03-01', output: 'REST API Endpoints' },
          { id: 'l5', task: '2.5 Monitoring & Improvement', owner: 'AI Engineer', status: 'Maintenance', startDate: '2024-03-02', dueDate: '2024-12-31', output: 'Performance Dashboards' },
        ]
      },
      {
        id: 'sheet-ai-stack',
        name: '2. Key Components & Tools',
        columns: [
          { id: 'task', title: 'Component / Category', type: 'text', width: 200 },
          { id: 'tool', title: 'Specific Tool', type: 'text', width: 180 },
          { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
          { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
          { id: 'purpose', title: 'Strategic Purpose', type: 'text', width: 350 },
        ],
        rows: [
          { id: 's1', task: 'Database', tool: 'Supabase (PostgreSQL)', startDate: '2024-01-01', dueDate: '2024-01-05', purpose: 'Core storage and historical training data source' },
          { id: 's2', task: 'ML Frameworks', tool: 'TensorFlow, PyTorch', startDate: '2024-01-06', dueDate: '2024-01-15', purpose: 'Building and training predictive models' },
          { id: 's3', task: 'MLOps Platform', tool: 'MLflow', startDate: '2024-01-16', dueDate: '2024-01-20', purpose: 'Experiment tracking and model registry' },
        ]
      },
      {
        id: 'sheet-ai-safety',
        name: '3. Reliability & Safety',
        columns: [
          { id: 'task', title: 'Guardrail / Feature', type: 'text', width: 250 },
          { id: 'type', title: 'Category', type: 'dropdown', width: 150, options: ['Input Validation', 'Model Logic', 'HITL', 'Explainability'] },
          { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
          { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
          { id: 'threshold', title: 'Conf. Threshold', type: 'number', width: 120 },
        ],
        rows: [
          { id: 'g1', task: '7.1 Input/Output Validation', type: 'Input Validation', startDate: '2024-02-01', dueDate: '2024-02-10', threshold: 1.0 },
          { id: 'g2', task: '7.2 Uncertainty Estimation', type: 'Model Logic', startDate: '2024-02-11', dueDate: '2024-02-20', threshold: 0.7 },
        ]
      }
    ]
  },

  // General Management
  {
    id: 'tpl-ops-hub',
    name: 'Operations Hub',
    description: 'Centralized tracking for team operations, recurring tasks, and resource allocation.',
    category: 'General Management',
    sheets: [{
      id: 'sheet-ops',
      name: 'Operations Log',
      columns: DEFAULT_COLUMNS,
      rows: [
        { id: 'o1', task: 'Weekly sync setup', owner: 'Operations Manager', status: 'To Do', priority: 'Medium', startDate: '2024-06-01', dueDate: '2024-06-07', progress: 0 },
        { id: 'o2', task: 'Resource planning Q3', owner: '', status: 'To Do', priority: 'High', startDate: '2024-06-15', dueDate: '2024-06-30', progress: 0 },
      ]
    }]
  },
  {
    id: 'tpl-exec-roadmap',
    name: 'Executive Roadmap',
    description: 'High-level strategic milestones for leadership alignment and quarterly goals.',
    category: 'General Management',
    sheets: [{
      id: 'sheet-exec',
      name: 'Milestones',
      columns: [
        { id: 'task', title: 'Strategic Goal', type: 'text', width: 300 },
        { id: 'owner', title: 'Executive Sponsor', type: 'text', width: 150 },
        { id: 'status', title: 'Status', type: 'dropdown', width: 120, options: ['On Track', 'At Risk', 'Off Track', 'Completed'] },
        { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
        { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
        { id: 'impact', title: 'Impact Score', type: 'number', width: 100 },
      ],
      rows: [
        { id: 'e1', task: 'Market Expansion: EMEA', owner: 'VP Sales', status: 'On Track', startDate: '2024-07-01', dueDate: '2024-09-30', impact: 9 },
        { id: 'e2', task: 'Customer Loyalty Program', owner: 'CMO', status: 'At Risk', startDate: '2024-08-01', dueDate: '2024-10-31', impact: 8 },
      ]
    }]
  },

  // Software Development
  {
    id: 'tpl-bug-tracker',
    name: 'Bug Tracker',
    description: 'Report, prioritize, and fix software defects with rigorous status tracking.',
    category: 'Software Development',
    sheets: [{
      id: 'sheet-bugs',
      name: 'Defect Log',
      columns: [
        { id: 'task', title: 'Issue Summary', type: 'text', width: 300 },
        { id: 'severity', title: 'Severity', type: 'dropdown', width: 100, options: ['Critical', 'Major', 'Minor', 'Trivial'] },
        { id: 'status', title: 'Resolution', type: 'dropdown', width: 120, options: ['New', 'In Progress', 'Testing', 'Fixed', 'Wont Fix'] },
        { id: 'startDate', title: 'Start Date', type: 'date', width: 140 },
        { id: 'dueDate', title: 'To Date', type: 'date', width: 140 },
        { id: 'owner', title: 'Assignee', type: 'text', width: 120 },
      ],
      rows: [
        { id: 'b1', task: 'Auth token timeout on Safari', severity: 'Critical', status: 'In Progress', startDate: '2024-05-15', dueDate: '2024-05-17', owner: 'Frontend Lead' },
        { id: 'b2', task: 'Missing padding in footer', severity: 'Minor', status: 'New', startDate: '2024-05-18', dueDate: '2024-05-20', owner: '' },
      ]
    }]
  }
];
