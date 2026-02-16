
import React, { useState, useMemo } from 'react';
import { RowData, Role } from '../types';
import { 
  ChevronLeft, 
  ChevronRight, 
  MessageSquare, 
  MoreHorizontal,
  Plus,
  Trash2
} from 'lucide-react';

interface CalendarViewProps {
  rows: RowData[];
  onUpdateCell: (rowId: string, colId: string, value: any) => void;
  userRole: Role;
  onOpenComments: (rowId: string) => void;
  onAddRow: (initialData?: Partial<RowData>) => void;
  onDeleteRow: (rowId: string) => void;
}

const CalendarView: React.FC<CalendarViewProps> = ({ rows, onUpdateCell, userRole, onOpenComments, onAddRow, onDeleteRow }) => {
  const [currentDate, setCurrentDate] = useState(new Date());
  const canEdit = userRole !== 'Viewer';

  const monthYear = useMemo(() => {
    return currentDate.toLocaleString('default', { month: 'long', year: 'numeric' });
  }, [currentDate]);

  const daysInMonth = useMemo(() => {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const firstDay = new Date(year, month, 1).getDay();
    const lastDate = new Date(year, month + 1, 0).getDate();
    
    const days = [];
    
    // Fill previous month days
    const prevMonthLastDate = new Date(year, month, 0).getDate();
    for (let i = firstDay - 1; i >= 0; i--) {
      days.push({
        date: new Date(year, month - 1, prevMonthLastDate - i),
        isCurrentMonth: false
      });
    }
    
    // Fill current month days
    for (let i = 1; i <= lastDate; i++) {
      days.push({
        date: new Date(year, month, i),
        isCurrentMonth: true
      });
    }
    
    // Fill next month days
    const remaining = 42 - days.length; // Ensure 6 rows
    for (let i = 1; i <= remaining; i++) {
      days.push({
        date: new Date(year, month + 1, i),
        isCurrentMonth: false
      });
    }
    
    return days;
  }, [currentDate]);

  const tasksByDate = useMemo(() => {
    const map: Record<string, RowData[]> = {};
    rows.forEach(row => {
      // Calendar shows tasks based on "To Date" (dueDate)
      if (row.dueDate) {
        const dateStr = new Date(String(row.dueDate)).toDateString();
        if (!map[dateStr]) map[dateStr] = [];
        map[dateStr].push(row);
      }
    });
    return map;
  }, [rows]);

  const handlePrevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const handleNextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const handleToday = () => {
    setCurrentDate(new Date());
  };

  const handleDragStart = (e: React.DragEvent, rowId: string) => {
    if (!canEdit) {
      e.preventDefault();
      return;
    }
    e.dataTransfer.setData('text/rowId', rowId);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
  };

  const handleDrop = (e: React.DragEvent, targetDate: Date) => {
    e.preventDefault();
    const rowId = e.dataTransfer.getData('text/rowId');
    if (rowId && canEdit) {
      const dateStr = targetDate.toISOString().split('T')[0];
      onUpdateCell(rowId, 'dueDate', dateStr);
    }
  };

  const handleQuickAdd = (e: React.MouseEvent, date: Date) => {
    e.stopPropagation();
    if (!canEdit) return;
    const dateStr = date.toISOString().split('T')[0];
    onAddRow({ dueDate: dateStr, startDate: dateStr });
  };

  return (
    <div className="flex-1 flex flex-col bg-white overflow-hidden select-none h-full min-h-full">
      {/* Calendar Header */}
      <div className="h-16 border-b border-[#e3e8ee] bg-white flex items-center justify-between px-8 shrink-0">
        <div className="flex items-center gap-6">
          <h2 className="text-xl font-extrabold text-[#1a1f36] tracking-tight">{monthYear}</h2>
          <div className="flex items-center bg-[#f7f8f9] border border-[#e3e8ee] rounded-lg overflow-hidden shadow-sm">
            <button 
              onClick={handlePrevMonth}
              className="p-2 hover:bg-[#ecedf0] transition-colors border-r border-[#e3e8ee]"
            >
              <ChevronLeft className="w-4 h-4 text-[#697386]" />
            </button>
            <button 
              onClick={handleToday}
              className="px-4 py-2 text-[12px] font-bold text-[#1a1f36] hover:bg-[#ecedf0] transition-colors"
            >
              Today
            </button>
            <button 
              onClick={handleNextMonth}
              className="p-2 hover:bg-[#ecedf0] transition-colors border-l border-[#e3e8ee]"
            >
              <ChevronRight className="w-4 h-4 text-[#697386]" />
            </button>
          </div>
        </div>

        <div className="flex items-center gap-2">
            <div className="flex items-center bg-[#f7f8f9] p-1 rounded-lg border border-[#e3e8ee]">
                <button className="px-4 py-1.5 bg-white shadow-sm rounded-md text-[12px] font-bold text-[#6366f1]">Month</button>
                <button className="px-4 py-1.5 text-[12px] font-bold text-[#697386] hover:text-[#1a1f36] transition-colors">Week</button>
            </div>
        </div>
      </div>

      {/* Week Day Labels */}
      <div className="grid grid-cols-7 border-b border-[#e3e8ee] bg-[#fbfcfd]">
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
          <div key={day} className="py-3 text-center text-[11px] font-bold text-[#697386] uppercase tracking-[0.1em]">
            {day}
          </div>
        ))}
      </div>

      {/* Calendar Grid */}
      <div className="flex-1 overflow-auto custom-scrollbar">
        <div className="grid grid-cols-7 grid-rows-6 h-full min-h-[600px]">
          {daysInMonth.map((day, i) => {
            const dateStr = day.date.toDateString();
            const isToday = new Date().toDateString() === dateStr;
            const tasks = tasksByDate[dateStr] || [];

            return (
              <div 
                key={i} 
                onDragOver={handleDragOver}
                onDrop={(e) => handleDrop(e, day.date)}
                className={`min-h-[140px] border-r border-b border-[#f0f2f5] p-3 flex flex-col gap-1 transition-colors relative group ${
                  day.isCurrentMonth ? 'bg-white' : 'bg-[#fbfcfd]'
                } ${isToday ? 'ring-2 ring-[#6366f1] ring-inset z-10' : ''}`}
              >
                <div className="flex items-center justify-between mb-2">
                  <span className={`text-[13px] font-bold ${
                    isToday ? 'text-[#6366f1] bg-[#f0f4ff] w-7 h-7 flex items-center justify-center rounded-full' : 
                    day.isCurrentMonth ? 'text-[#1a1f36]' : 'text-[#a3acb9]'
                  }`}>
                    {day.date.getDate()}
                  </span>
                  
                  {canEdit && (
                    <button 
                      onClick={(e) => handleQuickAdd(e, day.date)}
                      className="p-1 hover:bg-[#f0f4ff] text-[#a3acb9] hover:text-[#6366f1] rounded transition-all opacity-0 group-hover:opacity-100"
                      title="Quick Add Task"
                    >
                      <Plus className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>

                <div className="flex flex-col gap-1.5 flex-1 overflow-y-auto custom-scrollbar pr-0.5">
                  {tasks.map(task => {
                    const statusColors: any = {
                        'Done': 'bg-[#e6fff4] text-[#008a52] border-[#b3f5d8] decoration-[#00ca72]',
                        'In Progress': 'bg-[#f0f4ff] text-[#0055ff] border-[#d1dfff] decoration-[#6366f1]',
                        'To Do': 'bg-white text-[#4f566b] border-[#e3e8ee] decoration-[#a3acb9]',
                        'Blocked': 'bg-[#fff0f0] text-[#ff4d4d] border-[#ffd1d1] decoration-[#ff4d4d]'
                    };

                    return (
                      <div 
                        key={task.id}
                        draggable={canEdit}
                        onDragStart={(e) => handleDragStart(e, task.id)}
                        onClick={() => onOpenComments(task.id)}
                        className={`group/item px-2.5 py-2 rounded-lg border text-[11px] font-bold shadow-sm transition-all cursor-pointer hover:shadow-md hover:scale-[1.02] flex flex-col gap-1 ${
                          statusColors[String(task.status)] || 'bg-white text-gray-700'
                        }`}
                      >
                        <div className="flex items-center justify-between gap-2">
                            <span className={`truncate flex-1 ${task.status === 'Done' ? 'line-through opacity-60' : ''}`}>
                                {String(task.task || 'Untitled')}
                            </span>
                            <div className="flex items-center gap-1 opacity-0 group-hover/item:opacity-100 transition-opacity shrink-0">
                                {canEdit && (
                                  <button 
                                    onClick={(e) => { e.stopPropagation(); onDeleteRow(task.id); }}
                                    className="p-0.5 hover:bg-black/5 rounded text-[#a3acb9] hover:text-red-500"
                                    title="Delete"
                                  >
                                    <Trash2 className="w-2.5 h-2.5" />
                                  </button>
                                )}
                                <MessageSquare className="w-2.5 h-2.5" />
                            </div>
                        </div>
                        
                        <div className="flex items-center justify-between mt-1">
                          {Number(task.progress) > 0 && (
                              <div className="flex-1 h-0.5 bg-black/5 rounded-full overflow-hidden mr-2">
                                  <div 
                                      className="h-full bg-current opacity-40 transition-all duration-500" 
                                      style={{ width: `${task.progress}%` }}
                                  />
                              </div>
                          )}
                          <div className="w-4 h-4 rounded-full bg-white/50 border border-black/5 flex items-center justify-center text-[7px] font-black shrink-0">
                            {String(task.owner || '?').charAt(0)}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default CalendarView;
