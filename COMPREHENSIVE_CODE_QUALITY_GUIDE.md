# QuarryForce Admin Dashboard - Comprehensive Code Quality & User Flow Guide

**Date:** March 8, 2026  
**Version:** 1.0.0  
**Status:** ✅ All ESLint Warnings Resolved

---

## Table of Contents

1. [Repository Health Check](#repository-health-check)
2. [Code Quality Standards](#code-quality-standards)
3. [Component Architecture](#component-architecture)
4. [User Flow Diagrams](#user-flow-diagrams)
5. [Development Best Practices](#development-best-practices)
6. [Testing Strategy](#testing-strategy)
7. [Deployment Checklist](#deployment-checklist)

---

## Repository Health Check

### Current Status: ✅ CLEAN

#### ESLint Configuration

- **Total Components Scanned:** 18 React components
- **Resolved Issues:** All critical warnings fixed
- **Active Rules Enforced:**
  - `no-unused-vars` - Catches unused imports and variables
  - `react-hooks/exhaustive-deps` - Ensures proper useEffect dependencies
  - `no-undef` - Catches undefined variables
  - `jsx-a11y` - Accessibility rules

#### Files Analyzed

```
✅ CustomerOrdersPanel.js       - No issues (useEffect properly imported)
✅ LocationMapPicker.js         - No issues (geoLoadingError removed)
✅ TargetManagement.js          - No issues (useCallback dependencies fixed)
✅ PrivilegeEditor.js           - No issues (ROLES import removed)
✅ RoleManagement.js            - No issues (Save import removed)
✅ Layout.js                    - No issues (dependency array complete)
✅ CustomersManagement.js       - No issues
✅ OrdersManagement.js          - No issues
✅ Settings.js                  - No issues
✅ SalesRecording.js            - No issues
✅ UserManagement.js            - No issues
✅ FraudAlerts.js               - No issues
✅ Analytics.js                 - No issues
✅ Dashboard.js                 - No issues
✅ Overview.js                  - No issues
✅ OverviewTab.js               - No issues
✅ RepDetails.js                - No issues
✅ ProtectedTab.js              - No issues
```

---

## Code Quality Standards

### React Hooks Best Practices

#### 1. **useEffect Dependencies**

- ✅ All external variables used in effect must be in dependency array
- ✅ Functions used in effects should be wrapped in useCallback
- ✅ If intentionally empty, add comment explaining why

```javascript
// ✅ CORRECT
const fetchData = useCallback(() => {
  // fetch logic
}, [customerId]); // Dependency: customerId might change

useEffect(() => {
  fetchData();
}, [fetchData]); // Dependency: fetchData is defined above
```

#### 2. **Import Management**

- ❌ Never import unused modules
- ✅ Remove imports if they're not referenced in code
- ✅ Use ESLint to catch before commit

```javascript
// ❌ INCORRECT - Save is not used anywhere
import { Plus, Edit2, Trash2, Save } from "lucide-react";

// ✅ CORRECT - Only import what's used
import { Plus, Edit2, Trash2 } from "lucide-react";
```

#### 3. **Variable Declaration**

- ❌ Never declare unused state variables
- ✅ Remove if not referenced in render or event handlers

```javascript
// ❌ INCORRECT
const [geoLoadingError, setGeoLoadingError] = useState(null);
// Never used in JSX or other code

// ✅ CORRECT - Removed completely
// Only declare: const [geoLoading, setGeoLoading] = useState(false);
```

### ESLint Configuration

```json
{
  "extends": ["react-app"],
  "rules": {
    "no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
    "react-hooks/exhaustive-deps": "warn",
    "react-hooks/rules-of-hooks": "error",
    "no-undef": "error"
  }
}
```

---

## Component Architecture

### Core Components Hierarchy

```
Dashboard (Main Container)
├── Layout (Navigation & Layout)
│   ├── Sidebar Navigation
│   └── Role-Based Access Control
│
├── ProtectedTab (Route Protection)
│
├── Tab Components (Dynamic Content)
│   ├── OverviewTab → Overview.js
│   ├── CustomersManagement
│   │   ├── LocationMapPicker
│   │   └── CustomerOrdersPanel
│   ├── OrdersManagement
│   ├── TargetManagement
│   ├── SalesRecording
│   ├── UserManagement
│   │   └── PrivilegeEditor
│   ├── RoleManagement
│   │   └── PrivilegeEditor
│   ├── Settings
│   ├── FraudAlerts
│   └── Analytics
│
└── Context Providers
    ├── AuthContext (User & Privileges)
    └── API Client Layer
```

### Component Props Flow

```javascript
// CustomersManagement receives and manages:
{
  (customerId, //→ CustomerOrdersPanel, LocationMapPicker
    reps, // → Select options
    locationName, // → LocationMapPicker display
    latitude, // → LocationMapPicker center
    longitude); // → LocationMapPicker center
}

// LocationMapPicker emits:
onLocationSelect({
  latitude,
  longitude,
  locationName,
});

// CustomerOrdersPanel emits:
onOrderCreated(); // Triggers parent refresh
```

---

## User Flow Diagrams

### 1. Admin Login & Authentication Flow
