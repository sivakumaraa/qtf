/**
 * Protected Tab/Screen Component
 * Only renders content if user has required privileges
 */

import React from 'react';
import { useAuth } from '../context/AuthContext';
import { AlertCircle } from 'lucide-react';

/**
 * ProtectedTab component
 * Wraps a screen and checks for required privileges
 */
export const ProtectedTab = ({ 
  requiredPrivileges = [], 
  requireAll = true,
  children,
  fallback = null 
}) => {
  const { hasAllPrivileges, hasAnyPrivilege } = useAuth();

  const hasAccess = requireAll
    ? hasAllPrivileges(requiredPrivileges)
    : hasAnyPrivilege(requiredPrivileges);

  if (!hasAccess) {
    return fallback || <AccessDenied />;
  }

  return <>{children}</>;
};

/**
 * Default access denied message
 */
const AccessDenied = () => (
  <div className="flex flex-col items-center justify-center h-64 bg-white rounded-lg shadow-sm border border-gray-200">
    <AlertCircle className="w-16 h-16 text-red-400 mb-4" />
    <h3 className="text-xl font-bold text-gray-900 mb-2">Access Denied</h3>
    <p className="text-gray-600 text-center max-w-md">
      You don't have the required permissions to access this screen.
      Please contact your administrator for assistance.
    </p>
  </div>
);

/**
 * PrivilegeGate component
 * Conditionally renders content based on a specific privilege
 */
export const PrivilegeGate = ({ privilege, children, fallback = null }) => {
  const { hasPrivilege } = useAuth();

  if (!hasPrivilege(privilege)) {
    return fallback;
  }

  return <>{children}</>;
};

/**
 * Hook to check if a tab should be visible
 */
export const useTabAccess = (requiredPrivileges) => {
  const { hasAllPrivileges } = useAuth();
  return hasAllPrivileges(requiredPrivileges || []);
};
