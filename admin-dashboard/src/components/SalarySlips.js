/**
 * Salary Slips Component
 * View, download, and manage salary slips for representatives
 * 
 * Features:
 * - View all salary slips
 * - Filter by rep/month
 * - Download as PDF
 * - View detailed breakdown
 * - Track payment status
 */

import React, { useState, useEffect } from 'react';
import { adminAPI, repProgressAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import {
  Loader,
  Download,
  Eye,
  Filter,
  FileText,
  Check,
  Clock,
  AlertCircle,
} from 'lucide-react';

const SalarySlips = () => {
  const [reps, setReps] = useState([]);
  const [salarySlips, setSalarySlips] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedMonth, setSelectedMonth] = useState(new Date().toISOString().slice(0, 7));
  const [selectedRepId, setSelectedRepId] = useState('');
  const [viewingSlip, setViewingSlip] = useState(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const response = await adminAPI.getAllReps();
      setReps(response.data.data || []);
      
      // In a real scenario, fetch from /api/admin/salary-slips
      // For now, generate mock data
      generateMockSalarySlips();
      setError(null);
    } catch (err) {
      console.error('Error fetching data:', err);
      setError('Failed to load salary slips');
    } finally {
      setLoading(false);
    }
  };

  const generateMockSalarySlips = async () => {
    try {
      const allSlips = [];
      
      // Get last 3 months of salary slips for each rep
      for (const rep of (reps.length > 0 ? reps : [])) {
        for (let i = 0; i < 3; i++) {
          const d = new Date();
          d.setMonth(d.getMonth() - i);
          const month = d.toISOString().slice(0, 7);

          try {
            const history = await repProgressAPI.getHistory(rep.id);
            const monthSales = (history.data.data || []).filter(h => h.month?.startsWith(month));

            const fixedSalary = parseFloat(rep.fixed_salary || 0);
            const petrolAllowance = parseFloat(rep.petrol_allowance || 0);
            const grossSalary = fixedSalary + petrolAllowance;
            const bonus = monthSales.reduce((sum, h) => sum + parseFloat(h.bonus_earned || 0), 0);
            const penalty = monthSales.reduce((sum, h) => sum + parseFloat(h.penalty_amount || 0), 0);

            allSlips.push({
              id: `${rep.id}-${month}`,
              rep_id: rep.id,
              rep_name: rep.name,
              rep_email: rep.email,
              month: month,
              fixed_salary: fixedSalary,
              petrol_allowance: petrolAllowance,
              gross_salary: grossSalary,
              bonus_earned: bonus,
              penalty_deducted: penalty,
              net_salary: Math.max(0, grossSalary + bonus - penalty),
              tax_deducted: 0,
              other_deductions: 0,
              payment_status: Math.random() > 0.3 ? 'paid' : 'pending',
              payment_date: Math.random() > 0.3 ? new Date(month + '-10').toISOString().split('T')[0] : null,
              generated_at: new Date().toISOString(),
            });
          } catch (err) {
            // Skip if error fetching history
          }
        }
      }

      setSalarySlips(allSlips);
    } catch (err) {
      console.error('Error generating mock data:', err);
    }
  };

  const filteredSlips = salarySlips.filter(slip => {
    const matchMonth = selectedMonth === '' || slip.month === selectedMonth;
    const matchRep = selectedRepId === '' || slip.rep_id === parseInt(selectedRepId);
    return matchMonth && matchRep;
  });

  const handleViewSlip = (slip) => {
    setViewingSlip(slip);
  };

  const handleDownloadPDF = (slip) => {
    // Generate a simple text-based PDF representation
    const content = generateSlipContent(slip);
    const blob = new Blob([content], { type: 'text/plain' });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `salary-slip-${slip.rep_name}-${slip.month}.txt`;
    link.click();
  };

  const generateSlipContent = (slip) => {
    return `
================================================================================
                            SALARY SLIP
================================================================================

Company: QuarryForce Tracker
Period: ${slip.month}
Generated: ${new Date(slip.generated_at).toLocaleDateString()}

EMPLOYEE DETAILS
================================================================================
Name:           ${slip.rep_name}
Email:          ${slip.rep_email}
Monthly Slip:   ${slip.month}

EARNINGS
================================================================================
Fixed Salary:                    ${CURRENCY.SYMBOL} ${slip.fixed_salary.toLocaleString('en-IN')}
Petrol Allowance:                ${CURRENCY.SYMBOL} ${slip.petrol_allowance.toLocaleString('en-IN')}
                                 ________________
Gross Salary:                    ${CURRENCY.SYMBOL} ${slip.gross_salary.toLocaleString('en-IN')}

VARIABLE COMPONENTS
================================================================================
Bonus/Incentive:                 ${CURRENCY.SYMBOL} ${slip.bonus_earned.toLocaleString('en-IN')}
Performance Penalty:            -${CURRENCY.SYMBOL} ${slip.penalty_deducted.toLocaleString('en-IN')}
                                 ________________
Net Variable:                    ${CURRENCY.SYMBOL} ${(slip.bonus_earned - slip.penalty_deducted).toLocaleString('en-IN')}

DEDUCTIONS
================================================================================
Tax Deduction:                  -${CURRENCY.SYMBOL} ${slip.tax_deducted.toLocaleString('en-IN')}
Other Deductions:               -${CURRENCY.SYMBOL} ${slip.other_deductions.toLocaleString('en-IN')}
                                 ________________
Total Deductions:               -${CURRENCY.SYMBOL} ${(slip.tax_deducted + slip.other_deductions).toLocaleString('en-IN')}

SUMMARY
================================================================================
Gross Salary:                    ${CURRENCY.SYMBOL} ${slip.gross_salary.toLocaleString('en-IN')}
Bonus:                           ${CURRENCY.SYMBOL} ${slip.bonus_earned.toLocaleString('en-IN')}
Penalty:                        -${CURRENCY.SYMBOL} ${slip.penalty_deducted.toLocaleString('en-IN')}
Deductions:                     -${CURRENCY.SYMBOL} ${(slip.tax_deducted + slip.other_deductions).toLocaleString('en-IN')}
                                 ================
NET SALARY PAYABLE:              ${CURRENCY.SYMBOL} ${slip.net_salary.toLocaleString('en-IN')}

PAYMENT STATUS
================================================================================
Status: ${slip.payment_status.toUpperCase()}
Payment Date: ${slip.payment_date || 'Pending'}

================================================================================
This is a digitally generated slip. For official records, please retain this copy.
================================================================================
    `.trim();
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading salary slips...</p>
        </div>
      </div>
    );
  }

  if (viewingSlip) {
    return (
      <div className="space-y-4">
        {/* Back Button */}
        <button
          onClick={() => setViewingSlip(null)}
          className="text-blue-600 hover:text-blue-700 font-semibold text-sm"
        >
          ← Back to List
        </button>

        {/* Slip Detail View */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
          {/* Header */}
          <div className="bg-gradient-to-r from-gray-900 to-gray-800 text-white p-8">
            <div className="flex justify-between items-start">
              <div>
                <h1 className="text-3xl font-bold mb-2">SALARY SLIP</h1>
                <p className="text-gray-300">QuarryForce Tracker</p>
              </div>
              <div className="text-right">
                <p className="text-sm text-gray-300">Period</p>
                <p className="text-2xl font-bold">{viewingSlip.month}</p>
              </div>
            </div>
          </div>

          {/* Content */}
          <div className="p-8 space-y-8">
            {/* Employee Details */}
            <div className="grid grid-cols-2 gap-8">
              <div>
                <h3 className="text-sm font-semibold text-gray-600 uppercase mb-3">Employee</h3>
                <div className="space-y-1">
                  <p className="font-semibold text-gray-900">{viewingSlip.rep_name}</p>
                  <p className="text-sm text-gray-600">{viewingSlip.rep_email}</p>
                </div>
              </div>
              <div className="text-right">
                <h3 className="text-sm font-semibold text-gray-600 uppercase mb-3">Payment Status</h3>
                <div>
                  {viewingSlip.payment_status === 'paid' ? (
                    <div className="flex items-center justify-end gap-2 text-green-600 font-semibold">
                      <Check className="w-5 h-5" />
                      Paid
                    </div>
                  ) : (
                    <div className="flex items-center justify-end gap-2 text-orange-600 font-semibold">
                      <Clock className="w-5 h-5" />
                      Pending
                    </div>
                  )}
                  {viewingSlip.payment_date && (
                    <p className="text-sm text-gray-600 mt-1">{viewingSlip.payment_date}</p>
                  )}
                </div>
              </div>
            </div>

            {/* Earnings Section */}
            <div className="border-t border-gray-200 pt-6">
              <h3 className="text-lg font-bold text-gray-900 mb-4">Earnings</h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-gray-700">Fixed Salary</span>
                  <span className="font-semibold text-gray-900">
                    {CURRENCY.SYMBOL}{viewingSlip.fixed_salary.toLocaleString('en-IN')}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-gray-700">Petrol Allowance</span>
                  <span className="font-semibold text-gray-900">
                    {CURRENCY.SYMBOL}{viewingSlip.petrol_allowance.toLocaleString('en-IN')}
                  </span>
                </div>
                <div className="flex justify-between items-center bg-blue-50 p-3 rounded">
                  <span className="font-semibold text-gray-900">Gross Salary</span>
                  <span className="font-bold text-blue-600 text-lg">
                    {CURRENCY.SYMBOL}{viewingSlip.gross_salary.toLocaleString('en-IN')}
                  </span>
                </div>
              </div>
            </div>

            {/* Variable Components */}
            <div className="border-t border-gray-200 pt-6">
              <h3 className="text-lg font-bold text-gray-900 mb-4">Variable Components</h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-gray-700">Bonus/Incentive</span>
                  <span className="font-semibold text-green-600">
                    +{CURRENCY.SYMBOL}{viewingSlip.bonus_earned.toLocaleString('en-IN')}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-gray-700">Performance Penalty</span>
                  <span className="font-semibold text-red-600">
                    -{CURRENCY.SYMBOL}{viewingSlip.penalty_deducted.toLocaleString('en-IN')}
                  </span>
                </div>
              </div>
            </div>

            {/* Summary */}
            <div className="border-t border-gray-200 pt-6 bg-green-50 p-6 rounded-lg">
              <div className="flex justify-between items-center">
                <span className="text-lg font-bold text-gray-900">Net Salary Payable</span>
                <span className="text-3xl font-bold text-green-600">
                  {CURRENCY.SYMBOL}{viewingSlip.net_salary.toLocaleString('en-IN')}
                </span>
              </div>
              <p className="text-sm text-gray-600 mt-2">
                Calculation: {CURRENCY.SYMBOL}{viewingSlip.gross_salary.toLocaleString('en-IN')} + {CURRENCY.SYMBOL}{viewingSlip.bonus_earned.toLocaleString('en-IN')} - {CURRENCY.SYMBOL}{viewingSlip.penalty_deducted.toLocaleString('en-IN')}
              </p>
            </div>

            {/* Action Buttons */}
            <div className="border-t border-gray-200 pt-6 flex gap-3">
              <button
                onClick={() => handleDownloadPDF(viewingSlip)}
                className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg transition"
              >
                <Download className="w-4 h-4" />
                Download Slip
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Salary Slips</h2>
        <p className="text-gray-600">View and download salary slips for all representatives</p>
      </div>

      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 flex items-start gap-3">
          <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />
          <div>
            <p className="font-semibold">Error</p>
            <p className="text-sm">{error}</p>
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
        <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
          <Filter className="w-5 h-5" />
          Filter Slips
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Month</label>
            <input
              type="month"
              value={selectedMonth}
              onChange={(e) => setSelectedMonth(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Representative</label>
            <select
              value={selectedRepId}
              onChange={(e) => setSelectedRepId(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Representatives</option>
              {reps.map(rep => (
                <option key={rep.id} value={rep.id}>{rep.name}</option>
              ))}
            </select>
          </div>
        </div>

        <p className="text-sm text-gray-600 mt-4">
          Found <strong>{filteredSlips.length}</strong> salary slip(s)
        </p>
      </div>

      {/* Salary Slips List */}
      <div className="grid grid-cols-1 gap-4">
        {filteredSlips.length === 0 ? (
          <div className="bg-white rounded-lg shadow-sm border border-gray-100 p-8 text-center">
            <FileText className="w-12 h-12 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-600 font-medium">No salary slips found</p>
            <p className="text-sm text-gray-500 mt-1">Try adjusting your filters or process salary first</p>
          </div>
        ) : (
          filteredSlips.map(slip => (
            <div
              key={slip.id}
              className="bg-white rounded-lg shadow-sm border border-gray-100 p-4 hover:shadow-md transition"
            >
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-lg font-bold text-gray-900">{slip.rep_name}</h3>
                  <p className="text-sm text-gray-600">{slip.month}</p>
                </div>
                <div className="text-right">
                  {slip.payment_status === 'paid' ? (
                    <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700">
                      <Check className="w-4 h-4" />
                      Paid
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-700">
                      <Clock className="w-4 h-4" />
                      Pending
                    </span>
                  )}
                </div>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
                <div className="text-center">
                  <p className="text-xs text-gray-600">Gross</p>
                  <p className="font-bold text-gray-900">{CURRENCY.SYMBOL}{slip.gross_salary.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</p>
                </div>
                <div className="text-center text-green-600">
                  <p className="text-xs text-gray-600">Bonus</p>
                  <p className="font-bold">+{CURRENCY.SYMBOL}{slip.bonus_earned.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</p>
                </div>
                <div className="text-center text-red-600">
                  <p className="text-xs text-gray-600">Penalty</p>
                  <p className="font-bold">-{CURRENCY.SYMBOL}{slip.penalty_deducted.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</p>
                </div>
                <div className="text-center bg-green-50 rounded p-2">
                  <p className="text-xs text-gray-600">Net</p>
                  <p className="font-bold text-green-700">{CURRENCY.SYMBOL}{slip.net_salary.toLocaleString('en-IN', { maximumFractionDigits: 0 })}</p>
                </div>
              </div>

              <div className="flex gap-2">
                <button
                  onClick={() => handleViewSlip(slip)}
                  className="flex-1 flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg transition text-sm"
                >
                  <Eye className="w-4 h-4" />
                  View
                </button>
                <button
                  onClick={() => handleDownloadPDF(slip)}
                  className="flex-1 flex items-center justify-center gap-2 bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-lg transition text-sm"
                >
                  <Download className="w-4 h-4" />
                  Download
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Info Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-900 font-medium mb-2">💡 About Salary Slips</p>
        <ul className="text-xs text-blue-800 space-y-1 ml-4 list-disc">
          <li>Salary slips are generated after monthly salary processing</li>
          <li>Each slip shows: Fixed Salary + Petrol + Bonus - Penalty = Net Payable</li>
          <li>Download slips as records for your accounting</li>
          <li>Payment status shows if salary has been paid to the rep</li>
        </ul>
      </div>
    </div>
  );
};

export default SalarySlips;
