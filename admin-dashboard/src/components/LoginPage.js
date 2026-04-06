import React from 'react';
import { GoogleLogin } from '@react-oauth/google';
import { Shield, Mail, LogIn, ChevronRight } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import jwtDecode from 'jwt-decode';
import { motion } from 'framer-motion';

const LoginPage = () => {
  const { login, loading } = useAuth();
  const [error, setError] = React.useState(null);
  const [isLoading, setIsLoading] = React.useState(false);

  const AUTHORIZED_DOMAINS = ['quarryforce.local', 'quarryforce.com', 'gmail.com'];

  const handleGoogleSuccess = async (credentialResponse) => {
    try {
      setIsLoading(true);
      setError(null);
      const decoded = jwtDecode(credentialResponse.credential);
      const { email, name, picture, email_verified } = decoded;

      if (!email_verified) {
        setError('Email not verified by Google.');
        return;
      }

      const emailDomain = email.split('@')[1];
      if (!AUTHORIZED_DOMAINS.includes(emailDomain)) {
        setError(`Domain "${emailDomain}" is not authorized.`);
        return;
      }

      const userData = {
        id: decoded.sub,
        name: name || email.split('@')[0],
        email: email,
        role: 'admin',
        avatar: picture || null,
        provider: 'google',
      };

      login(userData);
      localStorage.setItem('googleToken', credentialResponse.credential);
      localStorage.setItem('user', JSON.stringify(userData));
    } catch (err) {
      setError('Failed to process login.');
    } finally {
      setIsLoading(false);
    }
  };

  if (loading) return (
    <div className="min-h-screen bg-[#F8FAFC] flex items-center justify-center">
      <div className="w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
    </div>
  );

  return (
    <div className="min-h-screen bg-[#0F172A] flex items-center justify-center p-6 relative overflow-hidden font-inter">
      {/* Decorative Blobs */}
      <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] bg-blue-600/20 blur-[120px] rounded-full animate-pulse" />
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-indigo-600/10 blur-[100px] rounded-full" />

      <motion.div 
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-full max-w-[480px] z-10"
      >
        <div className="glass-card bg-white/5 border-white/10 backdrop-blur-2xl p-10 shadow-2xl relative overflow-hidden group">
            {/* Header */}
            <div className="flex flex-col items-center mb-10 text-center">
               <motion.div 
                whileHover={{ rotate: 5, scale: 1.05 }}
                className="w-16 h-16 bg-gradient-to-tr from-blue-600 to-indigo-500 rounded-2xl flex items-center justify-center shadow-2xl shadow-blue-500/20 mb-6"
               >
                 <Shield className="w-8 h-8 text-white" />
               </motion.div>
               <h1 className="text-4xl font-extrabold text-white tracking-tight mb-2">QUARRYFORCE</h1>
               <p className="text-slate-400 font-medium">Internal Command Center Access</p>
            </div>

            {error && (
                <motion.div 
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="mb-8 p-4 bg-rose-500/10 border border-rose-500/20 rounded-xl text-rose-400 text-sm font-bold text-center"
                >
                    {error}
                </motion.div>
            )}

            <div className="space-y-6">
                <div className="flex justify-center flex-col items-center">
                    <GoogleLogin
                        onSuccess={handleGoogleSuccess}
                        onError={() => setError('Google Login Failed')}
                        theme="filled_black"
                        size="large"
                        shape="pill"
                        width="100%"
                    />
                </div>

                <div className="relative py-4">
                    <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-white/10"></div></div>
                    <div className="relative flex justify-center text-xs font-bold uppercase tracking-widest text-slate-500"><span className="px-4 bg-transparent backdrop-blur-xl">Developer Access</span></div>
                </div>

                <button
                    onClick={() => {
                        const demoUser = { id: 1, name: 'Demo Admin', email: 'demo@quarryforce.local', role: 'admin', avatar: null, provider: 'demo' };
                        login(demoUser);
                        localStorage.setItem('user', JSON.stringify(demoUser));
                    }}
                    disabled={isLoading}
                    className="w-full btn-premium bg-white/5 border border-white/10 text-white hover:bg-white/10 hover:border-blue-500/30 transition-all font-bold group"
                >
                    <LogIn className="w-4 h-4 text-blue-400 group-hover:translate-x-1 transition-transform" />
                    Enter Simulation (Demo)
                </button>
            </div>

            <div className="mt-12 flex items-center justify-center gap-6 text-slate-500 font-bold text-[10px] uppercase tracking-widest">
                <span className="flex items-center gap-1.5"><div className="w-1 h-1 bg-emerald-500 rounded-full animate-pulse" /> API SECURE</span>
                <span>v1.0.4</span>
                <span>GLOBAL OPS</span>
            </div>
        </div>

        {/* Info Banner */}
        <div className="mt-8 flex items-center justify-between px-4 text-slate-500 font-bold text-[10px] uppercase tracking-widest">
            <p>© 2024 QUARRYFORCE NETWORK</p>
            <div className="flex gap-4">
                <a href="#" className="hover:text-white transition-colors">Support</a>
                <a href="#" className="hover:text-white transition-colors">Privacy</a>
            </div>
        </div>
      </motion.div>
    </div>
  );
};

export default LoginPage;

