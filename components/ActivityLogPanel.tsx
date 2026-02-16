
import React from 'react';
import { Clock, Edit3, PlusCircle, Trash2, UserPlus, Sparkles, FilePlus } from 'lucide-react';
import { ActivityEntry } from '../types';

interface ActivityLogPageProps {
  logs: ActivityEntry[];
  entityName: string;
  filterRowId?: string | null;
}

const ActivityLogPage: React.FC<ActivityLogPageProps> = ({
  logs,
  entityName,
  filterRowId
}) => {
  const filteredLogs = filterRowId 
    ? logs.filter(log => log.rowId === filterRowId) 
    : logs;

  const getActionIcon = (action: string) => {
    const a = action.toLowerCase();
    if (a.includes('updated') || a.includes('changed')) return <Edit3 className="w-3.5 h-3.5" />;
    if (a.includes('added') || a.includes('created')) return <PlusCircle className="w-3.5 h-3.5 text-[#00ca72]" />;
    if (a.includes('removed') || a.includes('deleted')) return <Trash2 className="w-3.5 h-3.5 text-[#ff4d4d]" />;
    if (a.includes('invited')) return <UserPlus className="w-3.5 h-3.5 text-[#6366f1]" />;
    if (a.includes('ai')) return <Sparkles className="w-3.5 h-3.5 text-[#a855f7]" />;
    if (a.includes('sheet')) return <FilePlus className="w-3.5 h-3.5" />;
    return <Clock className="w-3.5 h-3.5" />;
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#f7f8f9] overflow-hidden animate-in fade-in duration-300">
      <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-white shrink-0">
        <div>
          <h2 className="text-2xl font-bold text-[#1a1f36] flex items-center gap-3">
            <Clock className="w-6 h-6 text-[#6366f1]" />
            {filterRowId ? 'Row History' : 'Activity History'}
          </h2>
          <p className="text-sm text-[#697386] font-medium mt-1">
            {filterRowId ? `Audit trail for a specific record` : `Complete activity log for ${entityName}`}
          </p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-10 custom-scrollbar">
        <div className="max-w-4xl mx-auto bg-white rounded-3xl border border-[#e3e8ee] p-10 shadow-sm">
          {filteredLogs.length === 0 ? (
            <div className="py-20 flex flex-col items-center justify-center text-center opacity-40">
              <div className="w-20 h-20 bg-[#f7f8f9] rounded-full flex items-center justify-center mb-6">
                <Clock className="w-10 h-10 text-[#a3acb9]" />
              </div>
              <p className="text-lg font-bold text-[#4f566b]">No activity recorded yet.</p>
              <p className="text-sm text-[#697386] mt-2">Every action taken by your team will appear here.</p>
            </div>
          ) : (
            <div className="space-y-10 relative before:absolute before:left-[17px] before:top-2 before:bottom-2 before:w-px before:bg-[#e3e8ee]">
              {[...filteredLogs].reverse().map((log) => (
                <div key={log.id} className="relative pl-12 group">
                  <div className="absolute left-0 top-1 w-9 h-9 rounded-full bg-white border border-[#e3e8ee] flex items-center justify-center shadow-sm z-10 text-[#697386] group-hover:border-[#6366f1] group-hover:text-[#6366f1] transition-all">
                    {getActionIcon(log.action)}
                  </div>
                  <div>
                    <div className="flex items-center gap-3 mb-1.5">
                      <span className="text-[15px] font-bold text-[#1a1f36]">{log.userName}</span>
                      <span className="text-[11px] font-bold text-[#a3acb9] uppercase tracking-wider bg-[#f7f8f9] px-2 py-0.5 rounded">
                        {new Date(log.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </span>
                    </div>
                    <p className="text-[14px] text-[#4f566b] font-medium leading-relaxed">
                      {log.action}
                    </p>
                    {log.details && (
                      <div className="mt-2.5 p-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl text-xs font-mono text-[#697386] break-words shadow-inner">
                        {log.details}
                      </div>
                    )}
                    <div className="text-[11px] text-[#a3acb9] font-bold mt-2 uppercase tracking-tight">
                      {new Date(log.timestamp).toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ActivityLogPage;
