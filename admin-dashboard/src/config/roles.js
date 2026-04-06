/**
 * Roles and Privileges Configuration
 * Defines what each role can do and which screens they can access
 */

export const ROLES = {
  ADMIN: 'admin',
  MANAGER: 'manager',
  REP: 'rep',
  SUPERVISOR: 'supervisor',
};

export const PRIVILEGES = {
  // Overview
  VIEW_OVERVIEW: 'view_overview',
  VIEW_DASHBOARD_STATS: 'view_dashboard_stats',

  // User Management
  VIEW_USERS: 'view_users',
  CREATE_USER: 'create_user',
  EDIT_USER: 'edit_user',
  DELETE_USER: 'delete_user',
  MANAGE_ROLES: 'manage_roles',

  // Rep Management
  VIEW_REPS: 'view_reps',
  EDIT_REP: 'edit_rep',
  DELETE_REP: 'delete_rep',

  // Targets
  VIEW_TARGETS: 'view_targets',
  CREATE_TARGETS: 'create_targets',
  EDIT_TARGETS: 'edit_targets',
  APPROVE_TARGETS: 'approve_targets',

  // Sales & Progress
  VIEW_PROGRESS: 'view_progress',
  RECORD_SALES: 'record_sales',
  EDIT_SALES: 'edit_sales',
  VIEW_SALES_HISTORY: 'view_sales_history',

  // Customers
  VIEW_CUSTOMERS: 'view_customers',
  CREATE_CUSTOMER: 'create_customer',
  EDIT_CUSTOMER: 'edit_customer',
  DELETE_CUSTOMER: 'delete_customer',

  // Orders
  VIEW_ORDERS: 'view_orders',
  CREATE_ORDER: 'create_order',
  EDIT_ORDER: 'edit_order',
  DELETE_ORDER: 'delete_order',

  // Fraud & Alerts
  VIEW_ALERTS: 'view_alerts',
  MANAGE_ALERTS: 'manage_alerts',

  // Logs & Analytics
  VIEW_LOGS: 'view_logs',
  VIEW_ANALYTICS: 'view_analytics',
  EXPORT_DATA: 'export_data',

  // Settings
  VIEW_SETTINGS: 'view_settings',
  EDIT_SETTINGS: 'edit_settings',
  MANAGE_SYSTEM: 'manage_system',
};

/**
 * Role-based Access Control Matrix
 * Maps roles to their allowed privileges
 */
export const ROLE_PRIVILEGES = {
  [ROLES.ADMIN]: [
    // Admins have all privileges
    ...Object.values(PRIVILEGES),
  ],

  [ROLES.MANAGER]: [
    // Manager privileges
    PRIVILEGES.VIEW_OVERVIEW,
    PRIVILEGES.VIEW_DASHBOARD_STATS,
    PRIVILEGES.VIEW_USERS,
    PRIVILEGES.EDIT_USER,
    PRIVILEGES.VIEW_REPS,
    PRIVILEGES.EDIT_REP,
    PRIVILEGES.VIEW_TARGETS,
    PRIVILEGES.EDIT_TARGETS,
    PRIVILEGES.APPROVE_TARGETS,
    PRIVILEGES.VIEW_PROGRESS,
    PRIVILEGES.VIEW_SALES_HISTORY,
    PRIVILEGES.VIEW_CUSTOMERS,
    PRIVILEGES.EDIT_CUSTOMER,
    PRIVILEGES.VIEW_ORDERS,
    PRIVILEGES.EDIT_ORDER,
    PRIVILEGES.VIEW_ALERTS,
    PRIVILEGES.VIEW_LOGS,
    PRIVILEGES.VIEW_ANALYTICS,
  ],

  [ROLES.SUPERVISOR]: [
    // Supervisor privileges (limited manager)
    PRIVILEGES.VIEW_OVERVIEW,
    PRIVILEGES.VIEW_DASHBOARD_STATS,
    PRIVILEGES.VIEW_REPS,
    PRIVILEGES.VIEW_TARGETS,
    PRIVILEGES.VIEW_PROGRESS,
    PRIVILEGES.VIEW_SALES_HISTORY,
    PRIVILEGES.VIEW_CUSTOMERS,
    PRIVILEGES.CREATE_CUSTOMER,
    PRIVILEGES.EDIT_CUSTOMER,
    PRIVILEGES.VIEW_ORDERS,
    PRIVILEGES.RECORD_SALES,
    PRIVILEGES.VIEW_ALERTS,
    PRIVILEGES.VIEW_LOGS,
    PRIVILEGES.VIEW_ANALYTICS,
  ],

  [ROLES.REP]: [
    // Rep privileges (limited view)
    PRIVILEGES.VIEW_OVERVIEW,
    PRIVILEGES.VIEW_PROGRESS,
    PRIVILEGES.RECORD_SALES,
    PRIVILEGES.VIEW_SALES_HISTORY,
    PRIVILEGES.VIEW_CUSTOMERS,
    PRIVILEGES.VIEW_ORDERS,
  ],
};

/**
 * Screen-to-Tab mapping with required privileges
 */
export const SCREEN_PRIVILEGES = {
  overview: {
    label: 'Overview Dashboard',
    required: [PRIVILEGES.VIEW_OVERVIEW],
  },
  users: {
    label: 'User Management',
    required: [PRIVILEGES.VIEW_USERS],
  },
  roles: {
    label: 'Role Management',
    required: [PRIVILEGES.MANAGE_ROLES],
  },
  reps: {
    label: 'Rep Details',
    required: [PRIVILEGES.VIEW_REPS],
  },
  targets: {
    label: 'Rep Targets & Progress',
    required: [PRIVILEGES.VIEW_TARGETS],
  },
  customers: {
    label: 'Customers',
    required: [PRIVILEGES.VIEW_CUSTOMERS],
  },
  orders: {
    label: 'Orders',
    required: [PRIVILEGES.VIEW_ORDERS],
  },
  alerts: {
    label: 'Fraud Alerts',
    required: [PRIVILEGES.VIEW_ALERTS],
  },
  logs: {
    label: 'Visit Logs',
    required: [PRIVILEGES.VIEW_LOGS],
  },
  settings: {
    label: 'Settings',
    required: [PRIVILEGES.VIEW_SETTINGS],
  },
};
