
import React, { useState } from 'react';
import { RowData, Column, Role } from '../types';
import { MoreHorizontal, Plus, Calendar, User, MessageSquare, Clock, Paperclip, Trash2 } from 'lucide-react';

interface KanbanBoardProps {
  rows: RowData[];
  columns: Column[];
  onUpdateCell: (rowId: string, colId: string, value: any) => void;
  onAddRow: (initialData?: Partial<RowData>) => void;
  onDeleteRow: (rowId: string) => void;
  userRole: Role;
  onOpenComments: (rowId: string) => void;
  onOpenRowActivity: (rowId: string) => void;
}

const KanbanBoard: React.FC<KanbanBoardProps> = ({ 
  rows, 
  columns, 
  onUpdateCell, 
  onAddRow, 
  onDeleteRow,
  userRole,
  onOpenComments,
  onOpenRowActivity
}) => {
  const [draggedRowId, setDraggedRowId] = useState<string | null>(null);
  const [activeDropStatus, setActiveDropStatus] = useState<string | null>(null);

  const statusCol = columns.find(c => c.id === 'status');
  const statuses = statusCol?.options || ['To Do', 'In Progress', 'Done', 'Blocked'];
  const canEdit = userRole !== 'Viewer';

  const handleDragStart = (e: React.DragEvent, rowId: string) => {
    if (!canEdit) {
      e.preventDefault();
      return;
    }
    setDraggedRowId(rowId);
    e.dataTransfer.setData('text/plain', rowId);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: React.DragEvent, status: string) => {
    e.preventDefault();
    if (activeDropStatus !== status) {
      setActiveDropStatus(status);
    }
  };

  const handleDrop = (e: React.DragEvent, status: string) => {
    e.preventDefault();
    const rowId = e.dataTransfer.getData('text/plain');
    if (rowId) {
      onUpdateCell(rowId, 'status', status);
    }
    setDraggedRowId(null);
    setActiveDropStatus(null);
  };

  const handleDragEnd = () => {
    setDraggedRowId(null);
    setActiveDropStatus(null);
  };

  return (
    <div className="flex-1 bg-[#f7f8f9] p-6 overflow-x-auto flex gap-6 custom-scrollbar select-none h-full min-h-full">
      {statuses.map(status => {
        const filteredRows = rows.filter(r => r.status === status);
        const isDraggingOver = activeDropStatus === status;

        return (
          <div 
            key={status} 
            className={`w-[320px] shrink-0 flex flex-col gap-4 rounded-xl transition-all duration-200 h-full ${
              isDraggingOver ? 'bg-[#6366f1]/5 ring-2 ring-[#6366f1] ring-inset' : ''
            }`}
            onDragOver={(e) => handleDragOver(e, status)}
            onDrop={(e) => handleDrop(e, status)}
            onDragLeave={() => setActiveDropStatus(null)}
          >
            <div className="flex items-center justify-between px-2 mb-1 shrink-0">
              <div className="flex items-center gap-3">
                <h3 className="font-bold text-[#1a1f36] text-[13px] uppercase tracking-wider">{status}</h3>
                <span className="px-2 py-0.5 bg-[#e3e8ee] text-[#4f566b] rounded-full text-[10px] font-black">
                  {filteredRows.length}
                </span>
              </div>
              <button className="p-1.5 hover:bg-[#ecedf0] rounded-md transition-colors text-[#a3acb9] hover:text-[#1a1f36]">
                <MoreHorizontal className="w-4 h-4" />
              </button>
            </div>

            <div className="flex flex-col gap-3 flex-1 overflow-y-auto custom-scrollbar pr-1 pb-10">
              {filteredRows.map(row => {
                const commentCount = row.comments?.length || 0;
                const attachmentCount = row.attachments?.length || 0;
                const isBeingDragged = draggedRowId === row.id;

                return (
                  <div 
                    key={row.id} 
                    draggable={canEdit}
                    onDragStart={(e) => handleDragStart(e, row.id)}
                    onDragEnd={handleDragEnd}
                    className={`bg-white p-4 rounded-xl border border-[#e3e8ee] shadow-sm hover:shadow-md hover:border-[#6366f1]/30 transition-all cursor-grab active:cursor-grabbing group relative shrink-0 ${
                      isBeingDragged ? 'opacity-40 scale-95 border-dashed grayscale' : ''
                    }`}
                  >
                    <div className="flex items-start justify-between mb-3">
                      <span className={`text-[9px] font-black px-1.5 py-0.5 rounded uppercase tracking-wider border ${
                        row.priority === 'High' ? 'bg-[#ffebed] text-[#ff4d4d] border-[#ffd1d1]' :
                        row.priority === 'Medium' ? 'bg-[#fff4e6] text-[#ff9900] border-[#ffe8cc]' :
                        'bg-[#f0f4ff] text-[#6366f1] border-[#d1dfff]'
                      }`}>
                        {String(row.priority)}
                      </span>
                      
                      <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button 
                          onClick={(e) => { e.stopPropagation(); onOpenRowActivity(row.id); }}
                          title="Row History"
                          className="p-1 hover:bg-[#f7f8f9] rounded transition-colors text-[#a3acb9] hover:text-[#6366f1]"
                        >
                          <Clock className="w-3.5 h-3.5" />
                        </button>
                        <button 
                          onClick={(e) => { e.stopPropagation(); onOpenComments(row.id); }}
                          title="Comments & Files"
                          className="p-1 hover:bg-[#f7f8f9] rounded transition-colors text-[#a3acb9] hover:text-[#6366f1] relative"
                        >
                          <MessageSquare className="w-3.5 h-3.5" />
                          {commentCount > 0 && (
                            <span className="absolute -top-1 -right-1 bg-[#6366f1] text-white text-[7px] font-bold w-3 h-3 rounded-full flex items-center justify-center border border-white">
                              {commentCount}
                            </span>
                          )}
                        </button>
                        {canEdit && (
                          <button 
                            onClick={(e) => { e.stopPropagation(); onDeleteRow(row.id); }}
                            title="Delete Task"
                            className="p-1 hover:bg-red-50 rounded transition-colors text-[#a3acb9] hover:text-red-500"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        )}
                      </div>
                    </div>
                    
                    <h4 className="font-bold text-[#1a1f36] mb-4 text-[14px] leading-snug group-hover:text-[#6366f1] transition-colors">
                      {String(row.task || 'Untitled Task')}
                    </h4>
                    
                    <div className="space-y-3">
                      <div className="w-full bg-[#f7f8f9] h-1 rounded-full overflow-hidden">
                        <div 
                          className={`h-full transition-all duration-500 ${Number(row.progress) === 100 ? 'bg-[#00ca72]' : 'bg-[#6366f1]'}`} 
                          style={{ width: `${row.progress}%` }}
                        ></div>
                      </div>

                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-1.5 text-[11px] font-bold text-[#697386]">
                          <Calendar className="w-3.5 h-3.5 text-[#a3acb9]" />
                          {String(row.dueDate)}
                        </div>
                        <div className="flex items-center gap-2">
                           {attachmentCount > 0 && (
                             <div className="flex items-center gap-1 text-[10px] font-bold text-[#a3acb9]">
                               <Paperclip className="w-3.5 h-3.5" />
                               {attachmentCount}
                             </div>
                           )}
                           <div className="w-6 h-6 rounded-full bg-[#f0f4ff] border border-[#d1dfff] flex items-center justify-center text-[#6366f1] text-[10px] font-black shadow-sm">
                             {String(row.owner).charAt(0) || '?'}
                           </div>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
              
              {canEdit && (
                <button 
                  onClick={() => onAddRow({ status: status })}
                  className="flex items-center justify-center gap-2 py-3 border-2 border-dashed border-[#e3e8ee] rounded-xl text-[12px] font-black text-[#a3acb9] uppercase tracking-widest hover:border-[#6366f1] hover:text-[#6366f1] hover:bg-white transition-all mt-1 shrink-0"
                >
                  <Plus className="w-3.5 h-3.5" />
                  Add Task
                </button>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default KanbanBoard;
