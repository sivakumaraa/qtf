import React, { useState, useEffect } from 'react';
import { repProgressAPI, adminAPI, repTargetsAPI } from '../api/client';
import { CURRENCY } from '../config/constants';

const SalesRecording = () => {
  const [reps, setReps] = useState([]);
  const [targets, setTargets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState(null);
  const [history, setHistory] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(false);
  const [formData, setFormData] = useState({
    rep_id: '',
    sales_volume_m3: '',
    month: new Date().toISOString().slice(0, 7) + '-01',
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [repsResponse, targetsResponse] = await Promise.all([
          adminAPI.getAllReps(),
          repTargetsAPI.getAll()
        ]);
        setReps(repsResponse.data.data || []);
        setTargets(targetsResponse.data.data || []);
      } catch (err) {
        console.error('Failed to fetch data:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setResult(null); // Clear previous result

    try {
      const response = await repProgressAPI.recordSales({
        rep_id: parseInt(formData.rep_id),
        sales_volume_m3: parseFloat(formData.sales_volume_m3),
        month: formData.month,
      });

      // Check if response was successful
      if (response.data.success) {
        setResult(response.data.data);
        // Refresh history to show the newly added record
        if (formData.rep_id) {
          fetchSalesHistory(formData.rep_id);
        }
        // Reset form on success
        setFormData({
          rep_id: formData.rep_id, // Keep the rep selected
          sales_volume_m3: '',
          month: new Date().toISOString().slice(0, 7) + '-01',
        });
      } else {
        // Handle error response from backend
        const errorResult = { error: response.data.message || 'Unknown error occurred' };
        setResult(errorResult);
      }
    } catch (err) {
      console.error('Submit error:', err);
      // Improved error handling
      const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message || 'Failed to record sales';
      const errorResult = { error: errorMsg };
      setResult(errorResult);
    } finally {
      setSubmitting(false);
    }
  };

  const clearResult = () => {
    setResult(null);
  };

  const resetForm = () => {
    setFormData({
      rep_id: formData.rep_id,
      sales_volume_m3: '',
      month: new Date().toISOString().slice(0, 7) + '-01',
    });
    setResult(null);
  };

  const fetchSalesHistory = async (repId) => {
    if (!repId) {
      setHistory([]);
      return;
    }

    setLoadingHistory(true);
    try {
      const response = await repProgressAPI.getHistory(repId);
      setHistory(response.data.data || []);
    } catch (err) {
      console.error('Failed to fetch history:', err);
      setHistory([]);
    } finally {
      setLoadingHistory(false);
    }
  };

  const handleRepChange = (e) => {
    const repId = e.target.value;
    setFormData({ ...formData, rep_id: repId });
    if (repId) {
      fetchSalesHistory(repId);
    } else {
      setHistory([]);
    }
  };

  // Calculate rep stats
  const selectedRep = reps.find(r => r.id === parseInt(formData.rep_id));
  const selectedRepTarget = formData.rep_id
    ? targets.find(t => t.rep_id === parseInt(formData.rep_id))
    : null;

  const repStats = history.length > 0 ? {
    total_sales: history.reduce((sum, h) => sum + parseFloat(h.sales_volume_m3), 0),
    total_bonus: history.reduce((sum, h) => sum + parseFloat(h.bonus_earned), 0),
    total_penalty: history.reduce((sum, h) => sum + parseFloat(h.penalty_amount), 0),
    avg_sales: history.reduce((sum, h) => sum + parseFloat(h.sales_volume_m3), 0) / history.length,
    records: history.length
  } : null;

  // Progress percentage
  const progressPercentage = selectedRepTarget
    ? (parseFloat(formData.sales_volume_m3 || 0) / parseFloat(selectedRepTarget.monthly_sales_target_m3)) * 100
    : 0;

  if (loading) return <div className="p-6 text-center">Loading reps...</div>;

  return (
    <div className="space-y-6 pb-10">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Sales Recording</h2>
          <p className="text-gray-600 mt-1">Record sales and auto-calculate compensation</p>
        </div>
        {selectedRep && (
          <div className="text-right">
            <p className="text-sm text-gray-600">Currently viewing:</p>
            <p className="text-lg font-semibold text-blue-600">{selectedRep.name}</p>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Form Section */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow-md p-6 sticky top-6">
            <h3 className="text-lg font-bold text-gray-900 mb-4">📝 New Entry</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Select Rep <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.rep_id}
                  onChange={handleRepChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
                  required
                >
                  <option value="">-- Choose a rep --</option>
                  {reps.map(rep => (
                    <option key={rep.id} value={rep.id}>
                      {rep.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Sales Volume (m³) <span className="text-red-500">*</span>
                </label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  value={formData.sales_volume_m3}
                  onChange={(e) =>
                    setFormData({ ...formData, sales_volume_m3: e.target.value })
                  }
                  placeholder="e.g., 350"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
                {selectedRepTarget && formData.sales_volume_m3 && (
                  <div className="mt-2">
                    <div className="flex justify-between text-xs text-gray-600 mb-1">
                      <span>Progress to Target</span>
                      <span>{Math.round(progressPercentage)}%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                      <div
                        className={`h-2 rounded-full transition-all duration-300 ${progressPercentage >= 100 ? 'bg-green-500' : progressPercentage >= 75 ? 'bg-yellow-500' : 'bg-blue-500'
                          }`}
                        style={{ width: `${Math.min(progressPercentage, 100)}%` }}
                      />
                    </div>
                    <p className="text-xs text-gray-500 mt-1">
                      Target: {selectedRepTarget.monthly_sales_target_m3} m³
                    </p>
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Month <span className="text-red-500">*</span>
                </label>
                <input
                  type="month"
                  value={formData.month.slice(0, 7)}
                  onChange={(e) =>
                    setFormData({ ...formData, month: e.target.value + '-01' })
                  }
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div className="flex gap-2 pt-2">
                <button
                  type="submit"
                  disabled={submitting || !formData.rep_id || !formData.sales_volume_m3}
                  className="flex-1 bg-green-600 text-white py-2 rounded-lg font-semibold hover:bg-green-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {submitting ? '⏳ Saving...' : '✓ Save'}
                </button>
                <button
                  type="button"
                  onClick={resetForm}
                  disabled={submitting}
                  className="px-4 bg-gray-300 text-gray-700 py-2 rounded-lg font-semibold hover:bg-gray-400 transition disabled:opacity-50"
                  title="Clear form"
                >
                  ↻
                </button>
              </div>
            </form>

            {/* Rep Statistics */}
            {repStats && (
              <div className="mt-6 pt-6 border-t border-gray-200 space-y-3">
                <h4 className="font-semibold text-gray-900 text-sm">📊 {selectedRep?.name} Stats</h4>
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div className="bg-blue-50 p-2 rounded">
                    <p className="text-gray-600">Total Sales</p>
                    <p className="font-bold text-blue-600">{repStats.total_sales.toFixed(1)} m³</p>
                  </div>
                  <div className="bg-green-50 p-2 rounded">
                    <p className="text-gray-600">Total Bonus</p>
                    <p className="font-bold text-green-600">{CURRENCY.format(repStats.total_bonus)}</p>
                  </div>
                  <div className="bg-red-50 p-2 rounded">
                    <p className="text-gray-600">Total Penalty</p>
                    <p className="font-bold text-red-600">{CURRENCY.format(repStats.total_penalty)}</p>
                  </div>
                  <div className="bg-purple-50 p-2 rounded">
                    <p className="text-gray-600">Avg Sales</p>
                    <p className="font-bold text-purple-600">{repStats.avg_sales.toFixed(1)} m³</p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Results and History Section */}
        <div className="lg:col-span-2 space-y-6">
          {/* Results */}
          {result && (
            <div
              className={`rounded-lg shadow-md p-6 animate-pulse-once ${result.error
                  ? 'bg-red-50 border-2 border-red-300'
                  : 'bg-green-50 border-2 border-green-300'
                }`}
            >
              <div className="flex justify-between items-start mb-4">
                <div>
                  {result.error ? (
                    <p className="text-red-700 font-semibold text-lg">❌ Error</p>
                  ) : (
                    <p className="text-green-700 font-semibold text-lg">✅ Sales Recorded Successfully!</p>
                  )}
                </div>
                <button
                  onClick={clearResult}
                  className="text-gray-400 hover:text-gray-600 text-2xl font-bold"
                  title="Close"
                >
                  ✕
                </button>
              </div>

              {result.error ? (
                <p className="text-red-600">{result.error}</p>
              ) : (
                <div className="space-y-3">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="bg-white bg-opacity-70 p-3 rounded">
                      <p className="text-gray-600 text-sm">Sales Volume</p>
                      <p className="font-bold text-lg text-gray-900">{result.sales_volume_m3} m³</p>
                    </div>
                    <div className="bg-white bg-opacity-70 p-3 rounded">
                      <p className="text-gray-600 text-sm">Target</p>
                      <p className="font-bold text-lg text-gray-900">{result.target_m3} m³</p>
                    </div>
                  </div>

                  {result.bonus_earned > 0 && (
                    <div className="bg-green-100 border-l-4 border-green-500 p-3 rounded">
                      <p className="text-green-700 text-sm font-semibold">💰 Bonus Earned</p>
                      <p className="text-green-600 font-bold text-lg">+{CURRENCY.format(result.bonus_earned)}</p>
                    </div>
                  )}

                  {result.penalty_amount > 0 && (
                    <div className="bg-red-100 border-l-4 border-red-500 p-3 rounded">
                      <p className="text-red-700 text-sm font-semibold">⚠️ Penalty Deducted</p>
                      <p className="text-red-600 font-bold text-lg">-{CURRENCY.format(result.penalty_amount)}</p>
                    </div>
                  )}

                  <div className="bg-blue-100 border-l-4 border-blue-500 p-4 rounded mt-4">
                    <p className="text-blue-700 text-sm font-semibold">Net Compensation</p>
                    <p
                      className={`font-bold text-2xl ${result.net_compensation >= 0
                          ? 'text-green-600'
                          : 'text-red-600'
                        }`}
                    >
                      {result.net_compensation >= 0 ? '+' : ''}{CURRENCY.format(Math.abs(result.net_compensation))}
                    </p>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Sales History */}
          {formData.rep_id && (
            <div className="bg-white rounded-lg shadow-md p-6">
              <h3 className="text-lg font-bold text-gray-900 mb-4">📈 Sales History</h3>

              {loadingHistory ? (
                <div className="text-center text-gray-600 py-8">Loading history...</div>
              ) : history && history.length > 0 ? (
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead className="bg-gray-100 border-b">
                      <tr>
                        <th className="px-4 py-2 text-left font-semibold">Month</th>
                        <th className="px-4 py-2 text-right font-semibold">Sales</th>
                        <th className="px-4 py-2 text-right font-semibold">Bonus</th>
                        <th className="px-4 py-2 text-right font-semibold">Penalty</th>
                        <th className="px-4 py-2 text-right font-semibold">Net</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y">
                      {history.map((record, index) => (
                        <tr key={index} className="hover:bg-gray-50 transition">
                          <td className="px-4 py-2">
                            {new Date(record.month).toLocaleDateString('en-US', { year: 'numeric', month: 'short' })}
                          </td>
                          <td className="px-4 py-2 text-right font-semibold">{record.sales_volume_m3} m³</td>
                          <td className="px-4 py-2 text-right text-green-600 font-semibold">
                            {CURRENCY.format(record.bonus_earned)}
                          </td>
                          <td className="px-4 py-2 text-right text-red-600 font-semibold">
                            {CURRENCY.format(record.penalty_amount)}
                          </td>
                          <td className={`px-4 py-2 text-right font-bold ${record.net_compensation >= 0 ? 'text-green-600' : 'text-red-600'
                            }`}>
                            {CURRENCY.format(Math.abs(record.net_compensation))}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <p className="text-gray-600 text-center py-8">No sales records yet</p>
              )}
            </div>
          )}

          {/* Information Card */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
            <h3 className="font-semibold text-gray-900 mb-3">💡 How Compensation Works</h3>
            <div className="space-y-3 text-sm text-gray-700">
              <div className="flex gap-3">
                <div className="text-lg">📊</div>
                <div>
                  <strong>Bonus:</strong> Earned when sales exceed monthly target
                  <div className="text-xs text-gray-600 mt-1">Bonus = (sales - target) × incentive_rate</div>
                </div>
              </div>
              <div className="flex gap-3">
                <div className="text-lg">⚠️</div>
                <div>
                  <strong>Penalty:</strong> Deducted when sales fall short of target
                  <div className="text-xs text-gray-600 mt-1">Penalty = (target - sales) × penalty_rate</div>
                </div>
              </div>
              {selectedRepTarget && (
                <div className="bg-white border border-blue-300 p-3 rounded mt-3">
                  <strong className="text-blue-600">Your Rep's Rates:</strong>
                  <div className="text-xs text-gray-600 mt-2 space-y-1">
                    <div>Target: {selectedRepTarget.monthly_sales_target_m3} m³/month</div>
                    <div>Incentive: {CURRENCY.SYMBOL}{selectedRepTarget.incentive_rate_per_m3}/m³</div>
                    <div>Penalty: {CURRENCY.SYMBOL}{selectedRepTarget.penalty_rate_per_m3}/m³</div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SalesRecording;
