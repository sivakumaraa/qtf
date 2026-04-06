import React, { useState, useEffect } from 'react';
import { adminAPI } from '../api/client';
import { Loader, AlertCircle } from 'lucide-react';
import LocationMapPicker from './LocationMapPicker';
import CustomerOrdersPanel from './CustomerOrdersPanel';

const CustomersManagement = () => {
  const [customers, setCustomers] = useState([]);
  const [reps, setReps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [expandedCustomerId, setExpandedCustomerId] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    phone_no: '',
    location: '',
    lat: '',
    lng: '',
    assigned_rep_id: '',
    site_type: 'Quarry',
    site_incharge_name: '',
    site_incharge_phone: '',
    material_needs: [],
    rmc_grade: '',
    aggregate_types: [],
    volume: '',
    volume_unit: 'm3',
    required_date: '',
    amount_concluded_per_unit: '',
    boom_pump_amount: '',
    address: '',
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [customersRes, repsRes] = await Promise.all([
        adminAPI.getAllCustomers(),
        adminAPI.getAllReps()
      ]);
      setCustomers(customersRes.data.data || []);
      setReps(repsRes.data.data || []);
      setError(null);
    } catch (err) {
      setError(err.message || 'Failed to fetch data');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Only Name and Assigned Rep are required; GPS is now optional
    if (!formData.name || !formData.assigned_rep_id) {
      setError('Customer Name and Assigned Rep are required');
      return;
    }

    try {
      setError(null);
      
      // Prepare data for submission
      const submitData = {
        ...formData,
        assigned_rep_id: parseInt(formData.assigned_rep_id, 10),
        material_needs: Array.isArray(formData.material_needs) ? JSON.stringify(formData.material_needs) : formData.material_needs,
        aggregate_types: Array.isArray(formData.aggregate_types) ? JSON.stringify(formData.aggregate_types) : formData.aggregate_types,
      };

      if (editingId) {
        // Update customer
        await adminAPI.updateCustomer(editingId, submitData);
        setSuccess('Customer updated successfully!');
        setEditingId(null);
      } else {
        // Create new customer
        await adminAPI.createCustomer(submitData);
        setSuccess('Customer created successfully!');
      }
      resetForm();
      await fetchData();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError(err.message || 'Failed to save customer');
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      phone_no: '',
      location: '',
      lat: '',
      lng: '',
      assigned_rep_id: '',
      site_type: 'Quarry',
      site_incharge_name: '',
      site_incharge_phone: '',
      material_needs: [],
      rmc_grade: '',
      aggregate_types: [],
      volume: '',
      volume_unit: 'm3',
      required_date: '',
      amount_concluded_per_unit: '',
      boom_pump_amount: '',
      address: '',
    });
    setEditingId(null);
    setShowForm(false);
  };

  const handleDelete = async (customerId) => {
    if (window.confirm('Are you sure you want to delete this customer?')) {
      try {
        setError(null);
        await adminAPI.deleteCustomer(customerId);
        setSuccess('Customer deleted successfully!');
        await fetchData();
        setTimeout(() => setSuccess(null), 3000);
      } catch (err) {
        setError(err.message || 'Failed to delete customer');
      }
    }
  };

  const handleEdit = (customer) => {
    setEditingId(customer.id);
    
    // Parse JSON fields if they come as strings from backend
    let materialNeeds = customer.material_needs || [];
    let aggregateTypes = customer.aggregate_types || [];
    
    if (typeof materialNeeds === 'string') {
      try {
        materialNeeds = JSON.parse(materialNeeds);
      } catch (e) {
        materialNeeds = [];
      }
    }
    
    if (typeof aggregateTypes === 'string') {
      try {
        aggregateTypes = JSON.parse(aggregateTypes);
      } catch (e) {
        aggregateTypes = [];
      }
    }
    
    setFormData({
      name: customer.name || '',
      phone_no: customer.phone_no || '',
      location: customer.location || '',
      lat: customer.lat || '',
      lng: customer.lng || '',
      assigned_rep_id: customer.assigned_rep_id ? String(customer.assigned_rep_id) : '',
      site_type: customer.site_type || 'Quarry',
      site_incharge_name: customer.site_incharge_name || '',
      site_incharge_phone: customer.site_incharge_phone || '',
      material_needs: Array.isArray(materialNeeds) ? materialNeeds : [],
      rmc_grade: customer.rmc_grade || '',
      aggregate_types: Array.isArray(aggregateTypes) ? aggregateTypes : [],
      volume: customer.volume || '',
      volume_unit: customer.volume_unit || 'm3',
      required_date: customer.required_date || '',
      amount_concluded_per_unit: customer.amount_concluded_per_unit || '',
      boom_pump_amount: customer.boom_pump_amount || '',
      address: customer.address || '',
    });
    setShowForm(true);
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading customers...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Customers Management</h2>
          <p className="text-gray-600">Add and manage customer locations</p>
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
          {showForm ? '✕ Cancel' : '+ Add Customer'}
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
            {editingId ? 'Edit Customer' : 'Add New Customer'}
          </h3>
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Section 1: Customer Info */}
            <div className="border-b pb-4">
              <h4 className="font-semibold text-gray-800 mb-3">Customer Information</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Customer Name *
                  </label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., Main Quarry, Site A"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Customer Phone
                  </label>
                  <input
                    type="tel"
                    value={formData.phone_no}
                    onChange={(e) => setFormData({ ...formData, phone_no: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., +91 9876543210"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Assigned Rep *
                  </label>
                  <select
                    value={formData.assigned_rep_id}
                    onChange={(e) => setFormData({ ...formData, assigned_rep_id: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    required
                  >
                    <option value="">-- Select Rep --</option>
                    {reps.map(rep => (
                      <option key={rep.id} value={rep.id}>
                        {rep.name}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Site Type
                  </label>
                  <select
                    value={formData.site_type}
                    onChange={(e) => setFormData({ ...formData, site_type: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  >
                    <option value="Quarry">Quarry</option>
                    <option value="Site">Site</option>
                    <option value="Dump">Dump</option>
                  </select>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Location & Map (Optional)
                  </label>
                  <LocationMapPicker 
                    latitude={formData.lat}
                    longitude={formData.lng}
                    locationName={formData.location}
                    isOptional={true}
                    onLocationSelect={(location) => {
                      setFormData({ 
                        ...formData, 
                        location: location.location,
                        lat: location.lat,
                        lng: location.lng
                      });
                    }}
                    onSkipLocation={() => {
                      setFormData({ 
                        ...formData, 
                        location: null,
                        lat: null,
                        lng: null
                      });
                    }}
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Address
                  </label>
                  <textarea
                    value={formData.address}
                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="Full address of the site"
                    rows="2"
                  />
                </div>
              </div>
            </div>

            {/* Section 2: Site In-Charge */}
            <div className="border-b pb-4">
              <h4 className="font-semibold text-gray-800 mb-3">Site In-Charge Details</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Site In-Charge Name
                  </label>
                  <input
                    type="text"
                    value={formData.site_incharge_name}
                    onChange={(e) => setFormData({ ...formData, site_incharge_name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., John Smith"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Site In-Charge Phone
                  </label>
                  <input
                    type="tel"
                    value={formData.site_incharge_phone}
                    onChange={(e) => setFormData({ ...formData, site_incharge_phone: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., +91 9876543210"
                  />
                </div>
              </div>
            </div>

            {/* Section 3: Material Needs */}
            <div className="border-b pb-4">
              <h4 className="font-semibold text-gray-800 mb-3">Material Requirements</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Material Type
                  </label>
                  <div className="flex gap-4">
                    <label className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={(formData.material_needs || []).includes('RMC')}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setFormData({ ...formData, material_needs: [...(formData.material_needs || []), 'RMC'] });
                          } else {
                            setFormData({ ...formData, material_needs: (formData.material_needs || []).filter(m => m !== 'RMC'), rmc_grade: '' });
                          }
                        }}
                        className="w-4 h-4 rounded"
                      />
                      <span className="text-sm">RMC</span>
                    </label>
                    <label className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        checked={(formData.material_needs || []).includes('Aggregates')}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setFormData({ ...formData, material_needs: [...(formData.material_needs || []), 'Aggregates'] });
                          } else {
                            setFormData({ ...formData, material_needs: (formData.material_needs || []).filter(m => m !== 'Aggregates'), aggregate_types: [] });
                          }
                        }}
                        className="w-4 h-4 rounded"
                      />
                      <span className="text-sm">Aggregates</span>
                    </label>
                  </div>
                </div>

                {(formData.material_needs || []).includes('RMC') && (
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      RMC Grade
                    </label>
                    <select
                      value={formData.rmc_grade}
                      onChange={(e) => setFormData({ ...formData, rmc_grade: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    >
                      <option value="">-- Select Grade --</option>
                      <option value="Grade 10">Grade 10</option>
                      <option value="Grade 15">Grade 15</option>
                      <option value="Grade 20">Grade 20</option>
                      <option value="Grade 25">Grade 25</option>
                      <option value="Grade 30">Grade 30</option>
                      <option value="Grade 35">Grade 35</option>
                      <option value="Grade 40">Grade 40</option>
                    </select>
                  </div>
                )}

                {(formData.material_needs || []).includes('Aggregates') && (
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Aggregate Types
                    </label>
                    <div className="space-y-2">
                      {['M sand', '40 mm', '20 mm', '12 mm', '6 mm', 'P sand'].map(type => (
                        <label key={type} className="flex items-center gap-2">
                          <input
                            type="checkbox"
                            checked={(formData.aggregate_types || []).includes(type)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setFormData({ ...formData, aggregate_types: [...(formData.aggregate_types || []), type] });
                              } else {
                                setFormData({ ...formData, aggregate_types: (formData.aggregate_types || []).filter(t => t !== type) });
                              }
                            }}
                            className="w-4 h-4 rounded"
                          />
                          <span className="text-sm">{type}</span>
                        </label>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Section 4: Volume & Pricing */}
            <div className="border-b pb-4">
              <h4 className="font-semibold text-gray-800 mb-3">Volume & Pricing</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Volume
                  </label>
                  <div className="flex gap-2">
                    <input
                      type="number"
                      step="0.01"
                      value={formData.volume}
                      onChange={(e) => setFormData({ ...formData, volume: e.target.value })}
                      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                      placeholder="Enter volume"
                    />
                    <select
                      value={formData.volume_unit}
                      onChange={(e) => setFormData({ ...formData, volume_unit: e.target.value })}
                      className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    >
                      <option value="m3">m³</option>
                      <option value="units">Units</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Required Date
                  </label>
                  <input
                    type="date"
                    value={formData.required_date}
                    onChange={(e) => setFormData({ ...formData, required_date: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Amount Concluded Per m³
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    value={formData.amount_concluded_per_unit}
                    onChange={(e) => setFormData({ ...formData, amount_concluded_per_unit: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., 5000"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Boom / Pump Amount
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    value={formData.boom_pump_amount}
                    onChange={(e) => setFormData({ ...formData, boom_pump_amount: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., 1000"
                  />
                </div>
              </div>
            </div>

            <div className="flex gap-3">
              <button
                type="submit"
                className="bg-green-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-green-700 transition"
              >
                {editingId ? 'Update Customer' : 'Save Customer'}
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

      {/* Customers Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-3 py-3 text-center text-xs font-semibold text-gray-600 uppercase w-10"></th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Customer Name</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Phone</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Assigned Rep</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Site Type</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Location</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Materials</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Volume</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Req. Date</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {customers.length === 0 ? (
                <tr>
                  <td colSpan="10" className="px-6 py-4 text-center text-gray-600">
                    No customers found. Add one to get started.
                  </td>
                </tr>
              ) : (
                customers.map(customer => (
                  <React.Fragment key={customer.id}>
                    <tr className="hover:bg-gray-50">
                      <td className="px-3 py-4 text-center">
                        <button
                          onClick={() => setExpandedCustomerId(expandedCustomerId === customer.id ? null : customer.id)}
                          className="text-gray-600 hover:text-gray-900 p-1 hover:bg-gray-200 rounded transition"
                          title="View/Edit Orders"
                        >
                          {expandedCustomerId === customer.id ? (
                            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
                            </svg>
                          ) : (
                            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                            </svg>
                          )}
                        </button>
                      </td>
                      <td className="px-6 py-4 font-semibold text-gray-900">
                        {customer.name || 'Unnamed'}
                      </td>
                      <td className="px-6 py-4 text-gray-700 text-sm">
                        {customer.phone_no || '-'}
                      </td>
                      <td className="px-6 py-4 text-gray-700 text-sm">
                        {reps.find(r => r.id === customer.assigned_rep_id)?.name || '-'}
                      </td>
                      <td className="px-6 py-4 text-gray-700 text-sm">
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                          customer.site_type === 'Quarry' ? 'bg-blue-100 text-blue-700' :
                          customer.site_type === 'Site' ? 'bg-purple-100 text-purple-700' :
                          'bg-amber-100 text-amber-700'
                        }`}>
                          {customer.site_type || 'Quarry'}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-gray-700 text-sm">
                        {customer.location || '-'}
                      </td>
                      <td className="px-6 py-4 text-gray-700 text-sm">
                        {(() => {
                          let materials = customer.material_needs;
                          if (typeof materials === 'string') {
                            try {
                              materials = JSON.parse(materials);
                            } catch (e) {
                              materials = [];
                            }
                          }
                          return materials && Array.isArray(materials) && materials.length > 0 
                            ? materials.join(', ')
                            : '-';
                        })()}
                      </td>
                      <td className="px-6 py-4 text-gray-700 text-sm">
                        {customer.volume ? `${customer.volume} ${customer.volume_unit}` : '-'}
                      </td>
                      <td className="px-6 py-4 text-gray-700 text-sm">
                        {customer.required_date ? new Date(customer.required_date).toLocaleDateString() : '-'}
                      </td>
                      <td className="px-6 py-4 flex gap-2">
                        <button
                          onClick={() => handleEdit(customer)}
                          className="text-blue-600 hover:text-blue-700 font-semibold text-sm hover:underline"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleDelete(customer.id)}
                          className="text-red-600 hover:text-red-700 font-semibold text-sm hover:underline"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                    {expandedCustomerId === customer.id && (
                      <tr className="bg-gray-50 border-t-2 border-gray-300">
                        <td colSpan="9" className="px-6 py-6">
                          <CustomerOrdersPanel 
                            customerId={customer.id}
                            customerName={customer.name}
                            reps={reps}
                            onClose={() => setExpandedCustomerId(null)}
                          />
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Info Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-900 font-medium mb-2">💡 About Customers</p>
        <ul className="text-xs text-blue-800 space-y-1 ml-4 list-disc">
          <li>Each customer location is assigned to one rep</li>
          <li>Customer details include contact, location, and material requirements</li>
          <li>Support both RMC (with grades) and Aggregates (multiple types)</li>
          <li>Track volume, pricing, and delivery requirements</li>
          <li>Site in-charge information for on-ground coordination</li>
          <li>Click the expand button (▶) to view and manage orders for each customer</li>
        </ul>
      </div>
    </div>
  );
};

export default CustomersManagement;
