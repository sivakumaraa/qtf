/**
 * Role Management Component
 * Manage roles, create new roles, and configure their privileges
 */

import React, { useState } from 'react';
import { Plus, Edit2, Trash2, Shield, Eye, EyeOff } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { ROLES, ROLE_PRIVILEGES, PRIVILEGES } from '../config/roles';
import PrivilegeEditor from './PrivilegeEditor';

const RoleManagement = () => {
  const { hasPrivilege } = useAuth();
  const [roles, setRoles] = useState(() => {
    // Initialize with existing roles from config
    return Object.entries(ROLE_PRIVILEGES).map(([roleKey, privs]) => ({
      id: roleKey,
      name: roleKey.charAt(0).toUpperCase() + roleKey.slice(1),
      displayName: getRoleDisplayName(roleKey),
      count: privs.length,
      privileges: privs,
      isSystem: Object.values(ROLES).includes(roleKey), // System roles can't be deleted
      description: getRoleDescription(roleKey),
    }));
  });

  const [showModal, setShowModal] = useState(false);
  const [editingRole, setEditingRole] = useState(null);
  const [formData, setFormData] = useState({ name: '', description: '' });
  const [showPrivilegeEditor, setShowPrivilegeEditor] = useState(null);
  const [showDetails, setShowDetails] = useState(null);

  const canManageRoles = hasPrivilege(PRIVILEGES.MANAGE_ROLES);

  function getRoleDisplayName(role) {
    const names = {
      [ROLES.ADMIN]: '👑 Admin',
      [ROLES.MANAGER]: '📊 Manager',
      [ROLES.SUPERVISOR]: '👤 Supervisor',
      [ROLES.REP]: '🚗 Sales Rep',
    };
    return names[role] || role.charAt(0).toUpperCase() + role.slice(1);
  }

  function getRoleDescription(role) {
    const descriptions = {
      [ROLES.ADMIN]: 'Full system access with all privileges',
      [ROLES.MANAGER]: 'Manage users, reps, approve targets and sales',
      [ROLES.SUPERVISOR]: 'Limited management, customer and sales operations',
      [ROLES.REP]: 'Field representatives with basic access',
    };
    return descriptions[role] || 'Custom role';
  }

  const handleOpenModal = (role = null) => {
    if (role) {
      setEditingRole(role);
      setFormData({
        name: role.displayName,
        description: role.description,
      });
    } else {
      setEditingRole(null);
      setFormData({ name: '', description: '' });
    }
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setEditingRole(null);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.name.trim()) return;

    if (editingRole) {
      // Update role
      setRoles(roles.map(r =>
        r.id === editingRole.id
          ? {
            ...r,
            displayName: formData.name,
            description: formData.description,
          }
          : r
      ));
    } else {
      // Create new role
      const newRoleId = formData.name.toLowerCase().replace(/\s+/g, '_');
      const newRole = {
        id: newRoleId,
        name: formData.name,
        displayName: formData.name,
        count: 0,
        privileges: [],
        isSystem: false,
        description: formData.description,
      };
      setRoles([...roles, newRole]);
    }

    handleCloseModal();
  };

  const handleDelete = (role) => {
    if (role.isSystem) {
      alert('System roles cannot be deleted');
      return;
    }
    if (window.confirm(`Delete role "${role.displayName}"?`)) {
      setRoles(roles.filter(r => r.id !== role.id));
    }
  };

  const handleSavePrivileges = (updatedPrivileges) => {
    setRoles(roles.map(r =>
      r.id === showPrivilegeEditor.id
        ? { ...r, privileges: updatedPrivileges, count: updatedPrivileges.length }
        : r
    ));
    setShowPrivilegeEditor(null);
  };

  if (!canManageRoles) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-red-700 text-center">
        <Shield className="w-12 h-12 mx-auto mb-4 opacity-50" />
        <p className="font-semibold">Access Denied</p>
        <p className="text-sm mt-1">You don't have permission to manage roles.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Role Management</h1>
          <p className="text-gray-600 mt-2">Create and configure roles with custom privileges</p>
        </div>
        <button
          onClick={() => handleOpenModal()}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-blue-700 transition"
        >
          <Plus className="w-5 h-5 mr-2" />
          Create Role
        </button>
      </div>

      {/* Info Panel */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex">
          <Shield className="w-5 h-5 text-blue-600 mr-3 flex-shrink-0 mt-0.5" />
          <div className="text-sm text-blue-900">
            <p className="font-semibold mb-2">How Role Management Works:</p>
            <ul className="space-y-1 ml-4 text-xs list-disc">
              <li>System roles (Admin, Manager, Supervisor, Rep) have fixed privileges but can be renamed</li>
              <li>Custom roles can be created with any combination of privileges</li>
              <li>Edit a role's privileges by clicking the "Configure" button</li>
              <li>Assign users to roles in User Management screen</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Roles Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {roles.map(role => (
          <div key={role.id} className="bg-white rounded-lg shadow-md border border-gray-200 hover:shadow-lg transition">
            {/* Role Header */}
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h3 className="text-lg font-bold text-gray-900">{role.displayName}</h3>
                  {role.isSystem && (
                    <span className="text-xs text-gray-500 font-semibold uppercase tracking-wider">System Role</span>
                  )}
                </div>
                {role.isSystem && <Shield className="w-5 h-5 text-blue-600" />}
              </div>
              <p className="text-sm text-gray-600">{role.description}</p>
            </div>

            {/* Role Stats */}
            <div className="px-6 py-4 bg-gray-50">
              <div className="flex justify-between items-center">
                <div>
                  <p className="text-2xl font-bold text-gray-900">{role.count}</p>
                  <p className="text-xs text-gray-500">Privileges</p>
                </div>
                {role.privileges.length > 0 && (
                  <button
                    onClick={() => setShowDetails(showDetails === role.id ? null : role.id)}
                    className="text-blue-600 hover:text-blue-800 flex items-center text-sm"
                  >
                    {showDetails === role.id ? (
                      <>
                        <EyeOff className="w-4 h-4 mr-1" />
                        Hide
                      </>
                    ) : (
                      <>
                        <Eye className="w-4 h-4 mr-1" />
                        View
                      </>
                    )}
                  </button>
                )}
              </div>
            </div>

            {/* Actions */}
            <div className="px-6 py-4 flex space-x-2 border-t border-gray-200">
              <button
                onClick={() => {
                  setShowPrivilegeEditor(role);
                }}
                className="flex-1 bg-purple-600 text-white py-2 rounded-lg hover:bg-purple-700 transition font-medium text-sm flex items-center justify-center"
              >
                <Shield className="w-4 h-4 mr-2" />
                Configure
              </button>
              <button
                onClick={() => handleOpenModal(role)}
                disabled={role.isSystem}
                className={`flex-1 py-2 rounded-lg transition font-medium text-sm flex items-center justify-center ${role.isSystem
                  ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                  : 'bg-blue-100 text-blue-700 hover:bg-blue-200'
                  }`}
              >
                <Edit2 className="w-4 h-4 mr-2" />
                Edit
              </button>
              <button
                onClick={() => handleDelete(role)}
                disabled={role.isSystem}
                className={`flex-1 py-2 rounded-lg transition font-medium text-sm flex items-center justify-center ${role.isSystem
                  ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                  : 'bg-red-100 text-red-700 hover:bg-red-200'
                  }`}
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>

            {/* Privileges List */}
            {showDetails === role.id && role.privileges.length > 0 && (
              <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 max-h-48 overflow-y-auto">
                <p className="text-xs font-semibold text-gray-600 mb-3 uppercase">Privileges:</p>
                <div className="space-y-2">
                  {role.privileges.slice(0, 8).map(priv => (
                    <div key={priv} className="text-xs text-gray-700 bg-white px-2 py-1 rounded border border-gray-200">
                      • {priv.replace(/_/g, ' ').split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                    </div>
                  ))}
                  {role.privileges.length > 8 && (
                    <div className="text-xs text-gray-500 italic">
                      +{role.privileges.length - 8} more privileges
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Role Form Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-lg max-w-md w-full">
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-4">
                {editingRole ? 'Edit Role' : 'Create New Role'}
              </h2>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Role Name *</label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    placeholder="e.g., Team Lead, Coordinator"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    placeholder="Describe what this role does..."
                    rows="3"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                  />
                </div>

                <div className="flex space-x-3 pt-4">
                  <button
                    type="submit"
                    className="flex-1 bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition font-medium"
                  >
                    {editingRole ? 'Update' : 'Create'}
                  </button>
                  <button
                    type="button"
                    onClick={handleCloseModal}
                    className="flex-1 bg-gray-200 text-gray-800 py-2 rounded-lg hover:bg-gray-300 transition font-medium"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Privilege Configuration Modal */}
      {showPrivilegeEditor && (
        <PrivilegeEditor
          user={{
            name: showPrivilegeEditor.displayName,
            role: showPrivilegeEditor.id,
            custom_privileges: showPrivilegeEditor.privileges,
          }}
          onClose={() => setShowPrivilegeEditor(null)}
          onSave={(data) => handleSavePrivileges(data.custom_privileges)}
        />
      )}
    </div>
  );
};

export default RoleManagement;
