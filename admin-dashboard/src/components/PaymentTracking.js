/**
 * Payment Tracking Component
 * Record and track salary payments for representatives
 * 
 * Features:
 * - Record payment for salary slip
 * - Mark as paid/pending
 * - View payment history
 * - Track payment method
 * - Generate payment reports
 */

import React, { useState, useEffect } from 'react';
import { adminAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import {
  Loader,
  Plus,
  Check,
  X,
  Save,
  Edit,
  Eye,
  AlertCircle,
  DollarSign,
  Calendar,
  CreditCard,
} from 'lucide-react';

const PaymentTracking = () => {
  const [reps, setReps] = useState([]);
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    rep_id: '',
    month: new Date().toISOString().slice(0, 7),
    amount: '',
    payment_method: 'bank_transfer',
    reference_no: '',
    notes: '',
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const response = await adminAPI.getAllReps();
      setReps(response.data.data || []);
      
      // In a real scenario, fetch from /api/admin/payments
      generateMockPayments();
      setError(null);
    } catch (err) {
      console.error('Error fetching data:', err);
      setError('Failed to load payment data');
    } finally {
      setLoading(false);
    }
  };

  const generateMockPayments = () => {
    const mockPayments = [
      {
        id: 1,
        rep_id: 1,
        rep_name: 'John Doe',
        month: '2026-02-01',
        amount: 17500,
        payment_method: 'bank_transfer',
        reference_no: 'TXN-2026-02-001',
        payment_date: '2026-02-15',
        status: 'paid',
        notes: 'Salary for February',
        created_at: '2026-02-15T10:30:00',
      },
      {
        id: 2,
        rep_id: 2,
        rep_name: 'Sarah Smith',
        month: '2026-02-01',
        amount: 16200,
        payment_method: 'bank_transfer',
        reference_no: 'TXN-2026-02-002',
        payment_date: '2026-02-15',
        status: 'paid',
        notes: 'Salary for February',
        created_at: '2026-02-15T10:35:00',
      },
      {
        id: 3,
        rep_id: 3,
        rep_name: 'Mike Johnson',
        month: '2026-03-01',
        amount: 18000,
        payment_method: 'pending',
        reference_no: '',
        payment_date: null,
        status: 'pending',
        notes: 'Pending approval',
        created_at: '2026-03-05T09:00:00',
      },
    ];
    setPayments(mockPayments);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!formData.rep_id || !formData.month || !formData.amount) {
      setError('Please fill all required fields');
      return;
    }

    try {
      setError(null);

      const selectedRep = reps.find(r => r.id === parseInt(formData.rep_id));
      
      if (editingId) {
        // Update payment
        const updatedPayments = payments.map(p =>
          p.id === editingId
            ? {
                ...p,
                rep_id: parseInt(formData.rep_id),
                rep_name: selectedRep.name,
                month: formData.month,
                amount: parseFloat(formData.amount),
                payment_method: formData.payment_method,
                reference_no: formData.reference_no,
                notes: formData.notes,
                status: formData.payment_method === 'pending' ? 'pending' : 'paid',
                payment_date: formData.payment_method === 'pending' ? null : new Date().toISOString().split('T')[0],
              }
            : p
        );
        setPayments(updatedPayments);
        setSuccess('Payment updated successfully!');
      } else {
        // Create payment
        const newPayment = {
          id: Math.max(...payments.map(p => p.id), 0) + 1,
          rep_id: parseInt(formData.rep_id),
          rep_name: selectedRep.name,
          month: formData.month,
          amount: parseFloat(formData.amount),
          payment_method: formData.payment_method,
          reference_no: formData.reference_no,
          notes: formData.notes,
          status: formData.payment_method === 'pending' ? 'pending' : 'paid',
          payment_date: formData.payment_method === 'pending' ? null : new Date().toISOString().split('T')[0],
          created_at: new Date().toISOString(),
        };
        setPayments([...payments, newPayment]);
        setSuccess('Payment recorded successfully!');
      }

      // Reset form
      setShowForm(false);
      setEditingId(null);
      setFormData({
        rep_id: '',
        month: new Date().toISOString().slice(0, 7),
        amount: '',
        payment_method: 'bank_transfer',
        reference_no: '',
        notes: '',
      });

      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError(err.message || 'Failed to save payment');
    }
  };

  const handleEdit = (payment) => {
    setEditingId(payment.id);
    setFormData({
      rep_id: payment.rep_id,
      month: payment.month,
      amount: payment.amount,
      payment_method: payment.status === 'pending' ? 'pending' : 'bank_transfer',
      reference_no: payment.reference_no || '',
      notes: payment.notes || '',
    });
    setShowForm(true);
  };

  const handleCancel = () => {
    setShowForm(false);
    setEditingId(null);
    setFormData({
      rep_id: '',
      month: new Date().toISOString().slice(0, 7),
      amount: '',
      payment_method: 'bank_transfer',
      reference_no: '',
      notes: '',
    });
  };

  const handleDelete = async (paymentId) => {
    if (!window.confirm('Are you sure you want to delete this payment record?')) {
      return;
    }

    try {
      setPayments(payments.filter(p => p.id !== paymentId));
      setSuccess('Payment record deleted');
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError('Failed to delete payment');
    }
  };

  const totalPaidAmount = payments
    .filter(p => p.status === 'paid')
    .reduce((sum, p) => sum + p.amount, 0);

  const totalPendingAmount = payments
    .filter(p => p.status === 'pending')
    .reduce((sum, p) => sum + p.amount, 0);

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading payment data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-start">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Payment Tracking</h2>
          <p className="text-gray-600">Record and track salary payments for representatives</p>
        </div>
        <button
          onClick={() => setShowForm(!showForm)}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg transition"
        >
          <Plus className="w-4 h-4" />
          Record Payment
        </button>
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
          <Check className="w-5 h-5 flex-shrink-0 mt-0.5" />
          <div>
            <p className="font-semibold">Success</p>
            <p className="text-sm">{success}</p>
          </div>
        </div>
      )}

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-6 border border-green-200">
          <div className="flex items-center justify-between mb-2">
            <p className="text-sm text-green-700 font-semibold">Total Paid</p>
            <Check className="w-5 h-5 text-green-600" />
          </div>
          <p className="text-3xl font-bold text-green-900">
            {CURRENCY.SYMBOL}{totalPaidAmount.toLocaleString('en-IN')}
          </p>
          <p className="text-xs text-green-700 mt-2">
            {payments.filter(p => p.status === 'paid').length} payments
          </p>
        </div>

        <div className="bg-gradient-to-br from-orange-50 to-orange-100 rounded-lg p-6 border border-orange-200">
          <div className="flex items-center justify-between mb-2">
            <p className="text-sm text-orange-700 font-semibold">Pending</p>
            <Calendar className="w-5 h-5 text-orange-600" />
          </div>
          <p className="text-3xl font-bold text-orange-900">
            {CURRENCY.SYMBOL}{totalPendingAmount.toLocaleString('en-IN')}
          </p>
          <p className="text-xs text-orange-700 mt-2">
            {payments.filter(p => p.status === 'pending').length} payments
          </p>
        </div>

        <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-6 border border-blue-200">
          <div className="flex items-center justify-between mb-2">
            <p className="text-sm text-blue-700 font-semibold">Total Processed</p>
            <DollarSign className="w-5 h-5 text-blue-600" />
          </div>
          <p className="text-3xl font-bold text-blue-900">
            {CURRENCY.SYMBOL}{(totalPaidAmount + totalPendingAmount).toLocaleString('en-IN')}
          </p>
          <p className="text-xs text-blue-700 mt-2">
            {payments.length} total records
          </p>
        </div>
      </div>

      {/* Form */}
      {showForm && (
        <div className="bg-white rounded-lg shadow-sm border border-gray-100 p-6">
          <h3 className="text-lg font-bold text-gray-900 mb-4">
            {editingId ? 'Edit Payment' : 'Record New Payment'}
          </h3>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Representative <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.rep_id}
                  onChange={(e) => setFormData({ ...formData, rep_id: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                >
                  <option value="">-- Select Rep --</option>
                  {reps.map(rep => (
                    <option key={rep.id} value={rep.id}>{rep.name}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Month <span className="text-red-500">*</span>
                </label>
                <input
                  type="month"
                  value={formData.month}
                  onChange={(e) => setFormData({ ...formData, month: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Amount ({CURRENCY.SYMBOL}) <span className="text-red-500">*</span>
                </label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.amount}
                  onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Payment Method <span className="text-red-500">*</span>
                </label>
                <select
                  value={formData.payment_method}
                  onChange={(e) => setFormData({ ...formData, payment_method: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                >
                  <option value="bank_transfer">Bank Transfer</option>
                  <option value="cash">Cash</option>
                  <option value="cheque">Cheque</option>
                  <option value="pending">Pending</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Reference No (Transaction ID / Cheque No)
                </label>
                <input
                  type="text"
                  value={formData.reference_no}
                  onChange={(e) => setFormData({ ...formData, reference_no: e.target.value })}
                  placeholder="e.g., TXN-2026-03-001"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Notes
              </label>
              <textarea
                value={formData.notes}
                onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                placeholder="e.g., Salary for March 2026"
                rows="3"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div className="flex gap-3 justify-end">
              <button
                type="button"
                onClick={handleCancel}
                className="bg-gray-300 hover:bg-gray-400 text-gray-900 font-semibold py-2 px-6 rounded-lg transition"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-6 rounded-lg transition flex items-center gap-2"
              >
                <Save className="w-4 h-4" />
                {editingId ? 'Update Payment' : 'Record Payment'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Payments List */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="bg-gray-50 px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-bold text-gray-900">Payment Records</h3>
          <p className="text-sm text-gray-600 mt-1">All payment transactions</p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-100 border-b border-gray-200">
              <tr>
                <th className="px-4 py-3 text-left font-semibold text-gray-700">Rep Name</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-700">Month</th>
                <th className="px-4 py-3 text-right font-semibold text-gray-700">Amount</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-700">Method</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-700">Ref No</th>
                <th className="px-4 py-3 text-center font-semibold text-gray-700">Status</th>
                <th className="px-4 py-3 text-left font-semibold text-gray-700">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {payments.length === 0 ? (
                <tr>
                  <td colSpan="7" className="px-6 py-4 text-center text-gray-600">
                    No payment records found
                  </td>
                </tr>
              ) : (
                payments.map(payment => (
                  <tr key={payment.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-semibold text-gray-900">{payment.rep_name}</td>
                    <td className="px-4 py-3 text-gray-700">{payment.month}</td>
                    <td className="px-4 py-3 text-right font-semibold text-gray-900">
                      {CURRENCY.SYMBOL}{payment.amount.toLocaleString('en-IN')}
                    </td>
                    <td className="px-4 py-3 text-gray-700 capitalize">
                      {payment.payment_method.replace('_', ' ')}
                    </td>
                    <td className="px-4 py-3 text-gray-700">
                      {payment.reference_no || '-'}
                    </td>
                    <td className="px-4 py-3 text-center">
                      {payment.status === 'paid' ? (
                        <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700">
                          <Check className="w-3 h-3" />
                          Paid
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-700">
                          <Calendar className="w-3 h-3" />
                          Pending
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 flex gap-2">
                      <button
                        onClick={() => handleEdit(payment)}
                        className="text-blue-600 hover:text-blue-700 font-semibold text-xs flex items-center gap-1"
                      >
                        <Edit className="w-3 h-3" />
                        Edit
                      </button>
                      <button
                        onClick={() => handleDelete(payment.id)}
                        className="text-red-600 hover:text-red-700 font-semibold text-xs flex items-center gap-1"
                      >
                        <X className="w-3 h-3" />
                        Delete
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Info Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-900 font-medium mb-2">💡 About Payment Tracking</p>
        <ul className="text-xs text-blue-800 space-y-1 ml-4 list-disc">
          <li>Record payment after generating salary slips from "Salary Processing"</li>
          <li>Track payment method: Bank Transfer, Cash, Cheque, or Pending</li>
          <li>Save transaction reference (bank transaction ID or cheque number)</li>
          <li>View payment status and history for accounting records</li>
          <li>Mark as "Pending" if payment is approved but not yet disbursed</li>
        </ul>
      </div>
    </div>
  );
};

export default PaymentTracking;
