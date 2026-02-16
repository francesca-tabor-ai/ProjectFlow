
import React, { useState } from 'react';
import { RefreshCw, Zap, Shield, History, Play, CheckCircle2, AlertCircle, Clock, Settings, ArrowRight, Database, BarChart, Server } from 'lucide-react';
import { RetrainingJob, RetrainingConfig, RetrainingStatus } from '../types';

interface AIRetrainingPageProps {
  jobs: RetrainingJob[];
  config: RetrainingConfig;
  onUpdateConfig: (config: RetrainingConfig) => void;
  onStartManualJob: () => void;
}

const AIRetrainingPage: React.FC<AIRetrainingPageProps> = ({ 
  jobs, 
  config, 
  onUpdateConfig,
  onStartManualJob 
}) => {
  const [activeTab, setActiveTab] = useState<'overview' | 'jobs' | 'settings'>('overview');
  const activeJob = jobs.find(j => j.status === 'running' || j.status === 'validating');

  const getStatusColor = (status: RetrainingStatus) => {
    switch (status) {
      case 'success': return 'text-[#00ca72] bg-[#e6fff4] border-[#b3f5d8]';
      case 'running': return 'text-[#6366f1] bg-[#f0f4ff] border-[#d1dfff]';
      case 'validating': return 'text-[#a855f7] bg-[#f3e8ff] border-[#e9d5ff]';
      case 'failed': return 'text-[#ff4d4d] bg-[#fff0f0] border-[#ffd1d1]';
      default: return 'text-[#697386] bg-[#f7f8f9] border-[#e3e8ee]';
    }
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#f7f8f9] overflow-hidden animate-in fade-in duration-300">
      <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-white shrink-0">
        <div className="flex items-center gap-5">
          <div className="w-14 h-14 bg-[#6366f1]/10 rounded-[20px] flex items-center justify-center">
            <RefreshCw className={`w-8 h-8 text-[#6366f1] ${activeJob ? 'animate-spin' : ''}`} />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-[#1a1f36]">Autonomous MLOps</h2>
            <p className="text-[#697386] text-sm font-medium mt-1">Continuous model training and validation pipeline.</p>
          </div>
        </div>
        <div className="flex bg-[#f7f8f9] p-1 rounded-xl border border-[#e3e8ee]">
          <button 
            onClick={() => setActiveTab('overview')}
            className={`px-6 py-2 text-sm font-bold rounded-lg transition-all ${activeTab === 'overview' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386]'}`}
          >
            Monitor
          </button>
          <button 
            onClick={() => setActiveTab('jobs')}
            className={`px-6 py-2 text-sm font-bold rounded-lg transition-all ${activeTab === 'jobs' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386]'}`}
          >
            History
          </button>
          <button 
            onClick={() => setActiveTab('settings')}
            className={`px-6 py-2 text-sm font-bold rounded-lg transition-all ${activeTab === 'settings' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386]'}`}
          >
            Config
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-10 custom-scrollbar">
        <div className="max-w-6xl mx-auto space-y-12">
          {activeTab === 'overview' && (
            <div className="space-y-10 animate-in fade-in duration-500">
              <div className="grid grid-cols-12 gap-8">
                <div className="col-span-8 p-10 bg-[#1a1f36] rounded-[48px] text-white relative overflow-hidden shadow-2xl">
                  <div className="absolute top-0 right-0 w-80 h-80 bg-[#6366f1]/20 rounded-full blur-[100px] -mr-32 -mt-32"></div>
                  <div className="relative">
                    <div className="flex items-center gap-4 mb-10">
                      <div className="px-4 py-1.5 bg-[#00ca72] text-white text-[11px] font-black uppercase rounded-full tracking-widest border border-white/20">Active Node</div>
                      <span className="text-white/40 text-xs font-mono">pf-gemini-3-retrained-774b</span>
                    </div>
                    <h3 className="text-5xl font-black mb-4 tracking-tighter">Workspace Brain v1.4.2</h3>
                    <p className="text-white/60 text-lg max-w-xl leading-relaxed">Processing live workspace drift. Currently maintaining 98.4% predictive accuracy across all task generations.</p>
                    <div className="mt-12 flex gap-12">
                      <div>
                        <div className="text-xs font-black text-white/30 uppercase tracking-[0.2em] mb-2">Inference Speed</div>
                        <div className="text-3xl font-black">142ms</div>
                      </div>
                      <div className="w-px h-12 bg-white/10"></div>
                      <div>
                        <div className="text-xs font-black text-white/30 uppercase tracking-[0.2em] mb-2">Model Uptime</div>
                        <div className="text-3xl font-black text-[#00ca72]">99.9%</div>
                      </div>
                      <div className="w-px h-12 bg-white/10"></div>
                      <div>
                        <div className="text-xs font-black text-white/30 uppercase tracking-[0.2em] mb-2">Last Sync</div>
                        <div className="text-3xl font-black">2h ago</div>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="col-span-4 p-10 bg-white border border-[#e3e8ee] rounded-[48px] flex flex-col justify-between shadow-sm">
                   <div>
                      <h4 className="text-xl font-bold text-[#1a1f36] mb-3">Manual Override</h4>
                      <p className="text-sm text-[#697386] leading-relaxed font-medium">Bypass autonomous triggers and force a full model retraining cycle using current data snapshots.</p>
                   </div>
                   <button 
                      onClick={onStartManualJob}
                      disabled={!!activeJob}
                      className="w-full py-5 bg-[#1a1f36] text-white font-black rounded-[24px] shadow-2xl hover:bg-black disabled:opacity-50 transition-all flex items-center justify-center gap-3 uppercase tracking-widest text-xs"
                    >
                      <Play className="w-5 h-5 fill-current" /> Trigger Retrain
                    </button>
                </div>
              </div>

              {activeJob && (
                <div className="p-10 bg-[#f0f4ff] border border-[#6366f1]/20 rounded-[48px] animate-in zoom-in-95 duration-500 shadow-lg">
                  <div className="flex items-center justify-between mb-12">
                     <div className="flex items-center gap-4">
                        <RefreshCw className="w-6 h-6 text-[#6366f1] animate-spin" />
                        <h4 className="text-2xl font-black text-[#1a1f36]">Active Pipeline Deployment</h4>
                     </div>
                     <span className="text-xs font-mono font-black text-[#6366f1] bg-white px-4 py-1.5 rounded-full border border-[#6366f1]/20 shadow-sm">JOB_ID: {activeJob.id.split('-')[1]}</span>
                  </div>

                  <div className="grid grid-cols-4 gap-4 relative before:absolute before:top-[24px] before:left-[10%] before:right-[10%] before:h-1 before:bg-[#e3e8ee] before:z-0">
                    {[
                      { label: 'Ingestion', status: 'success', icon: Database },
                      { label: 'Refinement', status: 'success', icon: Zap },
                      { label: 'Compute', status: activeJob.status === 'running' ? 'active' : 'success', icon: Server },
                      { label: 'Rollout', status: activeJob.status === 'validating' ? 'active' : 'pending', icon: ArrowRight },
                    ].map((step, i) => (
                      <div key={i} className="flex flex-col items-center text-center relative z-10">
                         <div className={`w-14 h-14 rounded-2xl flex items-center justify-center mb-4 shadow-lg transition-all ${
                            step.status === 'success' ? 'bg-[#00ca72] text-white' : 
                            step.status === 'active' ? 'bg-[#6366f1] text-white animate-pulse' : 
                            'bg-white text-[#a3acb9] border border-[#e3e8ee]'
                         }`}>
                            <step.icon className="w-6 h-6" />
                         </div>
                         <span className={`text-xs font-black uppercase tracking-[0.2em] ${step.status === 'pending' ? 'text-[#a3acb9]' : 'text-[#1a1f36]'}`}>{step.label}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div className="grid grid-cols-4 gap-6">
                 {[
                    { label: 'Data Drift', value: '1.2%', icon: BarChart, color: 'text-blue-500' },
                    { label: 'GPU Load', value: '44%', icon: Server, color: 'text-purple-500' },
                    { label: 'Success Ratio', value: '100%', icon: CheckCircle2, color: 'text-green-500' },
                    { label: 'Cost/Cycle', value: '$0.42', icon: Zap, color: 'text-orange-500' },
                 ].map((m, i) => (
                    <div key={i} className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] shadow-sm">
                       <m.icon className={`w-6 h-6 mb-4 ${m.color}`} />
                       <div className="text-3xl font-black text-[#1a1f36]">{m.value}</div>
                       <div className="text-[10px] font-black text-[#697386] uppercase tracking-[0.2em] mt-1">{m.label}</div>
                    </div>
                 ))}
              </div>
            </div>
          )}

          {activeTab === 'jobs' && (
            <div className="space-y-6 animate-in slide-in-from-right-4">
              {jobs.length === 0 ? (
                 <div className="py-40 text-center bg-white rounded-[48px] border border-[#e3e8ee] text-[#a3acb9]">
                    <History className="w-16 h-16 mx-auto mb-4 opacity-10" />
                    <p className="text-lg font-bold">Pipeline history is currently empty.</p>
                 </div>
              ) : (
                [...jobs].reverse().map(job => (
                  <div key={job.id} className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] flex items-center justify-between hover:shadow-md transition-all">
                     <div className="flex items-center gap-8">
                        <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${
                           job.status === 'success' ? 'bg-[#e6fff4] text-[#00ca72]' :
                           job.status === 'failed' ? 'bg-[#fff0f0] text-[#ff4d4d]' : 'bg-[#f0f4ff] text-[#6366f1]'
                        }`}>
                           {job.status === 'success' ? <CheckCircle2 className="w-7 h-7" /> : 
                            job.status === 'failed' ? <AlertCircle className="w-7 h-7" /> : <RefreshCw className="w-7 h-7 animate-spin" />}
                        </div>
                        <div>
                           <div className="text-xl font-bold text-[#1a1f36] flex items-center gap-4">
                              Deployment {job.id.substring(0, 8)}
                              <span className={`text-[10px] font-black uppercase px-3 py-1 rounded-full border ${getStatusColor(job.status)}`}>{job.status}</span>
                           </div>
                           <div className="text-sm font-medium text-[#697386] mt-1">
                              Triggered by <span className="text-[#1a1f36] font-bold">{job.trigger.toUpperCase()}</span> • {new Date(job.startTime).toLocaleString()}
                           </div>
                        </div>
                     </div>
                     
                     <div className="flex items-center gap-12">
                        {job.accuracyGain !== undefined && (
                           <div className="text-right">
                              <div className={`text-2xl font-black ${job.accuracyGain >= 0 ? 'text-[#00ca72]' : 'text-[#ff4d4d]'}`}>
                                 {job.accuracyGain > 0 ? '+' : ''}{job.accuracyGain}%
                              </div>
                              <div className="text-[10px] font-black text-[#a3acb9] uppercase tracking-widest">Accuracy Delta</div>
                           </div>
                        )}
                        <div className="text-right">
                           <div className="text-sm font-mono font-black text-[#1a1f36] bg-[#f7f8f9] px-3 py-1 rounded-lg border border-[#e3e8ee]">{job.newVersion || 'N/A'}</div>
                           <div className="text-[10px] font-black text-[#a3acb9] uppercase tracking-widest mt-1">Target Ver.</div>
                        </div>
                     </div>
                  </div>
                ))
              )}
            </div>
          )}

          {activeTab === 'settings' && (
            <div className="max-w-3xl space-y-12 animate-in slide-in-from-right-4 bg-white p-12 rounded-[48px] border border-[#e3e8ee]">
               <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                     <Zap className="w-7 h-7 text-[#6366f1]" />
                     <h3 className="text-2xl font-black text-[#1a1f36]">Autonomy Control</h3>
                  </div>
                  <button 
                    onClick={() => onUpdateConfig({ ...config, enabled: !config.enabled })}
                    className={`px-8 py-3 rounded-2xl text-xs font-black uppercase tracking-widest transition-all ${
                       config.enabled ? 'bg-[#00ca72] text-white shadow-xl shadow-[#00ca72]/20' : 'bg-[#e3e8ee] text-[#697386]'
                    }`}
                  >
                    {config.enabled ? 'Pipeline Online' : 'Pipeline Offline'}
                  </button>
               </div>

               <div className="grid grid-cols-1 gap-10">
                <div className="space-y-4">
                   <label className="text-xs font-black text-[#697386] uppercase tracking-[0.2em]">Deployment Recurrence</label>
                   <div className="grid grid-cols-3 gap-4">
                      {['daily', 'weekly', 'monthly'].map(s => (
                         <button 
                           key={s}
                           onClick={() => onUpdateConfig({ ...config, schedule: s as any })}
                           className={`py-5 rounded-[24px] border-2 font-black text-sm uppercase tracking-widest transition-all ${
                              config.schedule === s ? 'bg-[#f0f4ff] text-[#6366f1] border-[#6366f1]' : 'bg-transparent text-[#a3acb9] border-[#e3e8ee] hover:bg-[#f7f8f9]'
                           }`}
                         >
                           {s}
                         </button>
                      ))}
                   </div>
                </div>

                <div className="grid grid-cols-2 gap-10">
                   <div className="space-y-5">
                      <label className="text-xs font-black text-[#697386] uppercase tracking-[0.2em] block">Drift Sensitivity</label>
                      <div className="flex items-center gap-6">
                         <input 
                            type="range" min="1" max="50" value={config.driftThreshold} 
                            onChange={(e) => onUpdateConfig({ ...config, driftThreshold: parseInt(e.target.value) })}
                            className="flex-1 accent-[#6366f1]" 
                         />
                         <span className="text-2xl font-black text-[#6366f1] w-16">{config.driftThreshold}%</span>
                      </div>
                   </div>

                   <div className="space-y-5">
                      <label className="text-xs font-black text-[#697386] uppercase tracking-[0.2em] block">SLA Performance</label>
                      <div className="flex items-center gap-6">
                         <input 
                            type="range" min="1" max="20" value={config.performanceThreshold} 
                            onChange={(e) => onUpdateConfig({ ...config, performanceThreshold: parseInt(e.target.value) })}
                            className="flex-1 accent-[#ff4d4d]" 
                         />
                         <span className="text-2xl font-black text-[#ff4d4d] w-16">{config.performanceThreshold}%</span>
                      </div>
                   </div>
                </div>
               </div>

               <div className="p-8 bg-[#f0f4ff] border border-[#6366f1]/20 rounded-[32px] flex gap-6 items-start">
                  <Shield className="w-8 h-8 text-[#6366f1] shrink-0 mt-1" />
                  <div>
                     <h5 className="font-black text-[#6366f1] text-lg mb-1 uppercase tracking-tight">Security & Validation</h5>
                     <p className="text-sm text-[#4f566b] leading-relaxed font-medium">Every retrained model undergoes isolated shadow testing against the workspace's historical Golden Dataset. Automated promotion to production only occurs if performance is strictly improved.</p>
                  </div>
               </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AIRetrainingPage;
