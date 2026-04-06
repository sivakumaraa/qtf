# 🚀 Option A Deployment - Quick Start

Your deployment plan for separating admin and mobile app:

```
Admin Dashboard: https://valviyal.com/qft
Field Rep App:  https://valviyal.com/qft/mobile
```

---

## ⚡ Quick Steps (20 minutes)

### Step 1: Build Flutter Web (5 min)

Open PowerShell in your QuarryForce folder and run:

```powershell
cd d:\quarryforce
.\build-and-deploy-flutter-web.ps1
```

This script will:

- Clean the build
- Get dependencies
- Build Flutter web (takes 2-5 min)
- Create `qft-mobile-web.zip`

⏱️ **Wait for it to complete** - you'll see: `✅ BUILD COMPLETE!`

---

### Step 2: Upload to Namecheap (10 min)

1. **Login to cPanel:**

   ```
   https://valviyal.com:2083
   ```

2. **Go to File Manager → public_html → qft**

3. **Create folder:** `mobile`

4. **Upload ZIP:**
   - Drag `qft-mobile-web.zip` from your computer
   - Or use File Manager's Upload button

5. **Extract ZIP:**
   - Right-click ZIP file
   - Click "Extract"
   - Confirm

6. **Verify:** You should see in `/qft/mobile/`:
   ```
   index.html
   main.dart.js
   flutter.js
   [other files]
   ```

---

### Step 3: Update .htaccess (Already Done!)

✅ The `.htaccess` file has already been updated with `/mobile` routing!

**What was added:**

```apache
# Mobile app routing (Flutter web)
RewriteCond %{REQUEST_URI} ^/qft/mobile [NC]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^mobile(.*)$ /qft/mobile/index.html [QSA,L]
```

---

### Step 4: Test Both URLs (5 min)

**Test Admin (should still work):**

```
https://valviyal.com/qft
Expected: Admin dashboard with login
```

**Test Mobile (new):**

```
https://valviyal.com/qft/mobile
Expected: Mobile app with login screen
```

**Test Login on Mobile:**

```
Email: demo@quarryforce.local
Password: demo123
Expected: Dashboard loads ✅
```

---

## 📱 After Deployment

Share this link with field reps:

```
https://valviyal.com/qft/mobile
```

They can:

- ✅ Bookmark it
- ✅ Open from any phone/tablet
- ✅ Log in and start using the app
- ✅ All data syncs to your admin dashboard

---

## 🆘 Troubleshooting

| Issue                         | Solution                                                |
| ----------------------------- | ------------------------------------------------------- |
| "404 Not Found" on /mobile    | Wait 5 min, clear cache (Ctrl+Shift+Del), try incognito |
| Shows admin dashboard instead | Check /mobile/index.html exists in Namecheap            |
| API errors on mobile app      | URL already configured correctly, check network         |
| ZIP won't extract             | Try extracting again, or re-upload ZIP                  |

---

## 📚 Full Documentation

For detailed step-by-step instructions, see:

```
d:\quarryforce\qft-deployment\DEPLOY_FLUTTER_WEB_TO_NAMECHEAP.md
```

---

## ✅ Deployment Checklist

Track your progress:

```
[ ] Run build-and-deploy-flutter-web.ps1 script
[ ] Wait for "BUILD COMPLETE" ✅
[ ] ZIP file created (qft-mobile-web.zip)
[ ] Login to cPanel (valviyal.com:2083)
[ ] Create /qft/mobile folder
[ ] Upload ZIP to /qft/mobile/
[ ] Extract ZIP
[ ] Verify index.html exists in /qft/mobile/
[ ] .htaccess updated (already done! ✅)
[ ] Test https://valviyal.com/qft (admin)
[ ] Test https://valviyal.com/qft/mobile (mobile)
[ ] Login to admin dashboard
[ ] Login to mobile app
[ ] Test mobile features (checkin, visit, fuel)
[ ] Share https://valviyal.com/qft/mobile with reps
```

---

## 🎯 Result

You'll have a production system with:

- ✅ Admin dashboard at one URL
- ✅ Mobile app at separate URL
- ✅ Both accessing same API
- ✅ Data syncing perfectly
- ✅ Field reps can use from any device

**Ready?** Start with Step 1! 🚀

---

**Questions?** See the detailed guide:
`DEPLOY_FLUTTER_WEB_TO_NAMECHEAP.md`
