# 🚀 QuarryForce Local Development Setup Guide

**Complete guide to compile and run QuarryForce locally**

---

## 📋 System Architecture

```
┌─────────────────────────────────────────────────────┐
│ Frontend Applications                               │
├─────────────────────────────────────────────────────┤
│ ✅ React Admin Dashboard  (Port 3001)               │
│ ✅ Flutter Mobile Web App (Port 3002)               │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ Backend API (Node.js + Express)                     │
│ Port 3000 - 11 production-ready endpoints          │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│ Database (MySQL/MariaDB via XAMPP)                  │
│ - 5 Tables with audit fields & foreign keys        │
└─────────────────────────────────────────────────────┘
```

---

## 🔧 Prerequisites

Before starting, ensure you have:

### Required

- ✅ **Node.js** v14+ ([Download here](https://nodejs.org))
- ✅ **npm** (comes with Node.js)
- ✅ **MySQL/MariaDB** (via XAMPP or standalone)

### Optional

- 🎯 **Flutter SDK** (for mobile app development)
- 🎯 **Git** (for version control)

### Verify Installation

```powershell
# Check Node.js
node --version    # Should be v14 or higher
npm --version     # Should be v6 or higher

# Check Flutter (optional)
flutter --version

# Check MySQL/MariaDB
# Start XAMPP Control Panel and ensure MySQL is running
```

---

## 🗄️ Database Setup

### Step 1: Start MySQL

**Option A: Using XAMPP**

1. Open **XAMPP Control Panel**
2. Click **START** next to **MySQL** (wait for green indicator)
3. Click **START** next to **Apache** (optional for web interface)
4. Verify at `http://localhost/phpmyadmin`

**Option B: Using Command Line**

```powershell
# If MySQL is installed as a service
net start MySQL80    # or your MySQL service name
```

### Step 2: Create Database (if not already done)

```sql
-- Open http://localhost/phpmyadmin
-- Go to SQL tab and run:

CREATE DATABASE IF NOT EXISTS quarryforce;
USE quarryforce;

-- Then execute the CREATE_TABLES.sql file
-- Located at: d:\quarryforce\qft-deployment\CREATE_TABLES.sql
```

**Quick Setup via Command Line:**

```powershell
cd d:\quarryforce\qft-deployment
mysql -u root -p quarryforce < CREATE_TABLES.sql
# Leave password blank if using default XAMPP setup
```

### Step 3: Verify Database Connection

The `.env` file is already configured:

```
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASS=
DB_NAME=quarryforce
```

**Change these values if your MySQL setup is different:**

- If MySQL is on different host: update `DB_HOST`
- If MySQL has password: update `DB_PASS`
- If different username: update `DB_USER`

---

## 📦 Installation Method 1: Automated PowerShell Script (Recommended)

The easiest way to compile everything:

### Step 1: Run the Setup Script

```powershell
# Open PowerShell as Administrator
cd d:\quarryforce
.\START_LOCAL_DEVELOPMENT.ps1
```

### Step 2: Choose Your Option

```
1) Install all dependencies (first time only)
2) Start all services (Backend + Dashboard + Optional Flutter)
3) Start Backend only (Port 3000)
4) Start Admin Dashboard only (Port 3001)
5) Build & Run Flutter Web (Port 3002)
6) Open local URLs in browser
7) Full setup: Install + Start everything
```

**First time?** Choose option **7** to do everything at once.

---

## 📦 Installation Method 2: Manual Steps

If you prefer to do it manually:

### Step 1: Install Backend Dependencies

```powershell
cd d:\quarryforce\qft-deployment
npm install
```

**Expected output:**

```
added 89 packages in 15s
```

### Step 2: Install Admin Dashboard Dependencies

```powershell
cd d:\quarryforce\admin-dashboard
npm install
```

**Expected output:**

```
added 200+ packages in 30s
```

### Step 3: Get Flutter Dependencies

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter pub get
```

**Expected output:**

```
Running "flutter pub get" in quarryforce_mobile...
Running resolving dependencies...
```

---

## 🚀 Running the Application

### Option A: Run Everything (3 Services)

**Terminal 1: Backend API (Port 3000)**

```powershell
cd d:\quarryforce\qft-deployment
npm start
```

Expected output:

```
🚀 QuarryForce Backend Server Started!
📍 Server: http://localhost:3000
```

**Terminal 2: Admin Dashboard (Port 3001)**

```powershell
cd d:\quarryforce\admin-dashboard
npm start
```

Expected output:

```
Compiled successfully!
You can now view quarryforce-admin-dashboard in the browser.
Local: http://localhost:3001
```

**Terminal 3: Flutter Web App (Port 3002)**

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter run -d web-server
```

Expected output:

```
Flutter web app running at: http://localhost:3002
```

---

### Option B: Backend Only (for API testing)

```powershell
cd d:\quarryforce\qft-deployment
npm start
```

Test the API:

```powershell
# Base URL
curl http://localhost:3000

# Test endpoint
curl http://localhost:3000/api/settings
```

---

### Option C: Admin Dashboard Only

```powershell
cd d:\quarryforce\admin-dashboard
npm start
```

Access at: `http://localhost:3001`

---

### Option D: Flutter Web Only

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter run -d web-server
```

Access at: `http://localhost:3002`

---

## 🌐 Access Your Applications

Once all services are running:

| Service         | URL                         | Purpose               |
| --------------- | --------------------------- | --------------------- |
| Backend API     | http://localhost:3000       | REST API endpoints    |
| Admin Dashboard | http://localhost:3001       | User & rep management |
| Mobile Web App  | http://localhost:3002       | Field rep application |
| phpMyAdmin      | http://localhost/phpmyadmin | Database management   |

---

## 🧪 Testing the Setup

### Test 1: Backend Health Check

```powershell
curl http://localhost:3000/api/settings
```

**Expected response:**

```json
{
  "gps_radius_limit": 50,
  "company_name": "QuarryForce",
  "currency_symbol": "₹",
  ...
}
```

### Test 2: Using Postman

1. Download [Postman](https://www.postman.com/downloads/)
2. Import the collection: `d:\quarryforce\postman_collection.json`
3. Test any endpoint (includes all 11 APIs)

### Test 3: Using Browser

Visit: `http://localhost:3000/api/settings`

You should see JSON response with company settings.

---

## 🗂️ Project Structure

```
d:\quarryforce\
├── qft-deployment/           ← Backend (Node.js)
│   ├── index.js              ← Main server
│   ├── db.js                 ← Database connection
│   ├── package.json          ← Dependencies
│   ├── .env                  ← Configuration
│   ├── node_modules/         ← Installed packages
│   └── CREATE_TABLES.sql     ← Database schema
│
├── admin-dashboard/          ← React dashboard
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── node_modules/
│
├── quarryforce_mobile/       ← Flutter mobile app
│   ├── lib/                  ← Dart code
│   ├── web/                  ← Web assets
│   ├── pubspec.yaml          ← Dependencies
│   └── pubspec.lock
│
├── START_LOCAL_DEVELOPMENT.ps1  ← Setup script (this one!)
├── LOCAL_DEPLOYMENT_GUIDE.md    ← This file
├── API_DOCUMENTATION.md         ← API reference
└── postman_collection.json      ← API tests
```

---

## 🔧 Troubleshooting

### Issue: Port Already in Use

**Error:** `Error: listen EADDRINUSE :::3000`

**Solution:**

```powershell
# Find process using port
netstat -ano | findstr :3000

# Kill the process
taskkill /PID <process_id> /F

# Or use different port in .env
```

### Issue: Database Connection Error

**Error:** `connect ECONNREFUSED 127.0.0.1:3306`

**Solution:**

1. Start XAMPP and ensure MySQL is running
2. Check `.env` file has correct credentials:
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=quarryforce
   ```
3. Verify database exists: `mysql -u root -e "SHOW DATABASES;"`

### Issue: npm install Fails

**Solution:**

```powershell
# Clear npm cache
npm cache clean --force

# Delete node_modules and package-lock
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json

# Reinstall
npm install
```

### Issue: Flutter Dependencies Error

**Solution:**

```powershell
cd d:\quarryforce\quarryforce_mobile

# Clean and get fresh dependencies
flutter clean
flutter pub get

# If still failing, upgrade Flutter
flutter upgrade
```

### Issue: React Dashboard Won't Start

**Error:** `Cannot find react-scripts`

**Solution:**

```powershell
cd d:\quarryforce\admin-dashboard
npm cache clean --force
npm install
npm start
```

---

## 📝 Environment Configuration

### Backend Configuration (.env)

Located at: `d:\quarryforce\qft-deployment\.env`

```env
PORT=3000                              # API port
DB_HOST=localhost                      # Database host
DB_USER=root                           # Database user
DB_PASS=                               # Database password (empty for XAMPP)
DB_NAME=quarryforce                    # Database name
```

### React Dashboard Configuration

Located at: `d:\quarryforce\admin-dashboard\package.json`

Base path is set to `/qft/` for production. For local dev, it works as-is.

### Flutter Configuration

Located at: `d:\quarryforce\quarryforce_mobile\pubspec.yaml`

Update API base URL in code:

```dart
// lib/main.dart or config/api_config.dart
const String API_BASE_URL = 'http://localhost:3000';
```

---

## 📊 API Endpoints Reference

The backend provides 11 production-ready endpoints:

### User Endpoints

- `GET /api/settings` - Get system settings
- `POST /api/login` - Device binding login
- `POST /api/checkin` - GPS verification check-in
- `POST /api/visit/submit` - Submit site visit
- `POST /api/fuel/submit` - Submit fuel purchase

### Admin Endpoints

- `GET /api/admin/reps` - List all marketing reps
- `GET /api/admin/customers` - List customers with GPS
- `POST /api/admin/reset-device` - Reset device binding

### Utility

- `GET /test` - Health check

**Full documentation:** See `API_DOCUMENTATION.md`

---

## 🚀 Performance Optimization

### For Development

1. **Enable source maps** for debugging:
   - React: Already enabled
   - Flutter: Use `--debug` flag

2. **Use Debug Mode**:

   ```powershell
   flutter run -d web-server --debug
   ```

3. **Monitor Performance**:
   - React DevTools browser extension
   - Flutter DevTools: `flutter devtools`

### For Testing

1. **Load Testing**: Use Apache Bench

   ```powershell
   ab -n 100 -c 10 http://localhost:3000/api/settings
   ```

2. **API Testing**: Use Postman collection
   - Pre-configured endpoints
   - Request/response validation

---

## 📚 Additional Resources

- **API Documentation**: See `API_DOCUMENTATION.md`
- **Database Guide**: See `DATABASE_MIGRATION_GUIDE.md`
- **Deployment Guide**: See `DEPLOYMENT_README.md`
- **Development Best Practices**: See `DEVELOPMENT_BEST_PRACTICES.md`
- **Postman Collection**: Import `postman_collection.json`

---

## ✅ Checklist: Ready for Development?

- [ ] Node.js v14+ installed
- [ ] MySQL/XAMPP running
- [ ] Database created with tables
- [ ] Backend API running on port 3000
- [ ] Admin dashboard running on port 3001
- [ ] Can access http://localhost:3000/api/settings
- [ ] Can access http://localhost:3001
- [ ] (Optional) Flutter web running on port 3002

**If all checked:** You're ready to develop! 🎉

---

## 🎯 Next Steps

1. **Explore the APIs**:
   - Use Postman or curl to test endpoints
   - Add test data if needed

2. **Understand the Database**:
   - Open phpMyAdmin
   - Explore the 5 tables and relationships

3. **Develop Features**:
   - Backend: Modify `qft-deployment/index.js`
   - Dashboard: Modify files in `admin-dashboard/src`
   - Mobile: Modify files in `quarryforce_mobile/lib`

4. **Deploy When Ready**:
   - See `DEPLOYMENT_README.md` for production deployment
   - See `NAMECHEAP_STELLAR_DEPLOYMENT.md` for cloud hosting

---

**Happy coding!** 🚀

_Last Updated: March 9, 2026_
