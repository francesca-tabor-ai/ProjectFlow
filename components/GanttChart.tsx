
import React, { useState, useMemo, useRef, useEffect } from 'react';
import { RowData, Role } from '../types';
import { 
  ChevronLeft, 
  ChevronRight, 
  Link2, 
  Link2Off, 
  Settings2,
  CalendarDays,
  MousePointer2,
  Plus,
  Trash2
} from 'lucide-react';

interface GanttChartProps {
  rows: RowData[];
  userRole: Role;
  onUpdateCell: (rowId: string, columnId: string, value: any) => void;
  onAddRow: (initialData?: Partial<RowData>) => void;
  onDeleteRow: (rowId: string) => void;
  onUpdateRows?: (updates: Record<string, Partial<RowData>>) => void;
}

const DAY_WIDTH = 48;
const ROW_HEIGHT = 48;
const HEADER_HEIGHT = 80;
const TASK_BAR_HEIGHT = 28;

const GanttChart: React.FC<GanttChartProps> = ({ rows, userRole, onUpdateCell, onAddRow, onDeleteRow, onUpdateRows }) => {
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const sidebarContainerRef = useRef<HTMLDivElement>(null);
  const [dependencySource, setDependencySource] = useState<string | null>(null);
  const [containerHeight, setContainerHeight] = useState(0);

  const [dragState, setDragState] = useState<{
    rowId: string;
    type: 'move' | 'resize-left' | 'resize-right';
    startX: number;
    initialStart: number;
    initialEnd: number;
  } | null>(null);

  const canEdit = userRole !== 'Viewer';

  useEffect(() => {
    const updateSize = () => {
      if (scrollContainerRef.current) {
        setContainerHeight(scrollContainerRef.current.clientHeight);
      }
    };
    updateSize();
    window.addEventListener('resize', updateSize);
    return () => window.removeEventListener('resize', updateSize);
  }, []);

  // Extract tasks with valid dates
  const tasks = useMemo(() => rows.filter(r => r.startDate && r.dueDate), [rows]);

  // Calculate global time range
  const dateInfo = useMemo(() => {
    if (tasks.length === 0) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const end = new Date(today);
      end.setDate(today.getDate() + 30);
      return { min: today, max: end };
    }

    const startTimes = tasks.map(t => new Date(String(t.startDate)).getTime());
    const endTimes = tasks.map(t => new Date(String(t.dueDate)).getTime());
    
    let min = new Date(Math.min(...startTimes));
    let max = new Date(Math.max(...endTimes));

    // Pad by a week
    min.setDate(min.getDate() - 7);
    max.setDate(max.getDate() + 14);
    
    min.setHours(0, 0, 0, 0);
    max.setHours(0, 0, 0, 0);

    return { min, max };
  }, [tasks]);

  const totalDays = useMemo(() => {
    return Math.ceil((dateInfo.max.getTime() - dateInfo.min.getTime()) / (1000 * 60 * 60 * 24)) + 1;
  }, [dateInfo]);

  const timelineDays = useMemo(() => {
    return Array.from({ length: totalDays }, (_, i) => {
      const d = new Date(dateInfo.min);
      d.setDate(d.getDate() + i);
      return d;
    });
  }, [totalDays, dateInfo]);

  const getX = (dateStr: string) => {
    const d = new Date(dateStr);
    d.setHours(0, 0, 0, 0);
    const diff = d.getTime() - dateInfo.min.getTime();
    return (diff / (1000 * 60 * 60 * 24)) * DAY_WIDTH;
  };

  const getDateFromX = (x: number) => {
    const days = Math.round(x / DAY_WIDTH);
    const d = new Date(dateInfo.min);
    d.setDate(d.getDate() + days);
    return d.toISOString().split('T')[0];
  };

  // Drag handlers
  const handleMouseDown = (e: React.MouseEvent, rowId: string, type: 'move' | 'resize-left' | 'resize-right') => {
    if (!canEdit) return;
    e.stopPropagation();
    const task = tasks.find(t => t.id === rowId);
    if (!task) return;

    setDragState({
      rowId,
      type,
      startX: e.clientX,
      initialStart: getX(String(task.startDate)),
      initialEnd: getX(String(task.dueDate))
    });
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!dragState) return;

      const diffX = e.clientX - dragState.startX;
      const snapDiffX = Math.round(diffX / DAY_WIDTH) * DAY_WIDTH;

      const task = tasks.find(t => t.id === dragState.rowId);
      if (!task) return;

      let newStart = dragState.initialStart;
      let newEnd = dragState.initialEnd;

      if (dragState.type === 'move') {
        newStart += snapDiffX;
        newEnd += snapDiffX;
      } else if (dragState.type === 'resize-left') {
        newStart = Math.min(dragState.initialStart + snapDiffX, dragState.initialEnd - DAY_WIDTH);
      } else if (dragState.type === 'resize-right') {
        newEnd = Math.max(dragState.initialEnd + snapDiffX, dragState.initialStart + DAY_WIDTH);
      }

      const startStr = getDateFromX(newStart);
      const endStr = getDateFromX(newEnd);

      if (startStr !== String(task.startDate)) onUpdateCell(dragState.rowId, 'startDate', startStr);
      if (endStr !== String(task.dueDate)) onUpdateCell(dragState.rowId, 'dueDate', endStr);
    };

    const handleMouseUp = () => setDragState(null);

    if (dragState) {
      window.addEventListener('mousemove', handleMouseMove);
      window.addEventListener('mouseup', handleMouseUp);
    }
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [dragState, tasks, onUpdateCell]);

  const handleTaskClick = (rowId: string) => {
    if (dependencySource === rowId) {
      setDependencySource(null);
      return;
    }

    if (dependencySource) {
      const targetTask = rows.find(r => r.id === rowId);
      const deps = (targetTask?.dependencies as string[]) || [];
      if (!deps.includes(dependencySource)) {
        onUpdateCell(rowId, 'dependencies', [...deps, dependencySource]);
      }
      setDependencySource(null);
    }
  };

  const renderDependencyLines = () => {
    return tasks.flatMap((task, idx) => {
      const deps = (task.dependencies as string[]) || [];
      return deps.map(depId => {
        const depTask = tasks.find(t => t.id === depId);
        if (!depTask) return null;

        const depIdx = tasks.indexOf(depTask);
        const fromX = getX(String(depTask.dueDate)) + DAY_WIDTH;
        const fromY = depIdx * ROW_HEIGHT + ROW_HEIGHT / 2;
        const toX = getX(String(task.startDate));
        const toY = idx * ROW_HEIGHT + ROW_HEIGHT / 2;

        // Draw an orthogonal path
        const midX = fromX + (toX - fromX) / 2;
        
        return (
          <g key={`${depId}-${task.id}`} className="pointer-events-none">
            <path
              d={`M ${fromX} ${fromY} L ${midX} ${fromY} L ${midX} ${toY} L ${toX} ${toY}`}
              fill="none"
              stroke="#cbd5e1"
              strokeWidth="2"
              markerEnd="url(#arrowhead)"
            />
          </g>
        );
      });
    });
  };

  // Sync scroll between sidebar and timeline
  const handleTimelineScroll = (e: React.UIEvent<HTMLDivElement>) => {
    if (sidebarContainerRef.current) {
      sidebarContainerRef.current.scrollTop = e.currentTarget.scrollTop;
    }
  };

  // Logic to fill the page with empty rows
  const minRowsToFill = Math.ceil(containerHeight / ROW_HEIGHT);
  const totalRowsToRender = Math.max(tasks.length + (canEdit ? 1 : 0) + 5, minRowsToFill);

  const renderSidebarRow = (idx: number) => {
    if (idx < tasks.length) {
      const row = tasks[idx];
      return (
        <div 
          key={row.id} 
          className={`group h-[48px] px-5 border-b border-[#f0f2f5] flex items-center text-[13px] font-medium transition-colors ${
              dependencySource === row.id ? 'bg-[#f0f4ff] text-[#6366f1]' : 'text-[#4f566b] hover:bg-[#f7f8f9]'
          }`}
          onClick={() => handleTaskClick(row.id)}
        >
          <div className="truncate flex-1">{String(row.task || 'Untitled Task')}</div>
          {canEdit && (
            <button 
              onClick={(e) => { e.stopPropagation(); onDeleteRow(row.id); }}
              className="p-1.5 opacity-0 group-hover:opacity-100 hover:bg-red-50 text-[#a3acb9] hover:text-red-500 rounded transition-all"
            >
              <Trash2 className="w-3.5 h-3.5" />
            </button>
          )}
          {dependencySource && (
              <MousePointer2 className="w-3.5 h-3.5 opacity-40 animate-pulse ml-1" />
          )}
        </div>
      );
    }

    if (idx === tasks.length && canEdit) {
      return (
        <div key="action-row" className="h-[48px] border-b border-[#f0f2f5] flex items-center bg-white hover:bg-[#f0f4ff] group transition-colors">
          <button 
            onClick={() => onAddRow({ 
              startDate: new Date().toISOString().split('T')[0],
              dueDate: new Date(Date.now() + 86400000 * 7).toISOString().split('T')[0]
            })} 
            className="flex-1 h-full flex items-center gap-2 px-5 text-[11px] font-black text-[#6366f1] uppercase tracking-[0.1em] transition-all text-left"
          >
            <Plus className="w-4 h-4" /> 
            Insert task
          </button>
        </div>
      );
    }

    return (
      <div key={`empty-side-${idx}`} className="h-[48px] border-b border-[#f0f2f5] bg-[#fbfcfd]" />
    );
  };

  const renderTimelineRow = (idx: number) => {
    if (idx < tasks.length) {
      const row = tasks[idx];
      const left = getX(String(row.startDate));
      const endX = getX(String(row.dueDate));
      const width = Math.max(endX - left + DAY_WIDTH, DAY_WIDTH);
      const progress = Number(row.progress || 0);

      const statusColors: any = {
          'Done': 'bg-[#00ca72] border-[#00b365]',
          'In Progress': 'bg-[#6366f1] border-[#4f46e5]',
          'To Do': 'bg-[#a3acb9] border-[#697386]',
          'Blocked': 'bg-[#ff4d4d] border-[#e60000]'
      };

      return (
        <div 
          key={row.id} 
          className="h-[48px] border-b border-[#f0f2f5] relative flex items-center group transition-colors hover:bg-[#f7f8f9]/50"
        >
          <div 
            className={`absolute h-[28px] rounded-lg border-2 shadow-sm flex items-center transition-shadow cursor-move z-10 ${
                statusColors[String(row.status)] || 'bg-[#6366f1] border-[#4f46e5]'
            } ${dragState?.rowId === row.id ? 'ring-4 ring-[#6366f1]/20 shadow-xl scale-[1.02]' : 'hover:shadow-md'}`}
            style={{ left, width }}
            onMouseDown={(e) => handleMouseDown(e, row.id, 'move')}
          >
            {canEdit && (
              <div 
                className="absolute left-0 top-0 w-2 h-full cursor-w-resize opacity-0 group-hover:opacity-100 hover:bg-white/20 transition-opacity rounded-l-md"
                onMouseDown={(e) => handleMouseDown(e, row.id, 'resize-left')}
              />
            )}

            <div 
              className="absolute left-0 top-0 h-full bg-white/20 transition-all duration-500 rounded-l-md"
              style={{ width: `${progress}%` }}
            />

            <div className="px-3 relative text-[11px] font-bold text-white truncate w-full pointer-events-none drop-shadow-sm">
              {String(row.task)}
            </div>

            {canEdit && (
              <div 
                className="absolute right-0 top-0 w-2 h-full cursor-e-resize opacity-0 group-hover:opacity-100 hover:bg-white/20 transition-opacity rounded-r-md"
                onMouseDown={(e) => handleMouseDown(e, row.id, 'resize-right')}
              />
            )}

            {canEdit && (
              <div 
                className="absolute -right-2 top-1/2 -translate-y-1/2 w-4 h-4 bg-white border-2 border-[#6366f1] rounded-full scale-0 group-hover:scale-100 cursor-crosshair transition-transform shadow-sm flex items-center justify-center hover:scale-125 z-20"
                onClick={(e) => { e.stopPropagation(); setDependencySource(row.id); }}
              >
                <Link2 className="w-2.5 h-2.5 text-[#6366f1]" />
              </div>
            )}
          </div>
        </div>
      );
    }

    return (
      <div key={`empty-time-${idx}`} className="h-[48px] border-b border-[#f0f2f5] bg-white relative">
         <div className="absolute inset-0 flex">
            {timelineDays.map((_, i) => (
              <div key={i} className="w-[48px] border-r border-[#f0f2f5] h-full shrink-0" />
            ))}
         </div>
      </div>
    );
  };

  const rowsToRender = useMemo(() => {
    const side = [];
    const time = [];
    for (let i = 0; i < totalRowsToRender; i++) {
      side.push(renderSidebarRow(i));
      time.push(renderTimelineRow(i));
    }
    return { side, time };
  }, [totalRowsToRender, tasks, canEdit, timelineDays, dependencySource, dragState]);

  return (
    <div className="flex-1 flex flex-col bg-white overflow-hidden select-none h-full min-h-full">
      {/* Gantt Toolbar */}
      <div className="h-12 border-b border-[#e3e8ee] bg-[#fbfcfd] flex items-center justify-between px-6 shrink-0">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2 px-2 py-1 bg-white border border-[#e3e8ee] rounded-md shadow-sm">
            <CalendarDays className="w-4 h-4 text-[#6366f1]" />
            <span className="text-[12px] font-bold text-[#1a1f36] uppercase tracking-wider">Schedule View</span>
          </div>
          <div className="h-4 w-px bg-[#e3e8ee]"></div>
          <button 
            onClick={() => {}} // Placeholder for zoom
            className="p-1.5 hover:bg-white hover:shadow-sm rounded-md transition-all text-[#697386]"
          >
            <Settings2 className="w-4 h-4" />
          </button>
        </div>

        <div className="flex items-center gap-2">
          {canEdit && (
            <button 
                onClick={() => setDependencySource(dependencySource ? null : 'active')}
                className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-[12px] font-bold transition-all ${
                    dependencySource ? 'bg-[#6366f1] text-white shadow-lg' : 'bg-white text-[#697386] border border-[#e3e8ee] hover:bg-[#f7f8f9]'
                }`}
            >
                {dependencySource ? <Link2Off className="w-4 h-4" /> : <Link2 className="w-4 h-4" />}
                {dependencySource ? 'Dependency Mode: ON' : 'Link Tasks'}
            </button>
          )}
          <div className="flex items-center bg-white border border-[#e3e8ee] rounded-lg overflow-hidden shadow-sm">
            <button className="p-2 hover:bg-[#f7f8f9] border-r border-[#e3e8ee]"><ChevronLeft className="w-4 h-4" /></button>
            <button className="px-4 py-2 text-[12px] font-bold text-[#1a1f36]">Today</button>
            <button className="p-2 hover:bg-[#f7f8f9] border-l border-[#e3e8ee]"><ChevronRight className="w-4 h-4" /></button>
          </div>
        </div>
      </div>

      <div className="flex-1 flex overflow-hidden">
        {/* Left Sidebar: Task Names */}
        <div className="w-64 border-r border-[#e3e8ee] bg-[#fbfcfd] flex flex-col shrink-0">
          <div className="h-[80px] border-b border-[#e3e8ee] px-5 flex items-center shrink-0">
            <span className="text-[11px] font-bold text-[#697386] uppercase tracking-widest">Tasks</span>
          </div>
          <div ref={sidebarContainerRef} className="flex-1 overflow-hidden relative">
             <div className="absolute inset-0 bg-[#fbfcfd] border-r border-[#e3e8ee] z-0 h-full" />
             <div className="relative z-10">
                {rowsToRender.side}
             </div>
          </div>
        </div>

        {/* Right Area: Timeline and Bars */}
        <div ref={scrollContainerRef} onScroll={handleTimelineScroll} className="flex-1 overflow-auto custom-scrollbar relative bg-white">
          <div style={{ width: totalDays * DAY_WIDTH, minHeight: '100%' }}>
            {/* Timeline Header */}
            <div className="sticky top-0 z-30 bg-[#fbfcfd] border-b border-[#e3e8ee]" style={{ height: HEADER_HEIGHT }}>
              <div className="flex">
                {timelineDays.map((date, i) => {
                    const isFirstOfMonth = date.getDate() === 1;
                    const isToday = new Date().toDateString() === date.toDateString();
                    return (
                        <div 
                            key={i} 
                            className={`w-[48px] h-[80px] shrink-0 border-r border-[#f0f2f5] flex flex-col items-center justify-center gap-1 ${isToday ? 'bg-[#6366f1]/5' : ''}`}
                        >
                            {isFirstOfMonth && (
                                <span className="absolute top-2 text-[10px] font-bold text-[#6366f1] uppercase">
                                    {date.toLocaleString('default', { month: 'short' })}
                                </span>
                            )}
                            <span className={`text-[10px] font-bold ${isToday ? 'text-[#6366f1]' : 'text-[#a3acb9]'}`}>
                                {date.toLocaleString('default', { weekday: 'short' }).charAt(0)}
                            </span>
                            <span className={`text-[14px] font-extrabold ${isToday ? 'text-[#6366f1]' : 'text-[#1a1f36]'}`}>
                                {date.getDate()}
                            </span>
                        </div>
                    );
                })}
              </div>
            </div>

            {/* Grid & Bars Area */}
            <div className="relative" style={{ height: totalRowsToRender * ROW_HEIGHT }}>
              {/* Vertical Grid Lines - Main Content */}
              <div className="absolute inset-0 flex z-0">
                {timelineDays.map((_, i) => (
                  <div key={i} className="w-[48px] border-r border-[#f0f2f5] h-full shrink-0" />
                ))}
              </div>

              {/* Dependency Arrows Layer */}
              <svg className="absolute inset-0 w-full h-full pointer-events-none z-20 overflow-visible">
                <defs>
                  <marker id="arrowhead" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
                    <polygon points="0 0, 6 3, 0 6" fill="#cbd5e1" />
                  </marker>
                </defs>
                {renderDependencyLines()}
              </svg>

              {/* Task Bars Content Area */}
              <div className="relative z-10">
                {rowsToRender.time}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default GanttChart;
