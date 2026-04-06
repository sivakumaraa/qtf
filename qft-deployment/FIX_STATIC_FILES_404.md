# 🔧 STATIC FILES 404 FIX - QUICK RESOLUTION

## Problem Description

You see these errors in browser console (F12):

```
Failed to load resource: the server responded with a status of 404
main.a6d5cb41.js - Refused to execute script - MIME type 'application/json'
main.2288aed2.css - Refused to apply style - MIME type is not a supported stylesheet
```

**What this means:** The dashboard HTML loads, but CSS/JS files are returning 404 errors.

---

## Root Cause

The `.htaccess` Apache rewrite rules were processing static file requests (CSS/JS) as API routes, causing them to be rewritten incorrectly.

**What went wrong:**

- Old .htaccess checked for existing files AFTER processing API routes
- This allowed static file requests to be caught by API rewrite rules
- Static files got rewritten to `api.php?request=...`
- API returned JSON instead of CSS/JS files

---

## Solution: Update .htaccess (5 minutes)

### Option A: Re-upload ZIP with Fixed .htaccess (Easiest) ⭐ RECOMMENDED

**The ZIP file has been updated!** Just re-upload it:

1. **In Namecheap cPanel File Manager:**
   - Navigate to `/public_html/qft/`
   - Delete the old ZIP file (if still there)
   - Delete the old `.htaccess` file
2. **Upload the NEW ZIP:**
   - Location: `d:\quarryforce\qft-deployment\qft-php-deploy.zip`
   - This has the corrected `.htaccess` with rules in the right order

3. **Extract:**
   - Right-click → Extract → Extract Files
   - Wait for completion

4. **Test:**
   - Hard refresh: `Ctrl + Shift + R`
   - Go to: `https://valviyal.com/qft`
   - Dashboard should now load with CSS/JS working!

---

### Option B: Manually Fix .htaccess (If you prefer not to re-upload ZIP)

1. **In File Manager, edit `.htaccess`:**
   - Navigate to `/public_html/qft/`
   - Click pencil icon next to `.htaccess`

2. **Replace entire contents with this:**

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /qft/

  # Set default index file
  DirectoryIndex index.php index.html

  # IMPORTANT: Don't rewrite existing files or directories (must be FIRST!)
  RewriteCond %{REQUEST_FILENAME} -f [OR]
  RewriteCond %{REQUEST_FILENAME} -d
  RewriteRule ^ - [L]

  # API routes - pass to api.php (only for /api calls)
  RewriteCond %{REQUEST_URI} ^/qft/api [NC]
  RewriteRule ^api/(.*)$ /qft/api.php?request=$1 [QSA,L]

  # Admin API routes - pass to api.php for handling
  RewriteCond %{REQUEST_URI} ^/qft/admin [NC]
  RewriteCond %{REQUEST_URI} !/qft/static/ [NC]
  RewriteRule ^admin/(.*)$ /qft/api.php?request=admin/$1 [QSA,L]

  # React admin dashboard - route to index.html (catch-all)
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ /qft/admin/index.html [QSA,L]

</IfModule>

# Compression
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# Cache control
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType text/javascript "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType font/woff "access plus 1 year"
  ExpiresByType font/woff2 "access plus 1 year"
</IfModule>
```

3. **Click "Save Changes"**

4. **Wait 5 minutes** for Apache to reload the configuration

5. **Test:**
   - Hard refresh: `Ctrl + Shift + R`
   - Go to: `https://valviyal.com/qft`
   - CSS/JS should now load successfully!

---

## Key Changes in Fixed .htaccess

### ✅ What was fixed:

**Before (WRONG):**

```apache
# API routes first
RewriteCond %{REQUEST_URI} ^/qft/api [NC]
RewriteRule ^(.*)$ /qft/api.php?request=$1 [QSA,L]

# Then check for existing files (TOO LATE!)
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
```

**After (CORRECT):**

```apache
# Check for existing files FIRST!
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Then process API routes
RewriteCond %{REQUEST_URI} ^/qft/api [NC]
RewriteRule ^api/(.*)$ /qft/api.php?request=$1 [QSA,L]
```

**Why this matters:**

- Apache processes rewrite rules TOP-TO-BOTTOM
- If we check "does this file exist?" BEFORE trying to rewrite, we skip static files
- Static files (CSS, JS, images) are left alone
- Only actual API/Admin routes get rewritten to PHP

---

## ✅ After the Fix

**You should see:**

- ✅ Dashboard HTML loads
- ✅ CSS styles applied (blue header, proper colors)
- ✅ JS functionality works (menu clicks, etc.)
- ✅ NO 404 errors in console
- ✅ NO MIME type warnings

**Test URLs:**

1. `https://valviyal.com/qft` → Dashboard fully styled ✅
2. `https://valviyal.com/qft/api/test` → Returns JSON ✅
3. Browser console (F12) → No red errors ✅

---

## 🚨 If It Still Doesn't Work After Fix

### Step 1: Clear Browser Cache

```
Ctrl + Shift + Delete
- Check: JavaScript files, CSS files, Images
- Click: Clear data
```

### Step 2: Hard Refresh

```
Ctrl + Shift + R (Windows)
Command + Shift + R (Mac)
```

### Step 3: Check Apache Module

In cPanel:

1. Search for "Apache Modules"
2. Look for: `mod_rewrite`
3. Should be **enabled** (checked)
4. If not, enable it and restart Apache

### Step 4: Verify File Structure

In File Manager, `/public_html/qft/` should have:

- ✅ api.php
- ✅ index.php
- ✅ .htaccess (this is the file we fixed)
- ✅ admin/ folder
- ✅ admin/index.html
- ✅ admin/static/ folder (contains CSS/JS)

---

## 📝 Summary

| Action       | What It Does                                       |
| ------------ | -------------------------------------------------- |
| **Option A** | Re-upload ZIP (includes fixed .htaccess)           |
| **Option B** | Manually edit .htaccess on server                  |
| **Result**   | Static files load, CSS/JS work, dashboard displays |
| **Time**     | 5 minutes                                          |

---

## 🎯 Next Steps

1. **Choose Option A or B** above to apply the fix
2. **Wait 5 minutes** for Apache to reload
3. **Hard refresh:** `Ctrl + Shift + R`
4. **Test:** `https://valviyal.com/qft`
5. **Verify:** Dashboard loads with styling and no console errors

---

## 📞 If You Need More Help

- See: `UPLOAD_AND_TEST.md` - General troubleshooting
- See: `PHP_DEPLOYMENT_GUIDE.md` - Detailed Apache/cPanel help
- Check: Browser console (F12) for specific error messages

---

**Status:** Fixed ✅
**Date:** March 5, 2026
**Next:** Test dashboard loading with CSS/JS
