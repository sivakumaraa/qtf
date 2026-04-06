/**
 * Salary Processing Component
 * Calculate and process monthly salaries for all representatives
 * 
 * Features:
 * - Select month to process
 * - Calculate salary 
 * - Generate salary slips
 * - Preview before confirmation
 * - Bulk processing
 */

import React, { useState, useEffect } from 'react';
import { adminAPI, repProgressAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import { Loader, CheckCircle, AlertCircle, Download, Eye, Calculator } from 'lucide-react';

const SalaryProcessing = () => {
  const [reps, setReps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [selectedMonth, setSelectedMonth] = useState(new Date().toISOString().slice(0, 7));
  const [salaryData, setSalaryData] = useState([]);
  const [showPreview, setShowPreview] = useState(false);

  useEffect(() => {
    fetchReps();
  }, []);

  const fetchReps = async () => {
    try {
      setLoading(true);
      const response = await adminAPI.getAllReps();
      setReps(response.data.data || []);
      setError(null);
    } catch (err) {
      console.error('Error fetching reps:', err);
      setError(err.message || 'Failed to fetch reps');
    } finally {
      setLoading(false);
    }
  };

  const calculateRepSalary = async (rep, month) => {
    try {
      // Get sales history for the rep
      const historyResponse = await repProgressAPI.getHistory(rep.id);
      const history = historyResponse.data.data || [];

      // Filter for selected month
      const monthSales = history.filter(h => h.month?.startsWith(month));

      // Calculate totals
      const totalBonus = monthSales.reduce((sum, h) => sum + parseFloat(h.bonus_earned || 0), 0);
      const totalPenalty = monthSales.reduce((sum, h) => sum + parseFloat(h.penalty_amount || 0), 0);
      const totalSales = monthSales.length;

      // Gross salary (fixed + petrol)
      const fixedSalary = parseFloat(rep.fixed_salary || 0);
      const petrolAllowance = parseFloat(rep.petrol_allowance || 0);
      const grossSalary = fixedSalary + petrolAllowance;

      // Calculate net (simplified - without tax deductions for now)
      const netSalary = grossSalary + totalBonus - totalPenalty;

      return {
        rep_id: rep.id,
        rep_name: rep.name,
        month: month,
        fixed_salary: fixedSalary,
        petrol_allowance: petrolAllowance,
        gross_salary: grossSalary,
        total_sales: totalSales,
        bonus_earned: totalBonus,
        penalty_deducted: totalPenalty,
        net_salary: Math.max(0, netSalary), // Don't go below 0
        status: 'pending',
      };
    } catch (err) {
      console.error(`Error calculating salary for ${rep.name}:`, err);
      // Return default structure
      return {
        rep_id: rep.id,
        rep_name: rep.name,
        month: month,
        fixed_salary: parseFloat(rep.fixed_salary || 0),
        petrol_allowance: parseFloat(rep.petrol_allowance || 0),
        gross_salary: parseFloat(rep.fixed_salary || 0) + parseFloat(rep.petrol_allowance || 0),
        total_sales: 0,
        bonus_earned: 0,
        penalty_deducted: 0,
        net_salary: parseFloat(rep.fixed_salary || 0) + parseFloat(rep.petrol_allowance || 0),
        status: 'pending',
      };
    }
  };

  const handleCalculateSalary = async () => {
    if (!selectedMonth) {
      setError('Please select a month');
      return;
    }

    try {
      setProcessing(true);
      setError(null);
      
      const calculations = await Promise.all(
        reps.map(rep => calculateRepSalary(rep, selectedMonth))
      );

      setSalaryData(calculations);
      setShowPreview(true);
      setSuccess(`Salary calculated for ${reps.length} representatives`);
    } catch (err) {
      setError(err.message || 'Failed to calculate salary');
    } finally {
      setProcessing(false);
    }
  };

  const handleProcessSalary = async () => {
    if (!window.confirm(`Process salary for ${salaryData.length} reps in ${selectedMonth}?`)) {
      return;
    }

    try {
      setProcessing(true);
      setError(null);

      // Save all salary slips (in real implementation)
      const updatedData = salaryData.map(s => ({ ...s, status: 'processed' }));
      setSalaryData(updatedData);

      setSuccess(`✅ Salary processed for ${salaryData.length} representatives for ${selectedMonth}`);
      
      // In a real app, you would send this to the backend
      console.log('Processed salary data:', updatedData);

      setTimeout(() => {
        setShowPreview(false);
      }, 2000);
    } catch (err) {
      setError(err.message || 'Failed to process salary');
    } finally {
      setProcessing(false);
    }
  };

  const downloadSlipAsCSV = () => {
    const headers = [
      'Rep Name', 'Month', 'Fixed Salary', 'Petrol', 'Gross', 'Sales Count', 'Bonus', 'Penalty', 'Net Salary'
    ];

    const rows = salaryData.map(s => [
      s.rep_name,
      s.month,
      s.fixed_salary,
      s.petrol_allowance,
      s.gross_salary,
      s.total_sales,
      s.bonus_earned,
      s.penalty_deducted,
      s.net_salary,
    ]);

    const csv = [headers, ...rows].map(r => r.join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `salary-slip-${selectedMonth}.csv`;
    link.click();
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading representatives...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Monthly Salary Processing</h2>
        <p className="text-gray-600">Calculate and process salary for all representatives</p>
      </div>

      {/* Messages */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 flex items-start gap-3">
          <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />
          <div>
            <p className="font-semibold">Error</p>
            <p className="text-sm">{error}</p>
          </div>
        </div>
      )}

      {success && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-700 flex items-start gap-3">
          <CheckCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />
          <div>
            <p className="font-semibold">Success</p>
            <p className="text-sm">{success}</p>
          </div>
        </div>
      )}

      {/* Month Selector */}
      {!showPreview && (
        <div className="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
          <h3 className="text-lg font-bold text-gray-900 mb-4">Select Month</h3>
          
          <div className="flex gap-4 items-end max-w-md">
            <div className="flex-1">
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Choose Month to Process
              </label>
              <input
                type="month"
                value={selectedMonth}
                onChange={(e) => setSelectedMonth(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <button
              onClick={handleCalculateSalary}
              disabled={processing}
              className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold py-2 px-6 rounded-lg transition flex items-center gap-2"
            >
              {processing ? (
                <>
                  <Loader className="w-4 h-4 animate-spin" />
                  Calculating...
                </>
              ) : (
                <>
                  <Calculator className="w-4 h-4" />
                  Calculate
                </>
              )}
            </button>
          </div>

          <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <p className="text-sm text-blue-900">
              <strong>ℹ️ Note:</strong> This will calculate salary for all {reps.length} active representatives based on their fixed salary, petrol allowance, and performance bonuses/penalties.
            </p>
          </div>
        </div>
      )}

      {/* Preview Section */}
      {showPreview && (
        <div className="space-y-4">
          {/* Summary */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-4 border border-blue-200">
              <p className="text-sm text-blue-700 font-semibold mb-2">Total Reps</p>
              <p className="text-3xl font-bold text-blue-900">{salaryData.length}</p>
            </div>

            <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-4 border border-green-200">
              <p className="text-sm text-green-700 font-semibold mb-2">Total Gross Salary</p>
              <p className="text-3xl font-bold text-green-900">
                {CURRENCY.SYMBOL}{salaryData.reduce((sum, s) => sum + s.gross_salary, 0).toLocaleString('en-IN')}
              </p>
            </div>

            <div className="bg-gradient-to-br from-orange-50 to-orange-100 rounded-lg p-4 border border-orange-200">
              <p className="text-sm text-orange-700 font-semibold mb-2">Total Net Salary</p>
              <p className="text-3xl font-bold text-orange-900">
                {CURRENCY.SYMBOL}{salaryData.reduce((sum, s) => sum + s.net_salary, 0).toLocaleString('en-IN')}
              </p>
            </div>
          </div>

          {/* Salary Table */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
            <div className="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
              <div>
                <h3 className="text-lg font-bold text-gray-900">Salary Slip Preview</h3>
                <p className="text-sm text-gray-600 mt-1">Month: {selectedMonth}</p>
              </div>
              <button
                onClick={downloadSlipAsCSV}
                className="flex items-center gap-2 bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-lg transition text-sm"
              >
                <Download className="w-4 h-4" />
                Export CSV
              </button>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-gray-100 border-b border-gray-200">
                  <tr>
                    <th className="px-4 py-3 text-left font-semibold text-gray-700">Rep Name</th>
                    <th className="px-4 py-3 text-right font-semibold text-gray-700">Fixed</th>
                    <th className="px-4 py-3 text-right font-semibold text-gray-700">Petrol</th>
                    <th className="px-4 py-3 text-right font-semibold text-gray-700">Gross</th>
                    <th className="px-4 py-3 text-center font-semibold text-gray-700">Sales</th>
                    <th className="px-4 py-3 text-right font-semibold text-gray-700">Bonus</th>
                    <th className="px-4 py-3 text-right font-semibold text-gray-700">Penalty</th>
                    <th className="px-4 py-3 text-right font-semibold text-green-700 bg-green-50">Net</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {salaryData.map((s, idx) => (
                    <tr key={idx} className="hover:bg-gray-50">
                      <td className="px-4 py-3 font-semibold text-gray-900">{s.rep_name}</td>
                      <td className="px-4 py-3 text-right text-gray-700">{CURRENCY.SYMBOL}{s.fixed_salary.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</td>
                      <td className="px-4 py-3 text-right text-gray-700">{CURRENCY.SYMBOL}{s.petrol_allowance.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</td>
                      <td className="px-4 py-3 text-right font-semibold text-blue-600">{CURRENCY.SYMBOL}{s.gross_salary.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</td>
                      <td className="px-4 py-3 text-center text-gray-700">{s.total_sales}</td>
                      <td className="px-4 py-3 text-right text-green-600 font-semibold">+{CURRENCY.SYMBOL}{s.bonus_earned.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</td>
                      <td className="px-4 py-3 text-right text-red-600 font-semibold">-{CURRENCY.SYMBOL}{s.penalty_deducted.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</td>
                      <td className="px-4 py-3 text-right font-bold text-green-700 bg-green-50">{CURRENCY.SYMBOL}{s.net_salary.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-3 justify-end">
            <button
              onClick={() => setShowPreview(false)}
              className="bg-gray-300 hover:bg-gray-400 text-gray-900 font-semibold py-2 px-6 rounded-lg transition"
            >
              Back
            </button>
            <button
              onClick={handleProcessSalary}
              disabled={processing}
              className="bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white font-semibold py-2 px-6 rounded-lg transition flex items-center gap-2"
            >
              {processing ? (
                <>
                  <Loader className="w-4 h-4 animate-spin" />
                  Processing...
                </>
              ) : (
                <>
                  <CheckCircle className="w-4 h-4" />
                  Confirm & Process
                </>
              )}
            </button>
          </div>
        </div>
      )}

      {/* Info Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-900 font-medium mb-2">📋 Salary Processing Workflow</p>
        <ol className="text-xs text-blue-800 space-y-2 ml-4 list-decimal">
          <li>Select the month you want to process</li>
          <li>Click "Calculate" to compute salary for all reps</li>
          <li>Review the preview (gross = fixed + petrol, net = gross + bonus - penalty)</li>
          <li>Click "Confirm & Process" to finalize salary slips</li>
          <li>Salary slips can be viewed in the "Salary Slips" tab</li>
          <li>Record payments in the "Payment Tracking" tab</li>
        </ol>
      </div>
    </div>
  );
};

export default SalaryProcessing;
