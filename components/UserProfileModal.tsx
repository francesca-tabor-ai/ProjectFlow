
import React, { useState } from 'react';
import { X, User as UserIcon, Mail, Camera, Save, LogOut } from 'lucide-react';
import { User } from '../types';

interface UserProfileModalProps {
  user: User;
  onClose: () => void;
  onUpdate: (updatedUser: User) => void;
  onLogout: () => void;
}

const UserProfileModal: React.FC<UserProfileModalProps> = ({ user, onClose, onUpdate, onLogout }) => {
  const [name, setName] = useState(user.name);
  const [email, setEmail] = useState(user.email);
  const [saving, setSaving] = useState(false);

  const handleSave = () => {
    setSaving(true);
    setTimeout(() => {
      onUpdate({ ...user, name, email });
      setSaving(false);
      onClose();
    }, 600);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-[#1a1f36]/40 backdrop-blur-md p-4 animate-in fade-in duration-200">
      <div className="bg-white rounded-[24px] w-full max-w-md shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-300">
        <div className="p-6 border-b border-[#e3e8ee] flex items-center justify-between">
          <h3 className="text-xl font-bold text-[#1a1f36]">Account Settings</h3>
          <button onClick={onClose} className="p-2 hover:bg-[#f7f8f9] rounded-full transition-colors text-[#a3acb9] hover:text-[#1a1f36]">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-8 space-y-8">
          <div className="flex flex-col items-center">
            <div className="relative group cursor-pointer">
              <div className="w-24 h-24 rounded-3xl stripe-gradient flex items-center justify-center text-white text-3xl font-bold shadow-xl">
                {user.name.charAt(0)}
              </div>
              <div className="absolute inset-0 bg-black/20 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center backdrop-blur-[2px]">
                <Camera className="w-6 h-6 text-white" />
              </div>
            </div>
            <p className="mt-4 text-sm font-bold text-[#6366f1] uppercase tracking-widest">Update Photo</p>
          </div>

          <div className="space-y-5">
            <div className="space-y-1.5">
              <label className="text-[11px] font-bold text-[#697386] uppercase tracking-wider ml-1 flex items-center gap-2">
                <UserIcon className="w-3.5 h-3.5" /> Full Name
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-4 py-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-[11px] font-bold text-[#697386] uppercase tracking-wider ml-1 flex items-center gap-2">
                <Mail className="w-3.5 h-3.5" /> Email address
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-3 bg-[#f7f8f9] border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all"
              />
            </div>
          </div>

          <div className="pt-4 space-y-3">
            <button
              onClick={handleSave}
              disabled={saving}
              className="w-full py-4 bg-[#1a1f36] text-white font-bold rounded-xl shadow-lg hover:bg-[#2e344a] transition-all flex items-center justify-center gap-2 active:scale-[0.98]"
            >
              {saving ? (
                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  Save changes
                </>
              )}
            </button>
            <button
              onClick={onLogout}
              className="w-full py-3 bg-white text-[#ff4d4d] font-bold text-[14px] rounded-xl border border-[#ffebed] hover:bg-[#ffebed] transition-all flex items-center justify-center gap-2"
            >
              <LogOut className="w-4 h-4" />
              Sign out of ProjectFlow
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserProfileModal;
