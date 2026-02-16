
import React, { useMemo } from 'react';
import { Network, Zap, Waves, Activity, CheckCircle2, RefreshCw, Binary, Layers, ArrowUpRight, Cpu } from 'lucide-react';
import { AIMetric, AIAdvancedState, SelfHealingStatus } from '../types';

interface AIAdvancedPageProps {
  metrics: AIMetric[];
}

const AIAdvancedPage: React.FC<AIAdvancedPageProps> = ({ metrics }) => {
  const state = useMemo((): AIAdvancedState => {
    if (metrics.length === 0) {
      return { reliabilityScore: 100, selfHealingStatus: 'healthy', ensembleAgreement: 100, activeHealings: [] };
    }
    const recent = metrics.slice(0, 20);
    const successRate = (recent.filter(m => m.success).length / recent.length) * 100;
    const avgConfidence = (recent.reduce((acc, m) => acc + m.confidence, 0) / recent.length) * 100;
    const reliability = Math.round((successRate * 0.7) + (avgConfidence * 0.3));
    let status: SelfHealingStatus = 'healthy';
    if (reliability < 80) status = 'warning';
    if (reliability < 60) status = 'healing';

    return {
      reliabilityScore: reliability,
      selfHealingStatus: status,
      ensembleAgreement: Math.round(recent.reduce((acc, m) => acc + (m.consensusScore || 0), 0) / recent.length * 100),
      activeHealings: [
        { id: 'h1', timestamp: Date.now() - 3600000, trigger: 'High Latency spike in Pro model', action: 'Rerouted to Flash-Lite', status: 'completed', result: 'Latency normalized within 45ms' },
        { id: 'h2', timestamp: Date.now() - 10000, trigger: 'Confidence Drift detected in Planner', action: 'Triggered Weighted Ensemble voting', status: 'completed', result: 'Accuracy maintained > 92%' }
      ]
    };
  }, [metrics]);

  const getStatusColor = (s: SelfHealingStatus) => {
    switch (s) {
      case 'healthy': return 'text-[#10b981]';
      case 'warning': return 'text-[#f59e0b]';
      case 'healing': return 'text-[#6366f1]';
      case 'recovered': return 'text-[#10b981]';
      default: return 'text-[#64748b]';
    }
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#ffffff] overflow-hidden animate-in fade-in duration-500 font-sans">
      {/* Header - Serious, Technical but Clean */}
      <div className="p-10 border-b border-[#f1f5f9] flex items-center justify-between shrink-0 bg-white">
        <div className="flex items-center gap-6">
          <div className="w-14 h-14 bg-[#f8fafc] rounded-2xl flex items-center justify-center border border-[#e2e8f0] shadow-sm">
            <Cpu className="w-7 h-7 text-[#1e293b]" />
          </div>
          <div>
            <h2 className="text-3xl font-bold text-[#0f172a] tracking-tight flex items-center gap-3">
               Advanced core
               <span className={`text-[11px] font-bold uppercase px-3 py-1 rounded-full bg-[#f8fafc] border ${getStatusColor(state.selfHealingStatus)} border-[#e2e8f0] tracking-widest`}>
                  {state.selfHealingStatus}
               </span>
            </h2>
            <p className="text-[#64748b] text-[15px] font-medium mt-1 leading-relaxed">
              Autonomous governance and self-healing systems infrastructure.
            </p>
          </div>
        </div>
        <button className="px-5 py-2.5 bg-white text-[#1e293b] font-bold text-[13px] rounded-xl hover:bg-[#f8fafc] border border-[#e2e8f0] shadow-sm transition-all flex items-center gap-2">
           Internal logs <ArrowUpRight className="w-4 h-4" />
        </button>
      </div>

      <div className="flex-1 overflow-y-auto p-12 custom-scrollbar space-y-16">
        {/* Hero Section - Reliability Metric */}
        <div className="grid grid-cols-12 gap-10">
           <div className="col-span-5 p-12 bg-white border border-[#f1f5f9] rounded-[40px] flex flex-col items-center justify-center text-center relative overflow-hidden group shadow-[0_2px_15px_-3px_rgba(0,0,0,0.04)]">
              <div className="w-12 h-12 bg-[#f8fafc] rounded-full flex items-center justify-center mb-8 border border-[#f1f5f9]">
                <Activity className="w-6 h-6 text-[#6366f1]" />
              </div>
              <div className="text-9xl font-extrabold text-[#0f172a] mb-2 tracking-tighter leading-none">
                {state.reliabilityScore}<span className="text-4xl text-[#94a3b8] font-medium ml-1">%</span>
              </div>
              <div className="text-[12px] font-bold text-[#64748b] uppercase tracking-[0.3em]">System autonomy level</div>
              
              <div className="mt-12 w-full h-1.5 bg-[#f1f5f9] rounded-full overflow-hidden max-w-[200px]">
                 <div className="h-full stripe-gradient transition-all duration-1000" style={{ width: `${state.reliabilityScore}%` }}></div>
              </div>
           </div>

           <div className="col-span-7 grid grid-cols-2 gap-10">
              <div className="p-10 bg-white border border-[#f1f5f9] rounded-[40px] relative overflow-hidden group shadow-[0_2px_15px_-3px_rgba(0,0,0,0.04)]">
                 <div className="w-10 h-10 bg-[#fdf4ff] rounded-xl flex items-center justify-center mb-6">
                    <Layers className="w-5 h-5 text-[#a855f7]" />
                 </div>
                 <h4 className="text-xl font-bold text-[#0f172a] mb-2">Ensemble consensus</h4>
                 <p className="text-[#64748b] text-[14px] font-medium mb-10 leading-relaxed max-w-[240px]">
                    Multi-model alignment across active neural processing layers.
                 </p>
                 <div className="flex items-baseline gap-4">
                    <div className="text-5xl font-bold text-[#0f172a] tracking-tight">{state.ensembleAgreement}%</div>
                    <div className="text-[11px] font-bold text-[#10b981] uppercase tracking-wider bg-[#f0fdf4] px-2 py-0.5 rounded">Optimal</div>
                 </div>
              </div>

              <div className="p-10 bg-white border border-[#f1f5f9] rounded-[40px] shadow-[0_2px_15px_-3px_rgba(0,0,0,0.04)]">
                 <div className="w-10 h-10 bg-[#fff7ed] rounded-xl flex items-center justify-center mb-6">
                    <Zap className="w-5 h-5 text-[#f97316]" />
                 </div>
                 <h4 className="text-xl font-bold text-[#0f172a] mb-2">Healing latency</h4>
                 <p className="text-[#64748b] text-[14px] font-medium mb-10 leading-relaxed max-w-[240px]">
                    Response time to internal pipeline anomalies.
                 </p>
                 <div className="text-5xl font-bold text-[#0f172a] tracking-tight">420<span className="text-xl text-[#94a3b8] tracking-normal font-medium ml-1">ms</span></div>
              </div>
           </div>
        </div>

        {/* Content Grid - Streams & Layers */}
        <div className="grid grid-cols-2 gap-16">
           <div className="space-y-8">
              <div className="flex items-center justify-between border-b border-[#f1f5f9] pb-4">
                 <h4 className="text-[12px] font-bold text-[#64748b] uppercase tracking-[0.2em] flex items-center gap-3">
                    <RefreshCw className="w-4 h-4 text-[#6366f1]" /> Self-healing stream
                 </h4>
                 <span className="text-[10px] font-bold text-[#10b981] uppercase tracking-widest flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 bg-[#10b981] rounded-full animate-pulse"></span> Active
                 </span>
              </div>
              
              <div className="space-y-6">
                 {state.activeHealings.map(action => (
                    <div key={action.id} className="p-8 bg-white border border-[#f1f5f9] rounded-[32px] group hover:border-[#cbd5e1] transition-all shadow-[0_4px_20px_-10px_rgba(0,0,0,0.05)]">
                       <div className="flex items-center justify-between mb-6">
                          <span className="text-[10px] font-bold text-[#6366f1] bg-[#f0f4ff] px-3 py-1 rounded-full uppercase tracking-wider">Event: {action.trigger.split(' ')[0]}</span>
                          <span className="text-[11px] text-[#94a3b8] font-medium">{new Date(action.timestamp).toLocaleTimeString()}</span>
                       </div>
                       <div className="flex items-center gap-4 text-[#0f172a] font-bold text-lg mb-2">
                          <CheckCircle2 className="w-5 h-5 text-[#10b981]" />
                          {action.action}
                       </div>
                       <p className="text-[#64748b] text-[14px] font-medium pl-9 leading-relaxed">{action.result}</p>
                    </div>
                 ))}
              </div>
           </div>

           <div className="space-y-8">
              <div className="flex items-center justify-between border-b border-[#f1f5f9] pb-4">
                 <h4 className="text-[12px] font-bold text-[#64748b] uppercase tracking-[0.2em] flex items-center gap-3">
                    <Binary className="w-4 h-4 text-[#64748b]" /> Orchestration layer
                 </h4>
              </div>

              <div className="p-10 bg-[#f8fafc] rounded-[40px] border border-[#f1f5f9] space-y-10 shadow-inner">
                 {[
                    { name: 'Gemini 3 Pro', color: 'bg-[#6366f1]', width: '92%', status: 'Active' },
                    { name: 'Gemini 3 Flash', color: 'bg-[#a855f7]', width: '84%', status: 'Active' },
                    { name: 'Rules Engine', color: 'bg-[#e2e8f0]', width: '100%', status: 'Idle' }
                 ].map(m => (
                    <div key={m.name} className={`flex flex-col gap-4 ${m.status === 'Idle' ? 'opacity-40' : ''}`}>
                      <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-widest text-[#64748b]">
                         <span className="text-[#1e293b]">{m.name}</span>
                         <span className={m.status === 'Active' ? 'text-[#10b981]' : ''}>{m.status}</span>
                      </div>
                      <div className="h-1.5 bg-[#e2e8f0] rounded-full overflow-hidden">
                         <div className={`h-full ${m.color} transition-all duration-1000`} style={{ width: m.width }}></div>
                      </div>
                   </div>
                 ))}

                 <div className="pt-10 border-t border-[#e2e8ee] flex items-start gap-5">
                    <div className="w-10 h-10 rounded-xl bg-white border border-[#e2e8ee] flex items-center justify-center shadow-sm shrink-0">
                       <CheckCircle2 className="w-5 h-5 text-[#10b981]" />
                    </div>
                    <p className="text-[13px] text-[#64748b] leading-relaxed font-medium italic">
                      Neural Consensus Protocol v2.1 is currently processing. Real-time drift correction is active, minimizing hallucination risk for the current session data.
                    </p>
                 </div>
              </div>
           </div>
        </div>
      </div>

      {/* Footer Action - Minimal and Focused */}
      <div className="p-8 border-t border-[#f1f5f9] bg-white flex justify-end gap-6 shrink-0 relative z-10">
        <button className="px-8 py-4 bg-[#0f172a] text-white font-bold rounded-2xl shadow-lg hover:bg-black transition-all flex items-center gap-3 uppercase tracking-widest text-[12px] active:scale-95">
           <Waves className="w-5 h-5" /> Flush buffer
        </button>
      </div>
    </div>
  );
};

export default AIAdvancedPage;
