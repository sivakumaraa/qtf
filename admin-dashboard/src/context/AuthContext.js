/**
 * Authentication Context
 * Manages user authentication, roles, and privilege verification
 */

import React, { createContext, useContext, useState, useEffect } from 'react';
import { ROLE_PRIVILEGES } from '../config/roles';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Initialize user from localStorage or session
  useEffect(() => {
    const initAuth = async () => {
      try {
        // Check if user data exists in localStorage
        const storedUser = localStorage.getItem('user');
        if (storedUser) {
          setUser(JSON.parse(storedUser));
        }
        // Otherwise, user stays null and login page will be shown
      } catch (error) {
        console.error('Failed to initialize auth:', error);
      } finally {
        setLoading(false);
      }
    };

    initAuth();
  }, []);

  /**
   * Check if user has a specific privilege
   * Masters both role-based and custom privileges
   */
  const hasPrivilege = (privilege) => {
    if (!user) return false;
    
    // If user has custom privileges, use those (overrides role)
    if (user.custom_privileges && Array.isArray(user.custom_privileges)) {
      return user.custom_privileges.includes(privilege);
    }
    
    // Fall back to role-based privileges
    const userPrivileges = ROLE_PRIVILEGES[user.role] || [];
    return userPrivileges.includes(privilege);
  };

  /**
   * Check if user has any of the given privileges
   */
  const hasAnyPrivilege = (privileges) => {
    if (!user) return false;
    return privileges.some(p => hasPrivilege(p));
  };

  /**
   * Check if user has all of the given privileges
   */
  const hasAllPrivileges = (privileges) => {
    if (!user) return false;
    return privileges.every(p => hasPrivilege(p));
  };

  /**
   * Get all privileges for the current user
   * Includes both custom and role-based privileges
   */
  const getUserPrivileges = () => {
    if (!user) return [];
    // If user has custom privileges, return those (overrides role)
    if (user.custom_privileges && Array.isArray(user.custom_privileges)) {
      return user.custom_privileges;
    }
    // Fall back to role-based
    return ROLE_PRIVILEGES[user.role] || [];
  };

  /**
   * Login user
   */
  const login = (userData) => {
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
  };

  /**
   * Logout user
   */
  const logout = () => {
    setUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('googleToken');
    // Clear any other auth tokens
  };

  /**
   * Update user role
   */
  const updateUserRole = (newRole) => {
    if (user) {
      const updatedUser = { ...user, role: newRole };
      setUser(updatedUser);
    }
  };

  const value = {
    user,
    loading,
    hasPrivilege,
    hasAnyPrivilege,
    hasAllPrivileges,
    getUserPrivileges,
    login,
    logout,
    updateUserRole,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

/**
 * Hook to use auth context
 */
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

export default AuthContext;
