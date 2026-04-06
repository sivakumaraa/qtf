/**
 * Privilege Editor Component
 * Allows detailed customization of privileges for individual users
 */

import React, { useState } from 'react';
import { X, RotateCcw, Save } from 'lucide-react';
import { ROLE_PRIVILEGES, PRIVILEGES } from '../config/roles';

const PrivilegeEditor = ({ user, onClose, onSave }) => {
  const [selectedPrivileges, setSelectedPrivileges] = useState(
    user.custom_privileges || ROLE_PRIVILEGES[user.role] || []
  );
  const [hasCustomPrivileges] = useState(!!user.custom_privileges);

  const privilegeCategories = {
    'Overview': [PRIVILEGES.VIEW_OVERVIEW, PRIVILEGES.VIEW_DASHBOARD_STATS],
    'User Management': [PRIVILEGES.VIEW_USERS, PRIVILEGES.CREATE_USER, PRIVILEGES.EDIT_USER, PRIVILEGES.DELETE_USER, PRIVILEGES.MANAGE_ROLES],
    'Rep Management': [PRIVILEGES.VIEW_REPS, PRIVILEGES.EDIT_REP, PRIVILEGES.DELETE_REP],
    'Targets': [PRIVILEGES.VIEW_TARGETS, PRIVILEGES.CREATE_TARGETS, PRIVILEGES.EDIT_TARGETS, PRIVILEGES.APPROVE_TARGETS],
    'Sales & Progress': [PRIVILEGES.VIEW_PROGRESS, PRIVILEGES.RECORD_SALES, PRIVILEGES.EDIT_SALES, PRIVILEGES.VIEW_SALES_HISTORY],
    'Customers': [PRIVILEGES.VIEW_CUSTOMERS, PRIVILEGES.CREATE_CUSTOMER, PRIVILEGES.EDIT_CUSTOMER, PRIVILEGES.DELETE_CUSTOMER],
    'Orders': [PRIVILEGES.VIEW_ORDERS, PRIVILEGES.CREATE_ORDER, PRIVILEGES.EDIT_ORDER, PRIVILEGES.DELETE_ORDER],
    'Alerts': [PRIVILEGES.VIEW_ALERTS, PRIVILEGES.MANAGE_ALERTS],
    'Logs & Analytics': [PRIVILEGES.VIEW_LOGS, PRIVILEGES.VIEW_ANALYTICS, PRIVILEGES.EXPORT_DATA],
    'Settings': [PRIVILEGES.VIEW_SETTINGS, PRIVILEGES.EDIT_SETTINGS, PRIVILEGES.MANAGE_SYSTEM],
  };

  const togglePrivilege = (privilege) => {
    setSelectedPrivileges(prev =>
      prev.includes(privilege)
        ? prev.filter(p => p !== privilege)
        : [...prev, privilege]
    );
  };

  const toggleCategory = (privileges) => {
    const allSelected = privileges.every(p => selectedPrivileges.includes(p));
    if (allSelected) {
      setSelectedPrivileges(prev => prev.filter(p => !privileges.includes(p)));
    } else {
      setSelectedPrivileges(prev => [...new Set([...prev, ...privileges])]);
    }
  };

  const resetToRoleDefaults = () => {
    setSelectedPrivileges(ROLE_PRIVILEGES[user.role] || []);
  };

  const handleSave = () => {
    onSave({
      ...user,
      custom_privileges: selectedPrivileges,
    });
  };

  const formatPrivilegeName = (privilege) => {
    return privilege
      .replace(/_/g, ' ')
      .split(' ')
      .map(w => w.charAt(0).toUpperCase() + w.slice(1))
      .join(' ');
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4 overflow-y-auto">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl my-8">
        {/* Header */}
        <div className="flex justify-between items-center p-6 border-b border-gray-200">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">
              Customize Privileges
            </h2>
            <p className="text-gray-600 text-sm mt-1">
              {user.name} ({user.role.charAt(0).toUpperCase() + user.role.slice(1)})
            </p>
            {hasCustomPrivileges && (
              <p className="text-blue-600 text-xs mt-1">
                ℹ️ This user has custom privileges (overriding role defaults)
              </p>
            )}
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 max-h-[60vh] overflow-y-auto">
          <div className="space-y-6">
            {Object.entries(privilegeCategories).map(([category, privileges]) => {
              const allSelected = privileges.every(p => selectedPrivileges.includes(p));

              return (
                <div key={category} className="border border-gray-200 rounded-lg p-4">
                  {/* Category Header */}
                  <div className="flex items-center mb-4">
                    <input
                      type="checkbox"
                      checked={allSelected}
                      onChange={() => toggleCategory(privileges)}
                      className="w-5 h-5 rounded cursor-pointer accent-blue-600"
                      id={`cat-${category}`}
                    />
                    <label
                      htmlFor={`cat-${category}`}
                      className="ml-3 font-semibold text-gray-900 cursor-pointer flex-1"
                    >
                      {category}
                    </label>
                    <span className="text-sm text-gray-500">
                      {privileges.filter(p => selectedPrivileges.includes(p)).length} of{' '}
                      {privileges.length}
                    </span>
                  </div>

                  {/* Category Privileges */}
                  <div className="ml-8 space-y-3">
                    {privileges.map(privilege => (
                      <div key={privilege} className="flex items-center">
                        <input
                          type="checkbox"
                          checked={selectedPrivileges.includes(privilege)}
                          onChange={() => togglePrivilege(privilege)}
                          className="w-4 h-4 rounded cursor-pointer accent-blue-600"
                          id={`priv-${privilege}`}
                        />
                        <label
                          htmlFor={`priv-${privilege}`}
                          className="ml-3 text-gray-700 cursor-pointer text-sm"
                        >
                          {formatPrivilegeName(privilege)}
                        </label>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Footer */}
        <div className="flex space-x-3 p-6 border-t border-gray-200 bg-gray-50">
          <button
            onClick={resetToRoleDefaults}
            className="flex items-center px-4 py-2 text-gray-700 bg-gray-200 hover:bg-gray-300 rounded-lg transition font-medium"
          >
            <RotateCcw className="w-4 h-4 mr-2" />
            Reset to Role Defaults
          </button>
          <div className="flex-1" />
          <button
            onClick={onClose}
            className="px-6 py-2 text-gray-700 bg-gray-200 hover:bg-gray-300 rounded-lg transition font-medium"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            className="flex items-center px-6 py-2 bg-blue-600 text-white hover:bg-blue-700 rounded-lg transition font-medium"
          >
            <Save className="w-4 h-4 mr-2" />
            Save Privileges
          </button>
        </div>
      </div>
    </div>
  );
};

export default PrivilegeEditor;
