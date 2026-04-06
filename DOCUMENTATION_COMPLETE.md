# QuarryForce Project - Complete Feature Documentation

## Updated March 8, 2026

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Core Features](#core-features)
4. [Admin Dashboard](#admin-dashboard)
5. [Mobile Application](#mobile-application)
6. [Database Schema](#database-schema)
7. [API Documentation](#api-documentation)
8. [Deployment Guide](#deployment-guide)

---

## Project Overview

**QuarryForce** is a comprehensive field executive management and fraud detection system designed for quarry operations. It provides real-time tracking, sales recording, target management, and comprehensive analytics.

### Key Statistics

- **Framework:** React 18.2.0 (Web) + Flutter (Mobile)
- **Backend:** PHP with MySQL
- **Maps:** Leaflet 1.9.4 with OpenStreetMap
- **Mobile Storage:** shared_preferences (local-first)
- **Deployment:** Supports standalone PHP or cPanel hosting

### Current Phase

**Phase 3: Complete** - Comprehensive admin dashboard with location mapping, order management, target visualization, and offline-capable mobile app.

---

## System Architecture

### Technology Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    System Architecture                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  WEB TIER (Admin Dashboard)                                  │
│  ├── React 18.2.0                                            │
│  ├── Tailwind CSS (styling)                                  │
│  ├── Lucide Icons                                            │
│  ├── Leaflet + React-Leaflet (maps)                          │
│  └── Axios (API client)                                      │
│                                                               │
│  ↓ (REST API)                                                │
│                                                               │
│  API TIER (Backend)                                          │
│  ├── PHP (api.php)                                           │
│  ├── Logger class (logging)                                  │
│  ├── Database class (DB abstraction)                         │
│  └── Request routing                                         │
│                                                               │
│  ↓ (SQL)                                                     │
│                                                               │
│  DATA TIER (MySQL Database)                                  │
│  ├── Users (with roles)                                      │
│  ├── Customers (with locations)                              │
│  ├── Orders                                                  │
│  ├── Rep Targets                                             │
│  ├── Rep Progress                                            │
│  ├── Visit Logs                                              │
│  ├── Fuel Logs                                               │
│  ├── Sales History                                           │
│  └── System Settings                                         │
│                                                               │
│  MOBILE TIER (Flutter App)                                   │
│  ├── Local Storage (shared_preferences)                      │
│  ├── Offline Queue (OfflineQueueService)                     │
│  ├── Cache Service (responses + TTL)                         │
│  ├── API Client (sync when online)                           │
│  └── Maps (Google Maps)                                      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

**Web Dashboard:**

1. User action on React component
2. API call via axios (systemAPI/adminAPI/repTargetsAPI)
3. PHP endpoint processes request
4. MySQL query executes
5. Fresh data returned to UI
6. Component re-renders (no local cache)

**Mobile App:**

1. User action
2. Try local cache first (CacheService)
3. If offline: queue request (OfflineQueueService)
4. When online:
   - Process queued requests
   - Sync with server
   - Update local cache
   - Update UI

---

## Core Features

### 1. User & Role Management ✅

**Components:**

- User Management page (CRUD)
- Role-based access control (Admin/Rep/Supervisor)
- Privilege verification system

**Features:**

- Create users with roles
- Assign privileges per role
- Delete users
- manage user photos (base64 stored)
- Fixed salary configuration

### 2. Customer Management ✅

**Components:**

- Customers Management page
- Location Map Picker (NEW)
- Customer Orders Panel (NEW)

**Features:**

- Full customer CRUD
- Location selection with interactive map
- Real-time location search (Nominatim API)
- Previous orders display
- Create/edit/delete customer orders
- Lat/Long editable fields
- Customer assignment to reps

### 3. Order Management ✅

**Components:**

- Orders Management page
- CustomerOrdersPanel (in customer rows)

**Features:**

- Create orders with rep/customer/amount/date
- View all orders with customer details
- Update order status
- Delete orders
- Status color coding
- Integration with customer detail panels

**Order Status:** pending → confirmed → delivered → cancelled

### 4. Rep Target Management ✅

**Components:**

- Target Management page
- Target Progress Charts (NEW)

**Features:**

- Create sales targets per rep/month
- Target achievements visualization
- Month-based analysis
- Summary statistics:
  - Active targets count
  - Average achievement %
  - Total target volume
- Individual rep achievement cards
- Progress bars with color coding
- Duplicate target detection

**Color Coding:**

- 🟢 Green (100%+): Exceeded
- 🔵 Blue (75-99%): On track
- 🟡 Yellow (50-74%): Lagging
- 🔴 Red (<50%): Behind

### 5. Sales Recording ✅

**Features:**

- Record sales volume (m³)
- Associate with rep and specific month
- Automatic bonus/penalty calculation
- Sales history viewing
- Real-time calculation display

### 6. Analytics & Reporting ✅

**Components:**

- Analytics page
- Overview/Dashboard pages
- Fraud Alerts

**Metrics:**

- Total customers
- Active reps
- Monthly sales
- Orders completed
- Target achievement rates
- Fraud detection flags

### 7. System Settings ✅

**Fields:**

- Company Name
- Company Logo (image upload)
- Company Address
- Company Email
- Company Phone
- GPS Radius Limit (10-500m)
- Currency Symbol
- Site Types (editable list)
- API Logging toggle

**Storage:** Database (system_settings table)
**Access:** Admin-only

### 8. Fraud Alert System ✅

**Features:**

- Detect suspicious patterns
- Location-based fraud detection
- Alert notifications
- Historical fraud tracking

---

## Admin Dashboard

### Pages & Components

| Page            | Purpose           | Features                      | Status |
| --------------- | ----------------- | ----------------------------- | ------ |
| Dashboard       | Overview          | Stats cards, quick actions    | ✅     |
| Overview        | Analytics         | Charts, metrics, KPIs         | ✅     |
| Customers       | CRUD              | Map picker, orders, filtering | ✅     |
| Orders          | Management        | Create/read/update/delete     | ✅     |
| Rep Targets     | Target Management | Targets, achievements, charts | ✅     |
| Sales Recording | Sales Entry       | Record sales, calculate bonus | ✅     |
| Users           | User CRUD         | Create/edit/delete users      | ✅     |
| Roles           | Role Management   | Define roles & privileges     | ✅     |
| Settings        | Config            | Company info, GPS, currency   | ✅     |
| Fraud Alerts    | Monitoring        | Suspicious patterns           | ✅     |

### Data Handling

**Web App Philosophy:**

- ✅ Session-based (no localStorage)
- ✅ Always server-connected
- ✅ Database is single source of truth
- ✅ Stateless components
- ✅ Real-time API calls

**Benefits:**

- Instant data consistency
- No sync issues
- Clean memory management
- No stale data problems

### Key Libraries

```json
{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "react-router-dom": "^6.8.0",
  "axios": "^1.3.0",
  "leaflet": "^1.9.4",
  "react-leaflet": "^4.2.1",
  "chart.js": "^4.5.1",
  "react-chartjs-2": "^5.3.1",
  "lucide-react": "^0.575.0",
  "tailwindcss": "^3.x"
}
```

---

## Mobile Application

### Architecture: Local-First with Server Sync

**Philosophy:**

- Works offline using local storage
- Queues operations when offline
- Syncs automatically when online
- User never loses data

### Core Services

#### 1. CacheService ✅

```
Purpose: Local data caching
Storage: shared_preferences
Features:
- Cache responses with TTL
- Serve cached data offline
- Automatic expiration
```

#### 2. OfflineQueueService ✅

```
Purpose: Queue requests when offline
Storage: shared_preferences
Features:
- Queue up to 100 requests
- Auto-retry (max 3 times)
- FIFO processing
- Sync when connection available
```

#### 3. API Client

```
Behavior:
- Check cache first
- If online: fetch fresh data + update cache
- If offline: use cache + queue request
- Background sync when online
```

### Mobile Data Flow

```
User Action
    ↓
Check Internet
    ↓
    ├─ Online → Direct API call
    │             ↓
    │        Update Cache
    │             ↓
    │        Return data
    │
    └─ Offline → Check Cache
                  ↓
             Found? → Return data
                      + Queue for sync
             ↓
             Not found → Show offline message

Background Process
    Internet comes back
         ↓
    Process Queue (FIFO)
         ↓
    Sync each request
         ↓
    Update cache
         ↓
    Notify user
```

### Storage Limits

- Queue: Max 100 requests
- Cache: Unlimited (TTL-based expiration)
- Retry: Max 3 attempts per request

---

## Database Schema

### Core Tables

#### 1. users

```sql
id, name, email, password, role, mobile_no, photo,
device_uid, is_active, fixed_salary, created_at, updated_at
```

#### 2. customers

```sql
id, name, phone_no, location, assigned_rep_id,
site_incharge_name, site_incharge_phone, address,
material_needs, rmc_grade, aggregate_types,
volume, volume_unit, required_date,
amount_concluded_per_unit, boom_pump_amount,
status, lat, lng, created_at, updated_at
```

#### 3. orders (NEW)

```sql
id, customer_id, rep_id, order_amount, order_date,
status, created_at, updated_at
```

#### 4. rep_targets

```sql
id, rep_id, target_month, monthly_sales_target_m3,
incentive_rate_per_m3, incentive_rate_max_per_m3,
penalty_rate_per_m3, status, created_at, updated_at
```

#### 5. rep_progress

```sql
id, rep_id, target_month, total_sales_volume,
total_incentive, total_penalty, status, created_at, updated_at
```

#### 6. visit_logs

```sql
id, customer_id, rep_id, check_in_time, checkout_time,
requirements_json, lat_at_submission, lng_at_submission,
distance_meters, gps_verified, created_at
```

#### 7. fuel_logs

```sql
id, rep_id, odometer_reading, fuel_quantity_liters,
total_amount, lat, lng, logged_at, created_at
```

#### 8. system_settings (NEW FIELDS)

```sql
id, gps_radius_limit, company_name,
company_logo, company_address, company_email, company_phone,
currency_symbol, site_types, logging_enabled,
created_at, updated_at
```

---

## API Documentation

### Authentication Endpoints

```
POST /login
  Request: { email, password, device_uid }
  Response: { success, data: {user, token} }

POST /logout
  Request: { user_id }
  Response: { success }

POST /reset-password
  Request: { email, new_password }
  Response: { success }
```

### Customer Endpoints

```
GET    /api/admin/customers
POST   /api/admin/customers
PUT    /api/admin/customers/:id
DELETE /api/admin/customers/:id
GET    /api/admin/customers/:id
```

### Order Endpoints

```
GET    /api/admin/orders
GET    /api/admin/orders/customer/:id
POST   /api/admin/orders
PUT    /api/admin/orders/:id
DELETE /api/admin/orders/:id
```

### Rep & Target Endpoints

```
GET    /api/admin/reps
GET    /api/admin/rep-targets
POST   /api/admin/rep-targets
PUT    /api/admin/rep-targets/:id

GET    /api/admin/rep-progress/:rep_id
GET    /api/admin/rep-progress-history/:rep_id
POST   /api/admin/rep-progress/update
```

### Settings Endpoints

```
GET    /api/settings
PUT    /api/settings
```

### Response Format

**Success:**

```json
{
  "success": true,
  "data": {
    /* actual data */
  }
}
```

**Error:**

```json
{
  "success": false,
  "error": "Error message"
}
```

---

## Deployment Guide

### Prerequisites

- PHP 7.4+ with MySQLi
- MySQL 5.7+
- Node.js 14+ (for React build)
- Apache/Nginx web server

### Deployment Steps

1. **Database Setup**

   ```bash
   # Create database
   CREATE DATABASE quarryforce;

   # Import schema
   mysql -u root -p quarryforce < CREATE_TABLES.sql

   # Run migrations (if needed)
   mysql -u root -p quarryforce < MIGRATE_SETTINGS_TABLE.sql
   ```

2. **File Structure**

   ```
   /qft-deployment/
   ├── api.php          (main API)
   ├── config.php       (configuration)
   ├── Database.php     (DB class)
   └── static/          (frontend build)
   ```

3. **Environment Configuration** (config.php)

   ```php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'quarryforce');
   define('DB_PASS', 'secure_password');
   define('DB_NAME', 'quarryforce');
   define('API_BASE_URL', 'https://yourdomain.com/qft/');
   ```

4. **Frontend Build**

   ```bash
   cd admin-dashboard
   npm install
   npm run build
   # Copy build/ to /qft-deployment/static/
   ```

5. **Web Server Config** (.htaccess)

   ```apache
   <IfModule mod_rewrite.c>
     RewriteEngine On
     RewriteCond %{REQUEST_FILENAME} !-f
     RewriteCond %{REQUEST_FILENAME} !-d
     RewriteRule ^ api.php [QSA,L]
   </IfModule>
   ```

6. **Mobile App Build**
   ```bash
   cd quarryforce_mobile
   flutter pub get
   flutter build apk    # Android
   flutter build ios    # iOS
   ```

### Post-Deployment Checks

- [ ] Database connection working
- [ ] API responding at `/api/settings`
- [ ] Frontend loads without errors
- [ ] Can login with admin credentials
- [ ] Settings save to database
- [ ] Orders CRUD working
- [ ] Target charts displaying
- [ ] Location map picker functional

---

## Security Considerations

### API Security

- All data validated server-side
- GPS radius check prevents location fraud
- Device UID binding for reps
- Role-based access control

### Database Security

- Prepared statements (prevent SQL injection)
- Password hashing (bcrypt recommended)
- HTTPS required for production
- API logging for audit trail

### Mobile Security

- Local encryption for cached data (recommended)
- API token refresh on sync
- Device UID verification
- Offline queue includes timestamp

---

## Performance Optimization

### Web Dashboard

- Session-based (no storage overhead)
- Direct API calls (optimal latency)
- Component memoization recommended
- Lazy loading for large lists

### Mobile App

- Cache responses (reduce bandwidth)
- Batch queue processing (network efficiency)
- TTL-based cache expiration
- Compression for large syncs

---

## Troubleshooting

### Settings Not Saving

**Solution:** Ensure `system_settings` table has new columns:

```sql
ALTER TABLE system_settings
ADD COLUMN IF NOT EXISTS company_email VARCHAR(255);
ADD COLUMN IF NOT EXISTS company_phone VARCHAR(20);
```

### Orders Not Showing

**Cause:** API not returning full data
**Fix:** Verify API returns with customer/rep joins

### Map Not Loading

**Cause:** Leaflet CSS not loaded
**Fix:** Ensure `leaflet/dist/leaflet.css` imported in component

### Offline Queue Not Syncing

**Mobile Only - Cause:** Connection check failing
**Fix:** Verify internet connectivity detection

---

## Future Roadmap

### Q2 2026

- [ ] Interactive charts with Recharts
- [ ] Export to PDF/Excel
- [ ] Advanced search filters
- [ ] Real-time notifications

### Q3 2026

- [ ] Mobile app feature parity
- [ ] Enhanced analytics dashboard
- [ ] Bulk import (CSV)
- [ ] Role-based API access

### Q4 2026

- [ ] Multi-language support
- [ ] Dark mode
- [ ] Advanced reporting
- [ ] Custom dashboards

---

## Version History

| Version | Date        | Changes                                                |
| ------- | ----------- | ------------------------------------------------------ |
| 3.1     | Mar 8, 2026 | Target charts, Settings company info, Order management |
| 3.0     | Mar 7, 2026 | Location map picker, mobile offline-first confirmed    |
| 2.5     | Prior       | Sales recording, Rep targets, Fraud alerts             |
| 2.0     | Prior       | User management, Role-based access                     |
| 1.0     | Prior       | Initial dashboard, Customer management                 |

---

## Support & Maintenance

### Common Issues & Solutions

See `TROUBLESHOOTING.md` for detailed guides

### API Documentation

See `API_DOCUMENTATION.md` for full endpoint reference

### Deployment Checklist

See `DEPLOYMENT_CHECKLIST.md` for production deployment

### Testing Guide

See `TESTING_GUIDE_API_HANDLERS.md` for QA procedures

---

**Last Updated:** March 8, 2026  
**Status:** ✅ Phase 3 Complete  
**Next Review:** Quarterly
