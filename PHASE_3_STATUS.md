# QuarryForce Phase 3 Status & Implementation Plan

**Last Updated:** March 1, 2026  
**Status:** In Progress - Admin Dashboard Enhancements & Backend API Development

---

## Current System Status

### ✅ Completed

#### Flutter Mobile App (Lib)

- All Dart compilation errors fixed
- Lint warnings cleaned up
- 5 service layer classes implemented and integrated:
  - `CacheService` - TTL-based caching
  - `OfflineQueueService` - Async retry logic for offline operations
  - `ImageCompressionService` - JPEG compression
  - `ErrorHandlingService` - HTTP error mapping
  - `FormValidationService` - Input validation
- Mobile app code compiles without errors (web testing incomplete - requires emulator/device)

#### Admin Dashboard Frontend

- **Screens Implemented:**
  - ✅ Overview Dashboard
  - ✅ User Management
  - ✅ Target Management (with monthly targets & override detection)
  - ✅ Sales Recording
  - ✅ Fraud Alerts
  - ✅ Analytics
  - ✅ Settings (company name, GPS radius, currency symbol, site types)
  - ✅ Rep Details (with fixed salary component)
  - ✅ Customers Management (GPS coordinates, rep assignment)
  - ✅ Orders Management (order tracking with status workflow)

- **UI/UX Enhancements:**
  - ✅ Centralized currency configuration (CURRENCY object)
  - ✅ Hardcoded ₹ symbols replaced with config-based approach (13+ locations)
  - ✅ Tailwind CSS styling applied consistently
  - ✅ Lucide React icons integrated across all screens
  - ✅ Navigation sidebar updated with all new screens

- **Bug Fixes (Phase 3):**
  - ✅ Fixed JSX missing opening div (TargetManagement.js line 282)
  - ✅ Fixed `.toFixed()` error with GPS coordinates (CustomersManagement.js - parseFloat conversion)
  - ✅ Dashboard now compiles without critical errors

#### Backend API

- ✅ Fixed reset device endpoint (POST /api/admin/reset-device)
- ✅ Settings endpoints (GET/PUT /api/settings) with site_types support
- ✅ User endpoints with fixed_salary field support
- ✅ Rep targets with monthly targets and override detection

---

## 🔄 In Progress / Partially Complete

### Customer & Order Management

**Status:** Frontend UI complete, Backend CRUD endpoints not yet implemented

**Frontend Implemented:**

- CustomersManagement.js - Add/view/edit customer locations with GPS
- OrdersManagement.js - Add/view/edit orders with status tracking

**Backend Needed:**

- `POST /api/admin/customers` - Create customer
- `PUT /api/admin/customers/:id` - Update customer
- `DELETE /api/admin/customers/:id` - Delete customer
- `GET /api/admin/customers` - Fetch all customers
- `POST /api/admin/orders` - Create order
- `PUT /api/admin/orders/:id` - Update order
- `DELETE /api/admin/orders/:id` - Delete order
- `GET /api/admin/orders` - Fetch all orders

**Database Schema Needed:**

```sql
CREATE TABLE customers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  lat DECIMAL(10, 8),
  lng DECIMAL(10, 8),
  assigned_rep_id INT,
  address TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_rep_id) REFERENCES users(id)
);

CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  customer_id INT NOT NULL,
  order_amount DECIMAL(10, 2),
  order_date DATE,
  product_details TEXT,
  status ENUM('pending', 'confirmed', 'delivered', 'cancelled') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
```

---

---

## 🚀 Android Emulator Setup Guide

### Current Status

- ✅ Flutter installed (v3.38.5)
- ✅ Android SDK installed at `C:\Android\android-sdk`
- ❌ Android cmdline-tools missing (prevents emulator creation)
- ❌ No emulators created yet (needed for mobile testing)

### Step-by-Step Setup Instructions

#### Create Emulator Using Android Studio GUI

Android Studio is installed at `D:\Program Files\Android\Android Studio`. The SDK is at `C:\Users\sivak\AppData\Local\Android\Sdk`. To create the emulator:

1. Click **Device Manager** in Android Studio (or Tools → Device Manager)
2. Click **Create Device**
3. Select **Pixel 5** or **Pixel 8 Pro**
4. Choose **API Level 36** or higher
5. Name it **quarry_phone**
6. Click **Finish** and wait for creation
7. Click the **Play icon** to launch the emulator

#### Run Flutter App on Emulator

Once the emulator is running:

```powershell
cd d:\quarryforce\quarryforce_mobile
$env:ANDROID_SDK_ROOT="C:\Users\sivak\AppData\Local\Android\Sdk"
flutter run
```

This will automatically detect the running emulator and deploy the app.

#### Verify Emulator Connection

```powershell
$env:ANDROID_SDK_ROOT="C:\Users\sivak\AppData\Local\Android\Sdk"
flutter devices
```

Should show output like:

```
Found X connected devices:
  quarry_phone • emulator-5554 • android-x64 • Android 14 (API 34)
  ... other devices ...
```

#### Common Emulator Commands

```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch quarry_phone

# Run app on emulator (from project directory)
cd d:\quarryforce\quarryforce_mobile
flutter run

# Run with verbose logging to see detailed output
flutter run -v
```

#### Android Studio Device Manager Shortcut

If needed, you can also directly create/manage AVDs through:

- **Tools → Device Manager** in Android Studio
- Or download and use Android Emulator GUI separately

````

#### Testing Checklist on Device/Emulator

- [ ] App launches without crashes
- [ ] Splash screen displays correctly
- [ ] Navigation between screens works
- [ ] API calls succeed (backend must be running on `localhost:3000`)
- [ ] Login/authentication works
- [ ] Image compression function works
- [ ] Offline queue functionality works
- [ ] GPS location services work
- [ ] Database caching works
- [ ] Form validation displays errors

---

## ❌ Known Issues / TODO

### Mobile Emulator Setup (BLOCKER)

- [ ] Android cmdline-tools not installed
- [ ] Emulator creation fails without SDK components
- [ ] Android Studio installation recommended

### API Client Issues

- [ ] `adminAPI.getAllCustomers()` method exists but GET /api/admin/customers endpoint not implemented
- [ ] `adminAPI.getAllOrders()` method needs to be added

### ESLint Warnings (Non-critical)

- [ ] Unused variables in Analytics.js (lines 34, 40, 117, 121)
- [ ] Unused imports in CustomersManagement.js (Plus, Edit, Trash2, Loader)
- [ ] Unused imports in OrdersManagement.js (Edit, Trash2, Loader)
- [ ] Unused imports in RepDetails.js (Edit, Save, X icons unused in some code paths)
- [ ] useEffect missing dependency: 'fetchSettings' in Settings.js

### Missing Functionality

- [ ] Backend customer CRUD operations
- [ ] Backend order CRUD operations
- [ ] Delete functionality in customer/order management screens (UI shows Edit button only)
- [ ] Integration testing for new management screens
- [ ] Mobile app integration with site_types configuration

---

## 📋 Implementation Roadmap - Phase 3B (Next Steps)

### Priority 1: Backend Customer & Order Management (CRITICAL)

1. Add customers table to MySQL database
2. Add orders table to MySQL database
3. Implement 4 customer endpoints (GET, POST, PUT, DELETE)
4. Implement 4 order endpoints (GET, POST, PUT, DELETE)
5. Test with Postman

**Estimated Time:** 2-3 hours
**Files to Modify:** `index.js` (backend)

### Priority 2: Frontend Integration & Testing

1. Test customer creation/update/delete flows
2. Test order creation/update/delete flows
3. Add delete functionality to UI buttons
4. Verify data persistence and API communication

**Estimated Time:** 1-2 hours

### Priority 3: Code Quality

1. Remove unused imports (ESLint warnings)
2. Fix useEffect dependencies
3. Add error handling for failed API calls
4. Add loading states for form submissions

**Estimated Time:** 1 hour

### Priority 4: Mobile App Integration (Optional)

1. Create site_types configuration screen in mobile app
2. Add site type selection to visit/fuel entry screens
3. Sync site_types from settings API

**Estimated Time:** 2-3 hours

---

## 🏗️ Architecture Overview

### Data Flow

```
Flutter Mobile App
  ├─ Service Layer (5 services)
  │  └─ API Service (backend communication)
  ├─ Models & Providers (state management)
  └─ Screens (UI)

Admin Dashboard (React)
  ├─ Components (10+ screens)
  ├─ API Client
  │  └─ axios (HTTP requests)
  └─ Config (currency, constants)

Backend (Node.js/Express)
  ├─ Database Layer (MySQL)
  ├─ REST API Endpoints
  └─ Business Logic
```

### Database Schema

**Existing Tables:**

- users (with new: fixed_salary field, role field)
- rep_targets (with new: target_month field)
- rep_progress
- system_settings (with new: site_types JSON field)
- sales_history

**New Tables Needed:**

- customers
- orders

---

## 🔧 Configuration

### Currency Configuration (`admin-dashboard/src/config/constants.js`)

```javascript
export const CURRENCY = {
  SYMBOL: "₹",
  CODE: "INR",
  format: (amount) => {
    /* number formatting */
  },
  formatWithSign: (amount) => {
    /* with currency prefix */
  },
};
```

### Settings Available in Backend

- `company_name` - Display name of the quarry company
- `gps_radius_limit` - Validate GPS location within radius (meters)
- `currency_symbol` - Currency symbol for display (default: ₹)
- `site_types` - JSON array of site type categories

---

## 📊 Testing Checklist

### Phase 3A Testing (PARTIALLY COMPLETE ⚠️)

**Code Compilation:**

- [x] Flutter app compiles without errors
- [x] Admin dashboard compiles without errors
- [x] No critical JSX or Dart syntax errors

**Web Testing (Limited Validation):**

- [x] Settings screen displays and loads data
- [x] Rep Details screen shows reps with editable fields
- [x] Navigation between screens works
- [x] Currency formatting displays correctly

**Mobile Emulator/Device Testing (TODO - REQUIRED):**

- [ ] Run on Android emulator
- [ ] Run on iOS simulator (if available)
- [ ] Verify app launches without crashes
- [ ] Test GPS functionality on device
- [ ] Test image compression on device
- [ ] Test offline queue functionality
- [ ] Test caching behavior
- [ ] Verify API communication works on device

### Phase 3B Testing (TODO)

- [ ] Create new customer via API
- [ ] Update customer location
- [ ] Delete customer
- [ ] Fetch all customers in dropdown
- [ ] Create new order via API
- [ ] Update order status
- [ ] Delete order
- [ ] Fetch all orders in table
- [ ] Search/filter customers by rep
- [ ] Search/filter orders by status

---

## 📝 Code Coverage

### Admin Dashboard Components Created (Phase 3)

1. **Settings.js** (244 lines)
   - Company name configuration
   - GPS radius limit (10-500m)
   - Currency symbol input
   - Site types management (add/remove tags)

2. **RepDetails.js** (225 lines)
   - Rep list with editable fields
   - Fixed salary component with currency formatting
   - Status badge (Active/Inactive)
   - Inline edit/save/cancel workflow

3. **CustomersManagement.js** (310 lines)
   - Form for adding customers
   - GPS coordinates input (latitude/longitude)
   - Rep assignment dropdown
   - Address textarea
   - Table display with location data

4. **OrdersManagement.js** (353 lines)
   - Form for creating orders
   - Rep and customer selection
   - Order amount with currency formatting
   - Date picker for order date
   - Product details textarea
   - Status dropdown (pending/confirmed/delivered/cancelled)
   - Status-colored badges in table

### Modified Files (Phase 3)

- **Dashboard.js** - Added 3 new component imports and renderContent cases
- **Layout.js** - Added navigation items for new screens
- **api/client.js** - Updated with new API methods
- **index.js** (backend) - Added/updated endpoints for settings and users

---

## 🎯 Next Session Tasks

1. **Create customers database table**
   - Set up schema with foreign key constraints
   - Add test data

2. **Create orders database table**
   - Set up schema with foreign key constraints
   - Add relationships to customers and users tables

3. **Implement backend customer endpoints**
   - POST /api/admin/customers (create)
   - GET /api/admin/customers (fetch all)
   - PUT /api/admin/customers/:id (update)
   - DELETE /api/admin/customers/:id (delete)

4. **Implement backend order endpoints**
   - POST /api/admin/orders (create)
   - GET /api/admin/orders (fetch all)
   - PUT /api/admin/orders/:id (update)
   - DELETE /api/admin/orders/:id (delete)

5. **Test with Postman/browser**
   - Verify all CRUD operations
   - Check API response formats
   - Validate database persistence

---

## 📞 Notes

- All frontend screens are styled with Tailwind CSS and display correctly
- Currency is centrally configured and easy to change globally
- Service layer provides robust offline support for mobile app
- Database schema ready for customer/order tables
- API structure consistent with existing endpoints
- Monthly targets with override detection prevents data loss
- GPS coordinate validation integrated into mobile app

---

## Version History

| Version | Date       | Changes                                   |
| ------- | ---------- | ----------------------------------------- |
| 1.0     | 2024-01-15 | Initial system setup                      |
| 2.0     | 2024-06-30 | Phase 2: Mobile app & core features       |
| 2.1     | 2025-01-01 | Settings & rep management                 |
| 3.0     | 2026-03-01 | Advanced management screens (in progress) |
````
