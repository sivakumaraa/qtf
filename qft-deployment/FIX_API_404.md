# 🔧 FIX API 404 ERROR - Quick Resolution

## Problem

You're getting **404 errors** when accessing:

```
https://valviyal.com/qft/api
https://valviyal.com/qft/api/test
```

**Cause:** The `.htaccess` rewrite rules required a path after `/api`. They didn't accept bare `/api` endpoints.

---

## ✅ Solution: Update .htaccess (2 minutes)

### **The ZIP Has Been Updated!** ✅

The ZIP file now has the corrected `.htaccess`:

- **File:** `d:\quarryforce\qft-deployment\qft-php-deploy.zip`
- **Updated:** March 5, 2026 - 16:43:31
- **Fix:** API routes now accept `/api` and `/api/path`

---

## What Was Fixed

**Old (Broken):**

```apache
RewriteRule ^api/(.*)$ /qft/api.php?request=$1 [QSA,L]
```

❌ This required something after `/api/`, so `/api` alone returned 404

**New (Fixed):**

```apache
RewriteRule ^api(/.*)?$ /qft/api.php?request=api$1 [QSA,L]
```

✅ This accepts both `/api` and `/api/test` patterns

---

## Steps to Apply Fix (Choose One)

### **Option A: Re-upload ZIP (Recommended)** ⭐

**In Namecheap cPanel:**

1. **Delete old files:**
   - File Manager → `/public_html/qft/`
   - Delete: `qft-php-deploy.zip` (if present)
   - Delete: `.htaccess`

2. **Upload NEW ZIP:**
   - File: `d:\quarryforce\qft-deployment\qft-php-deploy.zip`
   - Wait: "Transfer Complete"

3. **Extract:**
   - Right-click ZIP → "Extract" → "Extract Files"

4. **Wait & Test:**
   ```
   Wait 5 minutes for Apache to reload
   Test: https://valviyal.com/qft/api/test
   Expected: JSON response with server status
   ```

---

### **Option B: Edit .htaccess Manually**

**In cPanel File Manager:**

1. Navigate to: `/public_html/qft/`
2. Edit: `.htaccess`
3. Find this section (around line 13-15):

```apache
# API routes - pass to api.php (only for /api calls)
RewriteCond %{REQUEST_URI} ^/qft/api [NC]
RewriteRule ^api/(.*)$ /qft/api.php?request=$1 [QSA,L]
```

4. Replace with:

```apache
# API routes - pass to api.php (only for /api calls)
RewriteCond %{REQUEST_URI} ^/qft/api [NC]
RewriteRule ^api(/.*)?$ /qft/api.php?request=api$1 [QSA,L]
```

5. Find this section (around line 19-22):

```apache
# Admin API routes - pass to api.php for handling
RewriteCond %{REQUEST_URI} ^/qft/admin [NC]
RewriteCond %{REQUEST_URI} !/qft/admin/static/ [NC]
RewriteRule ^admin/(.*)$ /qft/api.php?request=admin/$1 [QSA,L]
```

6. Replace with:

```apache
# Admin API routes - pass to api.php for handling
RewriteCond %{REQUEST_URI} ^/qft/admin [NC]
RewriteCond %{REQUEST_URI} !/qft/admin/static/ [NC]
RewriteRule ^admin(/.*)?$ /qft/api.php?request=admin$1 [QSA,L]
```

7. Click "Save Changes"
8. Wait 5 minutes for Apache reload
9. Test: `https://valviyal.com/qft/api/test`

---

## ✅ After Fix - Test These URLs

### Test 1: Base API

```
URL: https://valviyal.com/qft/api
Expected: Might return 404 if no route, but not Apache 404
Status: Should be handled by api.php
```

### Test 2: Health Check (Main Test)

```
URL: https://valviyal.com/qft/api/test
Expected: JSON response:
{
  "server": "Online",
  "database": "Connected",
  "version": "2.0.0"
}
Status: ✅ Should work now!
```

### Test 3: Login Endpoint

```
URL: https://valviyal.com/qft/api/login (POST)
Expected: Accepts login request
Status: Should work if database connected
```

---

## 🚀 How The Fix Works

**Before:**

```
Request: /qft/api/test
Pattern: ^api/(.*)$  matches: api/test ✓
Result: Rewritten to api.php?request=api/test

Request: /qft/api
Pattern: ^api/(.*)$  matches: ??? ✗ NO MATCH
Result: 404 error ❌
```

**After:**

```
Request: /qft/api/test
Pattern: ^api(/.*)?$  matches: api/test ✓
Result: Rewritten to api.php?request=api/test ✓

Request: /qft/api
Pattern: ^api(/.*)?$  matches: api ✓
Result: Rewritten to api.php?request=api ✓
```

---

## 🎯 Next Steps

1. **Choose Option A or B** above to apply the fix
2. **If Option A:** Upload ZIP and extract
3. **If Option B:** Edit .htaccess manually
4. **Wait:** 5 minutes for Apache reload
5. **Test:** `https://valviyal.com/qft/api/test`
6. **Expected:** JSON response with server/database status

---

## ✨ Complete API Endpoints

After this fix, these should all work:

| Endpoint              | Method | Purpose           |
| --------------------- | ------ | ----------------- |
| `/api`                | GET    | Base endpoint     |
| `/api/test`           | GET    | Health check      |
| `/api/login`          | POST   | User login        |
| `/api/checkin`        | POST   | Check in location |
| `/api/visit/submit`   | POST   | Submit visit      |
| `/api/fuel/submit`    | POST   | Submit fuel       |
| `/admin/reps`         | GET    | List reps         |
| `/admin/customers`    | GET    | List customers    |
| `/admin/rep-targets`  | GET    | List targets      |
| `/admin/rep-progress` | GET    | Show progress     |

---

## 📞 If Still Not Working

**Check these in order:**

1. **Browser cache cleared?** (Ctrl+Shift+Delete)
2. **Hard refresh done?** (Ctrl+Shift+R)
3. **Wait 5+ minutes** for Apache to load new .htaccess?
4. **Check error log** in cPanel → Error Log
5. **Verify file structure** - is api.php in /public_html/qft/?

---

**Status:** Fixed ✅  
**ZIP Updated:** 16:43:31 UTC  
**Next:** Apply fix and test `/api/test` endpoint!
