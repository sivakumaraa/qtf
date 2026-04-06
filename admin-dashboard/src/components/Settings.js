import React, { useState, useEffect, useCallback } from 'react';
import { systemAPI } from '../api/client';
import { Save, AlertCircle, CheckCircle, Loader } from 'lucide-react';

const Settings = () => {
  const [settings, setSettings] = useState({
    gps_radius_limit: 50,
    gps_update_interval: 5000,
    gps_min_distance: 10,
    company_name: 'QuarryForce',
    company_logo: null,
    company_address: '',
    company_email: '',
    company_phone: '',
    currency_symbol: '₹',
    site_types: ['Quarry', 'Site', 'Dump'],
    logging_enabled: false,
    production_url: 'https://admin.quarryforce.pro',
    backend_port: 8000,
    mobile_api_url: 'http://10.0.2.2:8000/api',
    prod_db_host: 'localhost',
    prod_db_user: 'root',
    prod_db_pass: '',
    prod_db_name: 'quarryforce_db',
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState(settings);
  const [newSiteType, setNewSiteType] = useState('');

  const fetchSettings = useCallback(async () => {
    try {
      setLoading(true);
      const response = await systemAPI.getSettings();
      if (response.data.success) {
        // Handle both array and object responses
        let data = response.data.data;
        const defaultSettings = {
          gps_radius_limit: 50,
          gps_update_interval: 5000,
          gps_min_distance: 10,
          company_name: 'QuarryForce',
          company_logo: null,
          company_address: '',
          company_email: '',
          company_phone: '',
          currency_symbol: '₹',
          site_types: ['Quarry', 'Site', 'Dump'],
          logging_enabled: false,
          production_url: 'https://admin.quarryforce.pro',
          backend_port: 8000,
          mobile_api_url: 'http://10.0.2.2:8000/api',
          prod_db_host: 'localhost',
          prod_db_user: 'root',
          prod_db_pass: '',
          prod_db_name: 'quarryforce_db',
        };
        if (Array.isArray(data)) {
          data = data[0] || defaultSettings;
        }
        // Ensure site_types is an array
        if (data && typeof data.site_types === 'string') {
          try {
            data.site_types = JSON.parse(data.site_types);
          } catch (e) {
            data.site_types = ['Quarry', 'Site', 'Dump'];
          }
        }
        setSettings(data);
        setFormData(data);
        setError(null);
      } else {
        setError('Failed to load settings');
        setFormData({
          gps_radius_limit: 50,
          gps_update_interval: 5000,
          gps_min_distance: 10,
          company_name: 'QuarryForce',
          company_logo: null,
          company_address: '',
          company_email: '',
          company_phone: '',
          currency_symbol: '₹',
          site_types: ['Quarry', 'Site', 'Dump'],
          logging_enabled: false,
        });
      }
    } catch (err) {
      console.error('Settings fetch error:', err);
      setError(err.message || 'Failed to fetch settings');
      setFormData({
        gps_radius_limit: 50,
        gps_update_interval: 5000,
        gps_min_distance: 10,
        company_name: 'QuarryForce',
        company_logo: null,
        company_address: '',
        company_email: '',
        company_phone: '',
        currency_symbol: '₹',
        site_types: ['Quarry', 'Site', 'Dump'],
        logging_enabled: false,
      });
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchSettings();
  }, [fetchSettings]);

  const handleInputChange = (e) => {
    const { name, value, type, files } = e.target;
    
    if (type === 'file' && files && files[0]) {
      // Convert file to base64 for logo
      const file = files[0];
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({
          ...prev,
          [name]: reader.result
        }));
      };
      reader.readAsDataURL(file);
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: ['gps_radius_limit', 'gps_update_interval', 'gps_min_distance'].includes(name) 
          ? parseInt(value) || '' 
          : value
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setSaving(true);
      setError(null);
      setSuccess(null);

      // Prepare data for submission - ensure site_types is properly formatted
      const submitData = {
        ...formData,
        // Ensure site_types is an array (convert if string)
        site_types: Array.isArray(formData.site_types) 
          ? formData.site_types 
          : (typeof formData.site_types === 'string' 
            ? formData.site_types.split(',').map(s => s.trim())
            : ['Quarry', 'Site', 'Dump']),
        // Ensure numeric fields are numbers
        gps_radius_limit: parseInt(formData.gps_radius_limit) || 50,
        gps_update_interval: parseInt(formData.gps_update_interval) || 5000,
        gps_min_distance: parseInt(formData.gps_min_distance) || 10,
        backend_port: formData.backend_port ? parseInt(formData.backend_port) : 8000,
        production_url: formData.production_url || '',
        mobile_api_url: formData.mobile_api_url || 'http://10.0.2.2:8000/api',
        prod_db_host: formData.prod_db_host || 'localhost',
        prod_db_user: formData.prod_db_user || 'root',
        prod_db_pass: formData.prod_db_pass || '',
        prod_db_name: formData.prod_db_name || 'quarryforce_db',
      };

      console.log('Submitting settings:', {
        company_name: submitData.company_name,
        company_email: submitData.company_email,
        company_phone: submitData.company_phone,
        company_address: submitData.company_address ? 'set' : 'empty',
        company_logo: submitData.company_logo ? 'set (base64)' : 'empty',
        gps_radius_limit: submitData.gps_radius_limit,
        currency_symbol: submitData.currency_symbol,
        site_types: submitData.site_types,
        logging_enabled: submitData.logging_enabled
      });

      const response = await systemAPI.updateSettings(submitData);
      
      if (response.data.success) {
        // Handle both array and object responses
        let data = response.data.data;
        if (Array.isArray(data)) {
          data = data[0] || submitData;
        }
        // Ensure site_types is an array
        if (data && typeof data.site_types === 'string') {
          try {
            data.site_types = JSON.parse(data.site_types);
          } catch (e) {
            data.site_types = submitData.site_types;
          }
        }
        setSettings(data);
        setFormData(data);
        setSuccess('Settings updated successfully!');
        setTimeout(() => setSuccess(null), 5000);
      } else {
        setError(response.data.error || 'Failed to update settings');
      }
    } catch (err) {
      console.error('Settings update error:', err);
      setError(err.message || 'Failed to save settings');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading settings...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8">
      {/* Header */}
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">System Settings</h2>
        <p className="text-gray-600">Configure app-wide settings including GPS radius and currency</p>
      </div>

      {/* Error Message */}
      {error && (
        <div className="mb-6 flex items-center gap-3 p-4 bg-red-50 border border-red-200 rounded-lg">
          <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0" />
          <p className="text-red-800">{error}</p>
        </div>
      )}

      {/* Success Message */}
      {success && (
        <div className="mb-6 flex items-center gap-3 p-4 bg-green-50 border border-green-200 rounded-lg">
          <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0" />
          <p className="text-green-800">{success}</p>
        </div>
      )}

      {/* Info Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
        <h3 className="font-semibold text-blue-900 mb-2">System Settings Documentation</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li><strong>Company Name:</strong> Your organization's name used in reports and documents</li>
          <li><strong>Company Logo:</strong> Upload your company logo (displayed as thumbnail in current values)</li>
          <li><strong>Company Address:</strong> Full company address for invoices and documentation</li>
          <li><strong>Company Email:</strong> Primary contact email for your organization</li>
          <li><strong>Company Phone:</strong> Primary contact phone number</li>
          <li><strong>GPS Radius:</strong> Maximum distance (in meters) allowed for rep location check-ins</li>
          <li><strong>GPS Update Interval:</strong> How often (in milliseconds) mobile devices report their GPS location</li>
          <li><strong>GPS Minimum Distance:</strong> Minimum distance (in meters) device must move before sending another update</li>
          <li><strong>Currency Symbol:</strong> Symbol displayed in all monetary fields across the app</li>
          <li><strong>Site Types:</strong> Comma-separated list of quarry site types (e.g., "Granite, Marble, Limestone")</li>
          <li><strong>API Logging:</strong> Enable/disable detailed API request logging for debugging</li>
          <li><strong>Production Domain:</strong> The URL where the app will be deployed (e.g., admin.quarryforce.pro)</li>
          <li><strong>Backend Port:</strong> The port the Node.js server will use in production (default: 8000)</li>
        </ul>
      </div>

      {/* Settings Form */}
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Company Name */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Company Name
          </label>
          <input
            type="text"
            name="company_name"
            value={formData.company_name || ''}
            onChange={handleInputChange}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
            placeholder="Enter company name"
          />
          <p className="text-xs text-gray-500 mt-1">Displayed in app header and reports</p>
        </div>

        {/* Company Logo */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Company Logo
          </label>
          <div className="flex gap-4 items-start">
            <div className="flex-1">
              <input
                type="file"
                name="company_logo"
                onChange={handleInputChange}
                accept="image/*"
                className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
              />
              <p className="text-xs text-gray-500 mt-1">Supported formats: JPG, PNG, GIF (Max 2MB)</p>
            </div>
            {formData.company_logo && (
              <div className="w-20 h-20 bg-gray-100 rounded-lg border border-gray-300 flex items-center justify-center overflow-hidden flex-shrink-0">
                <img 
                  src={formData.company_logo} 
                  alt="Company Logo Preview" 
                  className="w-full h-full object-cover"
                />
              </div>
            )}
          </div>
        </div>

        {/* Company Address */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Company Address
          </label>
          <textarea
            name="company_address"
            value={formData.company_address || ''}
            onChange={handleInputChange}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
            placeholder="Enter complete company address"
            rows="3"
          />
          <p className="text-xs text-gray-500 mt-1">Displayed on invoices and official documents</p>
        </div>

        {/* Company Email */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Company Email
          </label>
          <input
            type="email"
            name="company_email"
            value={formData.company_email || ''}
            onChange={handleInputChange}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
            placeholder="contact@company.com"
          />
          <p className="text-xs text-gray-500 mt-1">Used for communication and support</p>
        </div>

        {/* Company Phone */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Company Phone
          </label>
          <input
            type="tel"
            name="company_phone"
            value={formData.company_phone || ''}
            onChange={handleInputChange}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
            placeholder="+91 98765 43210"
          />
          <p className="text-xs text-gray-500 mt-1">Primary contact phone number</p>
        </div>

        {/* GPS Radius Limit */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            GPS Radius Limit (meters)
          </label>
          <div className="flex gap-3 items-end">
            <div className="flex-1">
              <input
                type="number"
                name="gps_radius_limit"
                value={formData.gps_radius_limit || ''}
                onChange={handleInputChange}
                min="10"
                max="500"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
                placeholder="50"
              />
              <p className="text-xs text-gray-500 mt-1">Range: 10-500 meters. Default: 50m</p>
            </div>
            <div className="bg-blue-50 border border-blue-200 rounded-lg px-4 py-3 text-center">
              <p className="text-xs text-gray-600 mb-1">Current Setting</p>
              <p className="text-lg font-bold text-blue-600">{formData.gps_radius_limit}m</p>
            </div>
          </div>
          <p className="text-xs text-gray-500 mt-2">Reps must be within this distance to check-in at locations</p>
        </div>

        {/* GPS Update Interval */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            GPS Update Interval (milliseconds)
          </label>
          <div className="flex gap-3 items-end">
            <div className="flex-1 space-y-2">
              <input
                type="range"
                name="gps_update_interval"
                value={formData.gps_update_interval || 5000}
                onChange={handleInputChange}
                min="1000"
                max="60000"
                step="1000"
                className="w-full"
              />
              <input
                type="number"
                name="gps_update_interval"
                value={formData.gps_update_interval || ''}
                onChange={handleInputChange}
                min="1000"
                max="60000"
                step="1000"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
                placeholder="5000"
              />
              <p className="text-xs text-gray-500">Range: 1000ms (1s) to 60000ms (60s). Default: 5000ms (5s)</p>
            </div>
            <div className="bg-blue-50 border border-blue-200 rounded-lg px-4 py-3 text-center min-w-max">
              <p className="text-xs text-gray-600 mb-1">Current Setting</p>
              <p className="text-lg font-bold text-blue-600">{(formData.gps_update_interval / 1000).toFixed(1)}s</p>
            </div>
          </div>
          <p className="text-xs text-gray-500 mt-2">How often mobile devices update their GPS location</p>
        </div>

        {/* GPS Minimum Distance */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            GPS Minimum Distance (meters)
          </label>
          <div className="flex gap-3 items-end">
            <div className="flex-1 space-y-2">
              <input
                type="range"
                name="gps_min_distance"
                value={formData.gps_min_distance || 10}
                onChange={handleInputChange}
                min="0"
                max="1000"
                step="10"
                className="w-full"
              />
              <input
                type="number"
                name="gps_min_distance"
                value={formData.gps_min_distance || ''}
                onChange={handleInputChange}
                min="0"
                max="1000"
                step="10"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
                placeholder="10"
              />
              <p className="text-xs text-gray-500">Range: 0m to 1000m. Default: 10m</p>
            </div>
            <div className="bg-blue-50 border border-blue-200 rounded-lg px-4 py-3 text-center min-w-max">
              <p className="text-xs text-gray-600 mb-1">Current Setting</p>
              <p className="text-lg font-bold text-blue-600">{formData.gps_min_distance}m</p>
            </div>
          </div>
          <p className="text-xs text-gray-500 mt-2">Minimum distance device must move before sending another location update</p>
        </div>

        {/* Currency Symbol */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Currency Symbol
          </label>
          <div className="flex gap-3 items-end">
            <div className="flex-1">
              <input
                type="text"
                name="currency_symbol"
                value={formData.currency_symbol || ''}
                onChange={handleInputChange}
                maxLength="3"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
                placeholder="₹"
              />
              <p className="text-xs text-gray-500 mt-1">Single character or symbol</p>
            </div>
            <div className="bg-green-50 border border-green-200 rounded-lg px-6 py-3 text-center">
              <p className="text-xs text-gray-600 mb-1">Preview</p>
              <p className="text-lg font-bold text-green-600">{formData.currency_symbol}1,000</p>
            </div>
          </div>
          <p className="text-xs text-gray-500 mt-2">Used in all monetary displays across the dashboard and mobile app</p>
        </div>

        {/* Logging Control */}
        <div className="bg-gradient-to-r from-purple-50 to-blue-50 border border-purple-200 rounded-lg p-6">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <span className="text-lg">📊</span>
              </div>
              <div>
                <label className="block text-sm font-semibold text-gray-900">
                  Enable API Logging
                </label>
                <p className="text-xs text-gray-600 mt-1">Log all API requests, responses, and errors for debugging</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <input
                type="checkbox"
                name="logging_enabled"
                checked={formData.logging_enabled ? true : false}
                onChange={(e) => {
                  setFormData(prev => ({
                    ...prev,
                    logging_enabled: e.target.checked
                  }));
                }}
                className="w-6 h-6 rounded border-gray-300 text-blue-600 focus:ring-2 focus:ring-blue-500 cursor-pointer"
              />
              <span className={`text-sm font-semibold ${formData.logging_enabled ? 'text-green-600' : 'text-gray-500'}`}>
                {formData.logging_enabled ? '✓ Enabled' : 'Disabled'}
              </span>
            </div>
          </div>
          <div className="bg-white rounded px-3 py-2 text-xs text-gray-600">
            <p><strong>When enabled:</strong> All API calls, logins, check-ins, and submissions are logged to the server console</p>
            <p className="mt-2"><strong>When disabled:</strong> Only errors are logged (recommended for production)</p>
          </div>
        </div>

        {/* Production Configuration (CloudPanel) */}
        <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-6">
          <h3 className="text-sm font-semibold text-blue-900 mb-4 flex items-center gap-2">
            🚀 CloudPanel Production Deployment Settings
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Production Domain */}
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">
                Production Domain / URL
              </label>
              <input
                type="text"
                name="production_url"
                value={formData.production_url || ''}
                onChange={handleInputChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition bg-white"
                placeholder="https://admin.quarryforce.pro"
              />
              <p className="text-xs text-gray-500 mt-1">Baked into the production build for API communication</p>
            </div>

            {/* Backend Port */}
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">
                Backend API Port
              </label>
              <input
                type="number"
                name="backend_port"
                value={formData.backend_port || ''}
                onChange={handleInputChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition bg-white"
                placeholder="8000"
              />
              <p className="text-xs text-gray-500 mt-1">The port your Node.js server listens on (CloudPanel VPS)</p>
            </div>

            {/* Mobile API URL */}
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-gray-900 mb-2">
                Mobile App API URL (Production)
              </label>
              <input
                type="text"
                name="mobile_api_url"
                value={formData.mobile_api_url || ''}
                onChange={handleInputChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition bg-white"
                placeholder="https://api.quarryforce.pro/api"
              />
              <p className="text-xs text-gray-500 mt-1">Used by the Flutter build script to set the API endpoint</p>
            </div>
          </div>
        </div>

        {/* Production Database Configuration */}
        <div className="bg-gradient-to-r from-orange-50 to-red-50 border border-orange-200 rounded-lg p-6">
          <h3 className="text-sm font-semibold text-orange-900 mb-4 flex items-center gap-2">
            🗄️ Production Database Configuration
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* DB Host */}
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">
                Database Host
              </label>
              <input
                type="text"
                name="prod_db_host"
                value={formData.prod_db_host || ''}
                onChange={handleInputChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent outline-none transition bg-white"
                placeholder="127.0.0.1"
              />
            </div>

            {/* DB Name */}
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">
                Database Name
              </label>
              <input
                type="text"
                name="prod_db_name"
                value={formData.prod_db_name || ''}
                onChange={handleInputChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent outline-none transition bg-white"
                placeholder="quarryforce_db"
              />
            </div>

            {/* DB User */}
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">
                Database User
              </label>
              <input
                type="text"
                name="prod_db_user"
                value={formData.prod_db_user || ''}
                onChange={handleInputChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent outline-none transition bg-white"
                placeholder="cp_user"
              />
            </div>

            {/* DB Password */}
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-2">
                Database Password
              </label>
              <input
                type="password"
                name="prod_db_pass"
                value={formData.prod_db_pass || ''}
                onChange={handleInputChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent outline-none transition bg-white"
                placeholder="••••••••"
              />
            </div>
          </div>
          <p className="text-xs text-orange-700 mt-4 bg-orange-100 p-2 rounded">
            ⚠️ <strong>Important:</strong> These values will be used by the build script to generate your production <code>.env</code> file.
          </p>
        </div>

        {/* Site Types Configuration */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Site Types (for rep visits)
          </label>
          <div className="space-y-3">
            <div className="flex gap-2">
              <input
                type="text"
                value={newSiteType}
                onChange={(e) => setNewSiteType(e.target.value)}
                placeholder="Enter new site type..."
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition"
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    if (newSiteType.trim() && !(formData.site_types || []).includes(newSiteType.trim())) {
                      setFormData(prev => ({
                        ...prev,
                        site_types: [...(prev.site_types || []), newSiteType.trim()]
                      }));
                      setNewSiteType('');
                    }
                  }
                }}
              />
              <button
                type="button"
                onClick={() => {
                  if (newSiteType.trim() && !(formData.site_types || []).includes(newSiteType.trim())) {
                    setFormData(prev => ({
                      ...prev,
                      site_types: [...(prev.site_types || []), newSiteType.trim()]
                    }));
                    setNewSiteType('');
                  }
                }}
                className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition"
              >
                Add
              </button>
            </div>
            <div className="flex flex-wrap gap-2">
              {(formData.site_types || []).map((type, idx) => (
                <div key={idx} className="bg-blue-100 text-blue-900 px-3 py-1 rounded-full text-sm font-medium flex items-center gap-2">
                  {type}
                  <button
                    type="button"
                    onClick={() => {
                      setFormData(prev => ({
                        ...prev,
                        site_types: prev.site_types.filter((_, i) => i !== idx)
                      }));
                    }}
                    className="ml-1 hover:text-blue-700 font-bold"
                  >
                    ✕
                  </button>
                </div>
              ))}
            </div>
          </div>
          <p className="text-xs text-gray-500 mt-2">Reps can select these site types when recording visits</p>
        </div>

        {/* Info Box */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <p className="text-sm text-blue-900 font-medium mb-2">💡 About These Settings</p>
          <ul className="text-xs text-blue-800 space-y-1 ml-4 list-disc">
            <li>Changes apply instantly across all connected devices</li>
            <li>GPS radius affects rep check-in validation</li>
            <li>GPS update interval controls how frequently mobile devices report location</li>
            <li>GPS minimum distance reduces battery drain by batching updates</li>
            <li>Currency symbol displays in bonus/penalty calculations</li>
            <li>Site types appear in mobile app visit recording screen</li>
            <li>All settings are saved to the database</li>
          </ul>
        </div>

        {/* Submit Button */}
        <div className="flex gap-3 pt-4 border-t border-gray-200">
          <button
            type="submit"
            disabled={saving || loading}
            className="flex items-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold rounded-lg transition"
          >
            {saving ? (
              <>
                <Loader className="w-4 h-4 animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save className="w-4 h-4" />
                Save Settings
              </>
            )}
          </button>
          <button
            type="button"
            onClick={() => setFormData(settings)}
            disabled={saving || loading}
            className="px-6 py-3 border border-gray-300 hover:bg-gray-50 text-gray-700 font-semibold rounded-lg transition"
          >
            Reset
          </button>
        </div>
      </form>
    </div>
  );
};

export default Settings;
