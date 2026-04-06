# Development Standards & Deployment Guide

## Development Best Practices

### 1. React Hook Guidelines

**✅ CORRECT Patterns:**

```javascript
// Pattern 1: useCallback for event handlers and dependencies
const handleDelete = useCallback(async (id) => {
  const response = await api.delete(`/items/${id}`);
  setItems((prev) => prev.filter((item) => item.id !== id));
}, []); // Empty deps if function doesn't use external state

// Pattern 2: useEffect with proper dependencies
useEffect(() => {
  const fetchData = async () => {
    setLoading(true);
    try {
      const data = await api.get();
      setItems(data);
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  };

  fetchData();
}, [customerId]); // Include all external values used in effect

// Pattern 3: useRef for stable references (no re-render)
const debounceTimer = useRef(null);
const handleSearch = (query) => {
  clearTimeout(debounceTimer.current);
  debounceTimer.current = setTimeout(() => {
    fetchResults(query);
  }, 300);
};
```

**❌ INCORRECT Patterns to Avoid:**

```javascript
// ❌ Missing dependencies - causes stale data
useEffect(() => {
  fetchData(customerId); // ❌ customerId not in deps array
}, []);

// ❌ Creating new function in render - causes infinite re-renders
useEffect(() => {
  const handler = () => doSomething(); // ❌ New function every render
  element.addEventListener("event", handler);
  return () => element.removeEventListener("event", handler);
}, []); // handler dependency missing

// ❌ Calling setState directly in render
const MyComponent = () => {
  const [count, setCount] = useState(0);
  setCount(count + 1); // ❌ Creates infinite loop
};

// ❌ Async function directly as dependency
useEffect(async () => {
  // ❌ useEffect callback can't be async
  await fetchData();
}, []);
```

### 2. Import Organization

**Standard import order (enforced by ESLint):**

```javascript
// 1. React and React extensions
import React, { useState, useEffect, useCallback } from "react";
import { useNavigate, useParams } from "react-router-dom";

// 2. External libraries
import axios from "axios";
import { MapContainer, TileLayer, Marker } from "react-leaflet";
import "leaflet/dist/leaflet.css";

// 3. Internal components (absolute imports)
import Dashboard from "@/components/Dashboard";
import { useAuth } from "@/hooks/useAuth";

// 4. Utils and constants
import { API_BASE_URL } from "@/config/constants";
import { formatNumber, validateEmail } from "@/utils/helpers";

// 5. Styles (should be last)
import "./Component.css";
```

### 3. Component Structure Template

```javascript
import React, { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";

const MyComponent = ({ prop1, prop2 = defaultValue }) => {
  // 1. Hooks at the top
  const navigate = useNavigate();
  const [state1, setState1] = useState(initialValue);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // 2. Derived state or memoized values
  const computedValue = useMemo(() => {
    return expensiveCalculation(state1);
  }, [state1]);

  // 3. Callbacks (wrapped with useCallback if used as dependencies)
  const handleAction = useCallback(async (id) => {
    try {
      const result = await api.post(`/endpoint`, { id });
      setState1(result);
    } catch (err) {
      setError(err.message);
    }
  }, []); // Include external dependencies

  // 4. Side effects
  useEffect(() => {
    loadData();
  }, [prop1]); // Include external dependencies

  // 5. Render logic
  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;

  return <div className="component">{/* Template content */}</div>;
};

export default MyComponent;
```

### 4. State Management Patterns

**For CRUD operations:**

```javascript
const [items, setItems] = useState([]);
const [loading, setLoading] = useState(false);
const [error, setError] = useState(null);
const [showForm, setShowForm] = useState(false);
const [editingId, setEditingId] = useState(null);
const [formData, setFormData] = useState({ name: "", email: "" });

// Fetch list
const fetchItems = useCallback(async () => {
  setLoading(true);
  try {
    const response = await api.get("/items");
    setItems(response.data);
    setError(null);
  } catch (err) {
    setError(err.message);
  } finally {
    setLoading(false);
  }
}, []);

// Create
const handleCreate = useCallback(async () => {
  if (!validate(formData)) return;
  try {
    const response = await api.post("/items", formData);
    setItems((prev) => [...prev, response.data]);
    resetForm();
    setShowForm(false);
  } catch (err) {
    setError(err.message);
  }
}, [formData]);

// Update
const handleUpdate = useCallback(
  async (id) => {
    if (!validate(formData)) return;
    try {
      const response = await api.put(`/items/${id}`, formData);
      setItems((prev) =>
        prev.map((item) => (item.id === id ? response.data : item)),
      );
      resetForm();
      setEditingId(null);
    } catch (err) {
      setError(err.message);
    }
  },
  [formData],
);

// Delete
const handleDelete = useCallback(async (id) => {
  if (!window.confirm("Confirm delete?")) return;
  try {
    await api.delete(`/items/${id}`);
    setItems((prev) => prev.filter((item) => item.id !== id));
  } catch (err) {
    setError(err.message);
  }
}, []);
```

### 5. Error Handling Constants

```javascript
const ERROR_MESSAGES = {
  NETWORK_ERROR: "Network connection failed",
  VALIDATION_ERROR: "Please check your input",
  UNAUTHORIZED: "You do not have permission",
  NOT_FOUND: "Item not found",
  SERVER_ERROR: "Server error occurred",
};

const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  SERVER_ERROR: 500,
};
```

---

## Testing Strategy

### Unit Test Configuration

**Test file location:** `src/components/__tests__/ComponentName.test.js`

```javascript
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import MyComponent from "../MyComponent";

describe("MyComponent", () => {
  test("renders without crashing", () => {
    render(<MyComponent />);
    expect(screen.getByText(/expected text/i)).toBeInTheDocument();
  });

  test("handles user interaction", async () => {
    render(<MyComponent />);
    const button = screen.getByRole("button", { name: /click/i });
    fireEvent.click(button);
    expect(screen.getByText(/result/i)).toBeInTheDocument();
  });

  test("loads and displays data", async () => {
    jest.mock("../api", () => ({
      get: jest.fn(() =>
        Promise.resolve({
          data: [{ id: 1, name: "Test" }],
        }),
      ),
    }));

    render(<MyComponent />);
    await waitFor(() => {
      expect(screen.getByText("Test")).toBeInTheDocument();
    });
  });
});
```

### Integration Test Checklist

- [ ] Component mounts without errors
- [ ] Data fetches on component mount
- [ ] User interactions trigger state updates
- [ ] Props changes cause re-render
- [ ] Error states display correctly
- [ ] Loading states display correctly
- [ ] API calls use correct endpoints
- [ ] Form validation works
- [ ] Navigation works correctly

### E2E Test Coverage Priority

**High Priority (must test):**

1. Login/Authentication flow
2. Create new item (customer/order/target)
3. Edit existing item
4. Delete item with confirmation
5. Role-based access control

**Medium Priority (should test):**

1. Filter and search operations
2. Pagination
3. Export/Report generation
4. Map interactions
5. Form validation

**Lower Priority (nice to have):**

1. UI animations
2. Responsive design variations
3. Browser compatibility edge cases

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  testEnvironment: "jsdom",
  setupFilesAfterEnv: ["<rootDir>/src/setupTests.js"],
  moduleNameMapper: {
    "^@/(.*)$": "<rootDir>/src/$1",
    "\\.(css|less|scss)$": "identity-obj-proxy",
  },
  collectCoverageFrom: [
    "src/**/*.{js,jsx}",
    "!src/index.js",
    "!src/reportWebVitals.js",
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};
```

---

## Pre-Deployment Checklist

### Code Quality Verification

- [ ] **ESLint Audit** - Run `npm run lint` and fix ALL warnings

  ```bash
  npm run lint
  # Expected: 0 errors, 0 warnings
  ```

- [ ] **Build Verification** - Ensure webpack build completes

  ```bash
  npm run build
  # Expected: Build completes without errors
  ```

- [ ] **Dependency Check** - No unused imports/variables
  ```bash
  npm run lint -- --fix
  # All files should pass after fix
  ```

### Component Testing

- [ ] **All 18 components verified clean** (see repository health check)
- [ ] **No console errors on page load**
- [ ] **All links and navigation working**
- [ ] **API endpoints responding correctly**

### Feature Verification

- [ ] **Authentication** - Login/logout working
- [ ] **Customer Management** - CRUD operations functional
- [ ] **Order Management** - New orders creation working
- [ ] **Target Management** - Progress calculations accurate
- [ ] **Location Picker** - Map and search functional
- [ ] **Settings** - Configuration saves properly
- [ ] **User Management** - Role assignment working
- [ ] **Sales Recording** - Commission calculations correct
- [ ] **Fraud Alerts** - Alert detection functional
- [ ] **Analytics** - Stats calculations accurate

### Browser Compatibility

- [ ] **Chrome** (latest version)
- [ ] **Firefox** (latest version)
- [ ] **Safari** (latest version)
- [ ] **Edge** (latest version)

### Performance Checklist

- [ ] **Page Load Time** - < 3 seconds on avg connection
- [ ] **API Response Time** - < 1 second per request
- [ ] **Bundle Size** - Monitor with `npm run build`
- [ ] **Console Warnings** - None on startup

### Security Verification

- [ ] **No hardcoded credentials** in code
- [ ] **API keys in environment variables** only
- [ ] **Authentication tokens properly managed**
- [ ] **CORS headers configured correctly**
- [ ] **SQL injection prevention** (parameterized queries)
- [ ] **XSS protection** (sanitized inputs)

### Database Verification

- [ ] **All migrations applied**
- [ ] **Test data loaded successfully**
- [ ] **Database backups current**
- [ ] **Foreign key constraints verified**

### Documentation Status

- [ ] **README.md** updated with new features
- [ ] **API documentation** complete
- [ ] **User guides** created for new features
- [ ] **Deployment instructions** documented

### Final Pre-Launch Steps

1. **Soft Launch Testing** - Deploy to staging environment

   ```bash
   npm run build
   # Verify all functions on staging URL
   ```

2. **Load Testing** - Simulate expected traffic
   - Test with 10, 50, 100 concurrent users
   - Monitor response times and error rates

3. **Backup Verification** - Ensure backups are current
   - Database backup timestamp
   - Code repository backup tag

4. **Rollback Plan** - Document rollback procedure
   - Previous version accessible
   - Database rollback script ready

5. **Communication** - Notify stakeholders
   - Release notes prepared
   - Support team briefed
   - Maintenance window announced

---

## Post-Deployment Monitoring

### First 24 Hours Checklist

- [ ] Monitor error logs for exceptions
- [ ] Check API response times
- [ ] Verify all reports generating correctly
- [ ] Monitor database performance
- [ ] Check user feedback channels

### Weekly Quality Metrics

- [ ] Average page load time
- [ ] API error rate
- [ ] User-reported bugs
- [ ] Database query performance
- [ ] Server resource utilization

---

## Troubleshooting Guide

### Common Issues and Solutions

**Issue: ESLint warnings after pulling code**

```bash
# Solution: Reinstall and rebuild
npm install
npm run lint -- --fix
npm run build
```

**Issue: Module not found errors**

```bash
# Solution: Check import paths match your directory structure
# Verify absolute import alias in jsconfig.json
# Ensure file extensions match (some systems are case-sensitive)
```

**Issue: Async operations showing stale data**

```bash
// Solution: Verify useCallback dependencies
const fetchData = useCallback(async () => {
  // Make sure all external variables are in dependency array
}, [dependency1, dependency2]);
```

**Issue: Infinite re-render loops**

```bash
// Solution: Check useEffect dependencies
// Add missing dependencies that the effect uses
useEffect(() => {
  // code that uses someValue
}, [someValue]); // not []
```

---

## Additional Resources

- [React Hooks Documentation](https://react.dev/reference/react)
- [ESLint React Plugin](https://github.com/jsx-eslint/eslint-plugin-react)
- [React Testing Library](https://testing-library.com/react)
- [Jest Documentation](https://jestjs.io)
