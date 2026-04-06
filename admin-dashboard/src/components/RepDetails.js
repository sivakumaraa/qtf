import React, { useState, useEffect } from 'react';
import { adminAPI } from '../api/client';
import { CURRENCY } from '../config/constants';
import { Edit, Save, X, Loader, Upload, Trash2 } from 'lucide-react';

const RepDetails = () => {
  const [reps, setReps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [editingId, setEditingId] = useState(null);
  const [editFormData, setEditFormData] = useState({});
  const [photoPreview, setPhotoPreview] = useState(null);

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
      name: rep.name,
      email: rep.email,
      mobile_no: rep.mobile_no || '',
      fixed_salary: rep.fixed_salary || 0,
      petrol_allowance: rep.petrol_allowance || 0,
      photo: rep.photo || null,
    });
    setPhotoPreview(rep.photo || null);
  };

  const handlePhotoChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        const base64 = event.target.result;
        setEditFormData({ ...editFormData, photo: base64 });
        setPhotoPreview(base64);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRemovePhoto = () => {
    setEditFormData({ ...editFormData, photo: null });
    setPhotoPreview(null);
  };

  const handleSave = async (repId) => {
    try {
      setError(null);
      const response = await adminAPI.updateUser(repId, editFormData);
      if (response.data.success) {
        setSuccess('Rep details updated successfully!');
        setEditingId(null);
        await fetchReps();
        setTimeout(() => setSuccess(null), 3000);
      } else {
        setError(response.data.message || 'Failed to update rep');
      }
    } catch (err) {
      setError(err.message || 'Failed to save changes');
    }
  };

  const handleCancel = () => {
    setEditingId(null);
    setEditFormData({});
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading rep details...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Rep Details</h2>
        <p className="text-gray-600">Manage rep information and fixed salary components</p>
      </div>

      {/* Messages */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {error}
        </div>
      )}

      {success && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-700">
          {success}
        </div>
      )}

      {/* Reps Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Photo</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Rep Name</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Email</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Mobile</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Fixed Salary</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Petrol</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {reps.length === 0 ? (
                <tr>
                  <td colSpan="8" className="px-6 py-4 text-center text-gray-600">
                    No reps found
                  </td>
                </tr>
              ) : (
                reps.map(rep => (
                  <tr key={rep.id} className="hover:bg-gray-50">
                    {editingId === rep.id ? (
                      <>
                        <td className="px-6 py-4">
                          <div className="flex flex-col items-center gap-2">
                            {photoPreview ? (
                              <img
                                src={photoPreview}
                                alt="preview"
                                className="w-12 h-12 rounded-full object-cover border-2 border-blue-500"
                              />
                            ) : (
                              <div className="w-12 h-12 rounded-full bg-gray-300 flex items-center justify-center text-gray-600 font-bold">
                                {editFormData.name?.charAt(0)?.toUpperCase() || 'R'}
                              </div>
                            )}
                            <label className="text-xs text-blue-600 cursor-pointer hover:text-blue-700">
                              <Upload className="w-3 h-3 inline mr-1" />
                              Upload
                              <input
                                type="file"
                                accept="image/*"
                                onChange={handlePhotoChange}
                                className="hidden"
                              />
                            </label>
                            {photoPreview && (
                              <button
                                onClick={handleRemovePhoto}
                                className="text-xs text-red-600 hover:text-red-700"
                              >
                                <Trash2 className="w-3 h-3" />
                              </button>
                            )}
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <input
                            type="text"
                            value={editFormData.name}
                            onChange={(e) => setEditFormData({ ...editFormData, name: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                          />
                        </td>
                        <td className="px-6 py-4">
                          <input
                            type="email"
                            value={editFormData.email}
                            onChange={(e) => setEditFormData({ ...editFormData, email: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                          />
                        </td>
                        <td className="px-6 py-4">
                          <input
                            type="tel"
                            value={editFormData.mobile_no}
                            onChange={(e) => setEditFormData({ ...editFormData, mobile_no: e.target.value })}
                            placeholder="e.g., +91 9876543210"
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                          />
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-1">
                            <span className="text-gray-600">{CURRENCY.SYMBOL}</span>
                            <input
                              type="number"
                              step="0.01"
                              value={editFormData.fixed_salary}
                              onChange={(e) => setEditFormData({ ...editFormData, fixed_salary: e.target.value })}
                              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-1">
                            <span className="text-gray-600">{CURRENCY.SYMBOL}</span>
                            <input
                              type="number"
                              step="0.01"
                              value={editFormData.petrol_allowance}
                              onChange={(e) => setEditFormData({ ...editFormData, petrol_allowance: e.target.value })}
                              placeholder="Petrol allowance"
                              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            />
                          </div>
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
                        <td className="px-6 py-4 flex gap-2">
                          <button
                            onClick={() => handleSave(rep.id)}
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
                        <td className="px-6 py-4">
                          <div className="flex justify-center">
                            {rep.photo ? (
                              <img
                                src={rep.photo}
                                alt={rep.name}
                                className="w-12 h-12 rounded-full object-cover border-2 border-gray-300"
                              />
                            ) : (
                              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center text-white font-bold text-lg">
                                {rep.name?.charAt(0)?.toUpperCase() || 'R'}
                              </div>
                            )}
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span className="font-semibold text-gray-900">{rep.name}</span>
                        </td>
                        <td className="px-6 py-4 text-gray-700">{rep.email}</td>
                        <td className="px-6 py-4 text-gray-700">{rep.mobile_no || '-'}</td>
                        <td className="px-6 py-4 font-semibold text-gray-900">
                          {CURRENCY.SYMBOL}{rep.fixed_salary ? parseFloat(rep.fixed_salary).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '0.00'}
                        </td>
                        <td className="px-6 py-4 font-semibold text-gray-900">
                          {CURRENCY.SYMBOL}{rep.petrol_allowance ? parseFloat(rep.petrol_allowance).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '0.00'}
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
        <p className="text-sm text-blue-900 font-medium mb-2">💡 About Rep Details</p>
        <ul className="text-xs text-blue-800 space-y-1 ml-4 list-disc">
          <li>Fixed Salary: Monthly base salary for the rep</li>
          <li>Petrol Allowance: Monthly travel/transport allowance</li>
          <li>Gross Monthly = Fixed Salary + Petrol Allowance</li>
          <li>Variable incentives (bonus/fines) are calculated based on performance</li>
          <li>Total Net Salary = Gross + Bonus - Fines - Deductions</li>
          <li>Changes are applied immediately</li>
        </ul>
      </div>
    </div>
  );
};

export default RepDetails;
