
import React, { useState } from 'react';
import { X, ShieldCheck, User, Users, Check, Lock, Globe } from 'lucide-react';
import { Member, PermissionConfig } from '../types';

interface PermissionsModalProps {
  onClose: () => void;
  onUpdate: (type: 'sheet' | 'column', id: string, config: PermissionConfig) => void;
  members: Member[];
  entityId: string;
  entityType: 'sheet' | 'column';
  entityName: string;
  initialConfig?: PermissionConfig;
}

const PermissionsModal: React.FC<PermissionsModalProps> = ({ 
  onClose, onUpdate, members, entityId, entityType, entityName, initialConfig 
}) => {
  const [viewers, setViewers] = useState<string[]>(initialConfig?.viewers || ['*']);
  const [editors, setEditors] = useState<string[]>(initialConfig?.editors || ['*']);

  const togglePermission = (userId: string, level: 'viewers' | 'editors') => {
    const list = level === 'viewers' ? viewers : editors;
    const setter = level === 'viewers' ? setViewers : setEditors;

    if (userId === '*') {
      setter(['*']);
      return;
    }

    let newList = list.filter(id => id !== '*');
    if (newList.includes(userId)) {
      newList = newList.filter(id => id !== userId);
    } else {
      newList.push(userId);
    }
    
    if (newList.length === 0) newList = ['*'];
    setter(newList);
  };

  const handleSave = () => {
    onUpdate(entityType, entityId, { viewers, editors });
  };

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center bg-[#1a1f36]/60 backdrop-blur-md p-4 animate-in fade-in duration-300">
      <div className="bg-white rounded-[32px] w-full max-w-lg shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-300">
        <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-[#fbfcfd]">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-[#6366f1]/10 rounded-2xl flex items-center justify-center">
              <ShieldCheck className="w-6 h-6 text-[#6366f1]" />
            </div>
            <div>
              <h3 className="text-xl font-extrabold text-[#1a1f36]">{entityType === 'sheet' ? 'Sheet' : 'Column'} Permissions</h3>
              <p className="text-[#697386] text-sm font-medium">Restricting "{entityName}"</p>
            </div>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-[#f7f8f9] rounded-full text-[#a3acb9] hover:text-[#1a1f36]">
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar max-h-[60vh]">
          {/* Permission levels */}
          {(['viewers', 'editors'] as const).map(level => (
            <div key={level} className="space-y-4">
              <div className="flex items-center justify-between">
                <h4 className="text-[11px] font-bold text-[#697386] uppercase tracking-widest flex items-center gap-2">
                  {level === 'viewers' ? <Globe className="w-3 h-3" /> : <Lock className="w-3 h-3" />}
                  Who can {level === 'viewers' ? 'view' : 'edit'} this?
                </h4>
              </div>

              <div className="space-y-1.5">
                <button 
                  onClick={() => togglePermission('*', level)}
                  className={`w-full flex items-center justify-between p-3.5 rounded-xl border transition-all ${
                    (level === 'viewers' ? viewers : editors).includes('*') 
                      ? 'border-[#6366f1] bg-[#f0f4ff] shadow-sm' 
                      : 'border-[#e3e8ee] hover:bg-[#f7f8f9]'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-white border border-[#e3e8ee] rounded-lg flex items-center justify-center text-[#697386]">
                      <Users className="w-4 h-4" />
                    </div>
                    <span className="text-[14px] font-bold text-[#1a1f36]">Everyone in Project</span>
                  </div>
                  {(level === 'viewers' ? viewers : editors).includes('*') && <Check className="w-4 h-4 text-[#6366f1]" />}
                </button>

                {members.map(member => (
                  <button 
                    key={member.userId}
                    onClick={() => togglePermission(member.userId, level)}
                    className={`w-full flex items-center justify-between p-3.5 rounded-xl border transition-all ${
                      (level === 'viewers' ? viewers : editors).includes(member.userId) 
                        ? 'border-[#6366f1] bg-[#f0f4ff] shadow-sm' 
                        : 'border-[#e3e8ee] hover:bg-[#f7f8f9]'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 stripe-gradient rounded-lg flex items-center justify-center text-white font-bold text-[10px]">
                        {member.name.charAt(0)}
                      </div>
                      <div className="text-left">
                        <div className="text-[14px] font-bold text-[#1a1f36]">{member.name}</div>
                        <div className="text-[11px] text-[#697386]">{member.email}</div>
                      </div>
                    </div>
                    {(level === 'viewers' ? viewers : editors).includes(member.userId) && <Check className="w-4 h-4 text-[#6366f1]" />}
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>

        <div className="p-8 border-t border-[#e3e8ee] bg-[#fbfcfd] flex gap-4">
          <button onClick={onClose} className="flex-1 py-3.5 text-[14px] font-bold text-[#697386] hover:text-[#1a1f36] transition-colors">Cancel</button>
          <button onClick={handleSave} className="flex-[2] py-3.5 stripe-gradient text-white font-bold rounded-xl shadow-lg hover:scale-[1.02] active:scale-[0.98] transition-all">Save Permissions</button>
        </div>
      </div>
    </div>
  );
};

export default PermissionsModal;
