import axios from 'axios';

// Configure API base URL
const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:3000';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Rep Targets API
export const repTargetsAPI = {
  // Get all targets
  getAll: () => apiClient.get('/api/admin/rep-targets'),

  // Get specific rep targets
  getByRepId: (repId) => apiClient.get(`/api/admin/rep-targets/${repId}`),

  // Create/set targets
  create: (data) => apiClient.post('/api/admin/rep-targets', data),

  // Update targets
  update: (repId, data) => apiClient.put(`/api/admin/rep-targets/${repId}`, data),
};

// Rep Progress API
export const repProgressAPI = {
  // Get rep progress (monthly)
  getProgress: (repId, month) =>
    apiClient.get(`/api/admin/rep-progress/${repId}`, { params: { month } }),

  // Get all historical sales for a rep
  getHistory: (repId) =>
    apiClient.get(`/api/admin/rep-progress-history/${repId}`),

  // Record sales and calculate bonus/penalty
  recordSales: (data) => apiClient.post('/api/admin/rep-progress/update', data),
};

// Admin Management API
export const adminAPI = {
  // Get all reps
  getAllReps: () => apiClient.get('/api/admin/reps'),

  // Get all customers
  getAllCustomers: () => apiClient.get('/api/admin/customers'),

  // Customer Management
  createCustomer: (data) => apiClient.post('/api/admin/customers', data),
  updateCustomer: (id, data) => apiClient.put(`/api/admin/customers/${id}`, data),
  deleteCustomer: (id) => apiClient.delete(`/api/admin/customers/${id}`),

  // User Management
  getAllUsers: () => apiClient.get('/api/admin/users'),
  createUser: (data) => apiClient.post('/api/admin/users', data),
  updateUser: (id, data) => apiClient.put(`/api/admin/users/${id}`, data),
  deleteUser: (id) => apiClient.delete(`/api/admin/users/${id}`),

  // Order Management
  getAllOrders: () => apiClient.get('/api/admin/orders'),
  getOrdersByCustomer: (customerId) => apiClient.get(`/api/admin/orders/customer/${customerId}`),
  createOrder: (data) => apiClient.post('/api/admin/orders', data),
  updateOrder: (id, data) => apiClient.put(`/api/admin/orders/${id}`, data),
  deleteOrder: (id) => apiClient.delete(`/api/admin/orders/${id}`),

  // Reset device
  resetDevice: (userId) =>
    apiClient.post('/api/admin/reset-device', { user_id: userId }),
};

// System API
export const systemAPI = {
  // Get settings
  getSettings: () => apiClient.get('/api/settings'),

  // Update settings
  updateSettings: (data) => apiClient.put('/api/settings', data),

  // Health check
  healthCheck: () => apiClient.get('/test'),

  // Welcome (list all APIs)
  getWelcome: () => apiClient.get('/'),
};

// Export client as named export
export const client = apiClient;

export default apiClient;
