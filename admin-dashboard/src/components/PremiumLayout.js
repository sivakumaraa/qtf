import React, { useState } from 'react';
import { NavLink, useLocation, useNavigate } from 'react-router-dom';
import { 
  LayoutDashboard, AlertTriangle, List, BarChart3, Settings, 
  Users, User, ShoppingCart, MapPin, Shield, Smartphone, 
  LogOut, DollarSign, FileText, TrendingUp, CreditCard,
  Search, Bell, ChevronLeft, ChevronRight, Menu, X
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '../context/AuthContext';
import { SCREEN_PRIVILEGES, ROLES, PRIVILEGES } from '../config/roles';

const PremiumLayout = ({ children }) => {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const { user, hasAllPrivileges, loading, logout } = useAuth();
    const location = useLocation();
    const navigate = useNavigate();

    const navItems = [
        { group: 'Overview', items: [
            { id: 'overview', label: 'Dashboard', icon: LayoutDashboard, path: '/overview', privileges: SCREEN_PRIVILEGES.overview.required },
        ]},
        { group: 'Administration', items: [
            { id: 'users', label: 'User Management', icon: Users, path: '/users', privileges: SCREEN_PRIVILEGES.users.required },
            { id: 'roles', label: 'Role Management', icon: Shield, path: '/roles', privileges: [PRIVILEGES.MANAGE_ROLES] },
            { id: 'settings', label: 'System Settings', icon: Settings, path: '/settings', privileges: SCREEN_PRIVILEGES.settings.required },
        ]},
        { group: 'Field Force', items: [
            { id: 'reps', label: 'Representatives', icon: User, path: '/reps', privileges: SCREEN_PRIVILEGES.reps.required },
            { id: 'device-activation', label: 'Devices', icon: Smartphone, path: '/device-activation', privileges: SCREEN_PRIVILEGES.reps.required },
        ]},
        { group: 'Sales & Metrics', items: [
            { id: 'targets', label: 'Targets', icon: BarChart3, path: '/targets', privileges: SCREEN_PRIVILEGES.targets.required },
            { id: 'customers', label: 'Customers', icon: MapPin, path: '/customers', privileges: SCREEN_PRIVILEGES.customers.required },
            { id: 'orders', label: 'Orders', icon: ShoppingCart, path: '/orders', privileges: SCREEN_PRIVILEGES.orders.required },
        ]},
        { group: 'Finances', items: [
            { id: 'salary-config', label: 'Config', icon: DollarSign, path: '/salary-config', privileges: SCREEN_PRIVILEGES.reps.required },
            { id: 'salary-processing', label: 'Payroll', icon: TrendingUp, path: '/salary-processing', privileges: SCREEN_PRIVILEGES.reps.required },
            { id: 'salary-slips', label: 'Slips', icon: FileText, path: '/salary-slips', privileges: SCREEN_PRIVILEGES.reps.required },
            { id: 'payment-tracking', label: 'Payments', icon: CreditCard, path: '/payment-tracking', privileges: SCREEN_PRIVILEGES.reps.required },
        ]},
        { group: 'Monitoring', items: [
            { id: 'logs', label: 'Visit Logs', icon: List, path: '/logs', privileges: SCREEN_PRIVILEGES.logs.required },
            { id: 'alerts', label: 'Fraud Alerts', icon: AlertTriangle, path: '/alerts', privileges: SCREEN_PRIVILEGES.alerts.required },
        ]}
    ];

    const filterItems = (items) => {
        if (!user || loading) return items;
        if (user.role === ROLES.ADMIN) return items;
        return items.filter(item => hasAllPrivileges(item.privileges || []));
    };

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    return (
        <div className="flex h-screen bg-[#F8FAFC] overflow-hidden font-inter">
            {/* Glass Sidebar */}
            <motion.aside 
                initial={false}
                animate={{ width: isSidebarOpen ? 280 : 80 }}
                className="bg-[#0F172A] text-white flex-shrink-0 z-30 relative shadow-2xl overflow-hidden flex flex-col"
            >
                {/* Decorative background glow */}
                <div className="absolute top-0 -left-20 w-40 h-40 bg-blue-500/10 blur-[100px]" />
                <div className="absolute bottom-0 -right-20 w-40 h-40 bg-indigo-500/10 blur-[100px]" />

                {/* Logo Area */}
                <div className="p-6 flex items-center justify-between border-b border-white/5 relative h-20">
                    <AnimatePresence mode="wait">
                        {isSidebarOpen ? (
                            <motion.div 
                                key="full-logo"
                                initial={{ opacity: 0, x: -10 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: -10 }}
                                className="flex items-center gap-3"
                            >
                                <div className="w-10 h-10 bg-gradient-to-tr from-blue-600 to-indigo-500 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/20">
                                    <Shield className="w-6 h-6 text-white" />
                                </div>
                                <span className="text-xl font-bold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-white to-white/70">
                                    QUARRYFORCE
                                </span>
                            </motion.div>
                        ) : (
                            <motion.div 
                                key="small-logo"
                                initial={{ opacity: 0, scale: 0.8 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.8 }}
                                className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center mx-auto"
                            >
                                <Shield className="w-6 h-6 text-white" />
                            </motion.div>
                        )}
                    </AnimatePresence>
                </div>

                {/* Navigation Items */}
                <div className="flex-1 overflow-y-auto custom-scrollbar py-4 px-3 space-y-6">
                    {navItems.map((group, gIdx) => {
                        const visibleItems = filterItems(group.items);
                        if (visibleItems.length === 0) return null;

                        return (
                            <div key={gIdx} className="space-y-1">
                                {isSidebarOpen && (
                                    <h3 className="px-4 text-[10px] font-bold text-slate-500 uppercase tracking-[0.2em] mb-2">
                                        {group.group}
                                    </h3>
                                )}
                                {visibleItems.map((item) => {
                                    const Icon = item.icon;
                                    const isActive = location.pathname.startsWith(item.path);
                                    
                                    return (
                                        <NavLink
                                            key={item.id}
                                            to={item.path}
                                            className={({ isActive }) => `
                                                flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-300 group relative
                                                ${isActive 
                                                    ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/20' 
                                                    : 'text-slate-400 hover:text-white hover:bg-white/5'}
                                            `}
                                        >
                                            <Icon className={`w-5 h-5 flex-shrink-0 transition-transform duration-300 ${isActive ? 'scale-110' : 'group-hover:scale-110'}`} />
                                            {isSidebarOpen && (
                                                <span className="font-medium text-sm whitespace-nowrap overflow-hidden">
                                                    {item.label}
                                                </span>
                                            )}
                                            {isActive && (
                                                <motion.div 
                                                    layoutId="active-nav-glow"
                                                    className="absolute -left-3 w-1 h-8 bg-blue-400 rounded-r-full blur-[2px]"
                                                />
                                            )}
                                        </NavLink>
                                    );
                                })}
                            </div>
                        );
                    })}
                </div>

                {/* Bottom User Area */}
                <div className="p-4 border-t border-white/5 space-y-4">
                    <button 
                        onClick={() => setIsSidebarOpen(!isSidebarOpen)}
                        className="w-full flex items-center justify-center p-2 rounded-lg hover:bg-white/5 text-slate-400 transition-colors"
                    >
                        {isSidebarOpen ? <ChevronLeft className="w-5 h-5" /> : <ChevronRight className="w-5 h-5" />}
                    </button>
                </div>
            </motion.aside>

            {/* Main Content Area */}
            <main className="flex-1 flex flex-col h-full bg-[#F8FAFC]">
                {/* Premium Header */}
                <header className="h-20 bg-white/80 backdrop-blur-md border-b border-slate-200 flex items-center justify-between px-8 z-20">
                    <div className="flex items-center gap-4 flex-1">
                        <div className="relative max-w-md w-full group">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                            <input 
                                type="text" 
                                placeholder="Search everything..." 
                                className="w-full pl-10 pr-4 py-2.5 bg-slate-100 border-transparent focus:bg-white focus:border-blue-200 rounded-xl text-sm transition-all outline-none"
                            />
                        </div>
                    </div>

                    <div className="flex items-center gap-6">
                        <div className="flex items-center gap-2">
                            <button className="p-2.5 rounded-xl hover:bg-slate-100 text-slate-600 relative transition-colors">
                                <Bell className="w-5 h-5" />
                                <span className="absolute top-2.5 right-2.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white" />
                            </button>
                        </div>

                        {/* User Profile */}
                        {user && (
                            <div className="flex items-center gap-4 pl-6 border-l border-slate-200">
                                <div className="text-right hidden sm:block">
                                    <p className="text-sm font-bold text-slate-800">{user.name}</p>
                                    <p className="text-[10px] uppercase tracking-wider font-bold text-blue-600">{user.role}</p>
                                </div>
                                <div className="relative group">
                                    <button className="w-10 h-10 rounded-xl bg-gradient-to-tr from-slate-200 to-slate-100 border border-slate-200 flex items-center justify-center text-slate-700 font-bold overflow-hidden shadow-sm hover:shadow-md transition-all">
                                        {user.avatar ? <img src={user.avatar} alt="" /> : user.name.charAt(0)}
                                    </button>
                                    
                                    {/* Minimal Quick Action Dropdown Concept */}
                                    <div className="absolute right-0 top-full pt-2 opacity-0 scale-95 pointer-events-none group-hover:opacity-100 group-hover:scale-100 group-hover:pointer-events-auto transition-all duration-200 z-50">
                                        <div className="w-48 bg-white rounded-2xl shadow-2xl border border-slate-100 p-2">
                                            <button 
                                                onClick={handleLogout}
                                                className="w-full flex items-center gap-2 px-4 py-3 text-red-600 hover:bg-red-50 rounded-xl text-sm font-semibold transition-colors"
                                            >
                                                <LogOut className="w-4 h-4" />
                                                Log out
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                </header>

                {/* Viewport Content */}
                <div className="flex-1 overflow-y-auto p-4 sm:p-8 relative custom-scrollbar">
                    {/* Background Decorative Blob */}
                    <div className="absolute top-0 right-0 -z-10 w-full h-full overflow-hidden pointer-events-none opacity-50">
                        <div className="absolute -top-[10%] -right-[10%] w-[40%] h-[40%] bg-blue-500/5 blur-[120px] rounded-full" />
                        <div className="absolute top-[40%] -left-[10%] w-[30%] h-[30%] bg-indigo-500/5 blur-[100px] rounded-full" />
                    </div>

                    <motion.div 
                        key={location.pathname}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.4, ease: "easeOut" }}
                        className="max-w-7xl mx-auto min-h-full"
                    >
                        {children}
                    </motion.div>
                </div>
            </main>
        </div>
    );
};

export default PremiumLayout;
