# PHP Backend Deployment Guide - Namecheap Shared Hosting

## Overview

This guide covers deploying the **PHP version** of QuarryForce backend to Namecheap shared hosting. The conversion from Node.js to PHP provides native compatibility with shared hosting environments.

## Prerequisites

- Namecheap shared hosting account
- cPanel access
- MySQL database created
- Domain/subdomain pointing to public_html
- FTP access (optional - use cPanel File Manager instead)

## Quick Deployment (10 minutes)

### Step 1: Prepare Files (Locally)

```bash
cd d:\quarryforce\qft-deployment

# DO NOT include:
# - node_modules/
# - nodejs-backup/ (optional - safe to exclude)
# - .git/
# - node_process.json
# - package-lock.json

# Include everything else:
# - ✓ index.php (entry point)
# - ✓ api.php (all endpoints)
# - ✓ config.php (configuration)
# - ✓ Database.php (database wrapper)
# - ✓ Logger.php (logging)
# - ✓ .env.template (rename to .env on server)
# - ✓ .htaccess (Apache routing)
# - ✓ admin/ (React dashboard build)
# - ✓ uploads/ (empty folder)
# - ✓ Documentation files
```

### Step 2: ZIP Files

```bash
# Windows PowerShell
Compress-Archive -Path @(
  "api.php",
  "config.php",
  "Database.php",
  "Logger.php",
  "index.php",
  ".env.template",
  ".htaccess",
  "admin/",
  "uploads/",
  "*.md"
) -DestinationPath "qft-php-deploy.zip" -Force
```

Or manually:

- Select all files EXCEPT node_modules, nodejs-backup, .git
- Right-click → Send to → Compressed folder
- Rename to: `qft-php-deploy.zip`

### Step 3: Upload to Namecheap (cPanel)

1. **Login to cPanel**
   - Go to: cpanel.valviyal.com (or your cPanel URL)
   - Username/Password: Your cPanel credentials

2. **Open File Manager**
   - cPanel → File Manager
   - Navigate to: `/public_html/qft` (or create the qft folder)

3. **Upload ZIP**
   - Click "Upload"
   - Select `qft-php-deploy.zip`
   - Wait for upload to complete

4. **Extract ZIP**
   - Right-click `qft-php-deploy.zip`
   - Select "Extract"
   - Confirm extraction to current directory

5. **Delete ZIP file**
   - Right-click `qft-php-deploy.zip`
   - Select "Delete"

### Step 4: Create .env File on Server

1. **Create new file**
   - In File Manager: `/public_html/qft/`
   - Click "Create New" → "File"
   - Name: `.env` (note the leading dot)

2. **Edit .env**

   ```bash
   # Use exact values from your Namecheap setup
   NODE_ENV=production

   # Database credentials (from cPanel → MySQL Databases)
   DB_HOST=localhost
   DB_USER=your_user_here
   DB_PASSWORD=your_password_here
   DB_NAME=your_database_here
   DB_PORT=3306

   # Your domain
   API_URL=https://valviyal.com/qft
   FRONTEND_URL=https://valviyal.com/qft

   # Logging (enable for testing, can disable after)
   LOGGING_ENABLED=true
   LOG_LEVEL=INFO
   ```

3. **Save file**

### Step 5: Set Folder Permissions

In File Manager:

- Right-click `logs` folder → "Change Permissions"
- Set to: `755` (read, write, execute)
- Right-click `uploads` folder → "Change Permissions"
- Set to: `755`

### Step 6: Test Deployment

1. **Open browser**
   - Go to: `https://valviyal.com/qft`
   - Should see QuarryForce Admin Dashboard

2. **Test API endpoint**
   - Go to: `https://valviyal.com/qft/api/test`
   - Should see: `{"server":"Online","database":"Connected"}`

3. **Test login endpoint**
   - Use Postman or curl:

   ```bash
   curl -X POST https://valviyal.com/qft/api/login \
     -H "Content-Type: application/json" \
     -d '{"email":"demo@quarryforce.local","device_uid":"test-device-001"}'
   ```

   - Should return: `{"success":true,"message":"Device registered successfully!","user":{...}}`

4. **Check logs**
   - File Manager → logs/ → app.log
   - Should contain JSON log entries

## Troubleshooting

### Problem: "404 Not Found" for API endpoints

**Causes:**

- .htaccess not properly configured
- Apache mod_rewrite not enabled
- Incorrect RewriteBase path

**Fixes:**

1. Check .htaccess exists in `/public_html/qft/`
2. Verify your actual domain URL in browser (not IP address)
3. Update RewriteBase in .htaccess if path is different:

   ```apache
   # If deployed to /qft/
   RewriteBase /qft/

   # If deployed to root/
   RewriteBase /
   ```

### Problem: "500 Internal Server Error"

**Checks:**

1. PHP error log: cPanel → Error Log (check for PHP errors)
2. Check .env file exists: `/public_html/qft/.env`
3. Check database credentials in .env
4. Check app.log: `/public_html/qft/logs/app.log`

**Quick test:**

```bash
# Create test.php in /public_html/qft/
<?php phpinfo(); ?>

# Visit: https://valviyal.com/qft/test.php
# If shows error, check cPanel Error Log
```

### Problem: "Cannot connect to database"

**Verify credentials:**

1. cPanel → MySQL Databases
2. Check username, password, database name
3. Make DB_HOST=localhost (don't use IP)

**Test connection:**

```php
// Create db-test.php in /public_html/qft/
<?php
$conn = new PDO('mysql:host=localhost;dbname=quarryforce_db', 'user', 'password');
echo "Connected!";
?>
```

### Problem: Admin dashboard shows blank page

**Checks:**

1. Open browser developer console (F12)
2. Check Network tab for 404 errors on CSS/JS files
3. Hard refresh: Ctrl+Shift+R
4. Check that admin/ folder exists

**Rebuild admin if needed:**

```bash
# In admin-dashboard folder (local machine)
npm install
npm run build
# Copy dist/ contents to qft/admin/
```

### Problem: Logs not being written

**Checks:**

1. Verify `/qft/logs/ ` folder exists
2. Check permissions: should be 755
3. Check LOGGING_ENABLED=true in .env
4. Verify PHP can write to directory

**Fix:**

```bash
# In File Manager
# Right-click logs/ → Change Permissions → 755
# Right-click app.log (if exists) → Change Permissions → 644
```

## Database Setup

### Import Test Data

1. **cPanel → phpMyAdmin**
2. **Select Database:** Click your database name
3. **Import**:
   - Click "Import" tab
   - Click "Choose File"
   - Select `TEST_DATA.sql` from your local machine
   - Click "Import"

### Create Tables Manually (if needed)

If tables don't exist, create them:

```sql
-- Users table
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  role ENUM('admin','rep','manager') DEFAULT 'rep',
  device_uid VARCHAR(500),
  is_active INT DEFAULT 1,
  fixed_salary DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers table
CREATE TABLE customers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  assigned_rep_id INT,
  status ENUM('active','inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_rep_id) REFERENCES users(id)
);

-- Rep targets table
CREATE TABLE rep_targets (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  target_month VARCHAR(7),
  monthly_sales_target_m3 DECIMAL(10,2),
  incentive_rate_per_m3 DECIMAL(8,2),
  incentive_rate_max_per_m3 DECIMAL(10,2),
  penalty_rate_per_m3 DECIMAL(8,2),
  status ENUM('active','inactive') DEFAULT 'active',
  updated_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id),
  UNIQUE KEY unique_rep_month (rep_id, target_month)
);

-- Rep progress table
CREATE TABLE rep_progress (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  month VARCHAR(7),
  sales_volume_m3 DECIMAL(10,2),
  bonus_earned DECIMAL(12,2) DEFAULT 0,
  penalty_amount DECIMAL(12,2) DEFAULT 0,
  net_compensation DECIMAL(12,2) DEFAULT 0,
  status ENUM('pending','approved','paid') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id),
  UNIQUE KEY unique_rep_month (rep_id, month)
);

-- Visit logs table
CREATE TABLE visit_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT,
  rep_id INT,
  check_in_time DATETIME,
  requirements_json LONGTEXT,
  lat_at_submission DECIMAL(10,8),
  lng_at_submission DECIMAL(11,8),
  distance_meters INT,
  gps_verified INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (rep_id) REFERENCES users(id)
);

-- Fuel logs table
CREATE TABLE fuel_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT,
  odometer_reading INT,
  fuel_quantity_liters DECIMAL(8,2),
  total_amount DECIMAL(10,2),
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  logged_at DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id)
);

-- System settings table
CREATE TABLE system_settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  gps_radius_limit INT DEFAULT 100,
  company_name VARCHAR(255) DEFAULT 'QuarryForce',
  currency_symbol VARCHAR(3) DEFAULT '₹',
  site_types JSON,
  logging_enabled INT DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT INTO system_settings (company_name, currency_symbol, gps_radius_limit, logging_enabled)
VALUES ('QuarryForce', '₹', 100, 1);
```

## Performance Tips

1. **Enable caching** in .htaccess (already done)
2. **Enable gzip compression** in .htaccess (already done)
3. **Monitor logs** - check `/qft/logs/app.log` regularly
4. **Clean up old logs** - Logs rotate at 10MB, but you can delete old ones manually

## Security Notes

✅ **Already implemented:**

- HTTPS enforced (domain setup)
- Database credentials not exposed
- Prepared statements (no SQL injection)
- CORS properly configured
- Error messages don't expose database info
- Logs don't store sensitive data

📋 **Additional recommendations:**

- Change demo account credentials after testing
- Set LOGGING_ENABLED=false in production (optional)
- Restrict cPanel access to IP addresses
- Regular database backups in cPanel

## Mobile App Integration

Update Flutter app with new PHP API URL:

```dart
// In Flutter app config
const String API_BASE_URL = 'https://valviyal.com/qft/api';

// Example endpoint call
final response = await http.post(
  Uri.parse('$API_BASE_URL/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'device_uid': deviceId}),
);
```

## Next Steps

1. ✅ Deploy files to Namecheap
2. ✅ Test root URL and API endpoints
3. ✅ Import test data to database
4. ✅ Access admin dashboard
5. ✅ Update mobile app with new API URL
6. ✅ Monitor logs for issues
7. ✅ Enable/disable logging as needed

## Support & Debugging

### View Logs

```bash
# Use File Manager to browse logs/app.log
# or via SSH (if available):
tail -f /home/brutsaxr/public_html/qft/logs/app.log
```

### Common Log Entries

```json
// Successful login
{"timestamp":"2026-03-05 10:30:45","level":"INFO","message":"User login successful","request":{"method":"POST","uri":"/api/login"},"data":"{\"user_id\":1}"}

// Database error
{"timestamp":"2026-03-05 10:30:46","level":"ERROR","message":"Failed to fetch settings","request":{"method":"GET","uri":"/api/settings"},"data":"{\"error\":\"SQLSTATE[HY000]\"}"}

// Check-in successful
{"timestamp":"2026-03-05 10:30:47","level":"INFO","message":"Check-in successful","request":{"method":"POST","uri":"/api/checkin"},"data":"{\"rep_id\":1,\"distance\":45}"}
```

### Get Help

If issues persist:

1. Check cPanel Error Log
2. Review app.log in /qft/logs/
3. Test database credentials manually
4. Verify all files were uploaded
5. Check file permissions (folders: 755, files: 644)

Email support if needed with:

- Error messages from Error Log
- Relevant entries from app.log
- .env configuration (hide password)
- Steps you've already tried
