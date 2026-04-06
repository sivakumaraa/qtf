import React, { useState, useEffect } from 'react';
import { 
  Users, Truck, AlertOctagon, LocateFixed, Activity, 
  CheckCircle2, TrendingUp, Clock, ArrowUpRight, ArrowDownRight,
  MoreVertical
} from 'lucide-react';
import { motion } from 'framer-motion';
import { adminAPI } from '../api/client';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix Leaflet marker icon issue
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
    iconUrl: require('leaflet/dist/images/marker-icon.png'),
    shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});

const StatCard = ({ title, value, icon: Icon, color, trend, trendValue, delay }) => (
    <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay }}
        className="glass-card p-6 flex flex-col justify-between group hover:border-blue-500/30 transition-colors"
    >
        <div className="flex justify-between items-start">
            <div className={`p-3 rounded-2xl ${color} bg-opacity-10 transition-transform group-hover:scale-110 duration-300`}>
                <Icon className={`w-6 h-6 ${color.replace('bg-', 'text-')}`} />
            </div>
            {trend && (
                <div className={`flex items-center gap-1 text-xs font-bold ${trend === 'up' ? 'text-emerald-500' : 'text-rose-500'}`}>
                    {trend === 'up' ? <ArrowUpRight className="w-3 h-3" /> : <ArrowDownRight className="w-3 h-3" />}
                    {trendValue}
                </div>
            )}
        </div>
        <div className="mt-4">
            <p className="text-sm font-semibold text-slate-500 mb-1">{title}</p>
            <h3 className="text-3xl font-extrabold text-slate-900 tracking-tight">{value}</h3>
        </div>
    </motion.div>
);

const ActivityItem = ({ title, time, type, status }) => {
    const icons = {
        visit: <LocateFixed className="w-4 h-4 text-blue-500" />,
        alert: <AlertOctagon className="w-4 h-4 text-rose-500" />,
        checkin: <CheckCircle2 className="w-4 h-4 text-emerald-500" />
    };
    
    return (
        <div className="flex items-center gap-4 p-3 hover:bg-slate-50 rounded-xl transition-colors group cursor-pointer">
            <div className="w-10 h-10 rounded-xl bg-white border border-slate-100 shadow-sm flex items-center justify-center group-hover:border-blue-200 transition-colors">
                {icons[type] || icons.visit}
            </div>
            <div className="flex-1">
                <p className="text-sm font-bold text-slate-800">{title}</p>
                <div className="flex items-center gap-2 text-[10px] font-semibold text-slate-400">
                    <Clock className="w-3 h-3" /> {time}
                </div>
            </div>
            {status && (
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600 uppercase tracking-wider">
                    {status}
                </span>
            )}
        </div>
    );
};

const RepItem = ({ rep }) => {
    const status = rep.is_active ? 'Active' : 'Idle';
    const fraudScore = Math.floor(Math.random() * 40);
    
    return (
        <div className="flex items-center gap-4 p-4 border border-slate-100 rounded-2xl hover:border-blue-200 hover:shadow-lg hover:shadow-blue-500/5 transition-all group">
            <div className="relative">
                {rep.photo ? (
                    <img src={rep.photo} alt="" className="w-12 h-12 rounded-xl object-cover" />
                ) : (
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-tr from-blue-100 to-indigo-50 border border-blue-200 flex items-center justify-center text-blue-700 font-bold">
                        {rep.name.charAt(0)}
                    </div>
                )}
                <div className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white ${rep.is_active ? 'bg-emerald-500' : 'bg-slate-300'}`} />
            </div>
            <div className="flex-1 min-w-0">
                <p className="text-sm font-bold text-slate-800 truncate">{rep.name}</p>
                <p className="text-xs font-semibold text-slate-400 truncate">{rep.email}</p>
            </div>
            <div className="text-right">
                <p className={`text-xs font-bold ${fraudScore > 30 ? 'text-amber-500' : 'text-emerald-500'}`}>
                    {fraudScore}% Fraud
                </p>
                <p className="text-[10px] font-bold text-slate-400 uppercase">Score</p>
            </div>
        </div>
    );
};

const OverviewTab = () => {
    const [reps, setReps] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchDashboardData = async () => {
            try {
                const repData = await adminAPI.getAllReps();
                const repsArray = Array.isArray(repData.data?.data) ? repData.data.data : [];
                setReps(repsArray);
            } catch (error) {
                console.error("Failed fetching data", error);
            } finally {
                setLoading(false);
            }
        };

        fetchDashboardData();
    }, []);

    const mapData = reps.length > 0 ? reps.map((r, i) => ({
        ...r,
        lat: 12.9716 + (Math.random() * 0.05 - 0.025),
        lng: 77.5946 + (Math.random() * 0.05 - 0.025),
        status: r.is_active ? 'Active' : 'Idle'
    })) : [
        { id: 1, name: 'John Doe', lat: 12.9716, lng: 77.5946, status: 'Active' },
        { id: 2, name: 'Jane Smith', lat: 12.9720, lng: 77.5950, status: 'Idle' }
    ];

    if (loading) return (
        <div className="flex flex-col justify-center items-center h-96 gap-4">
            <div className="w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
            <p className="text-slate-500 font-bold animate-pulse text-sm">Building Command Center...</p>
        </div>
    );

    const activeExecs = reps.filter(r => r.is_active).length;

    return (
        <div className="space-y-8 pb-12">
            {/* Header Section */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Executive Command Center</h1>
                    <p className="text-slate-500 font-medium">Real-time overview of your field operations.</p>
                </div>
                <div className="flex items-center gap-3">
                    <button className="btn-premium bg-white border border-slate-200 text-slate-700 hover:bg-slate-50">
                        <TrendingUp className="w-4 h-4" /> Reports
                    </button>
                    <button className="btn-premium bg-blue-600 text-white shadow-lg shadow-blue-500/20 hover:bg-blue-700">
                        Add Executive
                    </button>
                </div>
            </div>

            {/* Quick Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <StatCard
                    title="Active Executives"
                    value={`${activeExecs}/${reps.length}`}
                    icon={Users}
                    color="bg-blue-500"
                    trend="up"
                    trendValue="+4%"
                    delay={0.1}
                />
                <StatCard
                    title="Visits Today"
                    value="1,284"
                    icon={CheckCircle2}
                    color="bg-emerald-500"
                    trend="up"
                    trendValue="+12.5%"
                    delay={0.2}
                />
                <StatCard
                    title="Distance Traveled"
                    value="428 km"
                    icon={Truck}
                    color="bg-indigo-500"
                    trend="down"
                    trendValue="-2%"
                    delay={0.3}
                />
                <StatCard
                    title="Security Alerts"
                    value="14"
                    icon={AlertOctagon}
                    color="bg-rose-500"
                    trend="up"
                    trendValue="+1"
                    delay={0.4}
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
                {/* Real-time Map Area */}
                <motion.div 
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.5 }}
                    className="lg:col-span-8 glass-card overflow-hidden flex flex-col h-[500px]"
                >
                    <div className="p-5 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <div className="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center">
                                <LocateFixed className="w-4 h-4 text-blue-600" />
                            </div>
                            <h2 className="text-lg font-bold text-slate-800">Global Executive Map</h2>
                        </div>
                        <div className="flex items-center gap-2">
                           <span className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse" />
                           <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Live Updates</span>
                        </div>
                    </div>
                    <div className="flex-1 w-full relative z-0">
                        <MapContainer
                            center={[12.9716, 77.5946]}
                            zoom={12}
                            zoomControl={false}
                            style={{ height: '100%', width: '100%' }}
                        >
                            <TileLayer
                                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                            />
                            {mapData.map((rep) => (
                                <Marker key={rep.id} position={[rep.lat, rep.lng]}>
                                    <Popup className="premium-popup">
                                        <div className="p-1">
                                            <p className="font-bold text-slate-900">{rep.name}</p>
                                            <p className="text-[10px] font-bold text-blue-600 uppercase mb-2">{rep.status}</p>
                                            <button className="w-full py-1 text-[10px] font-bold text-white bg-blue-600 rounded-md">
                                                Track Device
                                            </button>
                                        </div>
                                    </Popup>
                                </Marker>
                            ))}
                        </MapContainer>
                    </div>
                </motion.div>

                {/* Right Pane: Status & Recent Logs */}
                <div className="lg:col-span-4 space-y-8">
                    {/* Executive List */}
                    <motion.div 
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.6 }}
                        className="glass-card p-6 flex flex-col h-[280px]"
                    >
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="text-lg font-bold text-slate-800">Team Status</h3>
                            <button className="p-1 hover:bg-slate-100 rounded-lg text-slate-400">
                                <MoreVertical className="w-4 h-4" />
                            </button>
                        </div>
                        <div className="space-y-3 overflow-y-auto pr-2 custom-scrollbar flex-1">
                            {reps.map(rep => (
                                <RepItem key={rep.id} rep={rep} />
                            ))}
                            {reps.length === 0 && <p className="text-sm text-gray-500 text-center py-8 font-medium">No active reps found.</p>}
                        </div>
                    </motion.div>

                    {/* Recent Activities */}
                    <motion.div 
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.7 }}
                        className="glass-card p-6 flex flex-col h-[188px]"
                    >
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="text-lg font-bold text-slate-800">Live Feed</h3>
                            <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full uppercase">Recent</span>
                        </div>
                        <div className="space-y-1 overflow-y-auto custom-scrollbar flex-1">
                            <ActivityItem title="Rahul Bose checked-in" time="2 mins ago" type="checkin" status="Success" />
                            <ActivityItem title="GPS Spoofing detected" time="15 mins ago" type="alert" status="Critical" />
                            <ActivityItem title="New visit assigned" time="45 mins ago" type="visit" />
                        </div>
                    </motion.div>
                </div>
            </div>
        </div>
    );
};

export default OverviewTab;

