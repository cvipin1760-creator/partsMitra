import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';
import AuthService from '../services/auth.service';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Mail, 
  Lock, 
  Smartphone,
  ShieldCheck,
  ArrowRight,
  AlertCircle,
  CheckCircle2,
  Languages,
  ArrowLeft
} from 'lucide-react';

const ForgotPassword = () => {
  const { t, language, toggleLanguage } = useLanguage();
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const navigate = useNavigate();

  const handleSendOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !email.includes('@')) {
      setMessage(t('login.email') + ' ' + t('common.error'));
      return;
    }
    setLoading(true);
    try {
      // Re-using AuthService.sendOtp, assuming backend handles purpose=reset or similar
      await AuthService.sendOtp(email);
      setOtpSent(true);
      setMessage('OTP sent to your email for password reset.');
    } catch (err: any) {
      setMessage(err.response?.data?.message || t('common.error'));
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      // Check if AuthService has resetPassword
      // If not, we'll use api directly or assume it exists
      // Based on my previous search, backend has /api/auth/reset-password (POST)
      const response = await (AuthService as any).resetPassword(email, otp, newPassword);
      setMessage('Password reset successful! Redirecting to login...');
      setTimeout(() => navigate('/login'), 3000);
    } catch (err: any) {
      setMessage(err.response?.data?.message || 'Reset failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col items-center justify-center py-12 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden -z-10">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary-100/30 rounded-full blur-3xl"></div>
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-primary-100/20 rounded-full blur-3xl"></div>
      </div>

      <motion.button
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        onClick={toggleLanguage}
        className="absolute top-6 right-6 flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 rounded-full shadow-sm hover:shadow-md transition-all text-sm font-medium text-gray-700 z-10"
      >
        <Languages size={18} className="text-primary-600" />
        {language === 'en' ? 'हिन्दी' : 'English'}
      </motion.button>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="max-w-md w-full space-y-8"
      >
        <div className="text-center">
          <motion.div 
            initial={{ scale: 0.5, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="mx-auto h-20 w-20 bg-primary-600 rounded-2xl flex items-center justify-center shadow-xl shadow-primary-200 mb-6"
          >
            <ShieldCheck size={40} className="text-white" />
          </motion.div>
          <h2 className="text-4xl font-black text-gray-900 tracking-tight">
            Reset Password
          </h2>
          <p className="mt-3 text-gray-500 font-medium">
            Follow the steps to regain access to your account
          </p>
        </div>

        <div className="bg-white p-8 sm:p-10 rounded-[2.5rem] border border-gray-100 shadow-2xl shadow-gray-200/50">
          <AnimatePresence mode="wait">
            {message && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className={`p-4 mb-6 rounded-2xl text-sm flex items-center gap-3 ${
                  message.includes('success') || message.includes('sent')
                    ? 'bg-green-50 text-green-700 border border-green-100' 
                    : 'bg-red-50 text-red-700 border border-red-100'
                }`}
              >
                {message.includes('success') || message.includes('sent') ? <CheckCircle2 size={18} /> : <AlertCircle size={18} />}
                <span className="font-medium">{message}</span>
              </motion.div>
            )}
          </AnimatePresence>

          {!otpSent ? (
            <form onSubmit={handleSendOtp} className="space-y-6">
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-gray-500 uppercase tracking-wider ml-1 block">
                  {t('login.email')}
                </label>
                <div className="relative group">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400 group-focus-within:text-primary-600 transition-colors">
                    <Mail size={18} />
                  </div>
                  <input
                    type="email"
                    className="block w-full pl-11 pr-4 py-3.5 bg-gray-50 border border-gray-100 text-gray-900 text-sm rounded-2xl focus:ring-2 focus:ring-primary-500 focus:border-transparent focus:bg-white transition-all outline-none font-medium"
                    placeholder="name@company.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full group relative flex items-center justify-center py-4 px-4 bg-primary-600 hover:bg-primary-700 text-white rounded-[1.25rem] font-black transition-all shadow-xl shadow-primary-200 active:scale-[0.98] disabled:opacity-70 disabled:active:scale-100"
              >
                {loading ? (
                  <div className="flex items-center gap-2">
                    <div className="w-5 h-5 border-3 border-white/30 border-t-white rounded-full animate-spin"></div>
                    <span>{t('common.loading')}</span>
                  </div>
                ) : (
                  <div className="flex items-center gap-2">
                    <span>{t('login.sendOtp')}</span>
                    <ArrowRight size={18} className="ml-1 group-hover:translate-x-1 transition-transform" />
                  </div>
                )}
              </button>
            </form>
          ) : (
            <form onSubmit={handleResetPassword} className="space-y-6">
              <div className="space-y-5">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-gray-500 uppercase tracking-wider ml-1 block">
                    {t('login.otp')}
                  </label>
                  <div className="relative group">
                    <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400 group-focus-within:text-primary-600 transition-colors">
                      <Smartphone size={18} />
                    </div>
                    <input
                      type="text"
                      className="block w-full pl-11 pr-4 py-3.5 bg-gray-50 border border-gray-100 text-gray-900 text-sm rounded-2xl focus:ring-2 focus:ring-primary-500 focus:border-transparent focus:bg-white transition-all outline-none font-medium"
                      value={otp}
                      onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                      required
                      placeholder="6-digit OTP"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-gray-500 uppercase tracking-wider ml-1 block">
                    New Password
                  </label>
                  <div className="relative group">
                    <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400 group-focus-within:text-primary-600 transition-colors">
                      <Lock size={18} />
                    </div>
                    <input
                      type="password"
                      className="block w-full pl-11 pr-4 py-3.5 bg-gray-50 border border-gray-100 text-gray-900 text-sm rounded-2xl focus:ring-2 focus:ring-primary-500 focus:border-transparent focus:bg-white transition-all outline-none font-medium"
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      required
                      placeholder="••••••••"
                      minLength={6}
                    />
                  </div>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full group relative flex items-center justify-center py-4 px-4 bg-primary-600 hover:bg-primary-700 text-white rounded-[1.25rem] font-black transition-all shadow-xl shadow-primary-200 active:scale-[0.98] disabled:opacity-70 disabled:active:scale-100"
              >
                {loading ? (
                  <div className="flex items-center gap-2">
                    <div className="w-5 h-5 border-3 border-white/30 border-t-white rounded-full animate-spin"></div>
                    <span>{t('common.loading')}</span>
                  </div>
                ) : (
                  <div className="flex items-center gap-2">
                    <span>Reset Password</span>
                    <ArrowRight size={18} className="ml-1 group-hover:translate-x-1 transition-transform" />
                  </div>
                )}
              </button>
            </form>
          )}

          <div className="mt-8 flex justify-center">
            <Link to="/login" className="flex items-center gap-2 text-sm font-bold text-gray-400 hover:text-primary-600 transition-colors">
              <ArrowLeft size={16} />
              Back to Login
            </Link>
          </div>
        </div>
      </motion.div>
    </div>
  );
};

export default ForgotPassword;
