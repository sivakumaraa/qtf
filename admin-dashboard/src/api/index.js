import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const getSystemSettings = async () => {
  const response = await api.get('/settings');
  return response.data;
};

export const getReps = async () => {
  const response = await api.get('/admin/reps');
  return response.data;
};

export const getCustomers = async () => {
  const response = await api.get('/admin/customers');
  return response.data;
};

export const getRepTargets = async () => {
    const response = await api.get('/admin/rep-targets');
    return response.data;
}

export const getRepProgress = async (repId, month) => {
    const params = month ? { month } : {};
    const response = await api.get(`/admin/rep-progress/${repId}`, { params });
    return response.data;
}

export const updateRepTargets = async (repId, data) => {
    const response = await api.put(`/admin/rep-targets/${repId}`, data);
    return response.data;
}

export const resetDevice = async (repId, adminId) => {
  const response = await api.post('/admin/reset-device', { rep_id: repId, updated_by: adminId });
  return response.data;
};

export default api;
