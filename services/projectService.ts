import { getSupabaseClient } from './supabaseService';
import { Project, Sheet, Column, RowData } from '../types';

/**
 * Get all projects for a workspace
 */
export const getProjects = async (workspaceId: string): Promise<Project[]> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      sheets (
        *,
        columns (*),
        rows (*)
      )
    `)
    .eq('workspace_id', workspaceId)
    .order('created_at', { ascending: false });
  
  if (error) throw error;
  
  // Transform data to match Project type
  return (data || []).map(project => ({
    id: project.id,
    name: project.name,
    workspaceId: project.workspace_id,
    activeSheetId: project.active_sheet_id,
    ownerId: project.owner_id,
    sheets: (project.sheets || []).map((sheet: any) => ({
      id: sheet.id,
      name: sheet.name,
      columns: (sheet.columns || []).map((col: any) => ({
        id: col.id,
        title: col.title,
        type: col.type,
        width: col.width,
        options: col.options,
        permissions: col.permissions
      })),
      rows: (sheet.rows || []).map((row: any) => ({
        id: row.id,
        ...row.row_data,
        dependencies: row.dependencies || []
      }))
    })),
    members: [], // Load separately if needed
    activityLog: [], // Load separately if needed
    savedViews: [], // Load separately if needed
    automations: [], // Load separately if needed
    integrations: { googleDriveConnected: false, apiKeys: [] } // Load separately if needed
  }));
};

/**
 * Get a single project by ID
 */
export const getProject = async (projectId: string): Promise<Project | null> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      sheets (
        *,
        columns (*),
        rows (*)
      )
    `)
    .eq('id', projectId)
    .single();
  
  if (error) {
    if (error.code === 'PGRST116') return null; // Not found
    throw error;
  }
  
  // Transform to match Project type
  return {
    id: data.id,
    name: data.name,
    workspaceId: data.workspace_id,
    activeSheetId: data.active_sheet_id,
    ownerId: data.owner_id,
    sheets: (data.sheets || []).map((sheet: any) => ({
      id: sheet.id,
      name: sheet.name,
      columns: (sheet.columns || []).map((col: any) => ({
        id: col.id,
        title: col.title,
        type: col.type,
        width: col.width,
        options: col.options,
        permissions: col.permissions
      })),
      rows: (sheet.rows || []).map((row: any) => ({
        id: row.id,
        ...row.row_data,
        dependencies: row.dependencies || []
      }))
    })),
    members: [],
    activityLog: [],
    savedViews: [],
    automations: [],
    integrations: { googleDriveConnected: false, apiKeys: [] }
  };
};

/**
 * Create a new project
 */
export const createProject = async (
  workspaceId: string,
  name: string,
  ownerId: string
): Promise<Project> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('projects')
    .insert({
      name,
      workspace_id: workspaceId,
      owner_id: ownerId
    })
    .select()
    .single();
  
  if (error) throw error;
  
  return {
    id: data.id,
    name: data.name,
    workspaceId: data.workspace_id,
    activeSheetId: data.active_sheet_id,
    ownerId: data.owner_id,
    sheets: [],
    members: [],
    activityLog: [],
    savedViews: [],
    automations: [],
    integrations: { googleDriveConnected: false, apiKeys: [] }
  };
};

/**
 * Update a project
 */
export const updateProject = async (
  projectId: string,
  updates: Partial<Project>
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('projects')
    .update({
      name: updates.name,
      active_sheet_id: updates.activeSheetId
    })
    .eq('id', projectId);
  
  if (error) throw error;
};

/**
 * Delete a project
 */
export const deleteProject = async (projectId: string): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('projects')
    .delete()
    .eq('id', projectId);
  
  if (error) throw error;
};

/**
 * Create a sheet in a project
 */
export const createSheet = async (
  projectId: string,
  name: string
): Promise<Sheet> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('sheets')
    .insert({
      project_id: projectId,
      name
    })
    .select()
    .single();
  
  if (error) throw error;
  
  return {
    id: data.id,
    name: data.name,
    columns: [],
    rows: []
  };
};

/**
 * Update a sheet
 */
export const updateSheet = async (
  sheetId: string,
  updates: Partial<Sheet>
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('sheets')
    .update({
      name: updates.name
    })
    .eq('id', sheetId);
  
  if (error) throw error;
};

/**
 * Delete a sheet
 */
export const deleteSheet = async (sheetId: string): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('sheets')
    .delete()
    .eq('id', sheetId);
  
  if (error) throw error;
};

/**
 * Create a column in a sheet
 */
export const createColumn = async (
  sheetId: string,
  column: Omit<Column, 'id'>
): Promise<Column> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('columns')
    .insert({
      sheet_id: sheetId,
      title: column.title,
      type: column.type,
      width: column.width,
      options: column.options,
      permissions: column.permissions,
      display_order: 0 // TODO: Calculate proper order
    })
    .select()
    .single();
  
  if (error) throw error;
  
  return {
    id: data.id,
    title: data.title,
    type: data.type,
    width: data.width,
    options: data.options,
    permissions: data.permissions
  };
};

/**
 * Update a column
 */
export const updateColumn = async (
  columnId: string,
  updates: Partial<Column>
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('columns')
    .update({
      title: updates.title,
      type: updates.type,
      width: updates.width,
      options: updates.options,
      permissions: updates.permissions
    })
    .eq('id', columnId);
  
  if (error) throw error;
};

/**
 * Delete a column
 */
export const deleteColumn = async (columnId: string): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('columns')
    .delete()
    .eq('id', columnId);
  
  if (error) throw error;
};

/**
 * Create a row in a sheet
 */
export const createRow = async (
  sheetId: string,
  rowData: Partial<RowData>
): Promise<RowData> => {
  const supabase = getSupabaseClient();
  
  const { id, dependencies, ...data } = rowData;
  const newId = id || crypto.randomUUID();
  
  const { data: result, error } = await supabase
    .from('rows')
    .insert({
      id: newId,
      sheet_id: sheetId,
      row_data: data,
      dependencies: dependencies || []
    })
    .select()
    .single();
  
  if (error) throw error;
  
  return {
    id: result.id,
    ...result.row_data,
    dependencies: result.dependencies || []
  };
};

/**
 * Update a row
 */
export const updateRow = async (
  rowId: string,
  updates: Partial<RowData>
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { id, dependencies, ...data } = updates;
  
  const updateData: any = {};
  if (Object.keys(data).length > 0) {
    // Get existing row data and merge
    const { data: existing } = await supabase
      .from('rows')
      .select('row_data')
      .eq('id', rowId)
      .single();
    
    updateData.row_data = { ...existing?.row_data, ...data };
  }
  
  if (dependencies !== undefined) {
    updateData.dependencies = dependencies;
  }
  
  const { error } = await supabase
    .from('rows')
    .update(updateData)
    .eq('id', rowId);
  
  if (error) throw error;
};

/**
 * Delete a row
 */
export const deleteRow = async (rowId: string): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('rows')
    .delete()
    .eq('id', rowId);
  
  if (error) throw error;
};

/**
 * Get rows for a sheet
 */
export const getRows = async (sheetId: string): Promise<RowData[]> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('rows')
    .select('*')
    .eq('sheet_id', sheetId)
    .order('created_at', { ascending: true });
  
  if (error) throw error;
  
  return (data || []).map(row => ({
    id: row.id,
    ...row.row_data,
    dependencies: row.dependencies || []
  }));
};
