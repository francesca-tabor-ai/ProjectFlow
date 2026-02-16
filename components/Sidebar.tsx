
import React, { useState, useRef, useEffect } from 'react';
import { 
  LayoutDashboard, 
  Plus, 
  FileText,
  Activity,
  Users,
  ChevronUp,
  ChevronDown,
  Briefcase,
  Clock,
  Zap,
  ShieldAlert,
  Plug,
  ShieldCheck,
  RefreshCw,
  Cpu,
  Info,
  Edit3,
  Trash2,
  Settings2,
  Sparkles,
  GripVertical
} from 'lucide-react';
import { Project, User, Workspace, Sheet, Role, AppPage } from '../types';

interface InlineEditableProps {
  value: string;
  onSave: (val: string) => void;
  canEdit: boolean;
  active: boolean;
  children: (isEditing: boolean, setIsEditing: (v: boolean) => void) => React.ReactNode;
}

const InlineEditable: React.FC<InlineEditableProps> = ({ value, onSave, canEdit, active, children }) => {
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
      <div className="flex-1 px-3 py-1">
        <input
          ref={inputRef}
          type="text"
          value={tempValue}
          onChange={(e) => setTempValue(e.target.value)}
          onBlur={handleSave}
          onKeyDown={(e) => e.key === 'Enter' && handleSave()}
          className="w-full bg-white border border-[#6366f1] rounded px-1 outline-none text-[13px] font-medium"
        />
      </div>
    );
  }

  return <>{children(isEditing, setIsEditing)}</>;
};

interface SidebarProps {
  workspaces: Workspace[];
  activeWorkspace: Workspace | null;
  projects: Project[];
  activeProject: Project | null;
  user: User | null;
  userRole: Role;
  currentPage: AppPage;
  onSelectWorkspace: (id: string) => void;
  onSelectProject: (id: string) => void;
  onSelectSheet: (id: string) => void;
  onOpenProfile: () => void;
  onCreateWorkspace: () => void;
  onCreateProject: () => void;
  onAddSheet: () => void;
  onNavigate: (page: AppPage) => void;
  onOpenSheetPermissions: (id: string, name: string) => void;
  onRenameProject: (id: string, name: string) => void;
  onDeleteProject: (id: string) => void;
  onRenameSheet: (projectId: string, sheetId: string, name: string) => void;
  onDeleteSheet: (projectId: string, sheetId: string) => void;
  onGeneratePlansForAllProjects?: () => void;
}

const SIDEBAR_WIDTH_STORAGE_KEY = 'projectflow_sidebar_width';
const MIN_SIDEBAR_WIDTH = 200;
const MAX_SIDEBAR_WIDTH = 600;
const DEFAULT_SIDEBAR_WIDTH = 256; // w-64 = 256px

const Sidebar: React.FC<SidebarProps> = ({ 
  workspaces, 
  activeWorkspace, 
  projects, 
  activeProject, 
  user, 
  userRole,
  currentPage,
  onSelectWorkspace, 
  onSelectProject, 
  onSelectSheet, 
  onOpenProfile,
  onCreateWorkspace,
  onCreateProject,
  onAddSheet,
  onNavigate,
  onOpenSheetPermissions,
  onRenameProject,
  onDeleteProject,
  onRenameSheet,
  onDeleteSheet,
  onGeneratePlansForAllProjects
}) => {
  const [isWorkspaceDropdownOpen, setIsWorkspaceDropdownOpen] = useState(false);
  const [sidebarWidth, setSidebarWidth] = useState<number>(() => {
    const saved = localStorage.getItem(SIDEBAR_WIDTH_STORAGE_KEY);
    return saved ? parseInt(saved, 10) : DEFAULT_SIDEBAR_WIDTH;
  });
  const [isResizing, setIsResizing] = useState(false);
  const sidebarRef = useRef<HTMLDivElement>(null);
  const canModify = userRole === 'Owner' || userRole === 'Editor';

  useEffect(() => {
    localStorage.setItem(SIDEBAR_WIDTH_STORAGE_KEY, sidebarWidth.toString());
  }, [sidebarWidth]);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isResizing) return;
      
      const newWidth = e.clientX;
      const clampedWidth = Math.max(MIN_SIDEBAR_WIDTH, Math.min(MAX_SIDEBAR_WIDTH, newWidth));
      setSidebarWidth(clampedWidth);
    };

    const handleMouseUp = () => {
      setIsResizing(false);
    };

    if (isResizing) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
    }

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
    };
  }, [isResizing]);

  const NavButton = ({ id, icon: Icon, label }: { id: AppPage, icon: any, label: string }) => (
    <button 
      onClick={() => onNavigate(id)}
      className={`w-full flex items-center gap-3 px-3 py-2 text-[13px] font-medium cursor-pointer rounded-md transition-all ${
        currentPage === id 
          ? 'bg-white text-[#6366f1] shadow-sm border border-[#e3e8ee]' 
          : 'text-[#4f566b] hover:text-[#1a1f36] hover:bg-[#ecedf0]'
      }`}
    >
      <Icon className={`w-4 h-4 ${currentPage === id ? 'text-[#6366f1]' : 'text-[#a3acb9]'}`} />
      {label}
    </button>
  );

  return (
    <div className="w-64 bg-[#f7f8f9] h-screen flex flex-col border-r border-[#e3e8ee] shrink-0">
      <div className="p-5 flex items-center gap-3 mb-2">
        <div className="w-8 h-8 stripe-gradient rounded-lg flex items-center justify-center shadow-sm">
          <Activity className="w-5 h-5 text-white" />
        </div>
        <span className="font-bold text-[#1a1f36] tracking-tight text-lg">ProjectFlow</span>
      </div>

      <div className="flex-1 overflow-y-auto custom-scrollbar px-3 py-2">
        <div className="mb-6">
          <div className="px-3 text-[11px] font-bold text-[#697386] uppercase tracking-wider mb-2 flex justify-between items-center">
            Workspace
            {canModify && (
              <button onClick={onCreateWorkspace} className="hover:text-[#1a1f36] transition-colors p-0.5">
                <Plus className="w-3.5 h-3.5" />
              </button>
            )}
          </div>
          <div className="relative">
            <button 
              onClick={() => setIsWorkspaceDropdownOpen(!isWorkspaceDropdownOpen)}
              className="flex items-center justify-between w-full px-3 py-2 rounded-md bg-white text-[#1a1f36] text-[13px] font-semibold shadow-sm border border-[#e3e8ee] transition-all hover:bg-[#fbfcfd]"
            >
              <div className="flex items-center gap-2.5 truncate">
                <Briefcase className="w-4 h-4 text-[#6366f1] shrink-0" />
                <span className="truncate">{activeWorkspace?.name || 'Select Workspace'}</span>
              </div>
              <ChevronDown className={`w-3.5 h-3.5 text-[#a3acb9] transition-transform ${isWorkspaceDropdownOpen ? 'rotate-180' : ''}`} />
            </button>
            
            {isWorkspaceDropdownOpen && (
              <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#e3e8ee] rounded-md shadow-lg z-50 py-1 overflow-hidden">
                {workspaces.map(ws => (
                  <button
                    key={ws.id}
                    onClick={() => {
                      onSelectWorkspace(ws.id);
                      setIsWorkspaceDropdownOpen(false);
                    }}
                    className={`w-full text-left px-3 py-2 text-[13px] transition-colors hover:bg-[#f7f8f9] ${activeWorkspace?.id === ws.id ? 'text-[#6366f1] font-bold bg-[#f0f4ff]' : 'text-[#4f566b]'}`}
                  >
                    {ws.name}
                  </button>
                ))}
              </div>
            )}
          </div>
          <div className="mt-1 px-1">
             <button 
                onClick={() => onNavigate('workspace-settings')}
                className={`w-full flex items-center gap-2 px-2 py-1.5 rounded-md text-[11px] font-bold uppercase tracking-wider transition-all ${
                  currentPage === 'workspace-settings' 
                    ? 'text-[#6366f1] bg-[#f0f4ff]' 
                    : 'text-[#a3acb9] hover:text-[#1a1f36] hover:bg-[#ecedf0]'
                }`}
              >
                <Settings2 className="w-3.5 h-3.5" />
                Workspace Settings
              </button>
          </div>
        </div>

        <div className="mb-6">
          <div className="flex items-center justify-between px-3 text-[11px] font-bold text-[#697386] uppercase tracking-wider mb-2">
            Projects
            <div className="flex items-center gap-1">
              {canModify && onGeneratePlansForAllProjects && (
                <button 
                  onClick={onGeneratePlansForAllProjects} 
                  className="hover:text-[#6366f1] transition-colors p-0.5"
                  title="Generate AI plans for all your projects"
                >
                  <Sparkles className="w-3.5 h-3.5" />
                </button>
              )}
              {canModify && (
                <button onClick={onCreateProject} className="hover:text-[#1a1f36] transition-colors p-0.5">
                  <Plus className="w-3.5 h-3.5" />
                </button>
              )}
            </div>
          </div>
          <div className="space-y-0.5">
            {projects.map(proj => (
              <div key={proj.id} className="space-y-0.5">
                <div className="group relative">
                  <InlineEditable 
                    value={proj.name} 
                    onSave={(val) => onRenameProject(proj.id, val)}
                    canEdit={canModify}
                    active={activeProject?.id === proj.id}
                  >
                    {(isEditing, setIsEditing) => (
                      <div className="flex items-center w-full">
                        <button
                          onClick={() => onSelectProject(proj.id)}
                          onDoubleClick={() => canModify && setIsEditing(true)}
                          className={`flex-1 flex items-center justify-between px-3 py-2 text-[13px] font-semibold rounded-md transition-all ${
                            activeProject?.id === proj.id && currentPage === 'project'
                              ? 'bg-white text-[#1a1f36] shadow-sm border border-[#e3e8ee]' 
                              : 'text-[#4f566b] hover:text-[#1a1f36] hover:bg-[#ecedf0]'
                          }`}
                        >
                          <div className="flex items-center gap-2.5 truncate">
                            <LayoutDashboard className={`w-4 h-4 ${activeProject?.id === proj.id && currentPage === 'project' ? 'text-[#6366f1]' : 'text-[#a3acb9]'}`} />
                            <span className="truncate">{proj.name}</span>
                          </div>
                          <div className="flex items-center gap-0.5">
                            {canModify && (
                              <>
                                <button 
                                  onClick={(e) => { e.stopPropagation(); setIsEditing(true); }}
                                  className="p-1 opacity-0 group-hover:opacity-100 hover:bg-black/5 rounded transition-all"
                                  title="Rename"
                                >
                                  <Edit3 className="w-3 h-3 text-[#a3acb9] hover:text-[#6366f1]" />
                                </button>
                                <button 
                                  onClick={(e) => { e.stopPropagation(); onDeleteProject(proj.id); }}
                                  className="p-1 opacity-0 group-hover:opacity-100 hover:bg-red-50 rounded transition-all"
                                  title="Delete Project"
                                >
                                  <Trash2 className="w-3 h-3 text-[#a3acb9] hover:text-red-500" />
                                </button>
                              </>
                            )}
                            {activeProject?.id === proj.id && <ChevronDown className="w-3.5 h-3.5 text-[#a3acb9]" />}
                          </div>
                        </button>
                      </div>
                    )}
                  </InlineEditable>
                </div>

                {activeProject?.id === proj.id && (
                  <div className="pl-5 space-y-0.5 mt-0.5 animate-in slide-in-from-top-1 duration-200">
                    {proj.sheets.map(sheet => (
                      <div key={sheet.id} className="group relative">
                        <InlineEditable 
                          value={sheet.name} 
                          onSave={(val) => onRenameSheet(proj.id, sheet.id, val)}
                          canEdit={canModify}
                          active={proj.activeSheetId === sheet.id}
                        >
                          {(isEditing, setIsEditing) => (
                            <div className="flex items-center gap-0.5">
                              <button
                                onClick={() => {
                                  onSelectSheet(sheet.id);
                                  onNavigate('project');
                                }}
                                onDoubleClick={() => canModify && setIsEditing(true)}
                                className={`flex-1 flex items-center gap-2.5 px-3 py-1.5 text-[13px] font-medium rounded-md transition-all ${
                                  proj.activeSheetId === sheet.id && currentPage === 'project'
                                    ? 'text-[#6366f1] bg-[#f0f4ff]' 
                                    : 'text-[#697386] hover:text-[#1a1f36] hover:bg-[#ecedf0]'
                                }`}
                              >
                                <FileText className={`w-4 h-4 ${proj.activeSheetId === sheet.id && currentPage === 'project' ? 'text-[#6366f1]' : 'text-[#a3acb9]'}`} />
                                <span className="truncate pr-8">{sheet.name}</span>
                                {sheet.permissions && <ShieldAlert className="w-2.5 h-2.5 text-[#ff9900]" title="Restricted Access" />}
                              </button>
                              {canModify && (
                                <div className="absolute right-1 flex items-center gap-0.5 opacity-0 group-hover:opacity-100 transition-all">
                                  <button 
                                    onClick={(e) => { e.stopPropagation(); setIsEditing(true); }}
                                    className="p-1 hover:bg-black/5 rounded transition-all"
                                  >
                                    <Edit3 className="w-3 h-3 text-[#a3acb9] hover:text-[#6366f1]" />
                                  </button>
                                  <button 
                                    onClick={(e) => { e.stopPropagation(); onDeleteSheet(proj.id, sheet.id); }}
                                    className="p-1 hover:bg-red-50 rounded transition-all"
                                  >
                                    <Trash2 className="w-3.5 h-3.5 text-[#a3acb9] hover:text-red-500" />
                                  </button>
                                </div>
                              )}
                            </div>
                          )}
                        </InlineEditable>
                      </div>
                    ))}
                    {canModify && (
                      <button 
                        onClick={onAddSheet}
                        className="flex items-center gap-2 w-full px-3 py-1.5 text-[12px] font-bold text-[#a3acb9] hover:text-[#6366f1] transition-colors"
                      >
                        <Plus className="w-3.5 h-3.5" />
                        Add Sheet
                      </button>
                    )}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="mb-8">
          <div className="px-3 text-[11px] font-bold text-[#697386] uppercase tracking-wider mb-2">
            Organization
          </div>
          <div className="space-y-0.5">
            <NavButton id="activity" icon={Clock} label="Activity History" />
            <NavButton id="automations" icon={Zap} label="Automations" />
            <NavButton id="integrations" icon={Plug} label="Integrations" />
            <NavButton id="ai-reliability" icon={ShieldCheck} label="AI Reliability" />
            <NavButton id="ai-retraining" icon={RefreshCw} label="AI Retraining" />
            <NavButton id="ai-advanced" icon={Cpu} label="Advanced Core" />
            <NavButton id="team" icon={Users} label="Team Members" />
          </div>
        </div>
      </div>

      <div className="p-4 border-t border-[#e3e8ee] bg-white/50">
        <button 
          onClick={onOpenProfile}
          className="group flex items-center justify-between w-full p-2.5 rounded-xl hover:bg-[#ecedf0] transition-all text-left"
        >
          <div className="flex items-center gap-3 overflow-hidden">
            <div className="w-9 h-9 shrink-0 bg-[#a855f7] rounded-lg flex items-center justify-center text-white font-bold text-xs shadow-sm">
              <Info className="w-5 h-5 text-white" />
            </div>
            <div className="flex flex-col items-start overflow-hidden min-w-0">
              <span className="text-[13px] font-bold text-[#1a1f36] truncate w-full">{user?.name || 'info'}</span>
              <span className="text-[11px] font-medium text-[#697386] truncate w-full">{user?.email || 'Settings'}</span>
            </div>
          </div>
          <ChevronUp className="w-4 h-4 text-[#a3acb9] group-hover:text-[#1a1f36]" />
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
