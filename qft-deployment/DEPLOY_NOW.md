# Namecheap Deployment - Ready to Go! ✅

## 🚀 FINAL DEPLOYMENT CHECKLIST

### Files to INCLUDE in ZIP: qft-php-deploy.zip

**Core PHP Backend (MUST HAVE):**

- ✅ `api.php` (all endpoints)
- ✅ `index.php` (entry point)
- ✅ `config.php` (configuration)
- ✅ `Database.php` (DB wrapper)
- ✅ `Logger.php` (logging)

**Configuration & Routing (MUST HAVE):**

- ✅ `.htaccess` (Apache routing)
- ✅ `.env.template` (environment template)

**Frontend (MUST HAVE):**

- ✅ `admin/` folder (React dashboard build)
  - index.html
  - static/css/ (all CSS files)
  - static/js/ (all JS files)

**Infrastructure (MUST HAVE):**

- ✅ `uploads/` folder (empty OK)

**Documentation (RECOMMENDED):**

- ✅ `PHP_DEPLOYMENT_GUIDE.md` (detailed guide)
- ✅ `PHP_CONVERSION_COMPLETE.md` (status summary)
- ✅ `DEPLOYMENT_FOLDER_STRUCTURE.txt` (overview)
- ✅ `BACKUP_AND_LOGGING_GUIDE.md` (logging info)
- ✅ `LOGGING_TEST_CHECKLIST.md` (testing guide)
- ✅ `README.md` (general info)

---

### Files to EXCLUDE from ZIP (Do NOT Include)

**Node.js Files (NOT NEEDED):**

- ❌ `index.js` (old Node.js backend)
- ❌ `db.js` (old DB config)
- ❌ `package.json` (npm dependencies)
- ❌ `package-lock.json` (npm lock file)
- ❌ `node_modules/` folder (LARGE - delete locally first)

**Development Files (NOT NEEDED):**

- ❌ `.git/` (version control)
- ❌ `.gitignore` (VCS config)

**Backups (OPTIONAL):**

- ❌ `nodejs-backup/` folder (safe to include but takes space)
- ❌ `qft.zip` (old ZIP file)

**Old Diagnostic Guides (OPTIONAL):**

- ❌ `CLOUDLINUX_DIAGNOSTIC_GUIDE.md` (for Node.js only)
- ❌ `DEPLOYMENT_CHECKLIST.md` (outdated)
- ❌ `QUICK_START.md` (outdated)

---

## 📦 Creating the ZIP File

### Windows PowerShell Method:

```powershell
cd d:\quarryforce\qft-deployment

# Create ZIP with only necessary files
Compress-Archive -Path @(
  'api.php',
  'index.php',
  'config.php',
  'Database.php',
  'Logger.php',
  '.htaccess',
  '.env.template',
  'admin',
  'uploads',
  'PHP_DEPLOYMENT_GUIDE.md',
  'PHP_CONVERSION_COMPLETE.md',
  'DEPLOYMENT_FOLDER_STRUCTURE.txt',
  'BACKUP_AND_LOGGING_GUIDE.md',
  'LOGGING_TEST_CHECKLIST.md',
  'README.md'
) -DestinationPath 'qft-php-deploy.zip'

# Verify ZIP was created
dir qft-php-deploy.zip
```

### Manual (Windows/Mac):

1. Create new folder: `qft-php-for-upload`
2. Copy files listed under "INCLUDE" above
3. Right-click → Send to → Compressed folder
4. Rename to: `qft-php-deploy.zip`

### Linux/Mac Terminal:

```bash
cd ~/quarryforce/qft-deployment

zip -r qft-php-deploy.zip \
  api.php index.php config.php Database.php Logger.php \
  .htaccess .env.template admin uploads \
  PHP_DEPLOYMENT_GUIDE.md PHP_CONVERSION_COMPLETE.md \
  DEPLOYMENT_FOLDER_STRUCTURE.txt

# Verify
ls -lh qft-php-deploy.zip
```

---

## 🌐 Uploading to Namecheap (5 Steps)

### Step 1: Login to cPanel

- URL: `https://cpanel.valviyal.com`
- Username: your cPanel username
- Password: your cPanel password
- Click "Login"

### Step 2: Open File Manager

- cPanel Home → File Manager
- Navigate to: `/public_html/qft/`
  - (or create `qft` folder if it doesn't exist)

### Step 3: Upload ZIP File

- Click "Upload" button
- Select: `qft-php-deploy.zip` from your computer
- Wait for upload to complete

### Step 4: Extract ZIP

- Right-click `qft-php-deploy.zip`
- Select "Extract"
- Dialog appears → Click "Extract Files"
- Wait for extraction (should take < 10 seconds)
- Files are now in `/public_html/qft/`

### Step 5: Clean Up

- Right-click `qft-php-deploy.zip`
- Select "Delete" or "Move to Trash"
- Delete old Node.js files if present:
  - `index.js`
  - `db.js`
  - `package.json`

---

## ⚙️ Server Configuration (2 minutes)

### Create .env File

1. In File Manager, navigate to: `/public_html/qft/`
2. Click "Create New" → "File"
3. Name: `.env` (include the dot!)
4. Click "Create File"
5. Click "Edit" (pencil icon)
6. Paste your configuration:

```bash
NODE_ENV=production
DB_HOST=localhost
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=your_database_name
DB_PORT=3306
API_URL=https://valviyal.com/qft
FRONTEND_URL=https://valviyal.com/qft
LOGGING_ENABLED=true
LOG_LEVEL=INFO
```

**Where to get credentials:**

- cPanel → MySQL Databases → Your Database
- Find: Database name, Username, Password
- Host is always: `localhost`

7. Click "Save Changes"

### Update permissions:

1. Right-click `logs` folder → "Change Permissions"
2. Change to: `755` → Click "Change"
3. Right-click `uploads` folder → "Change Permissions"
4. Change to: `755` → Click "Change"

---

## ✅ Testing (Instant!)

### Test 1: Admin Dashboard

Open browser:

```
https://valviyal.com/qft
```

**Expected:** QuarryForce dashboard loads

- Top menu shows: Customers, Reps, Targets, Progress
- No blank page or errors

### Test 2: API Health Check

Open browser:

```
https://valviyal.com/qft/api/test
```

**Expected:** JSON response

```json
{
  "server": "Online",
  "database": "Connected",
  "version": "2.0.0"
}
```

### Test 3: Check Logs

1. File Manager → `/public_html/qft/logs/`
2. Should see: `app.log` file
3. Click to view - should contain JSON entries like:

```json
{"timestamp":"2026-03-05 14:30:45","level":"DEBUG","message":"Root endpoint accessed"}
{"timestamp":"2026-03-05 14:30:46","level":"INFO","message":"Database connected"}
```

### Test 4: API Login Endpoint (Optional - use Postman/curl)

```bash
curl -X POST https://valviyal.com/qft/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email":"demo@quarryforce.local",
    "device_uid":"test-device-12345"
  }'
```

**Expected:** JSON response with user info

```json
{
  "success": true,
  "message": "Device registered successfully!",
  "user": {
    "id": 1,
    "name": "Demo Rep",
    "email": "demo@quarryforce.local",
    "role": "rep"
  }
}
```

---

## 🎯 Common Issues & Quick Fixes

### "Cannot GET /api/..."

**Problem:** API endpoints return 404
**Fix:**

- Check `.htaccess` file exists
- Check rewrite rules have correct path
- Clear browser cache (Ctrl+Shift+R)
- Wait 5 minutes for .htaccess to take effect

### API works but admin dashboard is blank

**Problem:** White page with no content
**Fix:**

- Open browser console (F12)
- Check Network tab for 404 on CSS/JS files
- Ensure `admin/static/` folders exist
- Hard refresh: Ctrl+Shift+R

### Database connection error

**Problem:** Error accessing users or customer data
**Fix:**

- Verify DB credentials in .env
- Go to: cPanel → MySQL Databases
- Copy exact username, password, database name
- Paste into .env file
- Save

### Can't create .env file

**Problem:** File Manager doesn't allow .env creation
**Fix:**

- Create as `env.txt` first
- Rename to `.env`
- Or use SSH if available:
  ```bash
  cd /public_html/qft
  cp .env.template .env
  nano .env  # edit credentials
  ```

---

## 📱 Mobile App Integration

Update Flutter app to use new PHP API:

**Old URL (Node.js):**

```dart
const String API_URL = 'https://valviyal.com/qft';
```

**New URL (PHP):**

```dart
const String API_URL = 'https://valviyal.com/qft/api';
```

All endpoints remain the same - just add `/api` prefix.

---

## 📋 Post-Deployment Checklist

- [ ] Dashboard loads without errors
- [ ] API test endpoint returns JSON
- [ ] app.log file contains entries
- [ ] No 404 errors in browser console
- [ ] Demo user can login
- [ ] Check logs for DB connection success
- [ ] Mobile app API URL updated
- [ ] Test at least one mobile feature

---

## 📊 What's Included

```
PHP Backend:          1,247 lines (api.php)
Database Layer:         120 lines (Database.php)
Configuration:           75 lines (config.php)
Logging System:         450 lines (Logger.php)
Entry Point:            62 lines (index.php)
Apache Routing:        ~50 lines (.htaccess)

Total PHP Code:     ~2,000 lines
Total Docs:         ~2,500 lines
Total Size:         <5MB (without node_modules!)

Original Node.js:   ~950 lines + npm dependencies
Node Backup Size:   ~35MB (with node_modules)
```

---

## 🔒 Security Checklist

- ✅ Prepared statements (SQL injection safe)
- ✅ Environment variables (credentials not in code)
- ✅ CORS properly configured
- ✅ Device binding (prevents unauthorized access)
- ✅ Territory protection (customer assignment)
- ✅ HTTPS enabled (domain requirement)
- ✅ Logs don't store sensitive data
- ✅ Error messages don't expose database

---

## ⚡ Performance Notes

- Logging adds ~1-2ms per request
- .htaccess caching enabled (CSS/JS cached 1 month)
- gzip compression enabled
- JSON responses are minimal
- No external API calls
- Database queries optimized

---

## 📞 If Something Goes Wrong

### Check These (in order):

1. **Browser Console (F12)**
   - JavaScript errors?
   - Network tab shows 404s?

2. **cPanel Error Log**
   - Path: Logs → Error Log
   - Any PHP errors?

3. **App Log**
   - Path: /public_html/qft/logs/app.log
   - Any error entries?

4. **File Permissions**
   - logs: 755?
   - uploads: 755?
   - .env readable?

5. **Database Credentials**
   - Test in cPanel phpMyAdmin
   - Are they correct?

### Get Support

Email with:

- Error messages from cPanel Error Log
- Relevant entries from logs/app.log
- Your .env configuration (hide password!)
- Steps you've already tried

---

## 🎉 You're Deployed!

Once everything passes testing, you're live in production!

**Next steps:**

1. Monitor logs for first week
2. Update mobile app with new API URL
3. Import test data if needed
4. Train users on new features
5. Monitor system performance

---

**PHP Backend Version:** 2.0.0
**Status:** Production Ready
**Last Updated:** March 5, 2026
**Estimated Deploy Time:** 5-10 minutes
