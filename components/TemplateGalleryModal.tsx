
import React, { useState } from 'react';
import { X, Layout, FileText, Briefcase, Zap, Plus, ArrowRight, Check } from 'lucide-react';
import { TEMPLATE_GALLERY } from '../constants';
import { Template } from '../types';

interface TemplateGalleryModalProps {
  onClose: () => void;
  onCreate: (name: string, template?: Template) => void;
}

const TemplateGalleryModal: React.FC<TemplateGalleryModalProps> = ({ onClose, onCreate }) => {
  const [selectedTemplate, setSelectedTemplate] = useState<Template | null>(null);
  const [projectName, setProjectName] = useState('');

  const handleStart = () => {
    const finalName = projectName.trim() || (selectedTemplate ? selectedTemplate.name : 'New Project');
    onCreate(finalName, selectedTemplate || undefined);
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-[#1a1f36]/60 backdrop-blur-md p-4 animate-in fade-in duration-300">
      <div className="bg-white rounded-[32px] w-full max-w-5xl h-[85vh] shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-300">
        
        <div className="flex flex-1 overflow-hidden">
          {/* Sidebar - Categories */}
          <div className="w-64 bg-[#f7f8f9] border-r border-[#e3e8ee] p-8 hidden md:flex flex-col">
            <h2 className="text-lg font-bold text-[#1a1f36] mb-8">Templates</h2>
            <nav className="space-y-1">
              {['All Templates', 'General Management', 'Marketing & Sales', 'Software Development'].map((cat) => (
                <button 
                  key={cat}
                  className={`w-full text-left px-4 py-2.5 text-sm font-semibold rounded-xl transition-all ${
                    cat === 'All Templates' ? 'bg-[#6366f1] text-white shadow-lg shadow-[#6366f1]/20' : 'text-[#697386] hover:bg-[#ecedf0]'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </nav>
            <div className="mt-auto p-4 bg-white border border-[#e3e8ee] rounded-2xl">
               <div className="flex items-center gap-2 text-[#6366f1] mb-1">
                  <Zap className="w-4 h-4" />
                  <span className="text-[11px] font-bold uppercase tracking-widest">Tip</span>
               </div>
               <p className="text-[12px] text-[#4f566b] font-medium leading-relaxed">Templates include pre-configured columns and automation rules.</p>
            </div>
          </div>

          {/* Main Content */}
          <div className="flex-1 flex flex-col min-w-0">
            <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between shrink-0">
              <div>
                <h3 className="text-2xl font-bold text-[#1a1f36]">Choose a starting point</h3>
                <p className="text-[#697386] text-sm font-medium">Select a template or start from scratch.</p>
              </div>
              <button onClick={onClose} className="p-2 hover:bg-[#f7f8f9] rounded-full transition-colors text-[#a3acb9] hover:text-[#1a1f36]">
                <X className="w-6 h-6" />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-8 custom-scrollbar">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Blank Project Card */}
                <div 
                  onClick={() => setSelectedTemplate(null)}
                  className={`relative p-8 rounded-[24px] border-2 cursor-pointer transition-all group ${
                    selectedTemplate === null ? 'border-[#6366f1] bg-[#f0f4ff] ring-4 ring-[#6366f1]/5' : 'border-[#e3e8ee] hover:border-[#6366f1]/50'
                  }`}
                >
                  <div className="w-14 h-14 rounded-2xl bg-white border border-[#e3e8ee] flex items-center justify-center shadow-sm mb-6 transition-transform group-hover:scale-110">
                    <Plus className="w-7 h-7 text-[#6366f1]" />
                  </div>
                  <h4 className="text-xl font-bold text-[#1a1f36] mb-2">Blank Project</h4>
                  <p className="text-[#697386] text-sm font-medium leading-relaxed">Start with a clean slate and build your own custom structure from the ground up.</p>
                  {selectedTemplate === null && (
                    <div className="absolute top-6 right-6 w-6 h-6 bg-[#6366f1] rounded-full flex items-center justify-center animate-in zoom-in">
                      <Check className="w-4 h-4 text-white" />
                    </div>
                  )}
                </div>

                {/* Templates List */}
                {TEMPLATE_GALLERY.map((tpl) => (
                  <div 
                    key={tpl.id}
                    onClick={() => setSelectedTemplate(tpl)}
                    className={`relative p-8 rounded-[24px] border-2 cursor-pointer transition-all group ${
                      selectedTemplate?.id === tpl.id ? 'border-[#6366f1] bg-[#f0f4ff] ring-4 ring-[#6366f1]/5' : 'border-[#e3e8ee] hover:border-[#6366f1]/50'
                    }`}
                  >
                    <div className="flex items-center justify-between mb-6">
                      <div className="w-14 h-14 rounded-2xl bg-white border border-[#e3e8ee] flex items-center justify-center shadow-sm transition-transform group-hover:scale-110">
                        {tpl.id.includes('tracker') ? <FileText className="w-7 h-7 text-[#6366f1]" /> :
                         tpl.id.includes('marketing') ? <Layout className="w-7 h-7 text-[#a855f7]" /> :
                         <Briefcase className="w-7 h-7 text-[#ec4899]" />}
                      </div>
                      <span className="text-[10px] font-bold text-[#697386] uppercase tracking-widest bg-white px-2.5 py-1 rounded-full border border-[#e3e8ee] shadow-sm">
                        {tpl.category.split(' ')[0]}
                      </span>
                    </div>
                    <h4 className="text-xl font-bold text-[#1a1f36] mb-2">{tpl.name}</h4>
                    <p className="text-[#697386] text-sm font-medium leading-relaxed">{tpl.description}</p>
                    
                    {selectedTemplate?.id === tpl.id && (
                      <div className="absolute top-6 right-6 w-6 h-6 bg-[#6366f1] rounded-full flex items-center justify-center animate-in zoom-in">
                        <Check className="w-4 h-4 text-white" />
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Footer - Project Name Input */}
            <div className="p-8 border-t border-[#e3e8ee] bg-[#fbfcfd] flex items-center gap-6 shrink-0">
               <div className="flex-1 space-y-1.5">
                  <label className="text-[11px] font-bold text-[#697386] uppercase tracking-wider ml-1">Project Name</label>
                  <input 
                    type="text" 
                    placeholder={selectedTemplate ? `My ${selectedTemplate.name}` : "Project Name"}
                    value={projectName}
                    onChange={(e) => setProjectName(e.target.value)}
                    className="w-full px-5 py-3.5 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-bold shadow-sm"
                  />
               </div>
               <button 
                  onClick={handleStart}
                  className="px-8 py-3.5 stripe-gradient text-white font-bold rounded-xl shadow-xl hover:shadow-2xl hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center gap-3 mt-4"
               >
                  {selectedTemplate ? 'Use Template' : 'Start Project'}
                  <ArrowRight className="w-5 h-5" />
               </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TemplateGalleryModal;
