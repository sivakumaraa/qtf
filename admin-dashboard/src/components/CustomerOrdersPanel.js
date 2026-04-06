import React, { useState, useEffect, useCallback } from 'react';
import { adminAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import { Plus, Trash2, Loader } from 'lucide-react';

const CustomerOrdersPanel = ({ customerId, customerName, reps, onClose }) => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showNewOrderForm, setShowNewOrderForm] = useState(false);
  const [newOrder, setNewOrder] = useState({
    rep_id: '',
    order_amount: '',
    order_date: new Date().toISOString().split('T')[0],
    product_details: '',
    status: 'pending',
  });

  const fetchOrders = useCallback(async () => {
    try {
      setLoading(true);
      const response = await adminAPI.getOrdersByCustomer(customerId);
      setOrders(response.data.data || []);
      setError(null);
    } catch (err) {
      setError(err.message || 'Failed to fetch orders');
    } finally {
      setLoading(false);
    }
  }, [customerId]);

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  const handleCreateOrder = async (e) => {
    e.preventDefault();
    
    if (!newOrder.rep_id || !newOrder.order_amount) {
      setError('Rep and order amount are required');
      return;
    }

    try {
      setError(null);
      
      const orderData = {
        ...newOrder,
        customer_id: customerId,
        rep_id: parseInt(newOrder.rep_id, 10),
        order_amount: parseFloat(newOrder.order_amount),
      };

      await adminAPI.createOrder(orderData);

      setSuccess('Order created successfully!');
      setNewOrder({
        rep_id: '',
        order_amount: '',
        order_date: new Date().toISOString().split('T')[0],
        product_details: '',
        status: 'pending',
      });
      setShowNewOrderForm(false);
      await fetchOrders();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError(err.message || 'Failed to create order');
    }
  };

  const handleDeleteOrder = async (orderId) => {
    if (window.confirm('Are you sure you want to delete this order?')) {
      try {
        await adminAPI.deleteOrder(orderId);
        setSuccess('Order deleted successfully!');
        await fetchOrders();
        setTimeout(() => setSuccess(null), 3000);
      } catch (err) {
        setError(err.message || 'Failed to delete order');
      }
    }
  };

  const getStatusBadgeColor = (status) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      case 'confirmed':
        return 'bg-blue-100 text-blue-800';
      case 'delivered':
        return 'bg-green-100 text-green-800';
      case 'cancelled':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="bg-gray-50 border border-gray-200 rounded-lg p-6 space-y-4">
      <div className="flex justify-between items-center">
        <h4 className="text-lg font-semibold text-gray-900">
          Orders for {customerName}
        </h4>
        <button
          onClick={onClose}
          className="text-gray-500 hover:text-gray-700"
        >
          ✕
        </button>
      </div>

      {/* Messages */}
      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
          {error}
        </div>
      )}

      {success && (
        <div className="p-3 bg-green-50 border border-green-200 rounded-lg text-green-700 text-sm">
          {success}
        </div>
      )}

      {/* Previous Orders */}
      <div>
        <h5 className="font-semibold text-gray-800 mb-3 flex items-center gap-2">
          <span>Previous Orders</span>
          {orders.length > 0 && (
            <span className="bg-blue-600 text-white text-xs px-2 py-0.5 rounded-full">
              {orders.length}
            </span>
          )}
        </h5>

        {loading ? (
          <div className="flex items-center justify-center py-8">
            <Loader className="w-6 h-6 animate-spin text-blue-600" />
          </div>
        ) : orders.length === 0 ? (
          <div className="bg-white rounded-lg border border-gray-200 p-4 text-center text-gray-600">
            No previous orders for this customer
          </div>
        ) : (
          <div className="space-y-3">
            {orders.map(order => (
              <div
                key={order.id}
                className="bg-white rounded-lg border border-gray-200 p-4 hover:shadow-md transition"
              >
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <p className="font-semibold text-gray-900">
                      {CURRENCY.SYMBOL}{parseFloat(order.order_amount).toFixed(2)} {CURRENCY.CODE}
                    </p>
                    <p className="text-sm text-gray-600">
                      {reps.find(r => r.id === order.rep_id)?.name || 'Unknown Rep'}
                    </p>
                  </div>
                  <span className={`px-3 py-1 rounded-full text-xs font-semibold ${getStatusBadgeColor(order.status)}`}>
                    {order.status}
                  </span>
                </div>
                <div className="text-xs text-gray-500 mb-2">
                  Order Date: {new Date(order.order_date).toLocaleDateString()}
                </div>
                {order.product_details && (
                  <p className="text-sm text-gray-700 mb-2">{order.product_details}</p>
                )}
                <button
                  onClick={() => handleDeleteOrder(order.id)}
                  className="text-red-600 hover:text-red-700 text-sm font-semibold flex items-center gap-1"
                >
                  <Trash2 className="w-3 h-3" />
                  Delete
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* New Order Form */}
      <div className="border-t pt-4">
        <button
          onClick={() => setShowNewOrderForm(!showNewOrderForm)}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg font-semibold hover:bg-blue-700 transition flex items-center gap-2 w-full justify-center"
        >
          <Plus className="w-4 h-4" />
          {showNewOrderForm ? 'Cancel New Order' : 'Create New Order'}
        </button>

        {showNewOrderForm && (
          <form onSubmit={handleCreateOrder} className="mt-4 space-y-4 bg-white rounded-lg p-4 border border-gray-200">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Select Rep *
                </label>
                <select
                  value={newOrder.rep_id}
                  onChange={(e) => setNewOrder({ ...newOrder, rep_id: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  required
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
                  Order Amount ({CURRENCY.CODE}) *
                </label>
                <div className="flex items-center gap-1">
                  <span className="text-gray-600">{CURRENCY.SYMBOL}</span>
                  <input
                    type="number"
                    step="0.01"
                    value={newOrder.order_amount}
                    onChange={(e) => setNewOrder({ ...newOrder, order_amount: e.target.value })}
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
                  value={newOrder.order_date}
                  onChange={(e) => setNewOrder({ ...newOrder, order_date: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Status
                </label>
                <select
                  value={newOrder.status}
                  onChange={(e) => setNewOrder({ ...newOrder, status: e.target.value })}
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
                  value={newOrder.product_details}
                  onChange={(e) => setNewOrder({ ...newOrder, product_details: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  placeholder="e.g., 50m³ of RMC Grade 30, delivery by truck"
                  rows="3"
                />
              </div>
            </div>

            <button
              type="submit"
              className="bg-green-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-green-700 transition w-full"
            >
              Create Order
            </button>
          </form>
        )}
      </div>
    </div>
  );
};

export default CustomerOrdersPanel;
