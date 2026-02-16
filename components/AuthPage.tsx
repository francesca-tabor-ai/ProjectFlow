
import React, { useState } from 'react';
import { Activity, Mail, Lock, ArrowRight, Github, Chrome } from 'lucide-react';
import { User } from '../types';
import GoogleLoginButton from './GoogleLoginButton';

interface AuthPageProps {
  onAuthSuccess: (user: User) => void;
}

const AuthPage: React.FC<AuthPageProps> = ({ onAuthSuccess }) => {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    // Simulate API delay
    setTimeout(() => {
      const mockUser: User = {
        id: 'user-123',
        name: isLogin ? (email.split('@')[0] || 'Member') : name,
        email: email,
      };
      onAuthSuccess(mockUser);
      setLoading(false);
    }, 800);
  };

  return (
    <div className="min-h-screen w-full flex bg-[#f7f8f9] items-center justify-center p-6 relative overflow-hidden">
      {/* Background Decor */}
      <div className="absolute top-0 left-0 w-full h-full opacity-40 pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] stripe-gradient rounded-full blur-[120px]"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] stripe-gradient rounded-full blur-[120px]"></div>
      </div>

      <div className="w-full max-w-[440px] z-10 animate-in fade-in slide-in-from-bottom-4 duration-700">
        <div className="bg-white rounded-[32px] shadow-[0_32px_64px_-12px_rgba(0,0,0,0.14)] border border-[#e3e8ee] p-10 md:p-12 overflow-hidden relative">
          <div className="flex flex-col items-center mb-10">
            <div className="w-14 h-14 stripe-gradient rounded-2xl flex items-center justify-center shadow-lg mb-6 transform hover:rotate-6 transition-transform">
              <Activity className="w-8 h-8 text-white" />
            </div>
            <h1 className="text-[28px] font-extrabold text-[#1a1f36] tracking-tight text-center leading-tight">
              {isLogin ? 'Welcome back' : 'Create your account'}
            </h1>
            <p className="text-[#4f566b] font-medium text-[15px] mt-2 text-center">
              The infrastructure for high-performance teams.
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            {!isLogin && (
              <div className="space-y-1.5">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">Full Name</label>
                <div className="relative group">
                  <input
                    required
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="w-full px-4 py-3.5 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                    placeholder="Jane Cooper"
                  />
                </div>
              </div>
            )}
            
            <div className="space-y-1.5">
              <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider ml-1">Email address</label>
              <div className="relative group">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9] group-focus-within:text-[#6366f1] transition-colors" />
                <input
                  required
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-11 pr-4 py-3.5 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                  placeholder="name@company.com"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <div className="flex justify-between items-center ml-1">
                <label className="text-[13px] font-bold text-[#4f566b] uppercase tracking-wider">Password</label>
                {isLogin && <button type="button" className="text-[13px] font-bold text-[#6366f1] hover:text-[#4f46e5]">Forgot?</button>}
              </div>
              <div className="relative group">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#a3acb9] group-focus-within:text-[#6366f1] transition-colors" />
                <input
                  required
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-11 pr-4 py-3.5 bg-white border border-[#e3e8ee] rounded-xl focus:ring-4 focus:ring-[#6366f1]/10 focus:border-[#6366f1] outline-none text-[#1a1f36] font-medium transition-all group-hover:border-[#cbd5e1]"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-4 stripe-gradient text-white font-bold text-[16px] rounded-xl shadow-xl hover:shadow-2xl hover:scale-[1.01] active:scale-[0.98] disabled:opacity-70 transition-all flex items-center justify-center gap-2 mt-2"
            >
              {loading ? (
                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
              ) : (
                <>
                  {isLogin ? 'Sign in' : 'Create account'}
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          <div className="mt-8 relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-[#e3e8ee]"></div>
            </div>
            <div className="relative flex justify-center text-[12px] uppercase font-bold tracking-widest">
              <span className="bg-white px-4 text-[#a3acb9]">Or continue with</span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 mt-6">
            <GoogleLoginButton />
            <button className="flex items-center justify-center gap-2 py-3 border border-[#e3e8ee] rounded-xl hover:bg-[#f7f8f9] transition-all font-semibold text-[14px] text-[#4f566b]">
              <Github className="w-4 h-4" />
              GitHub
            </button>
          </div>
        </div>

        <div className="mt-8 text-center">
          <button 
            onClick={() => setIsLogin(!isLogin)}
            className="text-[15px] font-semibold text-[#4f566b] hover:text-[#1a1f36] transition-colors"
          >
            {isLogin ? "Don't have an account? " : "Already have an account? "}
            <span className="text-[#6366f1] font-bold underline decoration-2 underline-offset-4">
              {isLogin ? 'Sign up' : 'Log in'}
            </span>
          </button>
        </div>

        <div className="mt-12 flex justify-center gap-6 text-[13px] font-medium text-[#a3acb9]">
          <a href="#" className="hover:text-[#697386]">Privacy Policy</a>
          <a href="#" className="hover:text-[#697386]">Terms of Service</a>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
