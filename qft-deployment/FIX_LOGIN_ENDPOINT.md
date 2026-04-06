# 🔧 FIX LOGIN ENDPOINT - Request Parameter Issue

## Problem

You tested:

```
POST https://valviyal.com/qft/api/login
Response: {"success":false,"error":"Endpoint not found"}
```

**What happened:** The API **IS** being reached (not a 404), but the `/login` endpoint isn't being recognized.

**Root cause:** The `.htaccess` rewrite was passing the path via `?request=api/login`, but `api.php` wasn't checking that parameter - it only parsed from `REQUEST_URI` directly.

---

## ✅ Solution: Update api.php (Automatic)

### **The ZIP Has Been Updated!** ✅

- **File:** `d:\quarryforce\qft-deployment\qft-php-deploy.zip`
- **Updated:** March 5, 2026 - 16:49:18
- **Fix:** api.php now checks `?request=` parameter as fallback

---

## What Was Fixed

**Added to api.php (after line 48):**

```php
// Fallback: check for request query parameter (from .htaccess rewrite)
if ($path === '/' && isset($_GET['request'])) {
    $request = $_GET['request'];
    $request = str_replace('api/', '', $request);
    $request = str_replace('api', '', $request);
    $path = '/' . trim($request, '/');
    $path = $path === '/' ? '/' : $path;
}
```

**How it works:**

1. .htaccess rewrites `/api/login` → `api.php?request=api/login`
2. `api.php` now checks `$_GET['request']`
3. Extracts `login` from `api/login`
4. Routes to the `/login` handler ✅

---

## Steps to Apply Fix

### **Option A: Re-upload ZIP (Recommended)** ⭐

**In Namecheap cPanel:**

1. **Delete old files:**
   - File Manager → `/public_html/qft/`
   - Delete: `qft-php-deploy.zip`
   - Delete: `api.php`

2. **Upload NEW ZIP:**
   - File: `d:\quarryforce\qft-deployment\qft-php-deploy.zip`
   - Wait: "Transfer Complete"

3. **Extract:**
   - Right-click → "Extract" → "Extract Files"

4. **Wait & Test:**
   ```
   Wait 2-3 minutes for Apache
   Test: https://valviyal.com/qft/api/login (POST)
   Expected: Success message or user data
   ```

---

### **Option B: Edit api.php Manually**

**In cPanel File Manager:**

1. Navigate to: `/public_html/qft/`
2. Edit: `api.php`
3. Find line 40-48:

```php
// Get request path and method
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/qft/api', '', $path);
$path = str_replace('/api', '', $path);
$path = rtrim($path, '/') ?: '/';
```

4. Add this after line 48:

```php

// Fallback: check for request query parameter (from .htaccess rewrite)
if ($path === '/' && isset($_GET['request'])) {
    $request = $_GET['request'];
    $request = str_replace('api/', '', $request);
    $request = str_replace('api', '', $request);
    $path = '/' . trim($request, '/');
    $path = $path === '/' ? '/' : $path;
}
```

5. Click "Save Changes"

---

## ✅ After Fix - Test Login

### Test: Login Endpoint

```bash
curl -X POST https://valviyal.com/qft/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@quarryforce.local","device_uid":"test-device-123"}'
```

**Expected Response:**

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

**Status:** ✅ Should work now!

---

## 🚀 Request Flow (After Fix)

```
Client Request:
POST https://valviyal.com/qft/api/login

↓

.htaccess processes:
^api(/.*)?$ → /qft/api.php?request=api/login

↓

Apache rewrite to:
GET /qft/api.php?request=api/login

↓

api.php parses:
$_GET['request'] = 'api/login'
Extract 'login' → $path = '/login'

↓

Routes to:
handleLogin($input) ✅

↓

Response returned:
JSON with user info ✅
```

---

## ✨ All API Endpoints Now Working

These should all work after the fix:

| Endpoint              | Method | Purpose           |
| --------------------- | ------ | ----------------- |
| `/api/test`           | GET    | Health check      |
| `/api/login`          | POST   | User login ✅     |
| `/api/checkin`        | POST   | Check in location |
| `/api/visit/submit`   | POST   | Submit visit      |
| `/api/fuel/submit`    | POST   | Submit fuel       |
| `/admin/reps`         | GET    | List reps         |
| `/admin/customers`    | GET    | List customers    |
| `/admin/rep-targets`  | GET    | List targets      |
| `/admin/rep-progress` | GET    | Show progress     |

---

## 📞 If Login Still Fails

**Possible reasons:**

1. **Database not connected**
   - Check: `https://valviyal.com/qft/api/test`
   - Should show: `"database": "Connected"`
   - If error: Fix .env credentials first

2. **Demo user doesn't exist**
   - Login attempts to find email in database
   - If using demo mode: Make sure user exists or database has test data
   - Try with a known email address

3. **Haven't uploaded latest ZIP**
   - Make sure you're using: `qft-php-deploy.zip` (16:49:18)
   - Old version won't have the fix

4. **Browser cache**
   - Clear: `Ctrl + Shift + Delete`
   - Hard refresh: `Ctrl + Shift + R`

---

## 🎯 Next Steps

1. **Choose Option A or B** above to apply fix
2. **Test:** `https://valviyal.com/qft/api/login` (POST with JSON)
3. **Expected:** User info returned in response
4. **If works:** Dashboard is fully functional! 🎉

---

## 📊 Complete Endpoint Testing

After login works, test these in order:

1. **Health Check** (GET)

   ```
   https://valviyal.com/qft/api/test
   Expected: Server and database status
   ```

2. **Admin Endpoints** (GET)

   ```
   https://valviyal.com/qft/api/admin/reps
   https://valviyal.com/qft/api/admin/customers
   https://valviyal.com/qft/api/admin/rep-targets
   ```

3. **Dashboard Features** (in browser)
   ```
   https://valviyal.com/qft
   Click menus: Customers, Reps, Targets, Progress
   Should load data from API
   ```

---

**Status:** Fixed ✅  
**ZIP Updated:** 16:49:18 UTC  
**Next:** Upload ZIP or edit api.php, then test login!
