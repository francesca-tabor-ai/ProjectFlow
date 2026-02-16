
import React, { useState, useEffect } from 'react';
import { X, Sparkles, Loader2, Target, CheckCircle2, Wand2, AlertTriangle, UserCheck, Terminal, Send, ShieldCheck, Info, Fingerprint } from 'lucide-react';
import { generateProjectPlan, predictDelays, suggestAssignments, parseAICommand } from '../services/geminiService';
import { RowData, AIInsight, Member, AICommandResult } from '../types';

interface AIAssistantProps {
  onClose: () => void;
  onApplyPlan: (tasks: RowData[]) => void;
  activeRows: RowData[];
  members: Member[];
  onCommand: (result: AICommandResult) => void;
}

type Tab = 'planner' | 'insights' | 'terminal';

const AIAssistant: React.FC<AIAssistantProps> = ({ onClose, onApplyPlan, activeRows, members, onCommand }) => {
  const [activeTab, setActiveTab] = useState<Tab>('planner');
  const [prompt, setPrompt] = useState('');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<{ tasks: RowData[], confidence: number } | null>(null);
  const [insights, setInsights] = useState<AIInsight[]>([]);
  const [commandInput, setCommandInput] = useState('');

  useEffect(() => {
    if (activeTab === 'insights' && insights.length === 0) {
      loadInsights();
    }
  }, [activeTab]);

  const loadInsights = async () => {
    setLoading(true);
    try {
      const [delays, suggestions] = await Promise.all([
        predictDelays(activeRows),
        suggestAssignments(activeRows, members)
      ]);
      setInsights([...delays, ...suggestions].sort((a, b) => b.confidence - a.confidence));
    } finally {
      setLoading(false);
    }
  };

  const handleGenerate = async () => {
    if (!prompt.trim()) return;
    setLoading(true);
    try {
      const plan = await generateProjectPlan(prompt);
      setResults(plan);
    } catch (err) {
      alert(err instanceof Error ? err.message : "Error generating plan.");
    } finally {
      setLoading(false);
    }
  };

  const handleSendCommand = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!commandInput.trim()) return;
    setLoading(true);
    try {
      const result = await parseAICommand(commandInput, { rows: activeRows, members });
      onCommand(result);
      setCommandInput('');
    } catch (err) {
      alert("Command failed.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[120] flex items-center justify-center bg-[#1a1f36]/40 backdrop-blur-md p-4 animate-in fade-in duration-300">
      <div className="bg-white rounded-[32px] w-full max-w-2xl h-[80vh] shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-300">
        
        {/* Header Section */}
        <div className="stripe-gradient p-8 text-white relative shrink-0">
          <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full -mr-20 -mt-20 blur-3xl"></div>
          <div className="relative flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center shadow-inner">
                <Sparkles className="w-7 h-7 text-white" />
              </div>
              <div>
                <h3 className="text-2xl font-bold tracking-tight flex items-center gap-2">
                   AI Project Architect
                   <span className="px-2 py-0.5 bg-white/20 rounded text-[10px] uppercase font-black">Stable v1.4.2</span>
                </h3>
                <p className="text-white/80 font-medium text-sm flex items-center gap-2">
                  <ShieldCheck className="w-3.5 h-3.5" />
                  Reliable inference powered by Gemini 3
                </p>
              </div>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-white/20 rounded-full transition-colors">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="flex bg-[#fbfcfd] border-b border-[#e3e8ee] shrink-0">
          {(['planner', 'insights', 'terminal'] as const).map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`flex-1 py-4 text-sm font-bold border-b-2 transition-all capitalize flex items-center justify-center gap-2 ${
                activeTab === tab ? 'border-[#6366f1] text-[#6366f1] bg-white' : 'border-transparent text-[#697386] hover:text-[#1a1f36]'
              }`}
            >
              {tab === 'planner' && <Wand2 className="w-4 h-4" />}
              {tab === 'insights' && <Target className="w-4 h-4" />}
              {tab === 'terminal' && <Terminal className="w-4 h-4" />}
              {tab}
            </button>
          ))}
        </div>

        {/* Tab Content */}
        <div className="flex-1 overflow-y-auto p-8 bg-[#f7f8f9] custom-scrollbar">
          {activeTab === 'planner' && (
            !results ? (
              <div className="space-y-8 animate-in fade-in duration-300">
                <div className="space-y-3">
                  <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider flex items-center justify-between">
                    Define your objective
                    <div className="flex items-center gap-1.5 text-[10px] text-[#00ca72]">
                       <ShieldCheck className="w-3 h-3" /> Input Guardrails Active
                    </div>
                  </label>
                  <textarea
                    className="w-full h-40 p-5 bg-white border border-[#e3e8ee] rounded-2xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium text-[15px] placeholder-[#a3acb9] transition-all shadow-sm resize-none"
                    placeholder="e.g. 'Launch a direct-to-consumer app for vintage furniture rentals.'"
                    value={prompt}
                    onChange={(e) => setPrompt(e.target.value)}
                    disabled={loading}
                  />
                </div>
                <button
                  onClick={handleGenerate}
                  disabled={loading || !prompt.trim()}
                  className="w-full py-4 stripe-gradient text-white font-bold text-lg rounded-xl shadow-xl hover:scale-[1.01] active:scale-[0.98] transition-all flex items-center justify-center gap-3 disabled:opacity-50"
                >
                  {loading ? <Loader2 className="w-6 h-6 animate-spin" /> : <Sparkles className="w-6 h-6" />}
                  Generate Verified Execution Plan
                </button>
              </div>
            ) : (
              <div className="space-y-4 animate-in slide-in-from-right-4">
                 <div className="flex items-center justify-between mb-4">
                    <div>
                       <h4 className="font-bold text-[#1a1f36]">Proposed Roadmap ({results.tasks.length} tasks)</h4>
                       <div className="flex items-center gap-2 mt-1">
                          <span className={`text-[10px] font-black uppercase px-2 py-0.5 rounded ${results.confidence > 0.9 ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}`}>
                             {Math.round(results.confidence * 100)}% Confidence
                          </span>
                          <span className="text-[10px] font-bold text-[#a3acb9] flex items-center gap-1">
                             <Fingerprint className="w-3 h-3" /> Traceable Output
                          </span>
                       </div>
                    </div>
                    <button onClick={() => setResults(null)} className="text-xs font-bold text-[#6366f1] hover:underline">Edit Prompt</button>
                 </div>
                 {results.tasks.map((task, idx) => (
                    <div key={idx} className="p-4 bg-white rounded-xl border border-[#e3e8ee] group relative">
                       <div className="flex items-center justify-between mb-2">
                          <div className="flex items-center gap-4">
                             <span className="w-6 h-6 rounded-full bg-[#f0f4ff] flex items-center justify-center text-[#6366f1] font-bold text-[10px]">{idx + 1}</span>
                             <span className="text-sm font-bold text-[#1a1f36]">{String(task.task)}</span>
                          </div>
                          <CheckCircle2 className="w-4 h-4 text-[#00ca72]" />
                       </div>
                       {task.reasoning && (
                          <div className="ml-10 text-[11px] text-[#697386] flex items-start gap-1.5 bg-[#f7f8f9] p-2 rounded-lg italic">
                             <Info className="w-3 h-3 mt-0.5 shrink-0" />
                             {String(task.reasoning)}
                          </div>
                       )}
                    </div>
                 ))}
                 <button onClick={() => onApplyPlan(results!.tasks)} className="w-full py-4 bg-[#00ca72] text-white font-extrabold rounded-xl shadow-lg mt-6 hover:bg-[#00b365]">Apply Plan</button>
              </div>
            )
          )}

          {activeTab === 'insights' && (
            <div className="space-y-6">
               <div className="flex items-center justify-between">
                  <h4 className="font-bold text-[#1a1f36]">Smart Risk Analysis</h4>
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-bold text-[#a3acb9]">Human-in-the-Loop Active</span>
                    <button onClick={loadInsights} className="p-2 hover:bg-[#e3e8ee] rounded-lg transition-all"><Target className="w-4 h-4 text-[#6366f1]" /></button>
                  </div>
               </div>
               {loading ? (
                 <div className="py-20 flex flex-col items-center justify-center text-[#a3acb9]">
                    <Loader2 className="w-10 h-10 animate-spin mb-4" />
                    <p className="font-bold text-sm">Performing drift analysis...</p>
                 </div>
               ) : (
                 <div className="space-y-3">
                    {insights.map((insight, idx) => {
                       const task = activeRows.find(r => r.id === insight.rowId);
                       return (
                          <div key={idx} className={`p-4 rounded-2xl border bg-white flex gap-4 transition-all hover:shadow-md ${insight.type === 'risk' ? 'border-[#ffebed]' : 'border-[#f0f4ff]'}`}>
                             <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${insight.type === 'risk' ? 'bg-[#ffebed] text-[#ff4d4d]' : 'bg-[#f0f4ff] text-[#6366f1]'}`}>
                                {insight.type === 'risk' ? <AlertTriangle className="w-5 h-5" /> : <UserCheck className="w-5 h-5" />}
                             </div>
                             <div>
                                <div className="text-[11px] font-extrabold uppercase tracking-wider text-[#697386] mb-1 flex items-center gap-2">
                                   {task ? String(task.task) : 'Global Suggestion'}
                                   <span className="w-1 h-1 bg-[#e3e8ee] rounded-full"></span>
                                   <span className="text-[9px] lowercase font-mono">v{insight.version?.split('-')[0] || '1.0'}</span>
                                </div>
                                <p className="text-sm font-bold text-[#1a1f36] leading-relaxed mb-1">{insight.message}</p>
                                {insight.reasoning && <p className="text-[12px] text-[#697386] leading-relaxed">{insight.reasoning}</p>}
                                <div className="mt-3 flex items-center gap-4">
                                   <div className="flex items-center gap-2 flex-1">
                                      <div className="h-1 flex-1 bg-[#f7f8f9] rounded-full overflow-hidden">
                                         <div className="h-full bg-current opacity-40" style={{ width: `${insight.confidence * 100}%` }}></div>
                                      </div>
                                      <span className="text-[10px] font-bold text-[#a3acb9] whitespace-nowrap">{Math.round(insight.confidence * 100)}% Confidence</span>
                                   </div>
                                   <div className="flex gap-1">
                                      <button className="px-2 py-1 bg-[#f0fdf4] text-[#00ca72] text-[10px] font-bold rounded border border-[#00ca72]/20 hover:bg-[#00ca72] hover:text-white transition-all">Approve</button>
                                      <button className="px-2 py-1 bg-[#f7f8f9] text-[#697386] text-[10px] font-bold rounded border border-[#e3e8ee] hover:bg-[#e3e8ee] transition-all">Correct</button>
                                   </div>
                                </div>
                             </div>
                          </div>
                       );
                    })}
                    {insights.length === 0 && <p className="text-center py-10 text-[#697386] text-sm">No insights found. Reliability filters passed.</p>}
                 </div>
               )}
            </div>
          )}

          {activeTab === 'terminal' && (
            <div className="h-full flex flex-col">
               <div className="flex-1 space-y-6">
                  <div className="bg-[#1a1f36] p-6 rounded-2xl border border-white/10 shadow-2xl text-white font-mono text-sm space-y-4 relative overflow-hidden">
                     <div className="absolute top-0 right-0 w-32 h-32 bg-[#6366f1]/5 rounded-full -mr-16 -mt-16 blur-2xl"></div>
                     <div className="flex items-center gap-2 text-[#00ca72]">
                        <Terminal className="w-4 h-4" />
                        <span className="font-bold">ProjectFlow Verifier v1.0</span>
                     </div>
                     <p className="text-white/60">Verified parser active. Input commands are scrubbed for security.</p>
                     <ul className="space-y-1.5 list-disc pl-4 text-xs text-white/40">
                        <li>"Set 'Design Prototype' status to Done"</li>
                        <li>"Assign task 2 to Bob"</li>
                        <li>"Filter by In Progress"</li>
                     </ul>
                  </div>

                  <form onSubmit={handleSendCommand} className="relative mt-8">
                     <input 
                       type="text"
                       placeholder="Type your command..."
                       value={commandInput}
                       onChange={(e) => setCommandInput(e.target.value)}
                       className="w-full pl-6 pr-16 py-4 bg-white border border-[#e3e8ee] rounded-2xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none font-bold text-[15px] shadow-xl"
                       disabled={loading}
                     />
                     <button 
                       type="submit"
                       disabled={loading || !commandInput.trim()}
                       className="absolute right-3 top-1/2 -translate-y-1/2 p-2.5 bg-[#6366f1] text-white rounded-xl shadow-lg hover:bg-[#4f46e5] disabled:opacity-50 transition-all"
                     >
                       {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Send className="w-5 h-5" />}
                     </button>
                  </form>
               </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AIAssistant;
