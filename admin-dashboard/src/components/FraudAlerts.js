import React from 'react';
import { CURRENCY } from '../config/constants';

const FraudAlerts = () => {
  const alerts = [
    {
      id: 1,
      name: 'Rajesh M',
      status: 'SUSPICIOUS',
      score: 75,
      alerts: [
        { type: 'location', message: 'Stationary at same location for 2+ hours' },
        { type: 'data', message: 'Unusual leads-to-distance ratio (12 leads in 12km)' },
        { type: 'pattern', message: 'Visit pattern matches fake GPS app signature' }
      ]
    },
    {
      id: 2,
      name: 'Kumar Raj',
      status: 'FRAUD_DETECTED',
      score: 95,
      alerts: [
        { type: 'gps', message: 'GPS spoofing detected - Mock location app active' },
        { type: 'movement', message: 'Impossible travel speed: 150km/h between visits' },
        { type: 'photo', message: 'Same photo uploaded for multiple visits' },
        { type: 'data', message: '20 visits in 8.5km - Physically impossible' }
      ]
    }
  ];

  const protocols = [
    { name: 'GPS Spoofing Detection', status: 'Active' },
    { name: 'Mock Location Blocking', status: 'Active' },
    { name: 'Photo Verification (AI)', status: 'Active' },
    { name: 'Distance Validation', status: 'Active' },
    { name: 'Speed Analysis', status: 'Active' },
    { name: 'Pattern Recognition', status: 'Active' },
    { name: 'Time Stamping', status: 'Active' },
    { name: 'Duplicate Photo Detection', status: 'Active' }
  ];

  return (
    <div className="space-y-6">
      {/* Active Alerts */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">🚨 Active Fraud Alerts</h2>
        <div className="space-y-4">
          {alerts.map(alert => (
            <div
              key={alert.id}
              className={`rounded-lg shadow-md p-6 border-2 ${
                alert.status === 'FRAUD_DETECTED'
                  ? 'border-red-500 bg-red-50'
                  : 'border-yellow-500 bg-yellow-50'
              }`}
            >
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-xl font-bold text-gray-900">{alert.name}</h3>
                  <p className="text-sm text-gray-600 mt-1">Rep ID: {alert.id}</p>
                </div>
                <div className="text-right">
                  <div
                    className={`px-3 py-1 rounded-full text-sm font-bold text-white ${
                      alert.status === 'FRAUD_DETECTED'
                        ? 'bg-red-600'
                        : 'bg-yellow-600'
                    }`}
                  >
                    {alert.status}
                  </div>
                  <p className={`text-lg font-bold mt-2 ${
                    alert.status === 'FRAUD_DETECTED'
                      ? 'text-red-600'
                      : 'text-yellow-600'
                  }`}>
                    Score: {alert.score}/100
                  </p>
                </div>
              </div>

              <div className="space-y-2">
                <p className="font-semibold text-gray-900 mb-3">Alert Details:</p>
                {alert.alerts.map((a, idx) => (
                  <div key={idx} className="bg-white bg-opacity-60 rounded-lg p-3 border-l-4 border-red-500">
                    <p className="text-sm font-semibold text-gray-900">{a.message}</p>
                  </div>
                ))}
              </div>

              <div className="flex space-x-2 mt-4">
                <button className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg font-semibold hover:bg-blue-700">
                  Review
                </button>
                {alert.status === 'FRAUD_DETECTED' && (
                  <button className="flex-1 bg-red-600 text-white px-4 py-2 rounded-lg font-semibold hover:bg-red-700">
                    Block Account
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Anti-Cheating Protocols */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h3 className="text-xl font-bold text-gray-900 mb-4">✅ Anti-Cheating Protocols</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {protocols.map((protocol, idx) => (
            <div key={idx} className="flex items-center justify-between p-4 bg-green-50 border-2 border-green-200 rounded-lg">
              <div className="flex items-center">
                <span className="w-3 h-3 bg-green-500 rounded-full animate-pulse mr-3"></span>
                <span className="font-semibold text-gray-900">{protocol.name}</span>
              </div>
              <span className="px-3 py-1 bg-green-600 text-white rounded-full text-xs font-bold">
                {protocol.status}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Fraud Prevention Stats */}
      <div className="bg-gradient-to-br from-purple-600 to-pink-600 rounded-lg shadow-lg p-6 text-white">
        <h3 className="text-xl font-bold mb-4">📊 Fraud Prevention Analytics</h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div>
            <p className="text-purple-100 text-sm mb-2">Fraud Attempts Blocked</p>
            <p className="text-4xl font-bold">12</p>
            <p className="text-purple-100 text-xs mt-2">This month</p>
          </div>
          <div>
            <p className="text-purple-100 text-sm mb-2">GPS Spoofing Detected</p>
            <p className="text-4xl font-bold">8</p>
            <p className="text-purple-100 text-xs mt-2">All time</p>
          </div>
          <div>
            <p className="text-purple-100 text-sm mb-2">Fake Photos Caught</p>
            <p className="text-4xl font-bold">5</p>
            <p className="text-purple-100 text-xs mt-2">This month</p>
          </div>
          <div>
            <p className="text-purple-100 text-sm mb-2">Money Saved</p>
            <p className="text-4xl font-bold">{CURRENCY.SYMBOL}2.4L</p>
            <p className="text-purple-100 text-xs mt-2">Prevented losses</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FraudAlerts;
