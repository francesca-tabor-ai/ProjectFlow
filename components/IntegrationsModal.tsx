
import React, { useState } from 'react';
import { Plug, Slack, Cloud, MessageSquare, Terminal, Key, Plus, Trash2, CheckCircle2, RefreshCw, ExternalLink } from 'lucide-react';
import { IntegrationSettings } from '../types';

interface IntegrationsPageProps {
  settings: IntegrationSettings;
  onUpdate: (updates: Partial<IntegrationSettings>) => void;
}

const IntegrationsPage: React.FC<IntegrationsPageProps> = ({ settings, onUpdate }) => {
  const [activeTab, setActiveTab] = useState<'apps' | 'api'>('apps');
  const [slackUrl, setSlackUrl] = useState(settings.slackWebhook || '');
  const [teamsUrl, setTeamsUrl] = useState(settings.teamsWebhook || '');
  const [isConnecting, setIsConnecting] = useState<string | null>(null);

  const handleConnectGoogle = () => {
    setIsConnecting('google');
    setTimeout(() => {
      onUpdate({ googleDriveConnected: true });
      setIsConnecting(null);
    }, 1500);
  };

  const generateApiKey = () => {
    const name = prompt("Key name (e.g. My Custom Script):");
    if (!name) return;
    const newKey = {
      id: `key-${Date.now()}`,
      name,
      key: `pf_${Math.random().toString(36).substring(2, 15)}`,
      createdAt: Date.now()
    };
    onUpdate({ apiKeys: [...settings.apiKeys, newKey] });
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[#f7f8f9] overflow-hidden animate-in fade-in duration-300">
      <div className="p-8 border-b border-[#e3e8ee] flex items-center justify-between bg-white shrink-0">
        <div className="flex items-center gap-5">
          <div className="w-14 h-14 bg-[#6366f1]/10 rounded-[20px] flex items-center justify-center">
            <Plug className="w-8 h-8 text-[#6366f1]" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-[#1a1f36]">Connected Integrations</h2>
            <p className="text-[#697386] text-sm font-medium mt-1">Unified ecosystem for your project data and communication.</p>
          </div>
        </div>
        <div className="flex bg-[#f7f8f9] p-1 rounded-xl border border-[#e3e8ee]">
          <button 
            onClick={() => setActiveTab('apps')}
            className={`px-6 py-2 text-sm font-bold rounded-lg transition-all ${activeTab === 'apps' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386]'}`}
          >
            Marketplace
          </button>
          <button 
            onClick={() => setActiveTab('api')}
            className={`px-6 py-2 text-sm font-bold rounded-lg transition-all ${activeTab === 'api' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386]'}`}
          >
            Developer API
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-10 custom-scrollbar">
        <div className="max-w-4xl mx-auto space-y-10">
          {activeTab === 'apps' ? (
            <div className="grid grid-cols-1 gap-6">
              {/* Google Drive */}
              <div className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] flex items-center justify-between hover:shadow-md transition-all">
                <div className="flex items-center gap-8">
                  <div className="w-20 h-20 bg-[#f7f8f9] rounded-2xl flex items-center justify-center text-blue-500 shadow-inner">
                    <Cloud className="w-10 h-10" />
                  </div>
                  <div>
                    <h4 className="text-xl font-bold text-[#1a1f36]">Google Drive</h4>
                    <p className="text-[#697386] font-medium mt-1">Cloud storage sync for document attachments.</p>
                  </div>
                </div>
                {settings.googleDriveConnected ? (
                  <div className="flex items-center gap-4">
                    <span className="text-xs font-black text-[#00ca72] bg-[#e6fff4] px-4 py-2 rounded-full border border-[#00ca72]/20">CONNECTED</span>
                    <button onClick={() => onUpdate({ googleDriveConnected: false })} className="text-sm font-bold text-[#ff4d4d] hover:underline">Revoke Access</button>
                  </div>
                ) : (
                  <button onClick={handleConnectGoogle} className="px-8 py-3 bg-[#1a1f36] text-white font-bold rounded-xl shadow-lg">Install App</button>
                )}
              </div>

              {/* Slack */}
              <div className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] space-y-6">
                <div className="flex items-center justify-between">
                   <div className="flex items-center gap-8">
                    <div className="w-20 h-20 bg-[#f7f8f9] rounded-2xl flex items-center justify-center text-[#E01E5A] shadow-inner">
                      <Slack className="w-10 h-10" />
                    </div>
                    <div>
                      <h4 className="text-xl font-bold text-[#1a1f36]">Slack Webhooks</h4>
                      <p className="text-[#697386] font-medium mt-1">Broadcast real-time task changes to channels.</p>
                    </div>
                  </div>
                  <button onClick={() => onUpdate({ slackWebhook: slackUrl })} className="px-6 py-2.5 bg-[#6366f1] text-white rounded-xl text-sm font-bold shadow-md">Update URL</button>
                </div>
                <input 
                  type="text"
                  placeholder="https://hooks.slack.com/services/..."
                  value={slackUrl}
                  onChange={(e) => setSlackUrl(e.target.value)}
                  className="w-full px-5 py-4 bg-[#f7f8f9] border border-[#e3e8ee] rounded-2xl outline-none font-mono text-xs"
                />
              </div>

              {/* MS Teams */}
              <div className="p-8 bg-white border border-[#e3e8ee] rounded-[32px] space-y-6">
                <div className="flex items-center justify-between">
                   <div className="flex items-center gap-8">
                    <div className="w-20 h-20 bg-[#f7f8f9] rounded-2xl flex items-center justify-center text-[#464EB8] shadow-inner">
                      <MessageSquare className="w-10 h-10" />
                    </div>
                    <div>
                      <h4 className="text-xl font-bold text-[#1a1f36]">Microsoft Teams</h4>
                      <p className="text-[#697386] font-medium mt-1">Native collaboration with Microsoft 365.</p>
                    </div>
                  </div>
                  <button onClick={() => onUpdate({ teamsWebhook: teamsUrl })} className="px-6 py-2.5 bg-[#6366f1] text-white rounded-xl text-sm font-bold shadow-md">Update URL</button>
                </div>
                <input 
                  type="text"
                  placeholder="https://company.webhook.office.com/..."
                  value={teamsUrl}
                  onChange={(e) => setTeamsUrl(e.target.value)}
                  className="w-full px-5 py-4 bg-[#f7f8f9] border border-[#e3e8ee] rounded-2xl outline-none font-mono text-xs"
                />
              </div>
            </div>
          ) : (
            <div className="space-y-10">
              <div className="bg-[#1a1f36] p-10 rounded-[40px] text-white relative overflow-hidden">
                 <div className="absolute top-0 right-0 w-64 h-64 bg-[#6366f1]/10 rounded-full blur-3xl -mr-32 -mt-32"></div>
                 <div className="relative flex items-center gap-4 mb-4 text-[#6366f1]">
                    <Terminal className="w-6 h-6" />
                    <h4 className="text-lg font-black uppercase tracking-[0.2em]">Developer Core</h4>
                 </div>
                 <h3 className="text-3xl font-black mb-4">Build on ProjectFlow</h3>
                 <p className="text-white/60 leading-relaxed mb-8 max-w-2xl text-lg">
                   The ProjectFlow Public API allows you to programmatically access sheets, trigger automations, and sync project states with your own proprietary tools.
                 </p>
                 <button className="px-8 py-4 bg-[#6366f1] text-white font-bold rounded-2xl shadow-2xl hover:scale-105 active:scale-95 transition-all">Explore Documentation</button>
              </div>

              <div className="space-y-6">
                <div className="flex items-center justify-between px-2">
                  <h4 className="text-xs font-black text-[#697386] uppercase tracking-[0.2em]">Authentication Keys</h4>
                  <button onClick={generateApiKey} className="flex items-center gap-2 px-4 py-2 bg-white border border-[#e3e8ee] rounded-xl text-xs font-bold hover:shadow-sm transition-all"><Plus className="w-4 h-4" /> Issue New Key</button>
                </div>

                <div className="space-y-4">
                  {settings.apiKeys.length === 0 ? (
                    <div className="py-24 border-2 border-dashed border-[#e3e8ee] rounded-[32px] flex flex-col items-center justify-center text-[#a3acb9]">
                      <Key className="w-12 h-12 mb-4 opacity-20" />
                      <p className="text-lg font-bold italic">No active API keys issue.</p>
                    </div>
                  ) : (
                    settings.apiKeys.map(key => (
                      <div key={key.id} className="p-6 bg-white border border-[#e3e8ee] rounded-[24px] flex items-center justify-between group hover:border-[#6366f1]/30 transition-all">
                        <div className="flex items-center gap-6">
                          <div className="w-12 h-12 bg-[#f7f8f9] rounded-xl flex items-center justify-center text-[#a3acb9]">
                            <Key className="w-6 h-6" />
                          </div>
                          <div>
                            <div className="text-lg font-bold text-[#1a1f36]">{key.name}</div>
                            <div className="text-xs font-mono text-[#a3acb9] mt-1">{key.key.substring(0, 16)}••••••••</div>
                          </div>
                        </div>
                        <button onClick={() => onUpdate({ apiKeys: settings.apiKeys.filter(k => k.id !== key.id) })} className="p-3 text-[#ff4d4d] hover:bg-[#ffebed] rounded-xl opacity-0 group-hover:opacity-100 transition-all"><Trash2 className="w-5 h-5" /></button>
                      </div>
                    ))
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default IntegrationsPage;
