import React, { useState, useEffect } from 'react';
import { adminAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import { Loader, AlertCircle } from 'lucide-react';

const OrdersManagement = () => {
  const [orders, setOrders] = useState([]);
  const [reps, setReps] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    rep_id: '',
    customer_id: '',
    order_amount: '',
    order_date: new Date().toISOString().split('T')[0],
    product_details: '',
    status: 'pending',
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [repsRes, customersRes, ordersRes] = await Promise.all([
        adminAPI.getAllReps(),
        adminAPI.getAllCustomers(),
        adminAPI.getAllOrders()
      ]);
      setReps(repsRes.data.data || []);
      setCustomers(customersRes.data.data || []);
      setOrders(ordersRes.data.data || []);
      setError(null);
    } catch (err) {
      setError(err.message || 'Failed to fetch data');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.rep_id || !formData.customer_id || !formData.order_amount) {
      setError('Rep, customer, and order amount are required');
      return;
    }

    try {
      setError(null);
      
      const submitData = {
        ...formData,
        rep_id: parseInt(formData.rep_id, 10),
        customer_id: parseInt(formData.customer_id, 10),
        order_amount: parseFloat(formData.order_amount),
      };

      if (editingId) {
        // Update order
        await adminAPI.updateOrder(editingId, submitData);
        setSuccess('Order updated successfully!');
        setEditingId(null);
      } else {
        // Create new order
        await adminAPI.createOrder(submitData);
        setSuccess('Order created successfully!');
      }
      resetForm();
      await fetchData();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError(err.message || 'Failed to save order');
    }
  };

  const resetForm = () => {
    setFormData({
      rep_id: '',
      customer_id: '',
      order_amount: '',
      order_date: new Date().toISOString().split('T')[0],
      product_details: '',
      status: 'pending',
    });
    setEditingId(null);
    setShowForm(false);
  };

  const handleEdit = (order) => {
    setEditingId(order.id);
    setFormData({
      rep_id: order.rep_id,
      customer_id: order.customer_id,
      order_amount: order.order_amount,
      order_date: order.order_date,
      product_details: order.product_details || '',
      status: order.status,
    });
    setShowForm(true);
  };

  const handleDelete = async (orderId) => {
    if (window.confirm('Are you sure you want to delete this order?')) {
      try {
        setError(null);
        await adminAPI.deleteOrder(orderId);
        setSuccess('Order deleted successfully!');
        await fetchData();
        setTimeout(() => setSuccess(null), 3000);
      } catch (err) {
        setError(err.message || 'Failed to delete order');
      }
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading orders...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Orders Management</h2>
          <p className="text-gray-600">Track and manage rep orders</p>
        </div>
        <button
          onClick={() => {
            if (showForm) {
              resetForm();
            } else {
              setShowForm(true);
            }
          }}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg font-semibold hover:bg-blue-700 transition flex items-center gap-2"
        >
          {showForm ? '✕ Cancel' : '+ Add Order'}
        </button>
      </div>

      {/* Messages */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg flex items-center gap-3">
          <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0" />
          <p className="text-red-700">{error}</p>
        </div>
      )}

      {success && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-700">
          {success}
        </div>
      )}

      {/* Form */}
      {showForm && (
        <div className="bg-white rounded-lg shadow-md p-6 border-l-4 border-blue-600 space-y-4">
          <h3 className="text-lg font-semibold text-gray-900">
            {editingId ? 'Edit Order' : 'Add New Order'}
          </h3>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Select Rep *
                </label>
                <select
                  value={formData.rep_id}
                  onChange={(e) => setFormData({ ...formData, rep_id: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  required
                  disabled={editingId !== null}
                >
                  <option value="">-- Choose Rep --</option>
                  {reps.map(rep => (
                    <option key={rep.id} value={rep.id}>
                      {rep.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Select Customer *
                </label>
                <select
                  value={formData.customer_id}
                  onChange={(e) => setFormData({ ...formData, customer_id: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  required
                >
                  <option value="">-- Choose Customer --</option>
                  {customers.map(customer => (
                    <option key={customer.id} value={customer.id}>
                      {customer.name || 'Unnamed Customer'}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Order Amount ({CURRENCY.CODE}) *
                </label>
                <div className="flex items-center gap-1">
                  <span className="text-gray-600">{CURRENCY.SYMBOL}</span>
                  <input
                    type="number"
                    step="0.01"
                    value={formData.order_amount}
                    onChange={(e) => setFormData({ ...formData, order_amount: e.target.value })}
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="0.00"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Order Date *
                </label>
                <input
                  type="date"
                  value={formData.order_date}
                  onChange={(e) => setFormData({ ...formData, order_date: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Status
                </label>
                <select
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                >
                  <option value="pending">Pending</option>
                  <option value="confirmed">Confirmed</option>
                  <option value="delivered">Delivered</option>
                  <option value="cancelled">Cancelled</option>
                </select>
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Product Details
                </label>
                <textarea
                  value={formData.product_details}
                  onChange={(e) => setFormData({ ...formData, product_details: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  placeholder="e.g., 50 tons quarry stone, grade A"
                  rows="3"
                />
              </div>
            </div>

            <div className="flex gap-3">
              <button
                type="submit"
                className="bg-green-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-green-700 transition"
              >
                {editingId ? 'Update Order' : 'Save Order'}
              </button>
              <button
                type="button"
                onClick={resetForm}
                className="bg-gray-300 text-gray-700 px-6 py-2 rounded-lg font-semibold hover:bg-gray-400 transition"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Orders Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Rep</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Customer</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Amount</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Date</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {orders.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-4 text-center text-gray-600">
                    No orders found. Add one to get started.
                  </td>
                </tr>
              ) : (
                orders.map(order => (
                  <tr key={order.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-semibold text-gray-900">
                      {reps.find(r => r.id === order.rep_id)?.name || '-'}
                    </td>
                    <td className="px-6 py-4 text-gray-700">
                      {customers.find(c => c.id === order.customer_id)?.name || '-'}
                    </td>
                    <td className="px-6 py-4 font-semibold text-gray-900">
                      {CURRENCY.SYMBOL}{parseFloat(order.order_amount).toLocaleString('en-IN')}
                    </td>
                    <td className="px-6 py-4 text-gray-700 text-sm">
                      {new Date(order.order_date).toLocaleDateString('en-IN')}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                        order.status === 'delivered'
                          ? 'bg-green-100 text-green-700'
                          : order.status === 'cancelled'
                          ? 'bg-red-100 text-red-700'
                          : order.status === 'confirmed'
                          ? 'bg-blue-100 text-blue-700'
                          : 'bg-yellow-100 text-yellow-700'
                      }`}>
                        {order.status.charAt(0).toUpperCase() + order.status.slice(1)}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => handleEdit(order)}
                        className="text-blue-600 hover:text-blue-700 font-semibold text-sm hover:underline"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => handleDelete(order.id)}
                        className="text-red-600 hover:text-red-700 font-semibold text-sm hover:underline ml-3"
                      >
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
        <p className="text-sm text-blue-900 font-medium mb-2">💡 About Orders</p>
        <ul className="text-xs text-blue-800 space-y-1 ml-4 list-disc">
          <li>Orders track all sales transactions made by reps</li>
          <li>Order status progresses from pending → confirmed → delivered</li>
          <li>Each order must be assigned to a rep and customer</li>
          <li>Order amounts are used for sales target calculations</li>
        </ul>
      </div>
    </div>
  );
};

export default OrdersManagement;
