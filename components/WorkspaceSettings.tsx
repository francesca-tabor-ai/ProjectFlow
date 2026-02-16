
import React, { useState } from 'react';
import { 
  Users, 
  Shield, 
  Plus, 
  Trash2, 
  Edit3, 
  Search, 
  Check, 
  X, 
  MoreVertical, 
  Settings2,
  Mail,
  UserPlus,
  ArrowRight,
  Info
} from 'lucide-react';
import { Workspace, Member, RoleDefinition, Role } from '../types';

interface WorkspaceSettingsProps {
  workspace: Workspace;
  currentUser: any;
  onAddMember: (email: string, role: string) => void;
  onUpdateMember: (userId: string, updates: Partial<Member>) => void;
  onDeleteMember: (userId: string) => void;
  onCreateRole: (role: Omit<RoleDefinition, 'id'>) => void;
  onUpdateRole: (roleId: string, updates: Partial<RoleDefinition>) => void;
  onDeleteRole: (roleId: string) => void;
}

const WorkspaceSettings: React.FC<WorkspaceSettingsProps> = ({
  workspace,
  currentUser,
  onAddMember,
  onUpdateMember,
  onDeleteMember,
  onCreateRole,
  onUpdateRole,
  onDeleteRole
}) => {
  const [activeTab, setActiveTab] = useState<'users' | 'roles'>('users');
  const [search, setSearch] = useState('');
  const [isAddingUser, setIsAddingUser] = useState(false);
  const [isAddingRole, setIsAddingRole] = useState(false);

  // Form states
  const [newEmail, setNewEmail] = useState('');
  const [newRole, setNewRole] = useState('Editor');
  const [newRoleName, setNewRoleName] = useState('');
  const [newRoleDesc, setNewRoleDesc] = useState('');
  const [newRoleBase, setNewRoleBase] = useState<'Owner' | 'Editor' | 'Viewer'>('Editor');

  const filteredMembers = workspace.members.filter(m => 
    m.name.toLowerCase().includes(search.toLowerCase()) || 
    m.email.toLowerCase().includes(search.toLowerCase())
  );

  const canManage = workspace.ownerId === currentUser.id || currentUser.id === 'guest';

  const handleAddUser = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newEmail.trim()) return;
    onAddMember(newEmail, newRole);
    setNewEmail('');
    setIsAddingUser(false);
  };

  const handleAddRole = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newRoleName.trim()) return;
    onCreateRole({
      name: newRoleName,
      description: newRoleDesc,
      baseRole: newRoleBase,
      color: '#6366f1'
    });
    setNewRoleName('');
    setNewRoleDesc('');
    setIsAddingRole(false);
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#f7f8f9] overflow-hidden animate-in fade-in duration-300">
      <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-white shrink-0">
        <div className="flex items-center gap-5">
          <div className="w-14 h-14 bg-[#1a1f36] rounded-[20px] flex items-center justify-center shadow-lg">
            <Settings2 className="w-8 h-8 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-[#1a1f36]">Workspace Governance</h2>
            <p className="text-[#697386] text-sm font-medium mt-1">Manage users, custom roles, and security policies for <strong>{workspace.name}</strong></p>
          </div>
        </div>
        <div className="flex bg-[#f7f8f9] p-1 rounded-xl border border-[#e3e8ee]">
          <button 
            onClick={() => setActiveTab('users')}
            className={`flex items-center gap-2 px-6 py-2 text-sm font-bold rounded-lg transition-all ${activeTab === 'users' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386]'}`}
          >
            <Users className="w-4 h-4" /> Users
          </button>
          <button 
            onClick={() => setActiveTab('roles')}
            className={`flex items-center gap-2 px-6 py-2 text-sm font-bold rounded-lg transition-all ${activeTab === 'roles' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386]'}`}
          >
            <Shield className="w-4 h-4" /> Roles
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-10 custom-scrollbar">
        <div className="max-w-6xl mx-auto">
          
          {activeTab === 'users' && (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div className="relative group w-80">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9] group-focus-within:text-[#6366f1]" />
                  <input 
                    type="text" 
                    placeholder="Search by name or email..." 
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-11 pr-4 py-3 bg-white border border-[#e3e8ee] rounded-2xl outline-none focus:ring-4 focus:ring-[#6366f1]/10 transition-all text-sm font-medium"
                  />
                </div>
                {canManage && (
                  <button 
                    onClick={() => setIsAddingUser(true)}
                    className="flex items-center gap-2 px-6 py-3 bg-[#6366f1] text-white rounded-xl font-bold shadow-lg hover:bg-[#4f46e5] active:scale-95 transition-all"
                  >
                    <UserPlus className="w-4 h-4" /> Add Member
                  </button>
                )}
              </div>

              {isAddingUser && (
                <div className="bg-white p-8 rounded-[32px] border-2 border-[#6366f1]/20 shadow-xl animate-in slide-in-from-top-4 duration-300">
                  <div className="flex items-center justify-between mb-6">
                    <h3 className="text-lg font-bold text-[#1a1f36]">Invite New Workspace Member</h3>
                    <button onClick={() => setIsAddingUser(false)} className="text-[#a3acb9] hover:text-[#1a1f36]"><X className="w-5 h-5" /></button>
                  </div>
                  <form onSubmit={handleAddUser} className="flex gap-4">
                    <div className="flex-1 relative">
                      <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9]" />
                      <input 
                        type="email" 
                        required
                        value={newEmail}
                        onChange={(e) => setNewEmail(e.target.value)}
                        placeholder="teammate@company.com"
                        className="w-full pl-11 pr-4 py-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl outline-none font-medium text-sm"
                      />
                    </div>
                    <select 
                      value={newRole}
                      onChange={(e) => setNewRole(e.target.value)}
                      className="px-4 py-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl font-bold text-sm outline-none"
                    >
                      {workspace.roles.map(r => <option key={r.id} value={r.name}>{r.name}</option>)}
                    </select>
                    <button type="submit" className="px-8 bg-[#1a1f36] text-white font-bold rounded-xl hover:bg-black transition-all">Send Invite</button>
                  </form>
                </div>
              )}

              <div className="bg-white border border-[#e3e8ee] rounded-[32px] overflow-hidden shadow-sm">
                <table className="w-full text-left">
                  <thead className="bg-[#fbfcfd] border-b border-[#e3e8ee]">
                    <tr>
                      <th className="px-8 py-4 text-[11px] font-black text-[#697386] uppercase tracking-[0.2em]">Member</th>
                      <th className="px-8 py-4 text-[11px] font-black text-[#697386] uppercase tracking-[0.2em]">Role</th>
                      <th className="px-8 py-4 text-[11px] font-black text-[#697386] uppercase tracking-[0.2em]">Status</th>
                      <th className="px-8 py-4"></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-[#f0f2f5]">
                    {filteredMembers.map(member => (
                      <tr key={member.userId} className="group hover:bg-[#fbfcfd] transition-colors">
                        <td className="px-8 py-5">
                          <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-2xl stripe-gradient flex items-center justify-center text-white font-black text-lg shadow-sm">
                              {member.name.charAt(0)}
                            </div>
                            <div>
                              <div className="font-bold text-[#1a1f36] text-[15px]">{member.name}</div>
                              <div className="text-xs text-[#697386] font-medium">{member.email}</div>
                            </div>
                          </div>
                        </td>
                        <td className="px-8 py-5">
                          {canManage && member.userId !== currentUser.id ? (
                            <select 
                              value={member.role}
                              onChange={(e) => onUpdateMember(member.userId, { role: e.target.value })}
                              className="bg-transparent font-bold text-[#6366f1] outline-none cursor-pointer"
                            >
                              {workspace.roles.map(r => <option key={r.id} value={r.name}>{r.name}</option>)}
                            </select>
                          ) : (
                            <span className="font-bold text-[#1a1f36]">{member.role}</span>
                          )}
                        </td>
                        <td className="px-8 py-5">
                          <span className="px-3 py-1 bg-[#e6fff4] text-[#00ca72] text-[10px] font-black rounded-full border border-[#00ca72]/20 uppercase">Active</span>
                        </td>
                        <td className="px-8 py-5 text-right">
                          {canManage && member.userId !== currentUser.id && (
                            <button 
                              onClick={() => onDeleteMember(member.userId)}
                              className="p-2.5 text-[#a3acb9] hover:text-[#ff4d4d] hover:bg-[#ffebed] rounded-xl transition-all opacity-0 group-hover:opacity-100"
                            >
                              <Trash2 className="w-5 h-5" />
                            </button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'roles' && (
            <div className="space-y-10">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-xl font-bold text-[#1a1f36]">Workspace Roles</h3>
                  <p className="text-sm text-[#697386] mt-1 font-medium">Define custom access levels for your organization.</p>
                </div>
                {canManage && (
                  <button 
                    onClick={() => setIsAddingRole(true)}
                    className="flex items-center gap-2 px-6 py-3 bg-[#1a1f36] text-white rounded-xl font-bold shadow-lg hover:bg-black transition-all"
                  >
                    <Plus className="w-4 h-4" /> Define New Role
                  </button>
                )}
              </div>

              {isAddingRole && (
                <div className="bg-white p-10 rounded-[32px] border-2 border-[#1a1f36]/10 shadow-2xl animate-in zoom-in-95 duration-300">
                  <div className="flex items-center justify-between mb-8">
                    <h3 className="text-2xl font-black text-[#1a1f36]">Role Definition</h3>
                    <button onClick={() => setIsAddingRole(false)} className="p-2 hover:bg-[#f7f8f9] rounded-full"><X className="w-6 h-6" /></button>
                  </div>
                  <form onSubmit={handleAddRole} className="space-y-8">
                    <div className="grid grid-cols-2 gap-8">
                      <div className="space-y-2">
                        <label className="text-[11px] font-black text-[#697386] uppercase tracking-widest ml-1">Role Display Name</label>
                        <input 
                          required
                          value={newRoleName}
                          onChange={(e) => setNewRoleName(e.target.value)}
                          placeholder="e.g. Project Lead"
                          className="w-full px-5 py-4 bg-[#f7f8f9] border border-[#e3e8ee] rounded-2xl outline-none font-bold focus:ring-4 focus:ring-[#6366f1]/10 transition-all"
                        />
                      </div>
                      <div className="space-y-2">
                        <label className="text-[11px] font-black text-[#697386] uppercase tracking-widest ml-1">Permission Profile</label>
                        <select 
                          value={newRoleBase}
                          onChange={(e) => setNewRoleBase(e.target.value as any)}
                          className="w-full px-5 py-4 bg-[#f7f8f9] border border-[#e3e8ee] rounded-2xl font-bold outline-none"
                        >
                          <option value="Owner">Full Access (Owner)</option>
                          <option value="Editor">Create & Edit (Editor)</option>
                          <option value="Viewer">Read Only (Viewer)</option>
                        </select>
                      </div>
                    </div>
                    <div className="space-y-2">
                       <label className="text-[11px] font-black text-[#697386] uppercase tracking-widest ml-1">Description</label>
                       <textarea 
                        value={newRoleDesc}
                        onChange={(e) => setNewRoleDesc(e.target.value)}
                        placeholder="What is this role responsible for?"
                        className="w-full px-5 py-4 bg-[#f7f8f9] border border-[#e3e8ee] rounded-2xl outline-none font-medium h-24 resize-none"
                       />
                    </div>
                    <button type="submit" className="w-full py-5 bg-[#6366f1] text-white font-black rounded-2xl shadow-xl hover:bg-[#4f46e5] transition-all uppercase tracking-[0.2em] text-xs">Register Role</button>
                  </form>
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {workspace.roles.map(role => (
                  <div key={role.id} className="p-8 bg-white border border-[#e3e8ee] rounded-[40px] hover:shadow-md transition-all group relative overflow-hidden">
                    <div className="absolute top-0 left-0 w-1.5 h-full" style={{ backgroundColor: role.color }}></div>
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h4 className="text-xl font-bold text-[#1a1f36]">{role.name}</h4>
                        <div className="flex items-center gap-2 mt-1">
                           <span className="text-[10px] font-black bg-[#f0f4ff] text-[#6366f1] px-2 py-0.5 rounded-full uppercase">Inherits: {role.baseRole}</span>
                           {role.isSystem && <span className="text-[10px] font-black bg-[#f7f8f9] text-[#a3acb9] px-2 py-0.5 rounded-full uppercase">System Default</span>}
                        </div>
                      </div>
                      {canManage && !role.isSystem && (
                        <div className="flex gap-1">
                          <button 
                            onClick={() => {
                              const newName = prompt("Rename role:", role.name);
                              if (newName) onUpdateRole(role.id, { name: newName });
                            }}
                            className="p-2 hover:bg-[#f7f8f9] rounded-lg transition-all text-[#a3acb9] hover:text-[#6366f1]"
                          >
                            <Edit3 className="w-4 h-4" />
                          </button>
                          <button 
                            onClick={() => onDeleteRole(role.id)}
                            className="p-2 hover:bg-[#ffebed] rounded-lg transition-all text-[#a3acb9] hover:text-[#ff4d4d]"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      )}
                    </div>
                    <p className="text-sm text-[#697386] leading-relaxed font-medium mb-6">{role.description || 'No description provided for this role.'}</p>
                    
                    <div className="flex items-center justify-between pt-6 border-t border-[#f0f2f5]">
                       <div className="flex -space-x-2">
                          {workspace.members.filter(m => m.role === role.name).slice(0, 5).map((m, i) => (
                             <div key={i} className="w-8 h-8 rounded-full border-2 border-white bg-[#f7f8f9] flex items-center justify-center text-[10px] font-bold text-[#697386]">
                                {m.name.charAt(0)}
                             </div>
                          ))}
                          {workspace.members.filter(m => m.role === role.name).length > 5 && (
                             <div className="w-8 h-8 rounded-full border-2 border-white bg-[#1a1f36] flex items-center justify-center text-[8px] font-bold text-white">
                                +{workspace.members.filter(m => m.role === role.name).length - 5}
                             </div>
                          )}
                       </div>
                       <span className="text-[11px] font-bold text-[#a3acb9] uppercase tracking-wider">
                          {workspace.members.filter(m => m.role === role.name).length} Assignments
                       </span>
                    </div>
                  </div>
                ))}
              </div>

              <div className="p-10 bg-[#1a1f36] rounded-[48px] text-white flex items-center gap-12 relative overflow-hidden shadow-2xl">
                 <div className="absolute top-0 right-0 w-64 h-64 bg-[#6366f1]/10 rounded-full blur-3xl -mr-32 -mt-32"></div>
                 <div className="w-24 h-24 bg-white/10 rounded-3xl flex items-center justify-center shrink-0 shadow-inner">
                    <Info className="w-12 h-12 text-[#6366f1]" />
                 </div>
                 <div>
                    <h4 className="text-2xl font-black mb-2">Enterprise Permissions</h4>
                    <p className="text-white/60 leading-relaxed font-medium">Custom roles allow you to tailor the exact experience for your team. Use Permission Profiles to control granular data access at the sheet and column level across all projects.</p>
                 </div>
              </div>
            </div>
          )}

        </div>
      </div>
    </div>
  );
};

export default WorkspaceSettings;
