# 📱 Deploy Flutter Web App to Namecheap at /mobile Route

Complete guide to deploy the Flutter web version to Namecheap so field reps can access it at a separate URL.

---

## 🎯 Final URLs After Deployment

```
Admin Dashboard: https://valviyal.com/qft
Field Rep App:  https://valviyal.com/qft/mobile
```

---

## 📋 Step 1: Build Flutter Web App

**On your computer:**

```powershell
cd d:\quarryforce\quarryforce_mobile

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build for web
flutter build web
```

**Expected output:**

```
✓ Built build/web successfully
```

---

## 📂 Step 2: Prepare Files for Upload

The Flutter web build is in: `build/web/`

**You'll upload everything from `build/web/` to Namecheap at `/public_html/qft/mobile/`**

---

## 📦 Step 3: Create ZIP for Upload

**Option A: Using PowerShell**

```powershell
cd d:\quarryforce\quarryforce_mobile\build\web

# Create ZIP
Compress-Archive -Path . -DestinationPath "d:\quarryforce\qft-mobile-web.zip" -Force

Write-Host "ZIP created: d:\quarryforce\qft-mobile-web.zip"
```

**Option B: Using Windows Explorer**

1. Open: `d:\quarryforce\quarryforce_mobile\build\web\`
2. Select all files (Ctrl + A)
3. Right-click → Send to → Compressed folder
4. Rename to: `qft-mobile-web.zip`

---

## 🚀 Step 4: Upload to Namecheap

### Step 4.1: Login to cPanel

```
https://valviyal.com:2083
Username: [your cPanel username]
Password: [your cPanel password]
```

### Step 4.2: Navigate to /public_html/qft/

**File Manager:**

1. Click: **File Manager**
2. Navigate: **public_html** → **qft**

### Step 4.3: Create /mobile Folder

In `/qft/` folder:

1. Right-click → **Create New Folder**
2. Name: `mobile`
3. Click: **Create**

### Step 4.4: Upload ZIP

**In `/qft/mobile/` folder:**

1. Click: **Upload**
2. Select: `qft-mobile-web.zip`
3. Wait for "Transfer Complete"

### Step 4.5: Extract ZIP

1. Right-click: `qft-mobile-web.zip`
2. Click: **Extract**
3. Click: **Extract Files**
4. Wait for completion

### Step 4.6: Verify Files

After extraction, you should see in `/qft/mobile/`:

```
index.html
main.dart.js
flutter.js
flutter_service_worker.js
[other Flutter files]
```

---

## 🔧 Step 5: Configure .htaccess for /mobile Route

**In `/qft/` folder:**

**Edit:** `.htaccess` file

**Add this section** (after the existing rules):

```apache
# Mobile app routing
RewriteCond %{REQUEST_URI} ^/qft/mobile [NC]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(mobile)(.*)$ /qft/mobile/index.html [L]
```

**Full .htaccess should look like:**

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /qft/

  # Static files - don't rewrite
  RewriteCond %{REQUEST_FILENAME} -f
  RewriteCond %{REQUEST_FILENAME} -d
  RewriteRule ^ - [L]

  # API routes
  RewriteCond %{REQUEST_URI} ^/qft/api [NC]
  RewriteRule ^api(.*)$ /qft/api.php?request=api$1 [L]

  # Admin routes
  RewriteCond %{REQUEST_URI} ^/qft/admin [NC]
  RewriteRule ^admin(.*)$ /qft/api.php?request=admin$1 [L]

  # React admin dashboard (root)
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ /qft/admin/index.html [L]

  # Mobile Flutter web app
  RewriteCond %{REQUEST_URI} ^/qft/mobile [NC]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^mobile(.*)$ /qft/mobile/index.html [L]
</IfModule>
```

**Save the file.**

---

## ✅ Step 6: Test Deployment

### Test 1: Admin Dashboard Still Works

```
Open in browser: https://valviyal.com/qft
Expected: Admin dashboard loads ✅
```

### Test 2: Mobile App Loads

```
Open in browser: https://valviyal.com/qft/mobile
Expected: Flutter mobile app loads with login screen ✅
```

### Test 3: Mobile App Login

**On any phone or computer browser:**

```
1. Go to: https://valviyal.com/qft/mobile
2. Email: demo@quarryforce.local
3. Tap: Login
4. Expected: Dashboard loads ✅
```

### Test 4: Mobile App Features

```
1. Tap: Check In → Get Location → Submit
2. Tap: Record Visit → Select customer → Submit
3. Tap: Log Fuel → Enter data → Submit
4. Expected: All features work ✅
```

### Test 5: Verify Data in Admin

```
1. Go to: https://valviyal.com/qft (admin)
2. Check: Fuel Log → See mobile fuel entry
3. Check: Visit History → See mobile visit
Expected: Data syncs from mobile to admin ✅
```

---

## 🌐 Testing URLs

After deployment, you have:

| User          | URL                               |
| ------------- | --------------------------------- |
| **Admin**     | `https://valviyal.com/qft`        |
| **Field Rep** | `https://valviyal.com/qft/mobile` |
| **API**       | `https://valviyal.com/qft/api/*`  |

---

## 📱 Share with Field Reps

Once tested, give field reps this bookmark:

```
https://valviyal.com/qft/mobile
```

They open it on their phone → Login → Use the app!

---

## 🔗 Complete Architecture

After this deployment:

```
https://valviyal.com/qft/
├── / (root)
│   └── Admin Dashboard (React)
│       └── HTML/CSS/JS from admin/
│
├── /api
│   └── Backend API (PHP)
│       └── All endpoints: login, checkin, visit, fuel, etc.
│
├── /mobile
│   └── Field Rep App (Flutter Web)
│       └── HTML/CSS/JS from build/web/
│
└── /admin/static
    └── Dashboard assets (CSS, JS, images)
```

---

## 🚨 Troubleshooting

### Issue: /mobile shows 404

**Solution:**

1. Verify `/mobile/index.html` exists in Namecheap
2. Check .htaccess rewrite rule is correct
3. Wait 5 minutes for cPanel to reload config

---

### Issue: /mobile shows admin dashboard

**Solution:**

1. Clear browser cache: `Ctrl + Shift + Delete`
2. Try incognito/private window
3. Verify `/mobile/` folder contains Flutter files, not admin files

---

### Issue: Mobile app loads but API calls fail

**Solution:**

1. Check app API URL is: `https://valviyal.com/qft/api`
2. Already configured in `lib/config/constants.dart`
3. Test API directly: `https://valviyal.com/qft/api/test`

---

## 📊 Deployment Checklist

```
[ ] flutter build web completed
[ ] qft-mobile-web.zip created
[ ] /mobile folder created in Namecheap
[ ] ZIP uploaded to /mobile/
[ ] ZIP extracted
[ ] index.html visible in /mobile/
[ ] .htaccess updated with mobile route
[ ] https://valviyal.com/qft still works (admin)
[ ] https://valviyal.com/qft/mobile loads (mobile app)
[ ] Login works on mobile app
[ ] Features work (checkin, visit, fuel)
[ ] Data syncs to admin dashboard
```

---

## ⏱️ Time Estimate

- Build Flutter web: 5 min
- Create ZIP: 1 min
- Upload to Namecheap: 5 min
- Extract: 2 min
- Configure .htaccess: 2 min
- Test: 5 min
- **Total: 20 minutes**

---

## 🎉 After This is Done

You'll have:

- ✅ Admin dashboard at one URL
- ✅ Field rep app at another URL
- ✅ Both connecting to same API
- ✅ Data syncing perfectly
- ✅ Production-ready system

**Ready to deploy?** Start with Step 1! 🚀
