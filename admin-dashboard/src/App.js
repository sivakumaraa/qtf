import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { GoogleOAuthProvider } from '@react-oauth/google';
import { AuthProvider, useAuth } from './context/AuthContext';
import Dashboard from './components/Dashboard';
import LoginPage from './components/LoginPage';
import OverviewTab from './components/OverviewTab';
import UserManagement from './components/UserManagement';
import RoleManagement from './components/RoleManagement';
import RepDetails from './components/RepDetails';
import RepDeviceActivation from './components/RepDeviceActivation';
import TargetManagement from './components/TargetManagement';
import SalesRecording from './components/SalesRecording';
import FraudAlerts from './components/FraudAlerts';
import Analytics from './components/Analytics';
import CustomersManagement from './components/CustomersManagement';
import OrdersManagement from './components/OrdersManagement';
import SalaryConfiguration from './components/SalaryConfiguration';
import SalaryProcessing from './components/SalaryProcessing';
import SalarySlips from './components/SalarySlips';
import PaymentTracking from './components/PaymentTracking';
import Settings from './components/Settings';
import './App.css';

// Protected Route Wrapper
const ProtectedRoute = ({ children }) => {
  const { user, loading } = useAuth();
  
  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }
  
  if (!user) {
    return <Navigate to="/login" replace />;
  }
  
  return children;
};

function App() {
  const GOOGLE_CLIENT_ID = process.env.REACT_APP_GOOGLE_CLIENT_ID || 'YOUR_GOOGLE_CLIENT_ID_HERE';

  return (
    <GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
      <AuthProvider>
        <BrowserRouter basename="/qft">
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            
            <Route path="/" element={
              <ProtectedRoute>
                <Dashboard />
              </ProtectedRoute>
            }>
              <Route index element={<Navigate to="/overview" replace />} />
              <Route path="overview" element={<OverviewTab />} />
              <Route path="users" element={<UserManagement />} />
              <Route path="roles" element={<RoleManagement />} />
              <Route path="reps" element={<RepDetails />} />
              <Route path="device-activation" element={<RepDeviceActivation />} />
              <Route path="targets" element={<TargetManagement />} />
              <Route path="sales" element={<SalesRecording />} />
              <Route path="alerts" element={<FraudAlerts />} />
              <Route path="logs" element={<Analytics />} />
              <Route path="customers" element={<CustomersManagement />} />
              <Route path="orders" element={<OrdersManagement />} />
              <Route path="salary-config" element={<SalaryConfiguration />} />
              <Route path="salary-processing" element={<SalaryProcessing />} />
              <Route path="salary-slips" element={<SalarySlips />} />
              <Route path="payment-tracking" element={<PaymentTracking />} />
              <Route path="settings" element={<Settings />} />
            </Route>

            {/* Fallback */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </GoogleOAuthProvider>
  );
}

export default App;

