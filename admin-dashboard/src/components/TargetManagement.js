import React, { useState, useEffect, useCallback } from 'react';
import { repTargetsAPI, repProgressAPI, adminAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import { 
  TrendingUp, Target, Award, BarChart3, 
  Plus, X, Edit2, ChevronRight, Calendar,
  Filter, Search, MoreVertical, AlertOctagon
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const TargetManagement = () => {
  const [targets, setTargets] = useState([]);
  const [reps, setReps] = useState([]);
  const [chartData, setChartData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [duplicateWarning, setDuplicateWarning] = useState(null);
  const [confirmOverride, setConfirmOverride] = useState(false);
  const [selectedMonth, setSelectedMonth] = useState(new Date().toISOString().slice(0, 7));
  const [formData, setFormData] = useState({
    rep_id: '',
    target_month: new Date().toISOString().slice(0, 7),
    monthly_sales_target_m3: '300',
    incentive_rate_per_m3: '5',
    incentive_rate_max_per_m3: '9',
    penalty_rate_per_m3: '50',
  });

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const [targetsRes, repsRes] = await Promise.all([
        repTargetsAPI.getAll(),
        adminAPI.getAllReps()
      ]);
      const targetsData = targetsRes.data.data || [];
      const repsData = repsRes.data.data || [];
      
      setTargets(targetsData);
      setReps(repsData);

      const chartArray = [];
      const currentMonth = selectedMonth;

      for (const rep of repsData) {
        try {
          const progressRes = await repProgressAPI.getProgress(rep.id, currentMonth);
          if (progressRes.data.success) {
            const repData = progressRes.data.data;
            const repTarget = targetsData.find(
              t => t.rep_id === rep.id && t.target_month === currentMonth
            );

            if (repTarget) {
              const actualSales = repData?.total_sales_volume || 0;
              const targetSales = repTarget.monthly_sales_target_m3;
              const achievementPercent = Math.round((actualSales / targetSales) * 100);

              chartArray.push({
                rep: rep.name,
                target: parseInt(targetSales),
                actual: Math.round(actualSales),
                achievement: achievementPercent,
                repId: rep.id
              });
            }
          }
        } catch (err) {
          console.warn(`Failed to fetch progress for rep ${rep.id}:`, err);
        }
      }

      setChartData(chartArray);
      setError(null);
    } catch (err) {
      setError(err.message || 'Failed to fetch data');
    } finally {
      setLoading(false);
    }
  }, [selectedMonth]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!editingId && formData.rep_id && formData.target_month) {
      const existing = targets.find(
        t => t.rep_id === parseInt(formData.rep_id) && t.target_month === formData.target_month
      );
      if (existing && !confirmOverride) {
        setDuplicateWarning(existing);
        setConfirmOverride(false);
        return;
      }
    }
    
    setConfirmOverride(false);
    setDuplicateWarning(null);
    
    try {
      if (editingId) {
        const response = await repTargetsAPI.update(editingId, { ...formData, updated_by: 1 });
        if (response.data.success) { resetForm(); await fetchData(); }
      } else {
        const response = await repTargetsAPI.create({ ...formData, updated_by: 1, force_override: confirmOverride });
        if (response.data.success) { resetForm(); await fetchData(); }
      }
    } catch (err) {
      setError(err.message || 'Failed to save targets');
    }
  };

  const handleEdit = (target) => {
    setEditingId(target.id);
    setFormData({
      rep_id: target.rep_id,
      target_month: target.target_month || new Date().toISOString().slice(0, 7),
      monthly_sales_target_m3: target.monthly_sales_target_m3,
      incentive_rate_per_m3: target.incentive_rate_per_m3,
      incentive_rate_max_per_m3: target.incentive_rate_max_per_m3,
      penalty_rate_per_m3: target.penalty_rate_per_m3,
    });
    setShowForm(true);
  };

  const resetForm = () => {
    setEditingId(null);
    setFormData({
      rep_id: '',
      target_month: new Date().toISOString().slice(0, 7),
      monthly_sales_target_m3: '300',
      incentive_rate_per_m3: '5',
      incentive_rate_max_per_m3: '9',
      penalty_rate_per_m3: '50',
    });
    setDuplicateWarning(null);
    setConfirmOverride(false);
    setShowForm(false);
  };

  if (loading && targets.length === 0) return (
    <div className="flex flex-col justify-center items-center h-64 gap-3">
        <div className="w-10 h-10 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
        <p className="text-slate-500 font-bold animate-pulse text-sm">Syncing Targets...</p>
    </div>
  );

  return (
    <div className="space-y-8 pb-12">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Target Management</h1>
          <p className="text-slate-500 font-medium">Configure and track sales objectives for your team.</p>
        </div>
        <div className="flex items-center gap-3">
            <div className="relative group">
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                <input
                    type="month"
                    value={selectedMonth}
                    onChange={(e) => setSelectedMonth(e.target.value)}
                    className="pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-bold shadow-sm focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all"
                />
            </div>
            <button
                onClick={() => setShowForm(!showForm)}
                className={`btn-premium ${showForm ? 'bg-slate-100 text-slate-700' : 'bg-blue-600 text-white shadow-lg shadow-blue-500/20 hover:bg-blue-700'}`}
            >
                {showForm ? <X className="w-4 h-4" /> : <Plus className="w-4 h-4" />}
                {showForm ? 'Cancel' : 'New Target'}
            </button>
        </div>
      </div>

      {/* Summary Stats */}
      <AnimatePresence>
        {chartData.length > 0 && (
            <motion.div 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="grid grid-cols-1 md:grid-cols-3 gap-6"
            >
                {[
                    { title: 'Active Targets', value: chartData.length, icon: Target, color: 'text-blue-600', bg: 'bg-blue-50' },
                    { title: 'Avg Achievement', value: `${Math.round(chartData.reduce((sum, d) => sum + d.achievement, 0) / chartData.length)}%`, icon: TrendingUp, color: 'text-emerald-600', bg: 'bg-emerald-50' },
                    { title: 'Total Volume', value: `${chartData.reduce((sum, d) => sum + d.target, 0).toLocaleString()} m³`, icon: Award, color: 'text-indigo-600', bg: 'bg-indigo-50' }
                ].map((stat, i) => (
                    <div key={i} className="glass-card p-6 flex flex-col justify-between group hover:border-blue-500/20 transition-all">
                        <div className="flex justify-between items-start">
                            <div className={`p-3 rounded-2xl ${stat.bg} ${stat.color} transition-transform group-hover:scale-110`}>
                                <stat.icon className="w-6 h-6" />
                            </div>
                            <button className="text-slate-300 hover:text-slate-600">
                                <MoreVertical className="w-4 h-4" />
                            </button>
                        </div>
                        <div className="mt-4">
                            <p className="text-sm font-semibold text-slate-500 mb-1">{stat.title}</p>
                            <h3 className="text-3xl font-extrabold text-slate-900 tracking-tight">{stat.value}</h3>
                        </div>
                    </div>
                ))}
            </motion.div>
        )}
      </AnimatePresence>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Form and List Container */}
        <div className={`lg:col-span-${showForm ? '7' : '12'} space-y-8 transition-all duration-500`}>
            {/* Targets Table */}
            <div className="glass-card overflow-hidden">
                <div className="p-6 border-b border-slate-100 flex items-center justify-between">
                    <h2 className="text-lg font-bold text-slate-800">Target List</h2>
                    <div className="flex items-center gap-2">
                        <button className="p-2 hover:bg-slate-100 rounded-lg text-slate-500"><Filter className="w-4 h-4" /></button>
                        <button className="p-2 hover:bg-slate-100 rounded-lg text-slate-500"><Search className="w-4 h-4" /></button>
                    </div>
                </div>
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead className="bg-slate-50/50">
                            <tr>
                                <th className="px-6 py-4 text-left text-[10px] font-bold text-slate-500 uppercase tracking-widest">Representative</th>
                                <th className="px-6 py-4 text-left text-[10px] font-bold text-slate-500 uppercase tracking-widest">Target</th>
                                <th className="px-6 py-4 text-left text-[10px] font-bold text-slate-500 uppercase tracking-widest text-center">Incentive</th>
                                <th className="px-6 py-4 text-left text-[10px] font-bold text-slate-500 uppercase tracking-widest">Status</th>
                                <th className="px-6 py-4 text-right text-[10px] font-bold text-slate-500 uppercase tracking-widest">Action</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                            {targets.length === 0 ? (
                                <tr>
                                    <td colSpan="5" className="px-6 py-12 text-center text-slate-400 font-medium">No targets configured for any month.</td>
                                </tr>
                            ) : (
                                targets.map((target) => (
                                    <tr key={target.id} className="hover:bg-blue-50/30 transition-colors group">
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center text-blue-700 font-bold text-xs">
                                                    {target.rep_name?.charAt(0)}
                                                </div>
                                                <div>
                                                    <p className="text-sm font-bold text-slate-800">{target.rep_name}</p>
                                                    <p className="text-[10px] font-bold text-slate-400">{target.target_month}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <p className="text-sm font-bold text-slate-700">{target.monthly_sales_target_m3} m³</p>
                                            <p className="text-[10px] font-bold text-slate-400">Total Target</p>
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            <span className="text-sm font-bold text-blue-600">{CURRENCY.SYMBOL}{target.incentive_rate_per_m3}</span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`px-2 py-1 rounded-lg text-[10px] font-bold uppercase tracking-wider ${target.status === 'active' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-600'}`}>
                                                {target.status}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <button 
                                                onClick={() => handleEdit(target)}
                                                className="p-2 hover:bg-blue-100 rounded-lg text-blue-600 transition-colors opacity-0 group-hover:opacity-100"
                                            >
                                                <Edit2 className="w-4 h-4" />
                                            </button>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        {/* Form Panel */}
        <AnimatePresence>
            {showForm && (
                <motion.div 
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: 20 }}
                    className="lg:col-span-5"
                >
                    <div className="glass-card p-8 sticky top-8">
                        <h3 className="text-xl font-bold text-slate-900 mb-6 flex items-center gap-2">
                            {editingId ? <Edit2 className="w-5 h-5 text-blue-600" /> : <Plus className="w-5 h-5 text-blue-600" />}
                            {editingId ? 'Edit Sales Target' : 'Create New Target'}
                        </h3>

                        <form onSubmit={handleSubmit} className="space-y-6">
                            <div className="space-y-2">
                                <label className="text-sm font-bold text-slate-700">Select Representative</label>
                                <select
                                    value={formData.rep_id}
                                    onChange={(e) => setFormData({ ...formData, rep_id: e.target.value })}
                                    disabled={editingId !== null}
                                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 outline-none transition-all font-medium text-slate-800 disabled:opacity-50"
                                    required
                                >
                                    <option value="">Choose a Rep</option>
                                    {reps.map(rep => (
                                        <option key={rep.id} value={rep.id}>{rep.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-slate-700">Target Month</label>
                                    <input
                                        type="month"
                                        value={formData.target_month}
                                        onChange={(e) => setFormData({ ...formData, target_month: e.target.value })}
                                        disabled={editingId !== null}
                                        className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl font-medium outline-none disabled:opacity-50"
                                        required
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-slate-700">Sales Target (m³)</label>
                                    <input
                                        type="number"
                                        value={formData.monthly_sales_target_m3}
                                        onChange={(e) => setFormData({ ...formData, monthly_sales_target_m3: e.target.value })}
                                        className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl font-medium outline-none"
                                        required
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4 pt-4 border-t border-slate-100">
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-slate-700 text-blue-600">Base Rate ({CURRENCY.SYMBOL})</label>
                                    <input
                                        type="number"
                                        value={formData.incentive_rate_per_m3}
                                        onChange={(e) => setFormData({ ...formData, incentive_rate_per_m3: e.target.value })}
                                        className="w-full px-4 py-3 bg-blue-50/30 border border-blue-100 rounded-xl font-bold text-blue-700 outline-none"
                                        required
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-slate-700 text-rose-600">Penalty Rate ({CURRENCY.SYMBOL})</label>
                                    <input
                                        type="number"
                                        value={formData.penalty_rate_per_m3}
                                        onChange={(e) => setFormData({ ...formData, penalty_rate_per_m3: e.target.value })}
                                        className="w-full px-4 py-3 bg-rose-50/30 border border-rose-100 rounded-xl font-bold text-rose-700 outline-none"
                                        required
                                    />
                                </div>
                            </div>

                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={resetForm}
                                    className="flex-1 px-6 py-3 border border-slate-200 rounded-xl font-bold text-slate-600 hover:bg-slate-50 transition-colors"
                                >
                                    Discard
                                </button>
                                <button
                                    type="submit"
                                    className="flex-3 bg-blue-600 text-white font-bold px-8 py-3 rounded-xl shadow-lg shadow-blue-500/20 hover:bg-blue-700 transition-colors"
                                >
                                    {editingId ? 'Save Changes' : 'Create Target'}
                                </button>
                            </div>
                        </form>
                    </div>
                </motion.div>
            )}
        </AnimatePresence>
      </div>

      {error && (
        <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="fixed bottom-8 right-8 bg-rose-600 text-white px-6 py-4 rounded-2xl shadow-2xl flex items-center gap-3 z-50"
        >
            <div className="bg-white/20 p-2 rounded-lg"><AlertOctagon className="w-5 h-5" /></div>
            <p className="font-bold">{error}</p>
            <button onClick={() => setError(null)} className="ml-4 hover:scale-110 transition-transform"><X className="w-4 h-4" /></button>
        </motion.div>
      )}
    </div>
  );
};

export default TargetManagement;

