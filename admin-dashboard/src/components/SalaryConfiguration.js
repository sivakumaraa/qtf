/**
 * Salary Configuration Component
 * Manage fixed and variable salary components for all reps
 * 
 * Components:
 * - Fixed Salary (base monthly salary)
 * - Petrol Allowance (travel/transport allowance)
 * - Default values for all reps
 * 
 * Features:
 * - Edit salary for individual reps
 * - Set company-wide defaults
 * - View salary history
 * - Calculate gross salary components
 */

import React, { useState, useEffect } from 'react';
import { adminAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import { Edit, Save, X, Loader, DollarSign, Truck, TrendingUp } from 'lucide-react';

const SalaryConfiguration = () => {
  const [reps, setReps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [editingId, setEditingId] = useState(null);
  const [editFormData, setEditFormData] = useState({});
  const [defaultSalary, setDefaultSalary] = useState({
    fixed_salary: 15000,
    petrol_allowance: 2000,
  });

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

  const handleEditClick = (rep) => {
    setEditingId(rep.id);
    setEditFormData({
      fixed_salary: rep.fixed_salary || 0,
      petrol_allowance: rep.petrol_allowance || 0,
    });
  };

  const handleSave = async (repId, repName) => {
    try {
      setError(null);
      const response = await adminAPI.updateUser(repId, editFormData);
      if (response.data.success) {
        setSuccess(`Salary updated for ${repName}`);
        setEditingId(null);
        await fetchReps();
        setTimeout(() => setSuccess(null), 3000);
      } else {
        setError(response.data.message || 'Failed to update salary');
      }
    } catch (err) {
      setError(err.message || 'Failed to save changes');
    }
  };

  const handleCancel = () => {
    setEditingId(null);
    setEditFormData({});
  };

  const applyDefaultsToAll = async () => {
    if (!window.confirm('Apply default salary to all reps? This will override individual settings.')) {
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      // Apply to all reps
      const promises = reps.map(rep =>
        adminAPI.updateUser(rep.id, defaultSalary).catch(err => {
          console.error(`Failed to update ${rep.name}:`, err);
          return null;
        })
      );

      await Promise.all(promises);
      setSuccess('Default salary applied to all reps!');
      await fetchReps();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError('Failed to apply defaults');
    } finally {
      setLoading(false);
    }
  };

  const calculateGross = (fixed, petrol) => {
    return (parseFloat(fixed) || 0) + (parseFloat(petrol) || 0);
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading salary configuration...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Salary Configuration</h2>
        <p className="text-gray-600">Manage fixed and variable salary components for all representatives</p>
      </div>

      {/* Messages */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 flex items-start gap-3">
          <span className="text-lg">⚠️</span>
          <div>
            <p className="font-semibold">Error</p>
            <p className="text-sm">{error}</p>
          </div>
        </div>
      )}

      {success && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-700 flex items-start gap-3">
          <span className="text-lg">✅</span>
          <div>
            <p className="font-semibold">Success</p>
            <p className="text-sm">{success}</p>
          </div>
        </div>
      )}

      {/* Default Salary Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Default Salary Cards */}
        <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-6 border border-blue-200">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-bold text-gray-900">Default Settings</h3>
            <DollarSign className="w-6 h-6 text-blue-600" />
          </div>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Default Fixed Salary
              </label>
              <div className="flex items-center gap-2">
                <span className="text-gray-700 font-semibold">{CURRENCY.SYMBOL}</span>
                <input
                  type="number"
                  step="100"
                  value={defaultSalary.fixed_salary}
                  onChange={(e) => setDefaultSalary({ 
                    ...defaultSalary, 
                    fixed_salary: e.target.value 
                  })}
                  className="flex-1 px-3 py-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
                />
              </div>
              <p className="text-xs text-gray-600 mt-1">Base monthly salary for new reps</p>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Default Petrol Allowance
              </label>
              <div className="flex items-center gap-2">
                <span className="text-gray-700 font-semibold">{CURRENCY.SYMBOL}</span>
                <input
                  type="number"
                  step="100"
                  value={defaultSalary.petrol_allowance}
                  onChange={(e) => setDefaultSalary({ 
                    ...defaultSalary, 
                    petrol_allowance: e.target.value 
                  })}
                  className="flex-1 px-3 py-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
                />
              </div>
              <p className="text-xs text-gray-600 mt-1">Monthly travel/transport allowance</p>
            </div>

            <div className="bg-white rounded p-3 mt-4">
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-semibold text-gray-700">Gross Monthly</span>
                <TrendingUp className="w-4 h-4 text-green-600" />
              </div>
              <p className="text-2xl font-bold text-green-600">
                {CURRENCY.SYMBOL}{calculateGross(defaultSalary.fixed_salary, defaultSalary.petrol_allowance).toLocaleString('en-IN')}
              </p>
            </div>

            <button
              onClick={applyDefaultsToAll}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg transition"
            >
              Apply to All Reps
            </button>
          </div>
        </div>

        {/* Info Cards */}
        <div className="col-span-2 space-y-4">
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
            <p className="text-sm font-semibold text-amber-900 mb-2">📋 Salary Components</p>
            <ul className="text-xs text-amber-800 space-y-2 ml-4 list-disc">
              <li><strong>Fixed Salary:</strong> Base monthly salary, paid regardless of performance</li>
              <li><strong>Petrol Allowance:</strong> Monthly travel/transport allowance</li>
              <li><strong>Gross Salary:</strong> Fixed Salary + Petrol Allowance (constant monthly)</li>
              <li><strong>Variable Components:</strong> Bonus, Fines, Commissions (added/subtracted)</li>
            </ul>
          </div>

          <div className="bg-green-50 border border-green-200 rounded-lg p-4">
            <p className="text-sm font-semibold text-green-900 mb-2">🧮 Salary Calculation</p>
            <p className="text-xs text-green-800 mb-2">
              <strong>Net Salary = Gross + Bonus - Fines - Tax - Deductions</strong>
            </p>
            <p className="text-xs text-green-800">
              Each month, bonuses and fines from sales records are added/subtracted from the gross salary to calculate net salary.
            </p>
          </div>
        </div>
      </div>

      {/* Individual Rep Salary Configuration */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="bg-gray-50 px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-bold text-gray-900">Rep-wise Salary Configuration</h3>
          <p className="text-sm text-gray-600 mt-1">Edit individual rep salary components</p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Rep Name</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Fixed Salary</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Petrol</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Gross/Month</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {reps.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-4 text-center text-gray-600">
                    No reps found
                  </td>
                </tr>
              ) : (
                reps.map(rep => (
                  <tr key={rep.id} className="hover:bg-gray-50">
                    {editingId === rep.id ? (
                      <>
                        <td className="px-6 py-4 font-semibold text-gray-900">{rep.name}</td>
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-1 max-w-xs">
                            <span className="text-gray-600">{CURRENCY.SYMBOL}</span>
                            <input
                              type="number"
                              step="100"
                              value={editFormData.fixed_salary}
                              onChange={(e) => setEditFormData({ 
                                ...editFormData, 
                                fixed_salary: e.target.value 
                              })}
                              className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-1 max-w-xs">
                            <span className="text-gray-600">{CURRENCY.SYMBOL}</span>
                            <input
                              type="number"
                              step="100"
                              value={editFormData.petrol_allowance}
                              onChange={(e) => setEditFormData({ 
                                ...editFormData, 
                                petrol_allowance: e.target.value 
                              })}
                              className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span className="font-semibold text-green-600">
                            {CURRENCY.SYMBOL}{calculateGross(editFormData.fixed_salary, editFormData.petrol_allowance).toLocaleString('en-IN')}
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          <span className="px-3 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-700">
                            Editing
                          </span>
                        </td>
                        <td className="px-6 py-4 flex gap-2">
                          <button
                            onClick={() => handleSave(rep.id, rep.name)}
                            className="inline-flex items-center gap-1 text-green-600 hover:text-green-700 font-semibold text-sm"
                          >
                            <Save className="w-4 h-4" />
                            Save
                          </button>
                          <button
                            onClick={handleCancel}
                            className="inline-flex items-center gap-1 text-gray-600 hover:text-gray-700 font-semibold text-sm"
                          >
                            <X className="w-4 h-4" />
                            Cancel
                          </button>
                        </td>
                      </>
                    ) : (
                      <>
                        <td className="px-6 py-4 font-semibold text-gray-900">{rep.name}</td>
                        <td className="px-6 py-4 text-gray-700">
                          {CURRENCY.SYMBOL}{parseFloat(rep.fixed_salary || 0).toLocaleString('en-IN', { minimumFractionDigits: 0 })}
                        </td>
                        <td className="px-6 py-4 text-gray-700">
                          {CURRENCY.SYMBOL}{parseFloat(rep.petrol_allowance || 0).toLocaleString('en-IN', { minimumFractionDigits: 0 })}
                        </td>
                        <td className="px-6 py-4 font-semibold text-green-600">
                          {CURRENCY.SYMBOL}{calculateGross(rep.fixed_salary, rep.petrol_allowance).toLocaleString('en-IN', { minimumFractionDigits: 0 })}
                        </td>
                        <td className="px-6 py-4">
                          <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                            rep.is_active
                              ? 'bg-green-100 text-green-700'
                              : 'bg-gray-100 text-gray-700'
                          }`}>
                            {rep.is_active ? 'Active' : 'Inactive'}
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          <button
                            onClick={() => handleEditClick(rep)}
                            className="inline-flex items-center gap-1 text-blue-600 hover:text-blue-700 font-semibold text-sm hover:underline"
                          >
                            <Edit className="w-4 h-4" />
                            Edit
                          </button>
                        </td>
                      </>
                    )}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Info Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-900 font-medium mb-2">💡 Tips for Salary Configuration</p>
        <ul className="text-xs text-blue-800 space-y-1 ml-4 list-disc">
          <li>Set company-wide defaults and apply to all new reps</li>
          <li>Edit individual reps if they have different salary structures</li>
          <li>Gross Salary (Fixed + Petrol) is paid every month regardless of performance</li>
          <li>Bonuses and fines are calculated monthly based on sales and penalties</li>
          <li>Changes take effect immediately for future salary calculations</li>
        </ul>
      </div>
    </div>
  );
};

export default SalaryConfiguration;
