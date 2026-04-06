/**
 * User Management Component with Roles and Privileges
 */

import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Lock, Eye, EyeOff, RefreshCcw, Shield } from 'lucide-react';
import { adminAPI } from '../api/client';
import { useAuth } from '../context/AuthContext';
import { ROLES, ROLE_PRIVILEGES, PRIVILEGES } from '../config/roles';
import PrivilegeEditor from './PrivilegeEditor';

const UserManagement = () => {
  const { hasPrivilege } = useAuth();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [showPrivileges, setShowPrivileges] = useState(null);
  const [showPrivilegeEditor, setShowPrivilegeEditor] = useState(null);

  const canCreateUser = hasPrivilege(PRIVILEGES.CREATE_USER);
  const canEditUser = hasPrivilege(PRIVILEGES.EDIT_USER);
  const canDeleteUser = hasPrivilege(PRIVILEGES.DELETE_USER);
  const canManageRoles = hasPrivilege(PRIVILEGES.MANAGE_ROLES);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    role: ROLES.REP,
    is_active: true,
  });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await adminAPI.getAllUsers();
      const usersArray = Array.isArray(response.data?.data) ? response.data.data : Array.isArray(response.data) ? response.data : [];
      setUsers(usersArray);
      setError(null);
    } catch (err) {
      console.error('Error fetching users:', err);
      // Mock data for development
      setUsers([
        {
          id: 1,
          name: 'Admin User',
          email: 'admin@quarryforce.local',
          role: ROLES.ADMIN,
          is_active: true,
        },
        {
          id: 2,
          name: 'Manager User',
          email: 'manager@quarryforce.local',
          role: ROLES.MANAGER,
          is_active: true,
        },
        {
          id: 3,
          name: 'Supervisor User',
          email: 'supervisor@quarryforce.local',
          role: ROLES.SUPERVISOR,
          is_active: true,
        },
        {
          id: 4,
          name: 'Rep User',
          email: 'rep@quarryforce.local',
          role: ROLES.REP,
          is_active: true,
        },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = (user = null) => {
    if (user) {
      setEditingUser(user);
      setFormData({
        name: user.name,
        email: user.email,
        role: user.role || ROLES.REP,
        is_active: user.is_active !== false,
      });
    } else {
      setEditingUser(null);
      setFormData({
        name: '',
        email: '',
        role: ROLES.REP,
        is_active: true,
      });
    }
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setEditingUser(null);
    setError(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingUser) {
        // Update user
        await adminAPI.updateUser(editingUser.id, formData);
        setUsers(users.map(u => u.id === editingUser.id ? { ...u, ...formData } : u));
        setSuccess('User updated successfully');
      } else {
        // Create user
        const response = await adminAPI.createUser(formData);
        const newUser = response.data?.data || { id: Date.now(), ...formData };
        setUsers([...users, newUser]);
        setSuccess('User created successfully');
      }
      setTimeout(handleCloseModal, 1000);
    } catch (err) {
      console.error('Error saving user:', err);
      setError(err.message || 'Failed to save user');
    }
  };

  const handleDelete = async (userId) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try {
        await adminAPI.deleteUser(userId);
        setUsers(users.filter(u => u.id !== userId));
        setSuccess('User deleted successfully');
      } catch (err) {
        console.error('Error deleting user:', err);
        setError('Failed to delete user');
      }
    }
  };

  const handleSavePrivileges = async (updatedUser) => {
    try {
      // Save the custom privileges
      await adminAPI.updateUser(updatedUser.id, {
        custom_privileges: updatedUser.custom_privileges,
      });
      
      // Update local state
      setUsers(users.map(u => u.id === updatedUser.id ? updatedUser : u));
      setShowPrivilegeEditor(null);
      setSuccess(`Privileges updated for ${updatedUser.name}`);
    } catch (err) {
      console.error('Error saving privileges:', err);
      setError('Failed to save privileges');
    }
  };

  const getRoleColor = (role) => {
    const colors = {
      [ROLES.ADMIN]: 'bg-red-100 text-red-800',
      [ROLES.MANAGER]: 'bg-purple-100 text-purple-800',
      [ROLES.SUPERVISOR]: 'bg-blue-100 text-blue-800',
      [ROLES.REP]: 'bg-green-100 text-green-800',
    };
    return colors[role] || 'bg-gray-100 text-gray-800';
  };

  const getRolePrivileges = (role) => {
    return ROLE_PRIVILEGES[role] || [];
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">User Management</h1>
          <p className="text-gray-600 mt-2">Manage users, roles, and permissions</p>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={fetchUsers}
            className="bg-gray-200 text-gray-800 px-4 py-2 rounded-lg flex items-center hover:bg-gray-300 transition"
          >
            <RefreshCcw className="w-5 h-5 mr-2" />
            Refresh
          </button>
          {canCreateUser && (
            <button
              onClick={() => handleOpenModal()}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center hover:bg-blue-700 transition"
            >
              <Plus className="w-5 h-5 mr-2" />
              Add User
            </button>
          )}
        </div>
      </div>

      {/* How to Customize Privileges Info */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex">
          <Shield className="w-5 h-5 text-blue-600 mr-3 flex-shrink-0 mt-0.5" />
          <div className="text-sm text-blue-900">
            <p className="font-semibold mb-2">How to Customize Privileges:</p>
            <ul className="space-y-1 ml-4 text-xs list-disc">
              <li><strong>By Role:</strong> Each user gets default privileges based on their role (Admin, Manager, Supervisor, Rep)</li>
              <li><strong>Custom Privileges:</strong> Click the <strong>"Edit"</strong> or <strong>"Custom"</strong> button in the "Customize" column to override role defaults</li>
              <li><strong>Per-Category Control:</strong> Enable/disable entire privilege categories or individual permissions</li>
              <li><strong>Reset:</strong> Use "Reset to Role Defaults" button in the editor to go back to role-based privileges</li>
            </ul>
          </div>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-red-700 flex justify-between items-center">
          <span>{error}</span>
          <button onClick={() => setError(null)} className="text-red-600 hover:text-red-800">✕</button>
        </div>
      )}

      {success && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4 text-green-700 flex justify-between items-center">
          <span>{success}</span>
          <button onClick={() => setSuccess(null)} className="text-green-600 hover:text-green-800">✕</button>
        </div>
      )}

      {/* Users Table */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Name</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Email</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Role</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Status</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Privileges</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Customize</th>
              <th className="px-6 py-3 text-right text-sm font-semibold text-gray-700">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {users.map(user => (
              <tr key={user.id} className="hover:bg-gray-50 transition">
                <td className="px-6 py-4">
                  <div className="font-medium text-gray-900">{user.name}</div>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">{user.email}</td>
                <td className="px-6 py-4">
                  <span className={`px-3 py-1 rounded-full text-xs font-semibold ${getRoleColor(user.role || ROLES.REP)}`}>
                    {(user.role || ROLES.REP).charAt(0).toUpperCase() + (user.role || ROLES.REP).slice(1)}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <span className={`text-sm font-medium ${user.is_active !== false ? 'text-green-600' : 'text-gray-500'}`}>
                    {user.is_active !== false ? '✓ Active' : '✗ Inactive'}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <button
                    onClick={() => setShowPrivileges(showPrivileges === user.id ? null : user.id)}
                    className="text-blue-600 hover:text-blue-800 flex items-center text-sm"
                  >
                    {showPrivileges === user.id ? (
                      <>
                        <EyeOff className="w-4 h-4 mr-1" />
                        Hide
                      </>
                    ) : (
                      <>
                        <Eye className="w-4 h-4 mr-1" />
                        View ({getRolePrivileges(user.role || ROLES.REP).length})
                        {user.custom_privileges && <span className="ml-1 text-orange-500">*</span>}
                      </>
                    )}
                  </button>
                </td>
                <td className="px-6 py-4">
                  {canManageRoles && (
                    <button
                      onClick={() => setShowPrivilegeEditor(user)}
                      className="text-purple-600 hover:text-purple-800 flex items-center text-sm p-2 hover:bg-purple-50 rounded-lg transition"
                      title="Customize privileges for this user"
                    >
                      <Shield className="w-4 h-4 mr-1" />
                      {user.custom_privileges ? 'Custom' : 'Edit'}
                    </button>
                  )}
                </td>
                <td className="px-6 py-4 text-right space-x-2">
                  {canEditUser && (
                    <button
                      onClick={() => handleOpenModal(user)}
                      className="text-blue-600 hover:text-blue-800 p-2 inline-block"
                      title="Edit user"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                  )}
                  {canDeleteUser && (
                    <button
                      onClick={() => handleDelete(user.id)}
                      className="text-red-600 hover:text-red-800 p-2 inline-block"
                      title="Delete user"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {users.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            No users found
          </div>
        )}
      </div>

      {/* Privileges Details */}
      {showPrivileges && (
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center mb-4">
            <Lock className="w-5 h-5 text-blue-600 mr-2" />
            <h3 className="text-lg font-bold text-gray-900">
              Privileges for {users.find(u => u.id === showPrivileges)?.name}
            </h3>
            {users.find(u => u.id === showPrivileges)?.custom_privileges && (
              <span className="ml-2 px-3 py-1 bg-orange-100 text-orange-800 text-xs font-semibold rounded-full">
                CUSTOM OVERRIDE
              </span>
            )}
          </div>
          
          {users.find(u => u.id === showPrivileges)?.custom_privileges && (
            <div className="bg-orange-50 border border-orange-200 rounded-lg p-3 mb-4 text-sm text-orange-800">
              ⚠️ This user has custom privileges that override the {users.find(u => u.id === showPrivileges)?.role} role defaults.
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {getRolePrivileges(users.find(u => u.id === showPrivileges)?.role || ROLES.REP).map(privilege => {
              const user = users.find(u => u.id === showPrivileges);
              const isCustom = user?.custom_privileges && user.custom_privileges.includes(privilege);
              const hasPriv = user?.custom_privileges ? isCustom : true;
              
              return (
                <div
                  key={privilege}
                  className={`rounded-lg p-3 border ${
                    hasPriv
                      ? 'bg-blue-50 border-blue-200'
                      : 'bg-gray-50 border-gray-200 opacity-50'
                  }`}
                >
                  <div className="flex items-center">
                    <input
                      type="checkbox"
                      checked={hasPriv}
                      disabled
                      className="w-4 h-4 rounded cursor-not-allowed"
                    />
                    <p className="text-sm font-medium ml-2">
                      {privilege.replace(/_/g, ' ').split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* User Form Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-lg max-w-md w-full">
            <div className="p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-4">
                {editingUser ? 'Edit User' : 'Add New User'}
              </h2>

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-3 mb-4 text-red-700 text-sm">
                  {error}
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Name *</label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                    required
                  />
                </div>

                {canManageRoles && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Role *</label>
                    <select
                      value={formData.role}
                      onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                    >
                      {Object.values(ROLES).map(role => (
                        <option key={role} value={role}>
                          {role.charAt(0).toUpperCase() + role.slice(1)} ({getRolePrivileges(role).length} privileges)
                        </option>
                      ))}
                    </select>
                  </div>
                )}

                <div>
                  <label className="flex items-center text-sm font-medium text-gray-700">
                    <input
                      type="checkbox"
                      checked={formData.is_active}
                      onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                      className="w-4 h-4 mr-2 rounded"
                    />
                    Active User
                  </label>
                </div>

                <div className="flex space-x-3 pt-4 border-t">
                  <button
                    type="submit"
                    className="flex-1 bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition font-medium"
                  >
                    {editingUser ? 'Update' : 'Create'}
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

      {/* Privilege Editor Modal */}
      {showPrivilegeEditor && (
        <PrivilegeEditor
          user={showPrivilegeEditor}
          onClose={() => setShowPrivilegeEditor(null)}
          onSave={handleSavePrivileges}
        />
      )}
    </div>
  );
};

export default UserManagement;
