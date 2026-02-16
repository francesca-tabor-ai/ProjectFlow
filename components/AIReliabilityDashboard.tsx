
import React, { useMemo } from 'react';
import { ShieldCheck, Activity, Clock, Target, AlertCircle, CheckCircle2, Server, Fingerprint } from 'lucide-react';
import { AIMetric } from '../types';

interface AIReliabilityPageProps {
  metrics: AIMetric[];
}

const AIReliabilityPage: React.FC<AIReliabilityPageProps> = ({ metrics }) => {
  const stats = useMemo(() => {
    if (metrics.length === 0) return { avgLatency: 0, successRate: 0, avgConfidence: 0, totalRequests: 0 };
    const successful = metrics.filter(m => m.success).length;
    return {
      avgLatency: Math.round(metrics.reduce((acc, m) => acc + m.latency, 0) / metrics.length),
      successRate: Math.round((successful / metrics.length) * 100),
      avgConfidence: Math.round((metrics.reduce((acc, m) => acc + m.confidence, 0) / metrics.length) * 100),
      totalRequests: metrics.length
    };
  }, [metrics]);

  return (
    <div className="flex-1 flex flex-col h-full bg-[#f7f8f9] overflow-hidden animate-in fade-in duration-300">
      <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-white shrink-0">
        <div className="flex items-center gap-5">
          <div className="w-14 h-14 bg-[#00ca72]/10 rounded-[20px] flex items-center justify-center">
            <ShieldCheck className="w-8 h-8 text-[#00ca72]" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-[#1a1f36]">AI Reliability Governance</h2>
            <p className="text-[#697386] text-sm font-medium mt-1">Enterprise-grade monitoring of predictive system health.</p>
          </div>
        </div>
        <div className="flex items-center gap-3">
           <div className="flex items-center gap-2 px-4 py-2 bg-[#f0fdf4] text-[#00ca72] rounded-xl text-xs font-black uppercase tracking-widest border border-[#00ca72]/20">
              <Activity className="w-3.5 h-3.5" /> System Up
           </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-10 custom-scrollbar">
        <div className="max-w-6xl mx-auto space-y-10">
          <div className="grid grid-cols-4 gap-6">
             <div className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] shadow-sm">
                <Activity className="w-6 h-6 text-[#00ca72] mb-4" />
                <div className="text-4xl font-black text-[#1a1f36]">{stats.successRate}%</div>
                <div className="text-xs font-bold text-[#697386] uppercase tracking-[0.2em] mt-1">Success Rate</div>
             </div>
             <div className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] shadow-sm">
                <Clock className="w-6 h-6 text-[#6366f1] mb-4" />
                <div className="text-4xl font-black text-[#1a1f36]">{stats.avgLatency}ms</div>
                <div className="text-xs font-bold text-[#697386] uppercase tracking-[0.2em] mt-1">Avg Latency</div>
             </div>
             <div className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] shadow-sm">
                <Target className="w-6 h-6 text-[#f97316] mb-4" />
                <div className="text-4xl font-black text-[#1a1f36]">{stats.avgConfidence}%</div>
                <div className="text-xs font-bold text-[#697386] uppercase tracking-[0.2em] mt-1">Confidence</div>
             </div>
             <div className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] shadow-sm">
                <Server className="w-6 h-6 text-[#4f566b] mb-4" />
                <div className="text-4xl font-black text-[#1a1f36]">{stats.totalRequests}</div>
                <div className="text-xs font-bold text-[#697386] uppercase tracking-[0.2em] mt-1">Inferences</div>
             </div>
          </div>

          <div className="grid grid-cols-3 gap-10">
            <div className="col-span-2 space-y-6">
              <div className="flex items-center justify-between px-2">
                <h4 className="text-xs font-black text-[#697386] uppercase tracking-[0.2em]">Inference Audit Stream</h4>
                <div className="flex items-center gap-2">
                   <div className="w-2 h-2 bg-[#00ca72] rounded-full animate-pulse"></div>
                   <span className="text-[10px] font-bold text-[#00ca72] uppercase">Live Monitor</span>
                </div>
              </div>
              
              <div className="space-y-3">
                {metrics.length === 0 ? (
                  <div className="py-32 text-center bg-white border-2 border-dashed border-[#e3e8ee] rounded-[40px] text-[#a3acb9]">
                    No active inference streams detected.
                  </div>
                ) : (
                  metrics.map(m => (
                    <div key={m.id} className="p-6 bg-white border border-[#e3e8ee] rounded-[24px] flex items-center justify-between hover:shadow-md transition-all group">
                      <div className="flex items-center gap-6">
                        <div className={`w-12 h-12 rounded-2xl flex items-center justify-center shadow-inner ${m.success ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600'}`}>
                          {m.success ? <CheckCircle2 className="w-6 h-6" /> : <AlertCircle className="w-6 h-6" />}
                        </div>
                        <div>
                          <div className="text-lg font-bold text-[#1a1f36] flex items-center gap-3">
                             {m.taskType.toUpperCase()} 
                             <span className="text-xs font-mono text-[#697386] bg-[#f7f8f9] px-2 py-1 rounded">{m.model}</span>
                          </div>
                          <div className="text-xs text-[#a3acb9] font-bold uppercase mt-1">{new Date(m.timestamp).toLocaleTimeString()} • {m.latency}ms RT</div>
                        </div>
                      </div>
                      <div className="flex items-center gap-6">
                         <div className="text-right">
                           <div className="text-xl font-black text-[#1a1f36]">{Math.round(m.confidence * 100)}%</div>
                           <div className="text-[9px] font-black text-[#a3acb9] uppercase tracking-widest">Conf.</div>
                         </div>
                         <div className="h-12 w-1.5 bg-[#f0f2f5] rounded-full overflow-hidden">
                           <div className={`w-full bg-current ${m.confidence > 0.8 ? 'text-green-500' : m.confidence > 0.6 ? 'text-orange-500' : 'text-red-500'}`} style={{ height: `${m.confidence * 100}%` }}></div>
                         </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>

            <div className="space-y-8">
              <div className="p-8 bg-[#1a1f36] rounded-[40px] text-white shadow-2xl relative overflow-hidden">
                 <div className="absolute bottom-0 right-0 w-32 h-32 bg-[#6366f1]/20 rounded-full blur-3xl"></div>
                 <div className="flex items-center gap-3 mb-8">
                    <Fingerprint className="w-6 h-6 text-[#6366f1]" />
                    <h4 className="text-xs font-black uppercase tracking-[0.2em] text-white/50">Model Registry</h4>
                 </div>
                 
                 <div className="space-y-8">
                    <div className="pb-8 border-b border-white/5">
                       <div className="text-xs font-black text-[#6366f1] uppercase tracking-widest mb-2">PRO v1.4.2</div>
                       <div className="text-lg font-bold">gemini-3-pro-preview</div>
                       <div className="text-[10px] text-white/30 mt-2 font-black uppercase flex items-center gap-2">
                          <span className="w-2 h-2 bg-[#00ca72] rounded-full"></span>
                          Production Stable
                       </div>
                    </div>
                    <div className="pb-8 border-b border-white/5">
                       <div className="text-xs font-black text-[#00ca72] uppercase tracking-widest mb-2">FLASH v1.4.2</div>
                       <div className="text-lg font-bold">gemini-3-flash-preview</div>
                       <div className="text-[10px] text-white/30 mt-2 font-black uppercase flex items-center gap-2">
                          <span className="w-2 h-2 bg-[#00ca72] rounded-full"></span>
                          Latency Optimized
                       </div>
                    </div>
                    <div>
                       <div className="text-xs font-black text-[#ec4899] uppercase tracking-widest mb-2">FALLBACK</div>
                       <div className="text-lg font-bold">Deterministic Engine</div>
                       <div className="text-[10px] text-white/30 mt-2 font-black uppercase flex items-center gap-2">
                          <span className="w-2 h-2 bg-[#a3acb9] rounded-full"></span>
                          Offline Ready
                       </div>
                    </div>
                 </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AIReliabilityPage;
