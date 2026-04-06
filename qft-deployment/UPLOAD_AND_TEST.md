# 🚀 UPLOAD & TEST GUIDE - QUICK REFERENCE

## 📋 CHECKLIST - 7 SIMPLE STEPS

---

## ✅ STEP 1: Get Database Credentials (2 minutes)

**From Namecheap cPanel:**

1. Login: `https://cpanel.valviyal.com`
2. Find: **MySQL Databases** (or search for "MySQL")
3. Look for your database - note down:
   - **Database Name:** `valviyal_quarryforce` (or your DB name)
   - **Username:** `valviyal_qf` (or your user)
   - **Password:** `(copy it exactly)`
   - **Host:** `localhost`

**Keep these handy for Step 5**

---

## ⬆️ STEP 2: Upload ZIP to Namecheap (3 minutes)

### 2.1 Open File Manager

1. From cPanel Home → Click **File Manager**
2. Navigate to: `/public_html/`
3. Create a new folder called `qft`:
   - Click "Create New" → "Folder"
   - Name: `qft`
   - Click "Create"

### 2.2 Upload ZIP File

1. Click into the new `qft` folder
2. Click **"Upload"** button (top left)
3. Select: `qft-php-deploy.zip` from your computer
   - Location: `d:\quarryforce\qft-deployment\qft-php-deploy.zip`
4. Upload begins automatically
5. **Wait for "Transfer Complete" message**

---

## 📦 STEP 3: Extract ZIP (20 seconds)

1. Right-click `qft-php-deploy.zip` in File Manager
2. Click **"Extract"**
3. Dialog appears → Click **"Extract Files"**
4. **Wait for extraction (5-10 seconds)**
5. Files are now in `/public_html/qft/`
6. **Delete the ZIP file** (right-click → Delete)

**Verify you see these files/folders:**

- ✅ admin/ folder (React dashboard)
- ✅ api.php file
- ✅ index.php file
- ✅ config.php file
- ✅ Database.php file
- ✅ Logger.php file
- ✅ .htaccess file
- ✅ .env.template file

**Note:** logs/ and uploads/ folders will be created in Step 5

---

## 📝 STEP 4: Create .env File on Server (2 minutes)

### 4.1 Create the File

1. In File Manager, click **"Create New"** → **"File"**
2. Name: `.env` _(include the dot at the start!)_
3. Click **"Create File"**

### 4.2 Edit .env with Credentials

1. Click the **pencil icon** (Edit) next to `.env`
2. Delete everything in the editor
3. **Paste this exactly** (update the `YOUR_*` values):

```
NODE_ENV=production
DB_HOST=localhost
DB_USER=valviyal_qf
DB_PASSWORD=YourPasswordHere
DB_NAME=valviyal_quarryforce
DB_PORT=3306
API_URL=https://valviyal.com/qft
FRONTEND_URL=https://valviyal.com/qft
LOGGING_ENABLED=true
LOG_LEVEL=INFO
```

**Replace these with YOUR values from Step 1:**

- `DB_USER=` → Use your MySQL username
- `DB_PASSWORD=` → Use your MySQL password
- `DB_NAME=` → Use your database name

4. Click **"Save Changes"**

---

## 🔐 STEP 5: Create & Set Folder Permissions (1-2 minutes)

The system needs to write logs and accept uploaded files. These folders are **not in the ZIP**, so you need to **create them first**.

### 5.1 Create logs/ Folder

1. In File Manager, navigate to `/public_html/qft/`
2. Click **"Create New"** → **"Folder"**
3. Name: `logs`
4. Click **"Create"**
5. Right-click the new `logs` folder → **"Change Permissions"**
6. Enter: `755`
7. Click **"Change"**

### 5.2 Create uploads/ Folder

1. Click **"Create New"** → **"Folder"**
2. Name: `uploads`
3. Click **"Create"**
4. Right-click the new `uploads` folder → **"Change Permissions"**
5. Enter: `755`
6. Click **"Change"**

**Result:** Both folders created with write permissions ✅

---

## ✅ STEP 6: Test - Dashboard (30 seconds)

**In browser, open:**

```
https://valviyal.com/qft
```

**Expected Result:**

- ✅ QuarryForce dashboard loads
- ✅ You see menu: Customers | Reps | Targets | Progress
- ✅ No blank page or 404 errors
- ✅ No red error messages

**If blank page:**

- Press `Ctrl + Shift + R` (hard refresh)
- Wait 5 seconds
- Check browser console (F12) for errors

---

## ✅ STEP 7: Test - API Health Check (30 seconds)

**In browser, open:**

```
https://valviyal.com/qft/api/test
```

**Expected Result - You should see:**

```json
{
  "server": "Online",
  "database": "Connected",
  "version": "2.0.0"
}
```

**If error appears:**

- If `"database": "Error"` → Check .env credentials in Step 4
- If `Cannot GET` → Wait 5 more minutes for .htaccess to take effect
- If blank page → Hard refresh (Ctrl+Shift+R)

---

## ✅ STEP 8: Test - Check Logs (30 seconds)

**In File Manager:**

1. Navigate to `/public_html/qft/logs/`
2. You should see: `app.log` file
3. Click the file to preview it
4. **You should see JSON entries like:**

```json
{"timestamp":"2026-03-05 14:30:45","level":"INFO","message":"..."}
{"timestamp":"2026-03-05 14:30:46","level":"DEBUG","message":"..."}
```

**If no log file exists:**

- You may need to access the dashboard first to trigger logging
- Go back to: `https://valviyal.com/qft`
- Wait 10 seconds
- Refresh the log folder

---

## ✅ STEP 9 (Optional): Test - API Login

**Use Postman or curl to test login endpoint:**

```bash
curl -X POST https://valviyal.com/qft/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@quarryforce.local","device_uid":"test-device"}'
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

---

## 🎯 SUMMARY - WHAT YOU'LL HAVE

After following these 9 steps:

| Status | What Works                                              |
| ------ | ------------------------------------------------------- |
| ✅     | Dashboard loads at https://valviyal.com/qft             |
| ✅     | API endpoints respond at https://valviyal.com/qft/api/* |
| ✅     | Logging system working (check logs/app.log)             |
| ✅     | Database connected                                      |
| ✅     | Admin panel functional                                  |
| ✅     | Ready for mobile app connection                         |

---

## 🚨 COMMON ISSUES & FIXES

### Issue: "Cannot GET /qft/" or "404"

**Fix:**

- Wait 5 minutes for .htaccess to take effect
- Hard refresh browser (Ctrl+Shift+R)
- Check that .htaccess file exists in /public_html/qft/

### Issue: API test shows "database": "Error"

**Fix:**

- Login to cPanel → MySQL Databases
- Double-check your credentials
- Edit .env file again with exact username/password/database
- Save changes

### Issue: Dashboard is blank/white page

**Fix:**

- Open browser console (F12)
- Look for 404 errors on CSS/JS files
- Hard refresh (Ctrl+Shift+R)
- Check that admin/ folder exists
- **If you see 404 on `/static/js/` or `/static/css/`:**
  - The `.htaccess` file has routing issues
  - Wait 5 minutes for .htaccess cache to clear
  - Then hard refresh (Ctrl+Shift+R)
  - Check that the `.htaccess` file has the correct RewriteBase /qft/
  - If still failing, replace `.htaccess` with correct rules (see PHP_DEPLOYMENT_GUIDE.md)

### Issue: Can't create .env file

**Fix:**

- Create as `env.txt` first
- Then rename to `.env`
- Or use SSH terminal if available:
  ```bash
  cd /public_html/qft
  cp .env.template .env
  nano .env    # edit and save
  ```

### Issue: Database won't connect

**Fix:**

- Verify credentials in cPanel MySQL Databases
- Make sure host is `localhost` (not a domain)
- Check for typos in .env file
- Save .env and wait 30 seconds
- Try again

---

## 📱 NEXT: Update Mobile App (If Using Flutter)

Once deployment is working, update your Flutter app:

**In your Flutter code, change:**

```dart
// OLD (Node.js)
const String API_URL = 'https://valviyal.com/qft';

// NEW (PHP)
const String API_URL = 'https://valviyal.com/qft/api';
```

Then rebuild and redeploy your app.

---

## ✨ FINAL CHECKLIST

- [ ] ZIP uploaded to /public_html/qft/
- [ ] ZIP extracted successfully
- [ ] .env file created with credentials
- [ ] logs/ folder created and set to 755
- [ ] uploads/ folder created and set to 755
- [ ] Dashboard loads: https://valviyal.com/qft ✅
- [ ] API test returns JSON: https://valviyal.com/qft/api/test ✅
- [ ] app.log file exists and has entries ✅
- [ ] Login endpoint works (optional test)
- [ ] Mobile app API URL updated (if needed)

---

## 🎉 YOU'RE LIVE!

When all steps are complete:

- Dashboard fully functional
- API responding to requests
- Logging system recording events
- Database connected
- Ready for users!

---

**Time to complete:** 10-15 minutes
**Difficulty:** Easy (mostly copy-paste)
**Support:** See PHP_DEPLOYMENT_GUIDE.md for detailed help

---

Created: March 5, 2026
Status: Production Ready ✅
