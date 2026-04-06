// ================================================================
// File: admin-dashboard/src/pages/RepLocations.jsx
// Purpose: Live rep locations map and list for admin dashboard
// Date: March 14, 2026
// ================================================================

import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import axios from 'axios';
import { Users, MapPin, Clock, AlertCircle, RefreshCw } from 'lucide-react';

const RepLocations = () => {
  const [reps, setReps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastRefresh, setLastRefresh] = useState(new Date());
  const [autoRefresh, setAutoRefresh] = useState(true);

  // Fetch locations on mount and set up auto-refresh
  useEffect(() => {
    fetchLocations();

    // Poll every 10 seconds if auto-refresh is enabled
    const interval = autoRefresh
      ? setInterval(fetchLocations, 10000)
      : null;

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [autoRefresh]);

  const fetchLocations = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(
        '/api/reps/locations?action=reps_locations',
        {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        }
      );

      if (response.data.success) {
        setReps(response.data.data.locations || []);
        setError(null);
        setLastRefresh(new Date());
      }
    } catch (err) {
      console.error('Error fetching locations:', err);
      setError('Failed to fetch rep locations');
    } finally {
      setLoading(false);
    }
  };

  const createMarkerIcon = (status) => {
    const color = status === 'online' ? '#10b981' : '#9ca3af';
    const pulseColor = status === 'online' ? '40, 167, 69' : '156, 163, 175';

    return L.divIcon({
      html: `
        <div style="
          position: relative;
          display: flex;
          align-items: center;
          justify-content: center;
        ">
          ${status === 'online' ? `<div style="
            position: absolute;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: rgba(${pulseColor}, 0.3);
            animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
          "></div>` : ''}
          <div style="
            background-color: ${color};
            border-radius: 50%;
            width: 32px;
            height: 32px;
            border: 3px solid white;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
            position: relative;
            z-index: 2;
          ">
            <span style="font-size: 16px;">👤</span>
          </div>
        </div>
        <style>
          @keyframes pulse {
            0%, 100% { transform: scale(0.95); opacity: 1; }
            50% { opacity: 0.7; }
          }
        </style>
      `,
      iconSize: [40, 40],
      className: 'custom-marker',
    });
  };

  if (loading && reps.length === 0) {
    return (
      <div className="p-8 text-center">
        <div className="flex justify-center mb-4">
          <RefreshCw className="w-6 h-6 animate-spin text-blue-600" />
        </div>
        <p className="text-gray-600">Loading rep locations...</p>
      </div>
    );
  }

  const onlineReps = reps.filter((r) => r.status === 'online');
  const offlineReps = reps.filter((r) => r.status === 'offline');
  const centerLat = reps.length > 0 ? reps[0].lat : 20.5937;
  const centerLng = reps.length > 0 ? reps[0].lng : 78.9629;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <MapPin className="w-6 h-6 text-blue-600" />
          <h1 className="text-2xl font-bold">Rep Live Locations</h1>
        </div>
        <div className="flex gap-3">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={autoRefresh}
              onChange={(e) => setAutoRefresh(e.target.checked)}
              className="w-4 h-4 text-blue-600 rounded"
            />
            <span className="text-sm text-gray-700">Auto-refresh</span>
          </label>
          <button
            onClick={fetchLocations}
            disabled={loading}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-400 flex items-center gap-2"
          >
            <RefreshCw className="w-4 h-4" />
            Refresh
          </button>
        </div>
      </div>

      {/* Last Refresh Time */}
      <div className="text-sm text-gray-500">
        Last updated: {lastRefresh.toLocaleTimeString()}
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 flex items-center gap-3">
          <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0" />
          <p className="text-red-800">{error}</p>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Stats Cards */}
        <div className="bg-green-50 rounded-lg shadow p-4 border border-green-200">
          <p className="text-green-800 text-sm font-medium">Online</p>
          <p className="text-3xl font-bold text-green-600 mt-2">
            {onlineReps.length}
          </p>
          <p className="text-xs text-green-700 mt-1">Last 5 minutes</p>
        </div>

        <div className="bg-yellow-50 rounded-lg shadow p-4 border border-yellow-200">
          <p className="text-yellow-800 text-sm font-medium">Inactive</p>
          <p className="text-3xl font-bold text-yellow-600 mt-2">
            {offlineReps.length}
          </p>
          <p className="text-xs text-yellow-700 mt-1">Offline</p>
        </div>

        <div className="bg-blue-50 rounded-lg shadow p-4 border border-blue-200">
          <p className="text-blue-800 text-sm font-medium">Total Reps</p>
          <p className="text-3xl font-bold text-blue-600 mt-2">
            {reps.length}
          </p>
          <p className="text-xs text-blue-700 mt-1">Tracked</p>
        </div>

        <div className="bg-purple-50 rounded-lg shadow p-4 border border-purple-200">
          <p className="text-purple-800 text-sm font-medium">Active %</p>
          <p className="text-3xl font-bold text-purple-600 mt-2">
            {reps.length > 0
              ? Math.round((onlineReps.length / reps.length) * 100)
              : 0}
            %
          </p>
          <p className="text-xs text-purple-700 mt-1">Coverage</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* List of Reps */}
        <div className="lg:col-span-1 bg-white rounded-lg shadow overflow-hidden flex flex-col">
          <div className="p-4 border-b bg-gray-50 sticky top-0">
            <h2 className="font-semibold flex items-center gap-2">
              <Users className="w-4 h-4" />
              Active Reps ({reps.length})
            </h2>
          </div>

          <div className="overflow-y-auto flex-1" style={{ maxHeight: '600px' }}>
            {reps.length === 0 ? (
              <div className="p-4 text-gray-500 text-center">No reps found</div>
            ) : (
              <div className="space-y-2 p-4">
                {reps.map((rep) => (
                  <div
                    key={rep.rep_id}
                    className={`p-3 rounded-lg border-l-4 transition-colors ${
                      rep.status === 'online'
                        ? 'border-green-500 bg-green-50 hover:bg-green-100'
                        : 'border-gray-400 bg-gray-50 hover:bg-gray-100'
                    }`}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <p className="font-semibold text-gray-900">
                          {rep.name}
                        </p>
                        <p className="text-sm text-gray-600">{rep.email}</p>
                        <p className="text-xs text-gray-500 mt-1">
                          {rep.mobile_no}
                        </p>
                      </div>
                      <div className={`flex-shrink-0 w-2 h-2 rounded-full mt-1 ${
                        rep.status === 'online'
                          ? 'bg-green-600'
                          : 'bg-gray-400'
                      }`}></div>
                    </div>

                    <div className="flex items-center gap-1 text-xs text-gray-500 mt-2">
                      <Clock className="w-3 h-3" />
                      <span>
                        {rep.minutes_ago === 0
                          ? 'Just now'
                          : rep.minutes_ago === 1
                          ? '1 min ago'
                          : `${rep.minutes_ago} min ago`}
                      </span>
                    </div>

                    <div className="mt-2 p-2 bg-white rounded text-xs">
                      <p className="text-gray-600">
                        📍 {rep.lat.toFixed(4)}, {rep.lng.toFixed(4)}
                      </p>
                      <p className="text-gray-500 mt-1">
                        🎯 Accuracy: {Math.round(rep.accuracy)}m
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Map */}
        <div className="lg:col-span-2 bg-white rounded-lg shadow overflow-hidden">
          {reps.length > 0 ? (
            <MapContainer
              center={[centerLat, centerLng]}
              zoom={13}
              style={{ width: '100%', height: '600px' }}
              scrollWheelZoom={true}
            >
              <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution='&copy; OpenStreetMap contributors'
              />

              {reps.map((rep) => (
                <Marker
                  key={rep.rep_id}
                  position={[rep.lat, rep.lng]}
                  icon={createMarkerIcon(rep.status)}
                >
                  <Popup className="rep-popup">
                    <div className="text-sm w-48">
                      <p className="font-bold text-gray-900 mb-2">
                        {rep.name}
                      </p>

                      <div className="space-y-1 text-gray-700 mb-3">
                        <p>
                          <span className="font-semibold">Email:</span>{' '}
                          {rep.email}
                        </p>
                        <p>
                          <span className="font-semibold">Phone:</span>{' '}
                          {rep.mobile_no}
                        </p>
                        <p>
                          <span className="font-semibold">Role:</span>{' '}
                          {rep.role}
                        </p>
                      </div>

                      <hr className="my-2" />

                      <div className="space-y-1 text-xs text-gray-600">
                        <p>
                          <span className="font-semibold">Last Update:</span>
                        </p>
                        <p>{rep.timestamp}</p>
                        <p className="mt-2">
                          (
                          {rep.minutes_ago === 0
                            ? 'Just now'
                            : `${rep.minutes_ago} min ago`}
                          )
                        </p>
                      </div>

                      <div className="mt-3 p-2 bg-blue-50 rounded text-xs">
                        <p className="font-semibold text-blue-900">
                          Coordinates:
                        </p>
                        <p className="text-blue-700">
                          {rep.lat.toFixed(6)}, {rep.lng.toFixed(6)}
                        </p>
                        <p className="text-blue-600 mt-1">
                          Accuracy: {Math.round(rep.accuracy)}m
                        </p>
                      </div>

                      <div className="mt-3">
                        <span
                          className={`inline-block px-2 py-1 rounded-full text-xs font-semibold ${
                            rep.status === 'online'
                              ? 'bg-green-100 text-green-800'
                              : 'bg-gray-100 text-gray-800'
                          }`}
                        >
                          {rep.status === 'online'
                            ? '🟢 Online'
                            : '🔘 Offline'}
                        </span>
                      </div>
                    </div>
                  </Popup>
                </Marker>
              ))}
            </MapContainer>
          ) : (
            <div className="flex items-center justify-center h-full text-gray-500">
              No location data available
            </div>
          )}
        </div>
      </div>

      {/* Footer Info */}
      <div className="bg-gray-50 rounded-lg p-4 text-sm text-gray-600">
        <p>
          <span className="text-green-600 font-semibold">●</span> Online: Last
          update within 5 minutes
        </p>
        <p>
          <span className="text-gray-400 font-semibold">●</span> Offline: No
          update for more than 5 minutes
        </p>
      </div>
    </div>
  );
};

export default RepLocations;
