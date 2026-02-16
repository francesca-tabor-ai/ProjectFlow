
import React, { useState } from 'react';
import { Zap, ArrowRight, Bell, Mail, Plus, Trash2, ToggleLeft, ToggleRight, Settings2 } from 'lucide-react';
import { AutomationRule, TriggerType, NotificationChannel } from '../types';

interface AutomationsPageProps {
  rules: AutomationRule[];
  onCreate: (rule: AutomationRule) => void;
  onUpdate: (id: string, updates: Partial<AutomationRule>) => void;
  onDelete: (id: string) => void;
  statuses: string[];
}

const AutomationsPage: React.FC<AutomationsPageProps> = ({ rules, onCreate, onUpdate, onDelete, statuses }) => {
  const [isBuilding, setIsBuilding] = useState(false);
  const [name, setName] = useState('');
  const [triggerType, setTriggerType] = useState<TriggerType>('status_change');
  const [statusValue, setStatusValue] = useState(statuses[0]);
  const [daysBefore, setDaysBefore] = useState(1);
  const [channel, setChannel] = useState<NotificationChannel>('in_app');
  const [recipient, setRecipient] = useState<'owner' | 'all'>('owner');

  const handleCreate = () => {
    if (!name.trim()) return;
    const newRule: AutomationRule = {
      id: `rule-${Date.now()}`,
      name,
      enabled: true,
      trigger: {
        type: triggerType,
        value: triggerType === 'status_change' ? statusValue : undefined,
        daysBefore: triggerType === 'date_approaching' ? daysBefore : undefined
      },
      action: { type: 'notify', channel, recipient }
    };
    onCreate(newRule);
    setIsBuilding(false);
    resetForm();
  };

  const resetForm = () => {
    setName('');
    setTriggerType('status_change');
    setStatusValue(statuses[0]);
    setDaysBefore(1);
    setChannel('in_app');
    setRecipient('owner');
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#f7f8f9] overflow-hidden animate-in fade-in duration-300">
      <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-white shrink-0">
        <div className="flex items-center gap-5">
          <div className="w-14 h-14 bg-[#6366f1]/10 rounded-[20px] flex items-center justify-center">
            <Zap className="w-8 h-8 text-[#6366f1]" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-[#1a1f36]">Workflow Automations</h2>
            <p className="text-[#697386] text-sm font-medium mt-1">Connect actions to events to scale your productivity.</p>
          </div>
        </div>
        {!isBuilding && (
          <button 
            onClick={() => setIsBuilding(true)}
            className="flex items-center gap-2 px-6 py-3 bg-[#6366f1] text-white rounded-xl text-sm font-bold hover:bg-[#4f46e5] transition-all shadow-lg shadow-[#6366f1]/20 active:scale-95"
          >
            <Plus className="w-4 h-4" />
            Create New Rule
          </button>
        )}
      </div>

      <div className="flex-1 overflow-y-auto p-10 custom-scrollbar">
        <div className="max-w-5xl mx-auto">
          {isBuilding ? (
            <div className="bg-white rounded-[32px] border border-[#e3e8ee] p-10 shadow-sm animate-in slide-in-from-bottom-4 duration-500">
              <h3 className="text-xl font-bold text-[#1a1f36] mb-8">Rule Configuration</h3>
              <div className="space-y-10">
                <div className="space-y-3">
                  <label className="text-[11px] font-bold text-[#697386] uppercase tracking-widest ml-1">Automated Rule Name</label>
                  <input 
                    type="text" 
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g., Notify Owner on Blocked Status"
                    className="w-full px-6 py-4 bg-[#f7f8f9] border border-[#e3e8ee] rounded-2xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-bold text-lg"
                  />
                </div>

                <div className="grid grid-cols-2 gap-12">
                  <div className="space-y-6">
                    <div className="flex items-center gap-3 text-sm font-black text-[#1a1f36] uppercase tracking-widest">
                      <div className="w-8 h-8 rounded-full bg-[#6366f1]/10 flex items-center justify-center text-[#6366f1]">1</div>
                      Trigger Event
                    </div>
                    <div className="space-y-4">
                      <select 
                        value={triggerType}
                        onChange={(e) => setTriggerType(e.target.value as TriggerType)}
                        className="w-full p-4 bg-white border border-[#e3e8ee] rounded-2xl font-bold text-sm shadow-sm"
                      >
                        <option value="status_change">When status changes to...</option>
                        <option value="date_approaching">When due date is near...</option>
                      </select>
                      
                      {triggerType === 'status_change' ? (
                        <div className="p-4 bg-[#f0f4ff] rounded-2xl border border-[#6366f1]/10">
                           <label className="text-[10px] font-bold text-[#6366f1] uppercase block mb-2">Target Status</label>
                           <select 
                            value={statusValue}
                            onChange={(e) => setStatusValue(e.target.value)}
                            className="w-full p-3 bg-white border border-[#6366f1]/20 rounded-xl font-bold text-sm text-[#6366f1]"
                          >
                            {statuses.map(s => <option key={s} value={s}>{s}</option>)}
                          </select>
                        </div>
                      ) : (
                        <div className="p-4 bg-[#f0f4ff] rounded-2xl border border-[#6366f1]/10 flex items-center gap-4">
                           <input 
                             type="number" 
                             min="1" 
                             max="30"
                             value={daysBefore}
                             onChange={(e) => setDaysBefore(parseInt(e.target.value))}
                             className="w-20 p-3 bg-white border border-[#6366f1]/20 rounded-xl font-bold text-sm text-[#6366f1]"
                           />
                           <span className="text-sm font-bold text-[#4f566b]">days before deadline</span>
                        </div>
                      )}
                    </div>
                  </div>

                  <div className="space-y-6">
                    <div className="flex items-center gap-3 text-sm font-black text-[#1a1f36] uppercase tracking-widest">
                      <div className="w-8 h-8 rounded-full bg-[#6366f1]/10 flex items-center justify-center text-[#6366f1]">2</div>
                      Resulting Action
                    </div>
                    <div className="space-y-4">
                      <div className="flex items-center gap-3 p-4 bg-[#f7f8f9] rounded-2xl border border-[#e3e8ee]">
                        <Bell className="w-5 h-5 text-[#a3acb9]" />
                        <span className="font-bold text-[#1a1f36]">Send Notification</span>
                      </div>
                      
                      <div className="grid grid-cols-2 gap-3">
                          <button 
                              onClick={() => setChannel('in_app')}
                              className={`flex flex-col items-center gap-2 p-5 rounded-2xl border font-bold text-sm transition-all ${
                                  channel === 'in_app' ? 'bg-[#6366f1] text-white border-[#6366f1] shadow-xl shadow-[#6366f1]/20' : 'bg-white text-[#697386] border-[#e3e8ee] hover:border-[#6366f1]'
                              }`}
                          >
                              <Bell className="w-6 h-6" />
                              In-App
                          </button>
                          <button 
                              onClick={() => setChannel('email')}
                              className={`flex flex-col items-center gap-2 p-5 rounded-2xl border font-bold text-sm transition-all ${
                                  channel === 'email' ? 'bg-[#6366f1] text-white border-[#6366f1] shadow-xl shadow-[#6366f1]/20' : 'bg-white text-[#697386] border-[#e3e8ee] hover:border-[#6366f1]'
                              }`}
                          >
                              <Mail className="w-6 h-6" />
                              Email
                          </button>
                      </div>

                      <select 
                        value={recipient}
                        onChange={(e) => setRecipient(e.target.value as 'owner' | 'all')}
                        className="w-full p-4 bg-white border border-[#e3e8ee] rounded-2xl font-bold text-sm shadow-sm"
                      >
                        <option value="owner">Recipient: Task Assignee</option>
                        <option value="all">Recipient: All Project Members</option>
                      </select>
                    </div>
                  </div>
                </div>

                <div className="pt-10 flex gap-6 border-t border-[#f0f2f5]">
                  <button 
                    onClick={() => setIsBuilding(false)}
                    className="flex-1 py-4 border border-[#e3e8ee] rounded-2xl font-bold text-[#697386] hover:bg-[#f7f8f9] transition-all"
                  >
                    Discard Draft
                  </button>
                  <button 
                    onClick={handleCreate}
                    disabled={!name.trim()}
                    className="flex-[2] py-4 stripe-gradient text-white font-extrabold rounded-2xl shadow-xl hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50"
                  >
                    Deploy Automation Rule
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <div className="space-y-8">
              {rules.length === 0 ? (
                <div className="py-40 bg-white rounded-[32px] border border-[#e3e8ee] flex flex-col items-center justify-center text-center">
                  <div className="w-24 h-24 bg-[#f7f8f9] rounded-full flex items-center justify-center mb-8">
                    <Zap className="w-10 h-10 text-[#a3acb9]" />
                  </div>
                  <h3 className="text-xl font-bold text-[#1a1f36]">No automation rules active</h3>
                  <p className="text-[#697386] mt-2 max-w-md">Automations help your team stay synchronized by handling repetitive notification tasks automatically.</p>
                  <button 
                    onClick={() => setIsBuilding(true)}
                    className="mt-8 px-8 py-3 bg-[#6366f1] text-white rounded-xl font-bold shadow-lg"
                  >
                    Create your first rule
                  </button>
                </div>
              ) : (
                <div className="grid grid-cols-1 gap-6">
                  {rules.map(rule => (
                    <div key={rule.id} className={`p-8 bg-white border rounded-[32px] transition-all flex items-center justify-between group shadow-sm ${rule.enabled ? 'border-[#6366f1]/10' : 'border-[#e3e8ee] grayscale opacity-60'}`}>
                      <div className="flex items-center gap-8">
                         <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shadow-inner ${rule.enabled ? 'bg-[#6366f1] text-white' : 'bg-[#e3e8ee] text-[#a3acb9]'}`}>
                            {rule.action.channel === 'email' ? <Mail className="w-7 h-7" /> : <Bell className="w-7 h-7" />}
                         </div>
                         <div>
                            <h5 className="font-bold text-[#1a1f36] text-lg">{rule.name}</h5>
                            <div className="flex items-center gap-4 mt-2 text-xs font-bold text-[#697386] uppercase tracking-widest">
                               <span className="flex items-center gap-2 bg-[#f7f8f9] px-3 py-1 rounded-full"><Zap className="w-3.5 h-3.5" /> {rule.trigger.type.replace('_', ' ')}</span>
                               <ArrowRight className="w-4 h-4 text-[#e3e8ee]" />
                               <span className="flex items-center gap-2 bg-[#f7f8f9] px-3 py-1 rounded-full"><Bell className="w-3.5 h-3.5" /> {rule.action.channel.replace('_', ' ')}</span>
                            </div>
                         </div>
                      </div>

                      <div className="flex items-center gap-4">
                        <button 
                          onClick={() => onUpdate(rule.id, { enabled: !rule.enabled })}
                          className="p-2 transition-transform hover:scale-110"
                        >
                          {rule.enabled ? <ToggleRight className="w-10 h-10 text-[#00ca72]" /> : <ToggleLeft className="w-10 h-10 text-[#a3acb9]" />}
                        </button>
                        <button 
                          onClick={() => onDelete(rule.id)}
                          className="p-3 text-[#a3acb9] hover:text-[#ff4d4d] hover:bg-[#ffebed] rounded-xl opacity-0 group-hover:opacity-100 transition-all"
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AutomationsPage;
