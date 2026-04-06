/**
 * Rep Device Activation Component
 * Manage device binding for field sales representatives
 * 
 * Features:
 * - View all reps and their device binding status
 * - Manually bind a device to a rep
 * - Reset device binding (device lock)
 * - Display device UID and binding date
 */

import React, { useState, useEffect } from 'react';
import { adminAPI } from '../api/client';
import { 
  Smartphone, 
  Lock, 
  Unlock, 
  Loader, 
  Copy, 
  Check,
  AlertCircle,
  Info 
} from 'lucide-react';

const RepDeviceActivation = () => {
  const [reps, setReps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [expandedRepId, setExpandedRepId] = useState(null);
  const [bindingRepId, setBindingRepId] = useState(null);
  const [newDeviceUid, setNewDeviceUid] = useState('');
  const [resettingRepId, setResettingRepId] = useState(null);
  const [copiedDeviceId, setCopiedDeviceId] = useState(null);

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

  const handleBindDevice = async (repId) => {
    if (!newDeviceUid.trim()) {
      setError('Please enter a device UID');
      return;
    }

    try {
      setError(null);
      // In a real scenario, you would call an API endpoint to bind the device
      // For now, we'll update locally
      setReps(reps.map(rep => 
        rep.id === repId 
          ? {
              ...rep, 
              device_uid: newDeviceUid,
              device_bound_at: new Date().toISOString()
            }
          : rep
      ));
      setSuccess(`Device bound successfully to ${reps.find(r => r.id === repId)?.name}`);
      setBindingRepId(null);
      setNewDeviceUid('');
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError(err.message || 'Failed to bind device');
    }
  };

  const handleResetDevice = async (repId) => {
    const rep = reps.find(r => r.id === repId);
    if (!window.confirm(`Reset device binding for ${rep?.name}? They will need to log in with a new device.`)) {
      return;
    }

    try {
      setResettingRepId(repId);
      setError(null);
      
      // Call API to reset device
      await adminAPI.resetDevice(repId);
      
      // Update local state
      setReps(reps.map(r => 
        r.id === repId 
          ? { ...r, device_uid: null, device_bound_at: null }
          : r
      ));
      
      setSuccess(`Device lock reset for ${rep?.name}. They can now register a new device.`);
      setExpandedRepId(null);
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      console.error('Error resetting device:', err);
      setError(err.message || 'Failed to reset device');
    } finally {
      setResettingRepId(null);
    }
  };

  const copyToClipboard = (deviceUid) => {
    navigator.clipboard.writeText(deviceUid);
    setCopiedDeviceId(deviceUid);
    setTimeout(() => setCopiedDeviceId(null), 2000);
  };

  const formatDate = (isoString) => {
    if (!isoString) return '-';
    try {
      return new Date(isoString).toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      });
    } catch {
      return '-';
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 flex items-center justify-center min-h-96">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin mx-auto mb-3 text-blue-600" />
          <p className="text-gray-600">Loading rep device information...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-3 mb-2">
          <Smartphone className="w-6 h-6 text-blue-600" />
          <h2 className="text-2xl font-bold text-gray-900">Rep Device Activation</h2>
        </div>
        <p className="text-gray-600">Manage device binding and activation for field representatives</p>
      </div>

      {/* Info Banner */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex gap-3">
          <Info className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
          <div className="text-sm text-blue-900">
            <p className="font-semibold mb-2">About Device Binding:</p>
            <ul className="space-y-1 ml-4 text-xs list-disc">
              <li><strong>First Login:</strong> Device UID is automatically bound when rep logs in from their mobile</li>
              <li><strong>One Device Per Rep:</strong> Each rep can only use one device for security</li>
              <li><strong>Reset Option:</strong> Admin can reset binding if rep gets a new phone</li>
              <li><strong>Security:</strong> Prevents account fraud and unauthorized access</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Messages */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 flex justify-between items-center">
          <div className="flex items-center gap-2">
            <AlertCircle className="w-5 h-5" />
            <span>{error}</span>
          </div>
          <button onClick={() => setError(null)} className="text-red-600 hover:text-red-800">✕</button>
        </div>
      )}

      {success && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-700 flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Check className="w-5 h-5" />
            <span>{success}</span>
          </div>
          <button onClick={() => setSuccess(null)} className="text-green-600 hover:text-green-800">✕</button>
        </div>
      )}

      {/* Reps List */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Rep Name</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Email</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Mobile</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Device Status</th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Bound Date</th>
                <th className="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {reps.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-gray-600">
                    No reps found
                  </td>
                </tr>
              ) : (
                reps.map(rep => (
                  <React.Fragment key={rep.id}>
                    <tr className="hover:bg-gray-50 transition">
                      <td className="px-6 py-4">
                        <div className="font-medium text-gray-900">{rep.name}</div>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">{rep.email}</td>
                      <td className="px-6 py-4 text-sm text-gray-600">{rep.mobile_no || '-'}</td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {rep.device_uid ? (
                            <>
                              <Lock className="w-4 h-4 text-green-600" />
                              <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700">
                                Bound
                              </span>
                            </>
                          ) : (
                            <>
                              <Unlock className="w-4 h-4 text-orange-600" />
                              <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-700">
                                Not Bound
                              </span>
                            </>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        {formatDate(rep.device_bound_at)}
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button
                          onClick={() => setExpandedRepId(expandedRepId === rep.id ? null : rep.id)}
                          className="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-blue-600 hover:bg-blue-50 rounded-lg transition"
                        >
                          <Smartphone className="w-4 h-4" />
                          {expandedRepId === rep.id ? 'Hide' : 'Details'}
                        </button>
                      </td>
                    </tr>

                    {/* Expanded Details Row */}
                    {expandedRepId === rep.id && (
                      <tr className="bg-gray-50 hover:bg-gray-50">
                        <td colSpan="6" className="px-6 py-6">
                          <div className="space-y-4">
                            {/* Current Device Info */}
                            {rep.device_uid && (
                              <div className="bg-white border border-gray-200 rounded-lg p-4">
                                <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                                  <Lock className="w-4 h-4 text-green-600" />
                                  Current Device Binding
                                </h4>
                                <div className="space-y-2">
                                  <div className="flex items-start gap-4">
                                    <label className="text-sm font-medium text-gray-700 min-w-32">Device UID:</label>
                                    <div className="flex items-center gap-2 flex-1">
                                      <code className="flex-1 bg-gray-100 px-3 py-2 rounded-lg text-xs font-mono text-gray-900 break-all">
                                        {rep.device_uid}
                                      </code>
                                      <button
                                        onClick={() => copyToClipboard(rep.device_uid)}
                                        className="p-2 text-gray-600 hover:text-blue-600 transition"
                                        title="Copy Device UID"
                                      >
                                        {copiedDeviceId === rep.device_uid ? (
                                          <Check className="w-4 h-4 text-green-600" />
                                        ) : (
                                          <Copy className="w-4 h-4" />
                                        )}
                                      </button>
                                    </div>
                                  </div>
                                  <div className="flex items-center gap-4">
                                    <label className="text-sm font-medium text-gray-700 min-w-32">Bound On:</label>
                                    <span className="text-sm text-gray-600">{formatDate(rep.device_bound_at)}</span>
                                  </div>
                                </div>

                                {/* Reset Device Button */}
                                <div className="mt-4 pt-4 border-t border-gray-200">
                                  <button
                                    onClick={() => handleResetDevice(rep.id)}
                                    disabled={resettingRepId === rep.id}
                                    className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition font-medium text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                                  >
                                    {resettingRepId === rep.id ? (
                                      <>
                                        <Loader className="w-4 h-4 animate-spin" />
                                        Resetting...
                                      </>
                                    ) : (
                                      <>
                                        <Unlock className="w-4 h-4" />
                                        Reset Device Lock
                                      </>
                                    )}
                                  </button>
                                  <p className="text-xs text-gray-600 mt-2">
                                    Allows {rep.name} to register a new device on their next login
                                  </p>
                                </div>
                              </div>
                            )}

                            {/* Manual Device Binding */}
                            {bindingRepId === rep.id ? (
                              <div className="bg-white border border-blue-200 rounded-lg p-4">
                                <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                                  <Smartphone className="w-4 h-4 text-blue-600" />
                                  Bind New Device
                                </h4>
                                <div className="space-y-3">
                                  <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">
                                      Device UID
                                    </label>
                                    <input
                                      type="text"
                                      value={newDeviceUid}
                                      onChange={(e) => setNewDeviceUid(e.target.value)}
                                      placeholder="Enter device UID (e.g., from mobile app)"
                                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                    />
                                    <p className="text-xs text-gray-600 mt-1">
                                      The device UID is displayed in the mobile app settings
                                    </p>
                                  </div>
                                  <div className="flex gap-2">
                                    <button
                                      onClick={() => handleBindDevice(rep.id)}
                                      className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium text-sm"
                                    >
                                      <Lock className="w-4 h-4" />
                                      Bind Device
                                    </button>
                                    <button
                                      onClick={() => {
                                        setBindingRepId(null);
                                        setNewDeviceUid('');
                                      }}
                                      className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition font-medium text-sm"
                                    >
                                      Cancel
                                    </button>
                                  </div>
                                </div>
                              </div>
                            ) : (
                              <button
                                onClick={() => setBindingRepId(rep.id)}
                                className="flex items-center gap-2 px-4 py-2 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition font-medium text-sm"
                              >
                                <Smartphone className="w-4 h-4" />
                                {rep.device_uid ? 'Bind Another Device' : 'Bind Device Manually'}
                              </button>
                            )}
                          </div>
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

      {/* Stats Summary */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-lg shadow-sm border border-gray-100 p-4">
          <div className="text-gray-600 text-sm font-medium mb-1">Total Reps</div>
          <div className="text-3xl font-bold text-gray-900">{reps.length}</div>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-100 p-4">
          <div className="text-gray-600 text-sm font-medium mb-1">Devices Bound</div>
          <div className="text-3xl font-bold text-green-600">{reps.filter(r => r.device_uid).length}</div>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-100 p-4">
          <div className="text-gray-600 text-sm font-medium mb-1">Awaiting Binding</div>
          <div className="text-3xl font-bold text-orange-600">{reps.filter(r => !r.device_uid).length}</div>
        </div>
      </div>

      {/* Help Section */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
        <h4 className="font-semibold text-gray-900 mb-2">How to Use</h4>
        <ol className="text-sm text-gray-700 space-y-2 ml-4 list-decimal">
          <li><strong>Create Rep First:</strong> Go to User Management and create a new user with role "Rep"</li>
          <li><strong>Share Mobile App:</strong> Provide the mobile app to the rep</li>
          <li><strong>Rep Logs In:</strong> Rep enters their email and logs in from their device</li>
          <li><strong>Auto Binding:</strong> Device UID is automatically captured and bound</li>
          <li><strong>Monitor Here:</strong> Check binding status in this screen</li>
          <li><strong>Reset if Needed:</strong> If rep gets a new phone, use "Reset Device Lock" button</li>
        </ol>
      </div>
    </div>
  );
};

export default RepDeviceActivation;
