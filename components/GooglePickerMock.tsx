
import React from 'react';
import { X, Cloud, Search, FileText, FileSpreadsheet, Image as ImageIcon, Check } from 'lucide-react';

interface GooglePickerMockProps {
  onClose: () => void;
  onSelect: (file: { id: string; name: string; type: string; size: number; url: string }) => void;
}

const GooglePickerMock: React.FC<GooglePickerMockProps> = ({ onClose, onSelect }) => {
  const mockFiles = [
    { id: 'gd-1', name: 'Brand Guidelines 2024.pdf', type: 'application/pdf', size: 4500000, icon: <FileText className="w-5 h-5 text-red-500" /> },
    { id: 'gd-2', name: 'Q3 Financial Projections.xlsx', type: 'application/vnd.ms-excel', size: 120000, icon: <FileSpreadsheet className="w-5 h-5 text-green-500" /> },
    { id: 'gd-3', name: 'Product Hero Banner.png', type: 'image/png', size: 890000, icon: <ImageIcon className="w-5 h-5 text-blue-500" /> },
    { id: 'gd-4', name: 'Project Brief.docx', type: 'application/msword', size: 45000, icon: <FileText className="w-5 h-5 text-blue-400" /> },
  ];

  return (
    <div className="fixed inset-0 z-[120] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className="bg-white rounded-xl w-full max-w-xl shadow-2xl flex flex-col overflow-hidden animate-in slide-in-from-top-4 duration-300">
        <div className="px-6 py-4 border-b border-[#e3e8ee] flex items-center justify-between">
          <div className="flex items-center gap-2 text-[#4285F4]">
            <Cloud className="w-5 h-5" />
            <span className="font-bold text-[14px]">Select from Google Drive</span>
          </div>
          <button onClick={onClose} className="p-1 hover:bg-[#f7f8f9] rounded text-[#a3acb9]">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-4 bg-[#fbfcfd] border-b border-[#e3e8ee]">
          <div className="flex items-center gap-3 px-3 py-2 bg-white border border-[#e3e8ee] rounded-md shadow-sm">
            <Search className="w-4 h-4 text-[#a3acb9]" />
            <input type="text" placeholder="Search Drive" className="bg-transparent border-none outline-none text-sm w-full" />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto max-h-[400px]">
          <div className="grid grid-cols-1">
            {mockFiles.map(file => (
              <button 
                key={file.id}
                onClick={() => onSelect({ ...file, url: '#' })}
                className="flex items-center justify-between px-6 py-4 hover:bg-[#f0f4ff] border-b border-[#f0f2f5] transition-colors group"
              >
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 bg-[#f7f8f9] rounded flex items-center justify-center group-hover:bg-white transition-colors">
                    {file.icon}
                  </div>
                  <div className="text-left">
                    <div className="text-[14px] font-bold text-[#1a1f36]">{file.name}</div>
                    <div className="text-[11px] text-[#697386]">Modified 2 days ago</div>
                  </div>
                </div>
                <Check className="w-4 h-4 text-[#6366f1] opacity-0 group-hover:opacity-100 transition-opacity" />
              </button>
            ))}
          </div>
        </div>

        <div className="p-4 bg-[#fbfcfd] border-t border-[#e3e8ee] flex justify-end gap-3">
          <button onClick={onClose} className="px-4 py-2 text-sm font-bold text-[#697386] hover:text-[#1a1f36]">Cancel</button>
          <button className="px-6 py-2 bg-[#4285F4] text-white font-bold rounded-lg shadow-sm hover:bg-[#3367D6] transition-all">Select</button>
        </div>
      </div>
    </div>
  );
};

export default GooglePickerMock;
