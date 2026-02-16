
import React, { useState, useRef, useEffect } from 'react';
import { X, Send, AtSign, MessageSquare, Paperclip, FileText, Download, Trash2, Plus, Image as ImageIcon, File, Cloud } from 'lucide-react';
import { Comment, Member, User, FileAttachment } from '../types';

interface CommentsPanelProps {
  rowId: string;
  rowName: string;
  comments: Comment[];
  attachments: FileAttachment[];
  members: Member[];
  currentUser: User;
  onClose: () => void;
  onAddComment: (rowId: string, text: string) => void;
  onAddAttachment: (rowId: string, attachment: FileAttachment) => void;
  onDeleteAttachment: (rowId: string, attachmentId: string) => void;
  onGoogleDrive: () => void;
  isGoogleConnected: boolean;
}

const CommentsPanel: React.FC<CommentsPanelProps> = ({
  rowId,
  rowName,
  comments,
  attachments,
  members,
  currentUser,
  onClose,
  onAddComment,
  onAddAttachment,
  onDeleteAttachment,
  onGoogleDrive,
  isGoogleConnected
}) => {
  const [activeTab, setActiveTab] = useState<'comments' | 'attachments'>('comments');
  const [text, setText] = useState('');
  const [showMentions, setShowMentions] = useState(false);
  const [mentionFilter, setMentionFilter] = useState('');
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [comments, activeTab]);

  const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value;
    setText(value);

    const cursorPosition = e.target.selectionStart;
    const lastAtSymbol = value.lastIndexOf('@', cursorPosition - 1);

    if (lastAtSymbol !== -1) {
      const textAfterAt = value.substring(lastAtSymbol + 1, cursorPosition);
      if (!textAfterAt.includes(' ')) {
        setShowMentions(true);
        setMentionFilter(textAfterAt.toLowerCase());
        return;
      }
    }
    setShowMentions(false);
  };

  const insertMention = (member: Member) => {
    const cursorPosition = inputRef.current?.selectionStart || 0;
    const lastAtSymbol = text.lastIndexOf('@', cursorPosition - 1);
    const newText = text.substring(0, lastAtSymbol) + `@${member.name} ` + text.substring(cursorPosition);
    setText(newText);
    setShowMentions(false);
    inputRef.current?.focus();
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!text.trim()) return;
    onAddComment(rowId, text.trim());
    setText('');
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const newAttachment: FileAttachment = {
        id: `file-${Date.now()}`,
        name: file.name,
        type: file.type,
        size: file.size,
        url: event.target?.result as string || '', 
        timestamp: Date.now(),
        provider: 'local'
      };
      onAddAttachment(rowId, newAttachment);
      if (fileInputRef.current) fileInputRef.current.value = '';
    };
    reader.readAsDataURL(file);
  };

  const formatSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const getFileIcon = (file: FileAttachment) => {
    if (file.provider === 'google_drive') return <Cloud className="w-5 h-5 text-blue-400" />;
    if (file.type.startsWith('image/')) return <ImageIcon className="w-5 h-5 text-pink-500" />;
    if (file.type.includes('pdf')) return <FileText className="w-5 h-5 text-red-500" />;
    return <File className="w-5 h-5 text-blue-500" />;
  };

  const filteredMembers = members.filter(m => 
    m.name.toLowerCase().includes(mentionFilter) || 
    m.email.toLowerCase().includes(mentionFilter)
  );

  return (
    <div className="fixed inset-y-0 right-0 w-96 bg-white border-l border-[#e3e8ee] shadow-2xl z-[60] flex flex-col animate-in slide-in-from-right duration-300">
      <div className="p-6 border-b border-[#e3e8ee] flex flex-col bg-[#fbfcfd] shrink-0">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-sm font-bold text-[#1a1f36] flex items-center gap-2">
              <MessageSquare className="w-4 h-4 text-[#6366f1]" />
              Details
            </h3>
            <p className="text-[12px] text-[#697386] font-medium truncate max-w-[240px] mt-0.5">
              Row: {rowName || 'Untitled Row'}
            </p>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-[#f7f8f9] rounded-full transition-colors text-[#a3acb9] hover:text-[#1a1f36]">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex bg-[#f7f8f9] p-1 rounded-xl border border-[#e3e8ee]">
          <button 
            onClick={() => setActiveTab('comments')}
            className={`flex-1 flex items-center justify-center gap-2 py-2 text-[12px] font-bold rounded-lg transition-all ${
              activeTab === 'comments' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386] hover:text-[#1a1f36]'
            }`}
          >
            <MessageSquare className="w-3.5 h-3.5" />
            Comments
            {comments.length > 0 && <span className="ml-1 px-1.5 py-0.5 bg-[#6366f1] text-white rounded-full text-[9px]">{comments.length}</span>}
          </button>
          <button 
            onClick={() => setActiveTab('attachments')}
            className={`flex-1 flex items-center justify-center gap-2 py-2 text-[12px] font-bold rounded-lg transition-all ${
              activeTab === 'attachments' ? 'bg-white text-[#6366f1] shadow-sm' : 'text-[#697386] hover:text-[#1a1f36]'
            }`}
          >
            <Paperclip className="w-3.5 h-3.5" />
            Files
            {attachments.length > 0 && <span className="ml-1 px-1.5 py-0.5 bg-[#6366f1] text-white rounded-full text-[9px]">{attachments.length}</span>}
          </button>
        </div>
      </div>

      <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar">
        {activeTab === 'comments' ? (
          comments.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center opacity-40">
              <div className="w-16 h-16 bg-[#f7f8f9] rounded-full flex items-center justify-center mb-4">
                <MessageSquare className="w-8 h-8 text-[#a3acb9]" />
              </div>
              <p className="text-sm font-medium text-[#4f566b]">No comments yet.<br/>Start the conversation!</p>
            </div>
          ) : (
            comments.map((comment) => (
              <div key={comment.id} className="flex gap-4 group">
                <div className="w-8 h-8 rounded-lg stripe-gradient shrink-0 flex items-center justify-center text-white font-bold text-[10px] shadow-sm">
                  {comment.userName.charAt(0)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-baseline justify-between mb-1">
                    <span className="text-[13px] font-bold text-[#1a1f36] truncate">{comment.userName}</span>
                    <span className="text-[10px] font-medium text-[#a3acb9]">
                      {new Date(comment.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                  <div className="text-[14px] text-[#4f566b] leading-relaxed break-words whitespace-pre-wrap">
                    {comment.text.split(/(@\w+)/g).map((part, i) => 
                      part.startsWith('@') ? <span key={i} className="text-[#6366f1] font-bold">{part}</span> : part
                    )}
                  </div>
                </div>
              </div>
            ))
          )
        ) : (
          <div className="space-y-4">
            <div className="flex items-center justify-between mb-2">
               <span className="text-[11px] font-bold text-[#697386] uppercase tracking-wider">Attached Assets</span>
               <div className="flex gap-1">
                  <button 
                    onClick={() => fileInputRef.current?.click()}
                    title="Upload Local File"
                    className="p-1.5 bg-[#f0f4ff] text-[#6366f1] rounded-lg hover:bg-[#6366f1] hover:text-white transition-all shadow-sm"
                  >
                    <Plus className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={onGoogleDrive}
                    title="Attach from Google Drive"
                    className="p-1.5 bg-[#f0fdf4] text-[#16a34a] rounded-lg hover:bg-[#16a34a] hover:text-white transition-all shadow-sm"
                  >
                    <Cloud className="w-4 h-4" />
                  </button>
               </div>
               <input 
                  type="file" 
                  ref={fileInputRef} 
                  onChange={handleFileChange} 
                  className="hidden" 
               />
            </div>
            
            {attachments.length === 0 ? (
              <div className="py-12 flex flex-col items-center justify-center text-center opacity-40">
                <div className="w-16 h-16 bg-[#f7f8f9] rounded-full flex items-center justify-center mb-4">
                  <Paperclip className="w-8 h-8 text-[#a3acb9]" />
                </div>
                <p className="text-sm font-medium text-[#4f566b]">No files attached.<br/>Upload briefs, mockups, or reports.</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 gap-3">
                {attachments.map((file) => (
                  <div 
                    key={file.id} 
                    className="p-3.5 bg-white border border-[#e3e8ee] rounded-xl hover:border-[#6366f1]/30 hover:shadow-md transition-all group flex items-center gap-4"
                  >
                    <div className="w-12 h-12 bg-[#f7f8f9] rounded-lg flex items-center justify-center shrink-0">
                       {getFileIcon(file)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <h5 className="text-[13px] font-bold text-[#1a1f36] truncate leading-tight flex items-center gap-1.5">
                        {file.name}
                        {file.provider === 'google_drive' && <span className="text-[9px] px-1 bg-blue-100 text-blue-600 rounded">Drive</span>}
                      </h5>
                      <p className="text-[11px] text-[#697386] mt-1 font-medium">{formatSize(file.size)} • {new Date(file.timestamp).toLocaleDateString()}</p>
                    </div>
                    <div className="flex items-center gap-1">
                      <a 
                        href={file.url} 
                        target="_blank"
                        rel="noreferrer"
                        download={file.provider === 'local' ? file.name : undefined}
                        className="p-2 text-[#a3acb9] hover:text-[#6366f1] hover:bg-[#f0f4ff] rounded-lg transition-all"
                        title={file.provider === 'local' ? "Download" : "Open Link"}
                      >
                        <Download className="w-4 h-4" />
                      </a>
                      <button 
                        onClick={() => onDeleteAttachment(rowId, file.id)}
                        className="p-2 text-[#a3acb9] hover:text-[#ff4d4d] hover:bg-[#ffebed] rounded-lg transition-all"
                        title="Delete"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </div>

      <div className="p-6 bg-[#f7f8f9] border-t border-[#e3e8ee] relative shrink-0">
        {activeTab === 'comments' ? (
          <>
            {showMentions && filteredMembers.length > 0 && (
              <div className="absolute bottom-full left-6 right-6 mb-2 bg-white border border-[#e3e8ee] rounded-xl shadow-xl overflow-hidden z-20 animate-in fade-in slide-in-from-bottom-2">
                <div className="px-3 py-2 bg-[#fbfcfd] border-b border-[#e3e8ee] text-[10px] font-bold text-[#a3acb9] uppercase tracking-wider">
                  Mentions
                </div>
                <div className="max-h-48 overflow-y-auto custom-scrollbar">
                  {filteredMembers.map(member => (
                    <button
                      key={member.userId}
                      onClick={() => insertMention(member)}
                      className="w-full flex items-center gap-3 px-4 py-2.5 text-left hover:bg-[#f0f4ff] transition-colors group"
                    >
                      <div className="w-6 h-6 rounded-md stripe-gradient flex items-center justify-center text-white font-bold text-[8px]">
                        {member.name.charAt(0)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="text-[13px] font-bold text-[#1a1f36] group-hover:text-[#6366f1]">{member.name}</div>
                        <div className="text-[11px] text-[#a3acb9] truncate">{member.email}</div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            )}

            <form onSubmit={handleSubmit} className="relative">
              <textarea
                ref={inputRef}
                rows={1}
                value={text}
                onChange={handleInputChange}
                placeholder="Add a comment... (use @ to mention)"
                className="w-full pl-4 pr-12 py-3 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[14px] font-medium transition-all resize-none shadow-sm"
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handleSubmit(e);
                  }
                }}
              />
              <button
                type="submit"
                disabled={!text.trim()}
                className="absolute right-2 top-1/2 -translate-y-1/2 p-2 text-[#6366f1] hover:bg-[#f0f4ff] rounded-lg transition-all disabled:opacity-30"
              >
                <Send className="w-5 h-5" />
              </button>
            </form>
          </>
        ) : (
          <div className="flex gap-3">
            <button 
              onClick={() => fileInputRef.current?.click()}
              className="flex-1 py-3.5 bg-white border border-[#e3e8ee] text-[#1a1f36] font-bold rounded-xl shadow-sm hover:bg-[#f7f8f9] transition-all flex items-center justify-center gap-2 active:scale-[0.98]"
            >
              <Paperclip className="w-4 h-4 text-[#6366f1]" />
              Upload Local
            </button>
            <button 
              onClick={onGoogleDrive}
              className="flex-1 py-3.5 bg-white border border-[#e3e8ee] text-[#1a1f36] font-bold rounded-xl shadow-sm hover:bg-[#f7f8f9] transition-all flex items-center justify-center gap-2 active:scale-[0.98]"
            >
              <Cloud className="w-4 h-4 text-[#16a34a]" />
              Cloud Drive
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default CommentsPanel;
