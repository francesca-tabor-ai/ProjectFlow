
import React from 'react';
import { X, Bell, Info, AlertTriangle, CheckCircle2 } from 'lucide-react';
import { AppNotification } from '../types';

interface NotificationStackProps {
  notifications: AppNotification[];
  onRemove: (id: string) => void;
}

const NotificationStack: React.FC<NotificationStackProps> = ({ notifications, onRemove }) => {
  return (
    <div className="fixed top-6 right-6 z-[200] flex flex-col gap-3 w-80 pointer-events-none">
      {notifications.map((notif) => (
        <div 
          key={notif.id}
          className="pointer-events-auto bg-white border border-[#e3e8ee] rounded-2xl shadow-[0_8px_32px_rgba(0,0,0,0.12)] p-4 flex gap-4 animate-in slide-in-from-right duration-500 overflow-hidden relative group"
        >
          {/* Progress Bar (Auto-dismiss hint) */}
          <div className="absolute bottom-0 left-0 h-1 bg-[#6366f1]/20 w-full">
            <div className="h-full bg-[#6366f1] animate-out fade-out duration-[5000ms] ease-linear w-full"></div>
          </div>

          <div className={`w-10 h-10 shrink-0 rounded-xl flex items-center justify-center ${
            notif.type === 'success' ? 'bg-[#00ca72]/10 text-[#00ca72]' :
            notif.type === 'warning' ? 'bg-[#ff9900]/10 text-[#ff9900]' :
            'bg-[#6366f1]/10 text-[#6366f1]'
          }`}>
            {notif.type === 'success' ? <CheckCircle2 className="w-5 h-5" /> :
             notif.type === 'warning' ? <AlertTriangle className="w-5 h-5" /> :
             <Bell className="w-5 h-5" />}
          </div>

          <div className="flex-1 min-w-0 pr-6">
            <h4 className="text-[14px] font-extrabold text-[#1a1f36] truncate">{notif.title}</h4>
            <p className="text-[13px] font-medium text-[#4f566b] mt-0.5 leading-tight">{notif.message}</p>
          </div>

          <button 
            onClick={() => onRemove(notif.id)}
            className="absolute top-2 right-2 p-1 text-[#a3acb9] hover:text-[#1a1f36] hover:bg-[#f7f8f9] rounded-lg transition-all opacity-0 group-hover:opacity-100"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      ))}
    </div>
  );
};

export default NotificationStack;
