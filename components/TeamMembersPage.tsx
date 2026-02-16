
import React, { useState } from 'react';
import { Users, Mail, Shield, Trash2, Search, UserPlus, ShieldCheck, ChevronDown, AtSign, Filter } from 'lucide-react';
import { Member, Role } from '../types';

interface TeamMembersPageProps {
  members: Member[];
  onInvite: (email: string, role: Role) => void;
  onUpdateRole: (userId: string, role: Role) => void;
  onRemove: (userId: string) => void;
  currentUserId: string;
  projectName: string;
  userRole: Role;
}

const TeamMembersPage: React.FC<TeamMembersPageProps> = ({ 
  members, onInvite, onUpdateRole, onRemove, currentUserId, projectName, userRole 
}) => {
  const [email, setEmail] = useState('');
  const [role, setRole] = useState<Role>('Editor');
  const [search, setSearch] = useState('');
  const canManage = userRole === 'Owner';

  const filteredMembers = members.filter(m => 
    m.name.toLowerCase().includes(search.toLowerCase()) || 
    m.email.toLowerCase().includes(search.toLowerCase())
  );

  const handleInvite = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !email.includes('@')) return;
    onInvite(email, role);
    setEmail('');
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#f7f8f9] overflow-hidden animate-in fade-in duration-300">
      <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-white shrink-0">
        <div className="flex items-center gap-5">
          <div className="w-14 h-14 bg-[#6366f1]/10 rounded-[20px] flex items-center justify-center">
            <Users className="w-8 h-8 text-[#6366f1]" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-[#1a1f36]">Team Management</h2>
            <p className="text-[#697386] text-sm font-medium mt-1">Project: <span className="text-[#1a1f36] font-bold">{projectName}</span></p>
          </div>
        </div>
        <div className="flex items-center gap-3">
           <div className="relative group">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9] group-focus-within:text-[#6366f1]" />
              <input 
                type="text" 
                placeholder="Search team..." 
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-10 pr-4 py-2.5 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl outline-none text-sm w-64 focus:ring-2 focus:ring-[#6366f1]/10 transition-all"
              />
           </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-10 custom-scrollbar">
        <div className="max-w-6xl mx-auto grid grid-cols-12 gap-10">
          
          {/* Members List */}
          <div className="col-span-8 space-y-6">
            <div className="flex items-center justify-between px-2">
               <h3 className="text-xs font-black text-[#697386] uppercase tracking-[0.2em] flex items-center gap-2">
                  <ShieldCheck className="w-4 h-4" /> Active Contributors ({members.length})
               </h3>
               <button className="flex items-center gap-2 text-xs font-bold text-[#6366f1] hover:underline">
                  <Filter className="w-3 h-3" /> Filter Roles
               </button>
            </div>

            <div className="space-y-3">
              {filteredMembers.map((member) => (
                <div key={member.userId} className="p-6 bg-white border border-[#e3e8ee] rounded-[32px] flex items-center justify-between hover:shadow-md transition-all group">
                  <div className="flex items-center gap-6">
                    <div className="w-14 h-14 rounded-2xl stripe-gradient flex items-center justify-center text-white font-black text-lg shadow-lg">
                      {member.name.charAt(0)}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                         <span className="font-bold text-[#1a1f36] text-lg">{member.name}</span>
                         {member.userId === currentUserId && <span className="text-[10px] font-black bg-[#f0f4ff] text-[#6366f1] px-2 py-0.5 rounded-full uppercase">You</span>}
                      </div>
                      <div className="flex items-center gap-2 text-sm text-[#697386] font-medium">
                         <AtSign className="w-3.5 h-3.5" />
                         {member.email}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-6">
                    <div className="text-right">
                       {canManage && member.userId !== currentUserId ? (
                          <div className="relative">
                            <select
                              value={member.role}
                              onChange={(e) => onUpdateRole(member.userId, e.target.value as Role)}
                              className="appearance-none bg-[#f7f8f9] border border-[#e3e8ee] px-4 py-2 pr-10 rounded-xl text-sm font-bold text-[#1a1f36] outline-none cursor-pointer hover:border-[#6366f1] transition-all"
                            >
                              <option value="Owner">Owner</option>
                              <option value="Editor">Editor</option>
                              <option value="Viewer">Viewer</option>
                            </select>
                            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9] pointer-events-none" />
                          </div>
                       ) : (
                          <div className="flex items-center gap-2 text-sm font-black text-[#697386] uppercase tracking-widest bg-[#f7f8f9] px-4 py-2 rounded-xl border border-[#e3e8ee]">
                             <Shield className="w-4 h-4" />
                             {member.role}
                          </div>
                       )}
                    </div>
                    {canManage && member.userId !== currentUserId && (
                       <button 
                        onClick={() => onRemove(member.userId)}
                        className="p-3 text-[#a3acb9] hover:text-[#ff4d4d] hover:bg-[#ffebed] rounded-xl opacity-0 group-hover:opacity-100 transition-all"
                       >
                        <Trash2 className="w-5 h-5" />
                       </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Right Sidebar - Actions */}
          <div className="col-span-4 space-y-8">
            {canManage && (
              <div className="p-8 bg-white border border-[#e3e8ee] rounded-[48px] shadow-sm">
                <h3 className="text-xl font-bold text-[#1a1f36] mb-6">Invite Member</h3>
                <form onSubmit={handleInvite} className="space-y-6">
                  <div className="space-y-2">
                    <label className="text-[11px] font-black text-[#697386] uppercase tracking-widest ml-1">Email Address</label>
                    <div className="relative">
                       <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9]" />
                       <input 
                         type="email" 
                         required
                         value={email}
                         onChange={(e) => setEmail(e.target.value)}
                         placeholder="teammate@company.com"
                         className="w-full pl-11 pr-4 py-4 bg-[#f7f8f9] border border-[#e3e8ee] rounded-2xl outline-none focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] transition-all font-bold text-sm"
                       />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="text-[11px] font-black text-[#697386] uppercase tracking-widest ml-1">Assigned Role</label>
                    <div className="grid grid-cols-2 gap-3">
                       {['Editor', 'Viewer'].map((r) => (
                          <button
                            key={r}
                            type="button"
                            onClick={() => setRole(r as Role)}
                            className={`py-3 rounded-xl border-2 font-bold text-sm transition-all ${
                               role === r ? 'bg-[#f0f4ff] border-[#6366f1] text-[#6366f1]' : 'bg-transparent border-[#e3e8ee] text-[#697386] hover:bg-[#f7f8f9]'
                            }`}
                          >
                             {r}
                          </button>
                       ))}
                    </div>
                  </div>

                  <button 
                    type="submit"
                    className="w-full py-4 bg-[#1a1f36] text-white font-black rounded-2xl shadow-xl hover:bg-black transition-all flex items-center justify-center gap-3 uppercase tracking-[0.2em] text-xs active:scale-95"
                  >
                    <UserPlus className="w-5 h-5" />
                    Send Invite
                  </button>
                </form>
              </div>
            )}

            <div className="p-8 bg-[#1a1f36] rounded-[48px] text-white shadow-2xl relative overflow-hidden">
               <div className="absolute top-0 right-0 w-32 h-32 bg-[#6366f1]/20 rounded-full blur-3xl -mr-16 -mt-16"></div>
               <ShieldCheck className="w-10 h-10 text-[#6366f1] mb-6" />
               <h4 className="text-xl font-black mb-4">Access Control</h4>
               <p className="text-white/50 text-sm leading-relaxed mb-6 font-medium">
                 Project owners can restrict visibility and editing capabilities at both the sheet and column level. Ensure your sensitive project data remains secure.
               </p>
               <button className="text-xs font-black uppercase tracking-widest text-[#6366f1] hover:underline flex items-center gap-2">
                  View Security Docs <ChevronDown className="w-4 h-4 -rotate-90" />
               </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TeamMembersPage;
