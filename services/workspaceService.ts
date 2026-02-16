import { getSupabaseClient } from './supabaseService';
import { Workspace, Member, RoleDefinition } from '../types';

/**
 * Get all workspaces for the current user
 */
export const getWorkspaces = async (): Promise<Workspace[]> => {
  const supabase = getSupabaseClient();
  
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('User not authenticated');
  
  const { data, error } = await supabase
    .from('workspaces')
    .select(`
      *,
      workspace_members (
        user_id,
        role,
        profiles (
          id,
          name,
          email
        )
      )
    `)
    .order('created_at', { ascending: false });
  
  if (error) throw error;
  
  // Transform data to match Workspace type
  return (data || []).map(workspace => ({
    id: workspace.id,
    name: workspace.name,
    ownerId: workspace.owner_id,
    members: (workspace.workspace_members || []).map((wm: any) => ({
      userId: wm.user_id,
      email: wm.profiles?.email || '',
      name: wm.profiles?.name || '',
      role: wm.role
    })),
    roles: [] // Load separately if needed
  }));
};

/**
 * Get a single workspace by ID
 */
export const getWorkspace = async (workspaceId: string): Promise<Workspace | null> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('workspaces')
    .select(`
      *,
      workspace_members (
        user_id,
        role,
        profiles (
          id,
          name,
          email
        )
      ),
      role_definitions (*)
    `)
    .eq('id', workspaceId)
    .single();
  
  if (error) {
    if (error.code === 'PGRST116') return null; // Not found
    throw error;
  }
  
  return {
    id: data.id,
    name: data.name,
    ownerId: data.owner_id,
    members: (data.workspace_members || []).map((wm: any) => ({
      userId: wm.user_id,
      email: wm.profiles?.email || '',
      name: wm.profiles?.name || '',
      role: wm.role
    })),
    roles: (data.role_definitions || []).map((rd: any) => ({
      id: rd.id,
      name: rd.name,
      description: rd.description || '',
      color: rd.color || '#94a3b8',
      baseRole: rd.base_role,
      isSystem: rd.is_system || false
    }))
  };
};

/**
 * Create a new workspace
 */
export const createWorkspace = async (
  name: string,
  ownerId: string
): Promise<Workspace> => {
  const supabase = getSupabaseClient();
  
  // Create workspace
  const { data: workspace, error: workspaceError } = await supabase
    .from('workspaces')
    .insert({
      name,
      owner_id: ownerId
    })
    .select()
    .single();
  
  if (workspaceError) throw workspaceError;
  
  // Add owner as member
  const { error: memberError } = await supabase
    .from('workspace_members')
    .insert({
      workspace_id: workspace.id,
      user_id: ownerId,
      role: 'Owner'
    });
  
  if (memberError) throw memberError;
  
  // Create default roles
  const defaultRoles = [
    { name: 'Owner', description: 'Full workspace and billing management access.', color: '#1e293b', base_role: 'Owner', is_system: true },
    { name: 'Editor', description: 'Can create and edit all project data.', color: '#6366f1', base_role: 'Editor', is_system: true },
    { name: 'Viewer', description: 'Read-only access to sheets and dashboards.', color: '#94a3b8', base_role: 'Viewer', is_system: true }
  ];
  
  const { error: rolesError } = await supabase
    .from('role_definitions')
    .insert(
      defaultRoles.map(role => ({
        workspace_id: workspace.id,
        ...role
      }))
    );
  
  if (rolesError) throw rolesError;
  
  return {
    id: workspace.id,
    name: workspace.name,
    ownerId: workspace.owner_id,
    members: [{
      userId: ownerId,
      email: '', // Will be loaded from profile
      name: '', // Will be loaded from profile
      role: 'Owner'
    }],
    roles: defaultRoles.map(role => ({
      id: '', // Will be set by database
      ...role,
      baseRole: role.base_role as 'Owner' | 'Editor' | 'Viewer'
    }))
  };
};

/**
 * Update a workspace
 */
export const updateWorkspace = async (
  workspaceId: string,
  updates: Partial<Workspace>
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('workspaces')
    .update({
      name: updates.name
    })
    .eq('id', workspaceId);
  
  if (error) throw error;
};

/**
 * Delete a workspace
 */
export const deleteWorkspace = async (workspaceId: string): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('workspaces')
    .delete()
    .eq('id', workspaceId);
  
  if (error) throw error;
};

/**
 * Add a member to a workspace
 */
export const addWorkspaceMember = async (
  workspaceId: string,
  userId: string,
  role: string
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('workspace_members')
    .insert({
      workspace_id: workspaceId,
      user_id: userId,
      role
    });
  
  if (error) throw error;
};

/**
 * Update a workspace member's role
 */
export const updateWorkspaceMember = async (
  workspaceId: string,
  userId: string,
  role: string
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('workspace_members')
    .update({ role })
    .eq('workspace_id', workspaceId)
    .eq('user_id', userId);
  
  if (error) throw error;
};

/**
 * Remove a member from a workspace
 */
export const removeWorkspaceMember = async (
  workspaceId: string,
  userId: string
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('workspace_members')
    .delete()
    .eq('workspace_id', workspaceId)
    .eq('user_id', userId);
  
  if (error) throw error;
};

/**
 * Create a custom role definition
 */
export const createRoleDefinition = async (
  workspaceId: string,
  role: Omit<RoleDefinition, 'id'>
): Promise<RoleDefinition> => {
  const supabase = getSupabaseClient();
  
  const { data, error } = await supabase
    .from('role_definitions')
    .insert({
      workspace_id: workspaceId,
      name: role.name,
      description: role.description,
      color: role.color,
      base_role: role.baseRole,
      is_system: role.isSystem || false
    })
    .select()
    .single();
  
  if (error) throw error;
  
  return {
    id: data.id,
    name: data.name,
    description: data.description || '',
    color: data.color || '#94a3b8',
    baseRole: data.base_role as 'Owner' | 'Editor' | 'Viewer',
    isSystem: data.is_system || false
  };
};

/**
 * Update a role definition
 */
export const updateRoleDefinition = async (
  roleId: string,
  updates: Partial<RoleDefinition>
): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('role_definitions')
    .update({
      name: updates.name,
      description: updates.description,
      color: updates.color,
      base_role: updates.baseRole,
      is_system: updates.isSystem
    })
    .eq('id', roleId);
  
  if (error) throw error;
};

/**
 * Delete a role definition
 */
export const deleteRoleDefinition = async (roleId: string): Promise<void> => {
  const supabase = getSupabaseClient();
  
  const { error } = await supabase
    .from('role_definitions')
    .delete()
    .eq('id', roleId);
  
  if (error) throw error;
};
