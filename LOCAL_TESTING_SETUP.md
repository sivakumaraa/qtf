# QuarryForce Local Testing Guide

## Prerequisites

You already have XAMPP installed at `D:\xampp`. You just need:

### Required Software

1. **XAMPP** - Already installed with PHP and MySQL ✓
2. **Node.js 16+** - Download from https://nodejs.org/ (if not already installed)

### Setup Steps

1. **Verify XAMPP Installation**:
   - XAMPP should be at: `D:\xampp`
   - Contains PHP, MySQL, and other tools
   - Verify PHP exists: `D:\xampp\php\php.exe`

2. **Install Node.js** (if needed):
   - Download from https://nodejs.org/
   - After installation, verify: Open PowerShell and run `node -v`

3. **No Need For**:
   - Separate PHP installation ✓
   - Separate MySQL installation ✓
   - PATH configuration (script handles XAMPP paths)

## Quick Start

### Windows with XAMPP

1. **Ensure MySQL is Running**:
   - Open XAMPP Control Panel
   - Click "START" next to MySQL service
   - Wait for it to show as running

2. **Start Development Environment**:
   - Open Command Prompt or PowerShell
   - Navigate to: `cd d:\quarryforce`
   - Run: `start-dev.bat`
   - Two console windows will open automatically

### macOS/Linux

1. Open Terminal
2. Navigate to the project root: `cd /path/to/quarryforce`
3. Run: `chmod +x start-dev.sh && ./start-dev.sh`

## What Gets Started

### PHP Backend (Port 8000)

- **URL**: http://localhost:8000
- **API Base**: http://localhost:8000/api/
- **Admin Panel**: http://localhost:8000/api/admin/
- **Status**: Access `/api/` for API documentation
- **Uses**: XAMPP PHP from `D:\xampp\php`

### React Admin Dashboard (Port 3000)

- **URL**: http://localhost:3000
- **Auto-reload**: Changes to React files automatically reload
- **Features**: All new customer management features are included

## Database Setup

### XAMPP MySQL Configuration

1. **Start MySQL Service**:
   - Open XAMPP Control Panel
   - Click "START" next to MySQL
   - Wait for it to show "Running"

2. **Create Database**:
   - Option A: Use phpMyAdmin (built into XAMPP)
     - Open http://localhost/phpmyadmin
     - Create new database: `quarryforce_db`
   - Option B: Use Command Line
     ```sql
     mysql -u root
     CREATE DATABASE quarryforce_db;
     EXIT;
     ```

3. **Update Configuration**:
   - Edit `qft-deployment/.env`:

   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=quarryforce_db
   ```

   Note: XAMPP defaults have no password for root user. If you set a password, update `DB_PASS=your_password`

4. **Import Database Schema** (if available):
   - Use phpMyAdmin import feature, or:

   ```
   mysql -u root quarryforce_db < backup.sql
   ```

5. **Verify Connection**:
   - Start the dev environment with `start-dev.bat`
   - Check PHP backend logs for connection success
   - Access http://localhost:8000/api/ to verify API responds

## Testing New Features

### Customer Management Updates

- **Location**: Instead of Lat/Lng, now uses string-based location
- **Materials**: RMC grades (10-40) and Aggregate types (M sand, 40mm, 20mm, etc.)
- **Site In-Charge**: New contact person details
- **Pricing**: Amount per unit and boom/pump charges

**Test Steps**:

1. Navigate to Admin Dashboard → Customers Management
2. Click "Add Customer"
3. Fill in all fields including:
   - Customer phone
   - Location (auto-fetch by rep)
   - Material needs
   - Volume and required date
   - Pricing details
4. Click "Save" and verify data appears in table

### Mobile Number Field in Reps

- **Location**: Admin Dashboard → Rep Details
- **Test**: Edit a rep and add their mobile number

## Troubleshooting

### PHP Server Won't Start

**Error**: "php: command not found" or "php.exe not found"

- **Solution**:
  - Script uses XAMPP PHP automatically
  - Verify XAMPP is at: `D:\xampp\php\php.exe`
  - Check drive letter matches (D: vs C:, etc.)
  - Edit `start-dev.bat` if XAMPP path is different

### MySQL Connection Failed

**Error**: "SQLSTATE[HY000]: General error: 2054" or "Connection refused"

- **Solution**:
  - Open XAMPP Control Panel
  - Click "START" next to MySQL service
  - Wait for it to show "Running" (not just "Starting")
  - Check credentials in `qft-deployment/.env`
  - Default XAMPP: `DB_USER=root` with no password
  - Verify database exists: `quarryforce_db`

### Port 8000/3000 Already in Use

**Error**: "Address already in use"

- **Solution**:
  - Port 8000: Another PHP server might be running
    - Close other console windows
    - Or restart your computer
  - Port 3000: React dev server already running
    - Close the React console
    - Wait 5 seconds and restart

### React Build Issues

**Error**: "npm ERR!" or dependency errors

- **Solution**:
  - Delete node modules: `cd admin-dashboard && rmdir /s node_modules`
  - Delete lock file: `del package-lock.json`
  - Reinstall: `npm install`
  - Wait for completion (can take 2-5 minutes)

### HTTPS/SSL Errors

**Error**: "SSL_ERROR_RX_RECORD_TOO_LONG" or similar

- **Solution**:
  - Make sure you're using `http://` not `https://`
  - Local dev uses HTTP only
  - Frontend: http://localhost:3000
  - Backend: http://localhost:8000

### Database Query Errors

**Error**: "Table doesn't exist" or "Column not found"

- **Solution**:
  - Import database schema if needed
  - Check `qft-deployment/` for SQL files
  - Use phpMyAdmin to verify tables exist
  - Access: http://localhost/phpmyadmin

## Development Workflow

### Making Changes

1. **Backend (PHP)**:
   - Edit files in `qft-deployment/`
   - Restart PHP server (close and re-run script)
   - Changes take effect immediately

2. **Frontend (React)**:
   - Edit files in `admin-dashboard/src/`
   - Browser auto-reloads
   - No restart needed

### Testing API Endpoints

Use Postman or curl:

```bash
# Get all customers
curl http://localhost:8000/api/customers

# Get all reps
curl http://localhost:8000/api/admin/reps

# Get API status
curl http://localhost:8000/api/
```

## Accessing the Application

1. **Admin Dashboard**: http://localhost:3000
2. **API Documentation**: http://localhost:8000/api/
3. **Direct API Calls**: http://localhost:8000/api/customers

## Logs and Debugging

### Console Output

- Both PHP and React servers log to their respective console windows
- Check console for errors during development

### Database Logging

- Enable query logging in `qft-deployment/config.php` if available
- Check system logs for database errors

## Stopping Development Environment

### Windows

- Close the console windows for each server
- Or press Ctrl+C in each window

### macOS/Linux

- Press Ctrl+C to stop the script
- Both servers will be terminated

## Next Steps

After local testing is successful:

1. Run full test suite (if available)
2. Verify all API endpoints
3. Test customer management forms
4. Check mobile number display in rep screen
5. Deploy to staging environment

## Support

For issues or questions:

- Check the logs in console windows
- Review `.env` configuration
- Ensure all prerequisites are installed
- Check database connectivity
