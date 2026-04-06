# QuarryForce Local Deployment Testing Checklist

**Date:** March 8, 2026  
**Status:** ✅ Code Ready | ⏳ Environment Setup Needed

---

## 🔧 Phase 1: XAMPP Setup

### ✓ XAMPP Control Panel

- [ ] **Step 1:** Open XAMPP Control Panel
  - Windows: Search for "XAMPP Control Panel" and open
  - Location: Typically `C:\xampp\xampp-control.exe` or `D:\xampp\xampp-control.exe`

- [ ] **Step 2:** Start Apache
  - Click the "Start" button next to **Apache**
  - Wait for status to show "Running" (green)
  - Expected port: `80`

- [ ] **Step 3:** Start MySQL
  - Click the "Start" button next to **MySQL**
  - Wait for status to show "Running" (green)
  - Expected port: `3306`

---

## 🗄️ Phase 2: Database Creation

### ✓ Create Database in phpMyAdmin

- [ ] **Step 1:** Open phpMyAdmin
  - Navigate to: `http://localhost/phpmyadmin`
  - Login: Username `root`, Password (leave empty)

- [ ] **Step 2:** Create Database
  - Click **Databases** tab
  - Database name: `quarryforce_db`
  - Collation: `utf8mb4_unicode_ci`
  - Click **Create**

- [ ] **Step 3:** Create Tables
  - Select `quarryforce_db` database
  - Click **SQL** tab
  - Paste the SQL script below
  - Click **Go**

### SQL Script to Execute:

```sql
-- Create users table
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) UNIQUE NOT NULL,
  `password` varchar(255),
  `role` enum('admin','rep','supervisor') DEFAULT 'rep',
  `mobile_no` varchar(20),
  `photo` longtext,
  `device_uid` varchar(255),
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create system_settings table
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `gps_radius_limit` int(11) DEFAULT 50,
  `company_name` varchar(255) DEFAULT 'QuarryForce',
  `currency_symbol` varchar(10) DEFAULT '₹',
  `site_types` json,
  `logging_enabled` tinyint(1) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `system_settings` VALUES (1, 50, 'QuarryForce', '₹', '["Quarry", "Site", "Dump"]', 1, NOW(), NOW());
```

---

## 📦 Phase 3: Dependencies

### ✓ Install Node Modules (If First Time)

- [ ] **Step 1:** Open PowerShell
  - Location: `D:\quarryforce\admin-dashboard`

- [ ] **Step 2:** Install Dependencies
  ```powershell
  npm install
  ```

  - Wait for completion (1-2 minutes)
  - Should see: `added XXX packages`

---

## 🚀 Phase 4: Start Development Environment

### ✓ Launch Development Servers

- [ ] **Step 1:** Open PowerShell
  - Location: `D:\quarryforce`

- [ ] **Step 2:** Run Startup Script

  ```powershell
  .\start-dev.bat
  ```

  - Should output messages for both PHP and React servers

- [ ] **Step 3:** Verify Services Starting
  - **PHP Server:** Should see `PHP 8.2.12 Development Server (http://localhost:8000) started`
  - **React Server:** After ~30 seconds, should see `webpack compiled successfully`

### ⏱️ Wait Time:

- PHP starts immediately
- React compilation: ~30-60 seconds
- Both processes should be running in background

---

## 🌐 Phase 5: Access The Application

### ✓ Test in Browser

- [ ] **Step 1:** Open Web Browser
  - Chrome, Firefox, Edge, or Safari

- [ ] **Step 2:** Navigate to Dashboard
  - URL: `http://localhost:3000/qft`
  - Should see: Admin Dashboard with menu on left

- [ ] **Step 3:** Test Core Screens
  - [ ] **User Management** - View/Add users
  - [ ] **Rep Details** - View/Edit reps with mobile numbers
  - [ ] **Customers** - Add customers with new fields
  - [ ] **Settings** - View system settings
  - [ ] **Sales Recording** - Record sales data

---

## 🧪 Phase 6: Validation Tests

### ✓ Feature Testing

- [ ] **Mobile Number Field**
  - Rep Details → Add/Edit Rep
  - Verify `mobile_no` field appears and saves

- [ ] **Customer Enhanced Fields**
  - Customers → Add/Edit Customer
  - Verify all 4 sections appear:
    - Customer Information
    - Site In-Charge Details
    - Material Requirements (RMC/Aggregates)
    - Volume & Pricing

- [ ] **Settings Page**
  - Settings → Load page
  - Should show GPS radius, company name, currency, site types
  - Try adding new site type

- [ ] **Data Persistence**
  - Add/Edit data in any form
  - Refresh page (F5)
  - Verify data persists (saved in MySQL)

- [ ] **No Console Errors**
  - Press F12 to open Developer Tools
  - Go to **Console** tab
  - Should show **zero errors** (warnings OK)

---

## 🔄 Phase 7: Restart & Clean Up

### ✓ Stop Services (When Done Testing)

- [ ] **Step 1:** Stop XAMPP Services
  - XAMPP Control Panel → Click "Stop" for Apache & MySQL
  - Or close PowerShell terminals (Ctrl+C)

- [ ] **Step 2:** Optional - Clear Browser Cache
  - If experiencing issues, press **Ctrl+Shift+Delete**
  - Clear "All time"
  - Reload page

---

## 📝 Configuration Files Verified

| File                           | Purpose            | Status                            |
| ------------------------------ | ------------------ | --------------------------------- |
| `admin-dashboard/.env`         | React API URL      | ✅ Set to `http://localhost:8000` |
| `qft-deployment/.env`          | PHP DB credentials | ✅ Set to XAMPP (root, empty pwd) |
| `start-dev.bat`                | Launch script      | ✅ Ready to run                   |
| `admin-dashboard/package.json` | Dependencies       | ✅ All installed                  |

---

## 🚨 Troubleshooting

### Issue: "Cannot connect to database"

**Solution:**

1. Verify MySQL is running in XAMPP Control Panel
2. Check `qft-deployment/.env` has correct DB_USER and DB_PASSWORD
3. Verify `quarryforce_db` database exists in phpMyAdmin

### Issue: "React app won't load" (blank page)

**Solution:**

1. Hard refresh: **Ctrl+Shift+Delete** → Clear cache
2. Check browser console (F12) for errors
3. Verify React server started (look for "webpack compiled" message)

### Issue: "Failed to load settings"

**Solution:**

1. Verify `system_settings` table exists in phpMyAdmin
2. Check Apache/PHP is running
3. Check browser console (F12) for specific error message

### Issue: "XAMPP not found"

**Solution:**

1. Update XAMPP path in `start-dev.bat` if installed elsewhere
2. Default paths: `C:\xampp` or `D:\xampp`
3. Correct line: `$phpExe = "D:\xampp\php\php.exe"` (if on D: drive)

---

## ✅ Success Criteria

**You're ready for testing when:**

- ✅ XAMPP Apache & MySQL running
- ✅ `quarryforce_db` database created with tables
- ✅ Both PHP and React servers started
- ✅ Browser loads `http://localhost:3000/qft` without errors
- ✅ Can view all dashboard pages
- ✅ Browser console shows zero errors
- ✅ Can add/edit data and it persists on refresh

---

## 📞 Quick Commands

### Start Development:

```powershell
cd d:\quarryforce
.\start-dev.bat
```

### Stop Development:

```powershell
# Press Ctrl+C in each PowerShell terminal
```

### Clear Node Modules (If Issues):

```powershell
cd d:\quarryforce\admin-dashboard
Remove-Item -Recurse node_modules
npm install
```

### Check PHP Server Status:

```powershell
curl http://localhost:8000/
```

---

**Estimated Total Setup Time:** 10-15 minutes

**Last Updated:** March 8, 2026  
**Status:** Ready for Testing ✅
