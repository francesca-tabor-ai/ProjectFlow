
import React, { useState } from 'react';
import { X, Mail, UserPlus, Shield, Trash2, Check, ChevronDown } from 'lucide-react';
import { Member, Role } from '../types';

interface ShareModalProps {
  onClose: () => void;
  members: Member[];
  onInvite: (email: string, role: Role) => void;
  onUpdateRole: (userId: string, role: Role) => void;
  onRemove: (userId: string) => void;
  currentUserId: string;
  entityName: string;
}

const ShareModal: React.FC<ShareModalProps> = ({ 
  onClose, 
  members, 
  onInvite, 
  onUpdateRole, 
  onRemove, 
  currentUserId,
  entityName
}) => {
  const [email, setEmail] = useState('');
  const [role, setRole] = useState<Role>('Editor');
  const [isAdding, setIsAdding] = useState(false);

  const currentUserRole = members.find(m => m.userId === currentUserId)?.role || 'Viewer';
  const canManage = currentUserRole === 'Owner';

  const handleInvite = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;
    onInvite(email, role);
    setEmail('');
    setIsAdding(false);
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-[#1a1f36]/40 backdrop-blur-md p-4 animate-in fade-in duration-200">
      <div className="bg-white rounded-[24px] w-full max-w-lg shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-300">
        <div className="p-6 border-b border-[#e3e8ee] flex items-center justify-between">
          <div>
            <h3 className="text-xl font-bold text-[#1a1f36]">Share "{entityName}"</h3>
            <p className="text-[#697386] text-sm mt-0.5">Manage access and collaboration permissions.</p>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-[#f7f8f9] rounded-full transition-colors text-[#a3acb9] hover:text-[#1a1f36]">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-8 space-y-8">
          {/* Invite Section */}
          {canManage && (
            <form onSubmit={handleInvite} className="space-y-4">
              <label className="text-[11px] font-bold text-[#697386] uppercase tracking-wider ml-1">Invite team member</label>
              <div className="flex gap-2">
                <div className="flex-1 relative group">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9] group-focus-within:text-[#6366f1]" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Enter email address"
                    className="w-full pl-11 pr-4 py-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all"
                  />
                </div>
                <div className="relative">
                  <select 
                    value={role}
                    onChange={(e) => setRole(e.target.value as Role)}
                    className="appearance-none h-full px-4 pr-10 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-bold text-sm cursor-pointer"
                  >
                    <option value="Editor">Editor</option>
                    <option value="Viewer">Viewer</option>
                  </select>
                  <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9] pointer-events-none" />
                </div>
                <button 
                  type="submit"
                  className="px-6 bg-[#1a1f36] text-white font-bold rounded-xl hover:bg-[#2e344a] transition-all flex items-center gap-2 active:scale-95"
                >
                  <UserPlus className="w-4 h-4" />
                  Invite
                </button>
              </div>
            </form>
          )}

          {/* Members List */}
          <div className="space-y-4">
            <h4 className="text-[11px] font-bold text-[#697386] uppercase tracking-wider ml-1">Current Members</h4>
            <div className="space-y-2">
              {members.map((member) => (
                <div key={member.userId} className="flex items-center justify-between p-4 rounded-2xl border border-[#e3e8ee] hover:bg-[#f7f8f9] transition-colors">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-xl stripe-gradient flex items-center justify-center text-white font-bold text-sm shadow-sm">
                      {member.name.charAt(0)}
                    </div>
                    <div>
                      <div className="font-bold text-[#1a1f36] text-[14px]">
                        {member.name} {member.userId === currentUserId && <span className="text-[#6366f1] ml-1">(You)</span>}
                      </div>
                      <div className="text-[12px] text-[#697386]">{member.email}</div>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    {canManage && member.userId !== currentUserId ? (
                      <>
                        <select
                          value={member.role}
                          onChange={(e) => onUpdateRole(member.userId, e.target.value as Role)}
                          className="bg-transparent text-[13px] font-bold text-[#1a1f36] outline-none cursor-pointer hover:text-[#6366f1]"
                        >
                          <option value="Owner">Owner</option>
                          <option value="Editor">Editor</option>
                          <option value="Viewer">Viewer</option>
                        </select>
                        <button 
                          onClick={() => onRemove(member.userId)}
                          className="p-2 text-[#a3acb9] hover:text-[#ff4d4d] hover:bg-[#ffebed] rounded-lg transition-all"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </>
                    ) : (
                      <span className="text-[13px] font-bold text-[#697386] px-3 py-1 bg-white border border-[#e3e8ee] rounded-lg">
                        {member.role}
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="p-6 bg-[#f7f8f9] border-t border-[#e3e8ee] flex justify-end">
          <button 
            onClick={onClose}
            className="px-6 py-2 bg-white border border-[#e3e8ee] text-[#1a1f36] font-bold rounded-xl hover:bg-gray-50 transition-all active:scale-95"
          >
            Done
          </button>
        </div>
      </div>
    </div>
  );
};

export default ShareModal;
