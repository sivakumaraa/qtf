import React, { useState } from 'react';
import { LayoutDashboard, AlertTriangle, List, BarChart3, Settings, Users, User, ShoppingCart, MapPin, Shield, Smartphone, LogOut, DollarSign, FileText, TrendingUp, CreditCard } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { SCREEN_PRIVILEGES, ROLES, PRIVILEGES } from '../config/roles';

const Layout = ({ children, activeTab, setActiveTab }) => {
    const [isSidebarOpen] = useState(true);
    const { user, hasAllPrivileges, loading, logout } = useAuth();

    // Debug logging
    React.useEffect(() => {
        console.log('[Layout Debug]', {
            user: user ? { name: user.name, role: user.role, id: user.id } : null,
            loading,
            hasAllPrivilegesFunc: typeof hasAllPrivileges
        });
    }, [user, loading, hasAllPrivileges]);

    const navItems = [
        // Dashboard
        { id: 'overview', label: 'Overview Dashboard', icon: LayoutDashboard, privileges: SCREEN_PRIVILEGES.overview.required },
        
        // Administration
        { id: 'users', label: 'User Management', icon: Users, privileges: SCREEN_PRIVILEGES.users.required },
        { id: 'roles', label: 'Role Management', icon: Shield, privileges: [PRIVILEGES.MANAGE_ROLES] },
        { id: 'settings', label: 'Settings', icon: Settings, privileges: SCREEN_PRIVILEGES.settings.required },
        
        // Field Force Management
        { id: 'reps', label: 'Rep Details', icon: User, privileges: SCREEN_PRIVILEGES.reps.required },
        { id: 'device-activation', label: 'Device Activation', icon: Smartphone, privileges: SCREEN_PRIVILEGES.reps.required },
        
        // Sales & Performance
        { id: 'targets', label: 'Rep Targets & Progress', icon: BarChart3, privileges: SCREEN_PRIVILEGES.targets.required },
        { id: 'customers', label: 'Customers', icon: MapPin, privileges: SCREEN_PRIVILEGES.customers.required },
        { id: 'orders', label: 'Orders', icon: ShoppingCart, privileges: SCREEN_PRIVILEGES.orders.required },
        
        // Salary Management
        { id: 'salary-config', label: 'Salary Configuration', icon: DollarSign, privileges: SCREEN_PRIVILEGES.reps.required },
        { id: 'salary-processing', label: 'Salary Processing', icon: TrendingUp, privileges: SCREEN_PRIVILEGES.reps.required },
        { id: 'salary-slips', label: 'Salary Slips', icon: FileText, privileges: SCREEN_PRIVILEGES.reps.required },
        { id: 'payment-tracking', label: 'Payment Tracking', icon: CreditCard, privileges: SCREEN_PRIVILEGES.reps.required },
        
        // Monitoring & Analytics
        { id: 'logs', label: 'Visit Logs', icon: List, privileges: SCREEN_PRIVILEGES.logs.required },
        { id: 'alerts', label: 'Fraud Alerts', icon: AlertTriangle, privileges: SCREEN_PRIVILEGES.alerts.required },
    ];

    // Filter navigation items based on user privileges
    // Admin users see everything, others are filtered by privileges
    const visibleNavItems = !user || loading 
        ? navItems 
        : user.role === ROLES.ADMIN 
            ? navItems 
            : navItems.filter(item => hasAllPrivileges(item.privileges || []));

    return (
        <div className="flex h-screen bg-gray-50 overflow-hidden">
            {/* Sidebar */}
            <aside className={`bg-gray-900 text-white w-64 flex-shrink-0 transition-all duration-300 ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full absolute'}`}>
                <div className="p-4 flex items-center justify-between border-b border-gray-800">
                    <h1 className="text-xl font-bold tracking-wider text-blue-400">QUARRYFORCE</h1>
                </div>

                <nav className="mt-6 px-4">
                    <ul className="space-y-2">
                        {visibleNavItems.length === 0 ? (
                            <li className="px-4 py-3 text-gray-400 text-sm">
                                <p>No accessible menus</p>
                                {user && (
                                    <div className="text-xs mt-2 bg-gray-800 p-2 rounded text-gray-500">
                                        <p>User: {user.name}</p>
                                        <p>Role: {user.role}</p>
                                        <p>Loading: {loading ? 'Yes' : 'No'}</p>
                                    </div>
                                )}
                            </li>
                        ) : (
                            visibleNavItems.map((item) => {
                                const Icon = item.icon;
                                return (
                                    <li key={item.id}>
                                        <button
                                            onClick={() => setActiveTab(item.id)}
                                            className={`w-full flex items-center px-4 py-3 rounded-lg transition-colors ${activeTab === item.id
                                                ? 'bg-blue-600 text-white shadow-lg'
                                                : 'text-gray-400 hover:bg-gray-800 hover:text-white'
                                                }`}
                                        >
                                            <Icon className="w-5 h-5 mr-3" />
                                            <span className="font-medium">{item.label}</span>
                                        </button>
                                    </li>
                                );
                            })
                        )}
                    </ul>
                </nav>
            </aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col h-full overflow-hidden">
                {/* Header */}
                <header className="bg-white shadow-sm border-b border-gray-200 z-10 px-6 py-4 flex justify-between items-center">
                    <h2 className="text-xl font-semibold text-gray-800 capitalize">
                        {navItems.find(i => i.id === activeTab)?.label || 'Dashboard'}
                    </h2>
                    {user && (
                        <div className="flex items-center space-x-4">
                            <div className="flex items-center space-x-3">
                                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold">
                                    {user.avatar || user.name.charAt(0)}
                                </div>
                                <div className="flex flex-col">
                                    <span className="text-sm font-medium text-gray-700">{user.name}</span>
                                    <span className="text-xs text-gray-500 capitalize">{user.role}</span>
                                </div>
                            </div>
                            <button
                                onClick={logout}
                                className="p-2 text-gray-600 hover:text-red-600 hover:bg-red-50 rounded-lg transition"
                                title="Logout"
                            >
                                <LogOut className="w-5 h-5" />
                            </button>
                        </div>
                    )}
                </header>

                {/* Dynamic Content Area */}
                <div className="flex-1 overflow-auto p-6 relative">
                    <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-blue-50 to-transparent -z-10" />
                    <div className="max-w-7xl mx-auto">
                        {children}
                    </div>
                </div>
            </main>
        </div>
    );
};

export default Layout;
