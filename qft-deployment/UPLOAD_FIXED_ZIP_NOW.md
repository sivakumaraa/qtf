# 📤 UPLOAD FIXED ZIP - Step by Step

## ⚡ Quick Version (2 minutes)

Navigate to: **cPanel → File Manager → /public_html/qft/**

```
1. Delete: qft-php-deploy.zip
2. Delete: api.php
3. Upload: d:\quarryforce\qft-deployment\qft-php-deploy.zip
4. Right-click → Extract
5. Wait 2 minutes
6. Test: https://valviyal.com/qft/api/login
```

Done! Login should work now.

---

## 📋 Detailed Steps

### Step 1: Login to cPanel

**Go to:** `https://valviyal.com:2083/`

- **Username:** Your cPanel username
- **Password:** Your cPanel password
- Click: **Login**

---

### Step 2: Open File Manager

**In cPanel Dashboard:**

- Find: **File Manager** (or search for it)
- Click to open

---

### Step 3: Navigate to /qft/ Folder

**In File Manager:**

1. Click: **Home Folder** (top navigation)
2. Open: **public_html** (double-click)
3. Open: **qft** (double-click)

**You should see:**

```
.htaccess
admin/
api.php
config.php
Database.php
index.php
Logger.php
uploads/
docs/
qft-php-deploy.zip (if present)
```

---

### Step 4: Delete Old Files

**First, delete old ZIP (if it exists):**

1. Right-click: `qft-php-deploy.zip`
2. Click: **Delete**
3. Confirm: **Yes, Delete**

**Second, delete old api.php:**

1. Right-click: `api.php`
2. Click: **Delete**
3. Confirm: **Yes, Delete**

---

### Step 5: Upload New ZIP

**In File Manager (still in /public_html/qft/):**

1. Click: **Upload** button (top toolbar)
2. Click: **Select File**
3. Navigate to: `d:\quarryforce\qft-deployment\`
4. Select: `qft-php-deploy.zip`
5. Click: **Open**
6. Wait for "Transfer Complete" message

**You should see:**

```
qft-php-deploy.zip ... 100% ... Complete ✅
```

---

### Step 6: Extract ZIP in cPanel

**Back in File Manager:**

1. Right-click: `qft-php-deploy.zip`
2. Click: **Extract**
3. Click: **Extract Files** (in popup)
4. Wait for completion message

**You should now see:**

```
.htaccess (overwritten with updates)
admin/ (updated)
api.php (NEW - with fix!)
config.php (updated)
Database.php (updated)
index.php (updated)
Logger.php (updated)
uploads/ (empty)
[extracted: qft-php-deploy.zip]
```

---

### Step 7: Clean Up (Optional)

**Delete the ZIP file after extracting:**

1. Right-click: `qft-php-deploy.zip`
2. Click: **Delete**
3. Confirm: **Yes, Delete**

---

### Step 8: Wait for Apache to Reload

⏳ **Wait 2-3 minutes** for Apache to recognize the new `.htaccess` file.

**Normal delay - Apache caches config files**

---

## ✅ Verify Upload Success

### Test 1: Check Dashboard Still Loads

```
Open: https://valviyal.com/qft
Expected: Admin dashboard loads with styling ✅
```

If dashboard doesn't load, .htaccess might have issues.

---

### Test 2: Test Health Check

```
Open: https://valviyal.com/qft/api/test
Expected: JSON response with server status ✅
```

---

### Test 3: Test Login Endpoint (THE FIX!)

**Using Postman or curl:**

```bash
curl -X POST https://valviyal.com/qft/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@quarryforce.local","device_uid":"test-123"}'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Device registered successfully!",
  "user": {
    "id": 1,
    "name": "Demo User",
    "email": "demo@quarryforce.local",
    "role": "rep"
  }
}
```

**If you get:**

```json
{
  "success": true,
  "message": "Demo API response (database error)"
}
```

✅ **The routing is fixed!** (just need to populate database)

---

## 🚨 Troubleshooting

### File says "Transfer Failed"

**Possible causes:**

- ZIP file too large (but ours is only 1MB, should be fine)
- Connection timeout
- cPanel session expired

**Solution:**

1. Logout of cPanel
2. Clear browser cache: `Ctrl + Shift + Delete`
3. Login again and retry upload

---

### Dashboard won't load or shows 404

**Likely cause:** Apache hasn't reloaded yet

**Solution:**

1. Wait another 2 minutes
2. Hard refresh: `Ctrl + Shift + R`
3. Check that `.htaccess` was extracted (not just ZIP)

---

### Login still returns "Endpoint not found"

**Check 1:** Was the NEW ZIP uploaded? (with 16:49:18 timestamp)

**Check 2:** Was api.php actually extracted?

- In File Manager, click `api.php`
- Should see fallback code around line 49-57
- Search for: `$_GET['request']`

**Check 3:** Revert and try manual edit instead

- See: `FIX_LOGIN_ENDPOINT.md` → Option B

---

## 📊 Files in Updated ZIP

Latest ZIP contains:

- ✅ `api.php` - WITH fallback parameter fix
- ✅ `.htaccess` - WITH optional path regex
- ✅ `config.php` - Database config
- ✅ `Database.php` - PDO wrapper
- ✅ `Logger.php` - Logging system
- ✅ `index.php` - Router
- ✅ `admin/` - React dashboard (pre-built)
- ✅ `uploads/` - Empty folders for user files
- ✅ `.env.template` - Environment setup guide

---

## 🎯 After Upload Success

Once login endpoint works:

1. **Update Database** (if needed)
   - Add test user: demo@quarryforce.local
   - Run: `REP_TARGETS_SETUP.sql` for sample data

2. **Test Other Endpoints**
   - `/api/checkin` - Location checkin
   - `/api/visit/submit` - Visit submission
   - `/admin/reps` - Fetch reps list

3. **Dashboard Testing**
   - Login in browser
   - Test: Customers, Reps, Targets, Progress menus
   - Verify data loads from API

4. **Mobile App** (if applicable)
   - Rebuild Flutter app with new API URL
   - Point to: `https://valviyal.com/qft/api`
   - Sign test user and verify functionality

---

## ✨ You're Almost Done!

The fix is already in the ZIP.  
Just upload and test. That's it!

**Expected result:** Full production system with:

- ✅ Admin dashboard working
- ✅ API endpoints routing correctly
- ✅ Login and all endpoints functional

---

**Questions?** Check `FIX_LOGIN_ENDPOINT.md` for detailed explanation.

Good luck! 🚀
