
import React, { useState, useRef, useEffect, useMemo } from 'react';
import { Column, RowData, SortConfig, RemoteCursor, Role, PermissionConfig } from '../types';
import { 
  ChevronDown, 
  Plus, 
  ArrowUp, 
  ArrowDown, 
  Trash2,
  Edit2,
  MessageSquare,
  Variable,
  Lock,
  ShieldCheck
} from 'lucide-react';

interface SheetGridProps {
  columns: Column[];
  rows: RowData[]; 
  rawRows: RowData[]; 
  sortConfig: SortConfig;
  remoteCursors: Record<string, RemoteCursor>;
  onUpdateCell: (rowId: string, columnId: string, value: any) => void;
  onAddRow: () => void;
  onDeleteRow: (rowId: string) => void;
  onUpdateColumn: (columnId: string, updates: Partial<Column>) => void;
  onAddColumn: () => void;
  onDeleteColumn: (columnId: string) => void;
  onSort: (columnId: string) => void;
  onReorderRow: (rowId: string, direction: 'up' | 'down') => void;
  onCellFocus?: (rowId: string, colId: string) => void;
  onOpenComments: (rowId: string) => void;
  onOpenRowActivity: (rowId: string) => void;
  userRole: Role;
  onOpenColumnPermissions: (id: string, name: string) => void;
  isSheetEditable: boolean;
}

const ROW_HEIGHT = 44;
const BUFFER_ROWS = 10;

const SheetGrid: React.FC<SheetGridProps> = ({ 
  columns, rows, rawRows, sortConfig, remoteCursors, onUpdateCell, onAddRow, onDeleteRow, onUpdateColumn, onAddColumn, onDeleteColumn, onSort, onReorderRow, onCellFocus, onOpenComments, onOpenRowActivity, userRole, onOpenColumnPermissions, isSheetEditable
}) => {
  const [editingCell, setEditingCell] = useState<{ rowId: string, colId: string } | null>(null);
  const [resizingCol, setResizingCol] = useState<{ id: string, startX: number, startWidth: number } | null>(null);
  const [openHeaderMenu, setOpenHeaderMenu] = useState<string | null>(null);
  const [scrollTop, setScrollTop] = useState(0);
  const [containerHeight, setContainerHeight] = useState(0);
  
  const scrollContainerRef = useRef<HTMLDivElement>(null);

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

  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  };

  // Logic to fill the page with empty rows
  const minRowsToFill = Math.ceil(containerHeight / ROW_HEIGHT);
  const totalRowsToRender = Math.max(rows.length + (isSheetEditable ? 1 : 0) + 5, minRowsToFill);

  const visibleRange = useMemo(() => {
    const startIdx = Math.max(0, Math.floor(scrollTop / ROW_HEIGHT) - BUFFER_ROWS);
    const endIdx = Math.min(totalRowsToRender, Math.ceil((scrollTop + containerHeight) / ROW_HEIGHT) + BUFFER_ROWS);
    return { startIdx, endIdx };
  }, [scrollTop, containerHeight, totalRowsToRender]);

  const checkColEdit = (col: Column) => {
    if (userRole === 'Owner') return true;
    if (!isSheetEditable) return false;
    if (!col.permissions) return true;
    return col.permissions.editors.includes('*') || col.permissions.editors.includes('current-user-id'); 
  };

  const handleMouseMove = (e: MouseEvent) => {
    if (!resizingCol) return;
    const diff = e.clientX - resizingCol.startX;
    onUpdateColumn(resizingCol.id, { width: Math.max(80, resizingCol.startWidth + diff) });
  };

  useEffect(() => {
    if (resizingCol) {
      window.addEventListener('mousemove', handleMouseMove);
      window.addEventListener('mouseup', () => setResizingCol(null));
    }
    return () => { window.removeEventListener('mousemove', handleMouseMove); };
  }, [resizingCol]);

  const renderCellContent = (row: RowData, col: Column) => {
    const value = row[col.id];
    const rawRow = rawRows.find(r => r.id === row.id);
    const rawValue = rawRow ? rawRow[col.id] : value;
    const isFormula = typeof rawValue === 'string' && rawValue.startsWith('=');
    const isEditing = editingCell?.rowId === row.id && editingCell?.colId === col.id;
    const canEditCol = checkColEdit(col);

    if (col.type === 'checkbox') {
      return <input type="checkbox" disabled={!canEditCol} checked={!!value} onChange={(e) => canEditCol && onUpdateCell(row.id, col.id, e.target.checked)} className={`w-4 h-4 rounded border-[#e3e8ee] text-[#6366f1] focus:ring-[#6366f1] ${!canEditCol ? 'cursor-not-allowed opacity-60' : ''}`} />;
    }

    if (isEditing && canEditCol) {
      if (col.type === 'dropdown' && col.options && !isFormula) {
        return <select autoFocus className="w-full h-full bg-white outline-none px-2 text-[13px] font-medium" value={String(rawValue)} onChange={(e) => { onUpdateCell(row.id, col.id, e.target.value); setEditingCell(null); }} onBlur={() => setEditingCell(null)}>{col.options.map(opt => <option key={opt} value={opt}>{opt}</option>)}</select>;
      }
      return <input autoFocus className="w-full h-full bg-white outline-none px-3 border-2 border-[#6366f1] text-[13px] font-medium z-20" type="text" value={String(rawValue || '')} onChange={(e) => onUpdateCell(row.id, col.id, e.target.value)} onBlur={() => setEditingCell(null)} onKeyDown={(e) => e.key === 'Enter' && setEditingCell(null)} />;
    }

    let displayValue = String(value || '');
    if (col.id === 'progress' || col.type === 'number') {
        const numVal = Number(value);
        if (col.id === 'progress') {
            return (
                <div className="w-full flex items-center gap-3">
                    <div className="flex-1 h-1.5 bg-[#f7f8f9] rounded-full overflow-hidden border border-[#e3e8ee]">
                        <div className={`h-full transition-all duration-500 ${numVal === 100 ? 'bg-[#00ca72]' : 'bg-[#6366f1]'}`} style={{ width: `${Math.min(100, numVal)}%` }}></div>
                    </div>
                    <span className="text-[11px] font-bold text-[#697386] w-8">{numVal}%</span>
                </div>
            );
        }
        return <div className="flex items-center justify-between w-full"><span className="text-[#1a1f36] font-medium text-[13px]">{numVal || 0}</span>{isFormula && <Variable className="w-3 h-3 text-[#6366f1] opacity-60" />}</div>;
    }

    if (col.id === 'status' || col.type === 'status' || col.type === 'dropdown' && col.id === 'status') {
      const colors: any = { 'Done': 'bg-[#e6fff4] text-[#008a52] border-[#b3f5d8]', 'In Progress': 'bg-[#f0f4ff] text-[#0055ff] border-[#d1dfff]', 'To Do': 'bg-[#f7f8f9] text-[#4f566b] border-[#e3e8ee]', 'Blocked': 'bg-[#fff0f0] text-[#ff4d4d] border-[#ffd1d1]' };
      return <span className={`px-2 py-0.5 rounded text-[11px] font-bold border leading-none ${colors[displayValue] || 'bg-gray-100 text-gray-600'}`}>{displayValue}</span>;
    }

    return (
      <div className="flex items-center justify-between w-full overflow-hidden">
        <span className="truncate text-[#1a1f36] font-medium text-[13px]">{displayValue}</span>
        <div className="flex items-center gap-1 shrink-0 ml-2">
            {!canEditCol && <Lock className="w-2.5 h-2.5 text-[#a3acb9]" />}
            {isFormula && <Variable className="w-3 h-3 text-[#6366f1] opacity-60" />}
        </div>
      </div>
    );
  };

  const renderRow = (idx: number) => {
    // 1. Data rows
    if (idx < rows.length) {
      const row = rows[idx];
      return (
        <div key={row.id} className="flex border-b border-[#f0f2f5] hover:bg-[#f7f8f9] group transition-colors bg-white" style={{ height: ROW_HEIGHT }}>
          <div className="w-12 border-r border-[#e3e8ee] flex flex-col items-center justify-center shrink-0 bg-[#fbfcfd] py-1 relative">
            <div className="absolute inset-0 flex flex-col items-center justify-center group/gutter">
              <span className="text-[10px] text-[#a3acb9] font-bold group-hover/gutter:hidden">{idx + 1}</span>
              <button 
                onClick={() => onDeleteRow(row.id)} 
                className="hidden group-hover/gutter:flex p-1 text-[#a3acb9] hover:text-red-500 transition-colors"
                title="Delete Row"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </button>
            </div>
            <div className="absolute right-0.5 bottom-0.5 flex items-center gap-0.5">
              <button onClick={() => onOpenComments(row.id)} title="Details" className="transition-all p-0.5 hover:bg-black/5 rounded"><MessageSquare className="w-3.5 h-3.5 text-[#a3acb9]" /></button>
            </div>
          </div>
          {columns.map(col => {
            const remoteCursor = (Object.values(remoteCursors) as RemoteCursor[]).find(rc => rc.rowId === row.id && rc.colId === col.id);
            return (
              <div key={col.id} className={`border-r border-[#f0f2f5] h-11 flex items-center px-3 shrink-0 cursor-text transition-all relative ${editingCell?.rowId === row.id && editingCell?.colId === col.id ? 'bg-white p-0 z-10 shadow-inner ring-2 ring-[#6366f1] ring-inset' : ''} ${!checkColEdit(col) ? 'bg-[#fbfcfd]' : ''}`} style={{ width: col.width }} onClick={() => onCellFocus?.(row.id, col.id)} onDoubleClick={() => checkColEdit(col) && setEditingCell({ rowId: row.id, colId: col.id })}>
                {remoteCursor && <div className="absolute inset-0 pointer-events-none ring-2 ring-inset transition-all duration-300 z-10" style={{ borderColor: remoteCursor.color, boxShadow: `inset 0 0 0 2px ${remoteCursor.color}` } as React.CSSProperties}><div className="absolute -top-4 right-0 px-1 py-0.5 text-[8px] font-bold text-white rounded-t whitespace-nowrap" style={{ backgroundColor: remoteCursor.color }}>{remoteCursor.userName}</div></div>}
                {renderCellContent(row, col)}
              </div>
            );
          })}
          <div className="flex-1 border-b border-[#f0f2f5]" />
        </div>
      );
    }

    // 2. Action row (Insert New Record)
    if (idx === rows.length && isSheetEditable) {
      return (
        <div key="action-row" className="flex border-b border-[#f0f2f5] group transition-colors bg-white hover:bg-[#f0f4ff]" style={{ height: ROW_HEIGHT }}>
          <div className="w-12 border-r border-[#e3e8ee] shrink-0 bg-[#fbfcfd]" />
          <button 
            onClick={onAddRow} 
            className="flex items-center gap-2 px-6 text-[12px] font-black text-[#6366f1] uppercase tracking-[0.2em] transition-all text-left"
          >
            <Plus className="w-4 h-4" /> 
            Insert new record
          </button>
          <div className="flex-1 border-b border-[#f0f2f5]" />
        </div>
      );
    }

    // 3. Decorative empty rows to fill full page
    return (
      <div key={`empty-${idx}`} className="flex border-b border-[#f0f2f5] bg-white" style={{ height: ROW_HEIGHT }}>
        <div className="w-12 border-r border-[#e3e8ee] shrink-0 bg-[#fbfcfd]" />
        {columns.map(col => (
          <div key={col.id} className="border-r border-[#f0f2f5] shrink-0" style={{ width: col.width }} />
        ))}
        <div className="flex-1 border-b border-[#f0f2f5]" />
      </div>
    );
  };

  const rowsToRender = useMemo(() => {
    const result = [];
    for (let i = visibleRange.startIdx; i < visibleRange.endIdx; i++) {
      result.push(renderRow(i));
    }
    return result;
  }, [visibleRange, rows.length, isSheetEditable, columns, editingCell, remoteCursors]);

  return (
    <div 
      ref={scrollContainerRef}
      onScroll={handleScroll}
      className="flex-1 overflow-auto custom-scrollbar bg-white relative h-full"
    >
      <div className="inline-block min-w-full relative" style={{ height: totalRowsToRender * ROW_HEIGHT }}>
        
        {/* Sticky Header */}
        <div className="flex bg-[#f7f8f9] sticky top-0 z-30 border-b border-[#e3e8ee]">
          <div className="w-12 border-r border-[#e3e8ee] flex items-center justify-center shrink-0">
            <span className="text-[10px] text-[#a3acb9] font-bold">#</span>
          </div>
          {columns.map(col => (
            <div key={col.id} className="relative border-r border-[#e3e8ee] flex items-center justify-between px-3 py-3 shrink-0 group hover:bg-[#ecedf0] cursor-pointer transition-colors" style={{ width: col.width }} onClick={() => onSort(col.id)}>
              <div className="flex items-center gap-2 overflow-hidden">
                <span className="font-bold text-[11px] text-[#697386] uppercase tracking-widest truncate">{col.title}</span>
                {col.permissions && <ShieldCheck className="w-2.5 h-2.5 text-[#ff9900]" />}
                {sortConfig.columnId === col.id && (sortConfig.direction === 'asc' ? <ArrowUp className="w-3 h-3 text-[#6366f1]" /> : <ArrowDown className="w-3 h-3 text-[#6366f1]" />)}
              </div>
              <div className="flex items-center">
                  {userRole === 'Owner' && (
                    <button onClick={(e) => { e.stopPropagation(); setOpenHeaderMenu(openHeaderMenu === col.id ? null : col.id); }} className="p-1 rounded hover:bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity">
                      <ChevronDown className="w-3.5 h-3.5 text-[#a3acb9]" />
                    </button>
                  )}
                  {openHeaderMenu === col.id && (
                    <div className="absolute top-full left-0 mt-1 w-48 bg-white border border-[#e3e8ee] rounded-xl shadow-2xl z-50 py-2 overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200">
                      <button onClick={() => { const newTitle = prompt('New title:', col.title); if (newTitle) onUpdateColumn(col.id, { title: newTitle }); setOpenHeaderMenu(null); }} className="w-full flex items-center gap-3 px-4 py-2 text-sm text-[#4f566b] hover:bg-[#f7f8f9] transition-colors"><Edit2 className="w-4 h-4" /> Rename Column</button>
                      <button onClick={() => { onOpenColumnPermissions(col.id, col.title); setOpenHeaderMenu(null); }} className="w-full flex items-center gap-3 px-4 py-2 text-sm text-[#6366f1] hover:bg-[#f0f4ff] transition-colors"><ShieldCheck className="w-4 h-4" /> Permissions</button>
                      <button onClick={() => { onDeleteColumn(col.id); setOpenHeaderMenu(null); }} className="w-full flex items-center gap-3 px-4 py-2 text-sm text-[#ff4d4d] hover:bg-[#ffebed] transition-colors"><Trash2 className="w-4 h-4" /> Delete Column</button>
                    </div>
                  )}
                  <div className={`absolute right-0 top-0 w-1 h-full cursor-col-resize hover:bg-[#6366f1] active:bg-[#6366f1] transition-colors ${userRole !== 'Owner' ? 'pointer-events-none' : ''}`} onMouseDown={(e) => { if (userRole !== 'Owner') return; e.stopPropagation(); setResizingCol({ id: col.id, startX: e.clientX, startWidth: col.width }); }} />
              </div>
            </div>
          ))}
          {userRole === 'Owner' && <button onClick={onAddColumn} className="flex items-center justify-center w-10 border-r border-[#e3e8ee] hover:bg-[#ecedf0] transition-colors shrink-0"><Plus className="w-4 h-4 text-[#a3acb9]" /></button>}
          <div className="flex-1 bg-[#f7f8f9] border-b border-[#e3e8ee]" />
        </div>

        {/* Rows Container */}
        <div className="relative z-10">
          <div 
            className="absolute top-0 left-0 w-full" 
            style={{ transform: `translateY(${visibleRange.startIdx * ROW_HEIGHT}px)` }}
          >
            {rowsToRender}
          </div>
        </div>
      </div>
    </div>
  );
};

export default SheetGrid;
