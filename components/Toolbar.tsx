
import React, { useState, useRef, useEffect } from 'react';
import { 
  Table, 
  GanttChartSquare, 
  KanbanSquare, 
  CalendarDays,
  Filter as FilterIcon, 
  Bookmark,
  Search,
  CloudCheck,
  RefreshCw,
  AlertCircle,
  Edit3,
  Upload,
  Sparkles
} from 'lucide-react';
import { ViewMode, User, Role, FilterConfig, SavedView } from '../types';

export type SaveStatus = 'idle' | 'saving' | 'saved' | 'error';

interface EditableTitleProps {
  value: string;
  onSave: (newValue: string) => void;
  className?: string;
  canEdit: boolean;
}

const EditableTitle: React.FC<EditableTitleProps> = ({ value, onSave, className, canEdit }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [tempValue, setTempValue] = useState(value);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (isEditing) {
      inputRef.current?.focus();
      inputRef.current?.select();
    }
  }, [isEditing]);

  useEffect(() => {
    setTempValue(value);
  }, [value]);

  const handleSave = () => {
    if (tempValue.trim() && tempValue !== value) {
      onSave(tempValue.trim());
    }
    setIsEditing(false);
  };

  if (isEditing && canEdit) {
    return (
      <input
        ref={inputRef}
        type="text"
        value={tempValue}
        onChange={(e) => setTempValue(e.target.value)}
        onBlur={handleSave}
        onKeyDown={(e) => e.key === 'Enter' && handleSave()}
        className={`bg-white border-2 border-[#6366f1] rounded px-1 outline-none ${className}`}
      />
    );
  }

  return (
    <div 
      onClick={() => canEdit && setIsEditing(true)}
      className={`group flex items-center gap-1.5 cursor-pointer hover:text-[#6366f1] transition-colors ${className}`}
    >
      <span className="truncate">{value}</span>
      {canEdit && <Edit3 className="w-3 h-3 text-[#a3acb9] opacity-0 group-hover:opacity-100 transition-opacity" />}
    </div>
  );
};

interface ToolbarProps {
  activeView: ViewMode;
  onViewChange: (view: ViewMode) => void;
  onAISuggestion: () => void;
  onShare: () => void;
  sheetName: string;
  activeProjectName: string;
  saveStatus: SaveStatus;
  collaborators: User[];
  currentUser: User | null;
  userRole: Role;
  activeFilters: FilterConfig;
  onUpdateFilters: (filters: FilterConfig) => void;
  owners: string[];
  statuses: string[];
  savedViews: SavedView[];
  onSaveView: (name: string) => void;
  onApplySavedView: (view: SavedView) => void;
  onDeleteView: (viewId: string) => void;
  onRenameProject: (name: string) => void;
  onRenameSheet: (name: string) => void;
  onImportCSV: (file: File) => void;
}

const Toolbar: React.FC<ToolbarProps> = ({ 
  activeView, 
  onViewChange, 
  onAISuggestion, 
  onShare,
  sheetName, 
  activeProjectName,
  saveStatus,
  collaborators,
  currentUser,
  userRole,
  activeFilters,
  onUpdateFilters,
  owners,
  statuses,
  savedViews,
  onSaveView,
  onApplySavedView,
  onDeleteView,
  onRenameProject,
  onRenameSheet,
  onImportCSV
}) => {
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [isViewsOpen, setIsViewsOpen] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const filterContainerRef = useRef<HTMLDivElement>(null);
  const viewsContainerRef = useRef<HTMLDivElement>(null);
  
  const canEdit = userRole !== 'Viewer';
  const activeFilterCount = activeFilters.owners.length + activeFilters.statuses.length + (activeFilters.dateRange !== 'all' ? 1 : 0);

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (filterContainerRef.current && !filterContainerRef.current.contains(event.target as Node)) {
        setIsFilterOpen(false);
      }
      if (viewsContainerRef.current && !viewsContainerRef.current.contains(event.target as Node)) {
        setIsViewsOpen(false);
      }
    };

    if (isFilterOpen || isViewsOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isFilterOpen, isViewsOpen]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      onImportCSV(file);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  return (
    <div className="h-16 bg-white border-b border-[#e3e8ee] flex items-center justify-between px-8 shrink-0 z-[40]">
      <div className="flex items-center gap-6">
        <div className="flex items-center gap-3">
          <EditableTitle 
            value={activeProjectName} 
            onSave={onRenameProject} 
            canEdit={canEdit}
            className="text-[15px] font-bold text-[#1a1f36] tracking-tight"
          />
          
          <span className="text-[#e3e8ee] font-light">/</span>

          <EditableTitle 
            value={sheetName} 
            onSave={onRenameSheet} 
            canEdit={canEdit}
            className="text-[14px] font-semibold text-[#697386] tracking-tight"
          />
        </div>

        <div className="flex items-center gap-1.5 p-1 bg-[#f0f2f5] rounded-xl">
          <button
            onClick={() => onViewChange('grid')}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-[13px] font-bold transition-all ${
              activeView === 'grid' ? 'text-[#6366f1] bg-white shadow-sm' : 'text-[#697386] hover:text-[#1a1f36]'
            }`}
          >
            <Table className="w-4 h-4" />
            Grid
          </button>
          <button
            onClick={() => onViewChange('gantt')}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-[13px] font-bold transition-all ${
              activeView === 'gantt' ? 'text-[#6366f1] bg-white shadow-sm' : 'text-[#697386] hover:text-[#1a1f36]'
            }`}
          >
            <GanttChartSquare className="w-4 h-4" />
            Timeline
          </button>
          <button
            onClick={() => onViewChange('kanban')}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-[13px] font-bold transition-all ${
              activeView === 'kanban' ? 'text-[#6366f1] bg-white shadow-sm' : 'text-[#697386] hover:text-[#1a1f36]'
            }`}
          >
            <KanbanSquare className="w-4 h-4" />
            Board
          </button>
          <button
            onClick={() => onViewChange('calendar')}
            className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-[13px] font-bold transition-all ${
              activeView === 'calendar' ? 'text-[#6366f1] bg-white shadow-sm' : 'text-[#697386] hover:text-[#1a1f36]'
            }`}
          >
            <CalendarDays className="w-4 h-4" />
            Calendar
          </button>
        </div>
      </div>

      <div className="flex items-center gap-4 relative">
        <div className="flex items-center bg-[#f7f8f9] rounded-xl px-4 py-2 border border-[#e3e8ee] focus-within:border-[#6366f1] focus-within:bg-white focus-within:ring-2 focus-within:ring-[#6366f1]/10 transition-all w-64 shadow-sm">
          <Search className="w-4 h-4 text-[#a3acb9]" />
          <input type="text" placeholder="Search" className="bg-transparent border-none outline-none text-[13px] ml-2 w-full placeholder-[#a3acb9] font-medium" />
        </div>
        
        <div className="flex items-center gap-2">
          {canEdit && (
            <div className="flex items-center bg-[#f7f8f9] p-1 rounded-xl border border-[#e3e8ee] mr-2">
              <input 
                type="file" 
                ref={fileInputRef} 
                onChange={handleFileChange} 
                accept=".csv" 
                className="hidden" 
              />
              <button 
                onClick={() => fileInputRef.current?.click()}
                className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[12px] font-bold text-[#697386] hover:text-[#1a1f36] transition-all"
                title="Bulk Import CSV"
              >
                <Upload className="w-3.5 h-3.5" />
                Import
              </button>
            </div>
          )}

          <div className="relative">
            <button 
              onClick={() => { setIsFilterOpen(!isFilterOpen); setIsViewsOpen(false); }}
              className={`flex items-center gap-2 px-4 py-2 text-[13px] font-bold rounded-xl transition-all border ${
                isFilterOpen || activeFilterCount > 0 ? 'text-[#6366f1] bg-[#f0f4ff] border-[#6366f1]/20 shadow-sm' : 'text-[#697386] bg-white border-[#e3e8ee] hover:bg-[#f7f8f9]'
              }`}
            >
              <FilterIcon className="w-4 h-4" />
              Filter
              {activeFilterCount > 0 && (
                <span className="ml-1 px-1.5 bg-[#6366f1] text-white rounded-full text-[10px] font-black">
                  {activeFilterCount}
                </span>
              )}
            </button>

            {/* Filter Dropdown */}
            {isFilterOpen && (
              <div ref={filterContainerRef} className="absolute top-full right-0 mt-2 w-80 bg-white border border-[#e3e8ee] rounded-xl shadow-xl z-50 p-4">
                <div className="space-y-4">
                  <div>
                    <label className="text-[11px] font-bold text-[#697386] uppercase tracking-wider mb-2 block">Owners</label>
                    <div className="space-y-2 max-h-32 overflow-y-auto">
                      {owners.map(owner => (
                        <label key={owner} className="flex items-center gap-2 cursor-pointer">
                          <input
                            type="checkbox"
                            checked={activeFilters.owners.includes(owner)}
                            onChange={(e) => {
                              const newOwners = e.target.checked
                                ? [...activeFilters.owners, owner]
                                : activeFilters.owners.filter(o => o !== owner);
                              onUpdateFilters({ ...activeFilters, owners: newOwners });
                            }}
                            className="w-4 h-4 text-[#6366f1] border-[#e3e8ee] rounded focus:ring-[#6366f1]"
                          />
                          <span className="text-[13px] font-medium text-[#1a1f36]">{owner}</span>
                        </label>
                      ))}
                    </div>
                  </div>

                  <div>
                    <label className="text-[11px] font-bold text-[#697386] uppercase tracking-wider mb-2 block">Status</label>
                    <div className="space-y-2 max-h-32 overflow-y-auto">
                      {statuses.map(status => (
                        <label key={status} className="flex items-center gap-2 cursor-pointer">
                          <input
                            type="checkbox"
                            checked={activeFilters.statuses.includes(status)}
                            onChange={(e) => {
                              const newStatuses = e.target.checked
                                ? [...activeFilters.statuses, status]
                                : activeFilters.statuses.filter(s => s !== status);
                              onUpdateFilters({ ...activeFilters, statuses: newStatuses });
                            }}
                            className="w-4 h-4 text-[#6366f1] border-[#e3e8ee] rounded focus:ring-[#6366f1]"
                          />
                          <span className="text-[13px] font-medium text-[#1a1f36]">{status}</span>
                        </label>
                      ))}
                    </div>
                  </div>

                  <div>
                    <label className="text-[11px] font-bold text-[#697386] uppercase tracking-wider mb-2 block">Date Range</label>
                    <select
                      value={activeFilters.dateRange}
                      onChange={(e) => onUpdateFilters({ ...activeFilters, dateRange: e.target.value as any })}
                      className="w-full px-3 py-2 text-[13px] font-medium border border-[#e3e8ee] rounded-lg focus:ring-2 focus:ring-[#6366f1] focus:border-[#6366f1] outline-none"
                    >
                      <option value="all">All Dates</option>
                      <option value="today">Today</option>
                      <option value="this-week">This Week</option>
                      <option value="overdue">Overdue</option>
                    </select>
                  </div>

                  {activeFilterCount > 0 && (
                    <button
                      onClick={() => onUpdateFilters({ owners: [], statuses: [], dateRange: 'all' })}
                      className="w-full px-4 py-2 text-[13px] font-bold text-[#6366f1] bg-[#f0f4ff] rounded-lg hover:bg-[#e0e7ff] transition-colors"
                    >
                      Clear All Filters
                    </button>
                  )}
                </div>
              </div>
            )}
          </div>

          <div className="relative">
            <button 
              onClick={() => { setIsViewsOpen(!isViewsOpen); setIsFilterOpen(false); }}
              className={`flex items-center gap-2 px-4 py-2 text-[13px] font-bold rounded-xl transition-all border ${
                isViewsOpen ? 'text-[#1a1f36] bg-[#f7f8f9] border-[#e3e8ee]' : 'text-[#697386] bg-white border-[#e3e8ee] hover:bg-[#f7f8f9]'
              }`}
            >
              <Bookmark className="w-4 h-4" />
              Views
            </button>

            {/* Views Dropdown */}
            {isViewsOpen && (
              <div ref={viewsContainerRef} className="absolute top-full right-0 mt-2 w-80 bg-white border border-[#e3e8ee] rounded-xl shadow-xl z-50 p-4">
                <div className="space-y-3">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="text-[13px] font-bold text-[#1a1f36]">Saved Views</h3>
                    {canEdit && (
                      <button
                        onClick={() => {
                          const name = prompt('View name:');
                          if (name) onSaveView(name);
                        }}
                        className="text-[12px] font-bold text-[#6366f1] hover:text-[#4f46e5]"
                      >
                        + New View
                      </button>
                    )}
                  </div>
                  <div className="space-y-1 max-h-64 overflow-y-auto">
                    {savedViews.length === 0 ? (
                      <p className="text-[12px] text-[#697386] text-center py-4">No saved views</p>
                    ) : (
                      savedViews.map(view => (
                        <div key={view.id} className="flex items-center justify-between p-2 hover:bg-[#f7f8f9] rounded-lg group">
                          <button
                            onClick={() => onApplySavedView(view)}
                            className="flex-1 text-left text-[13px] font-medium text-[#1a1f36] hover:text-[#6366f1]"
                          >
                            {view.name}
                          </button>
                          {canEdit && (
                            <button
                              onClick={() => onDeleteView(view.id)}
                              className="opacity-0 group-hover:opacity-100 text-[#a3acb9] hover:text-red-500 transition-opacity"
                              title="Delete view"
                            >
                              ×
                            </button>
                          )}
                        </div>
                      ))
                    )}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="h-6 w-px bg-[#e3e8ee]"></div>

        {canEdit && (
          <button 
            onClick={onAISuggestion}
            className="flex items-center gap-2 px-4 py-2 text-[13px] font-bold text-white stripe-gradient rounded-xl shadow-md shadow-[#6366f1]/20 hover:opacity-90 transition-all active:scale-95"
          >
            <Sparkles className="w-4 h-4" />
            AI Plan
          </button>
        )}
      </div>
    </div>
  );
};

export default Toolbar;
