# QuarryForce Namecheap Stellar Deployment - Quick Start

## Your Deployment Info

- **Hosting:** Namecheap Stellar (Shared Hosting)
- **Domain:** Registered at Namecheap ✓
- **Components:** Backend API + Admin Dashboard + Database
- **Setup Time:** ~1-2 hours

---

## 5-Minute Overview

### What Will Be Deployed

```
perspectivetechnology.in/qft (Namecheap)
├── Backend API (Node.js)
│   ├── URLs: https://perspectivetechnology.in/qft/api/*
│   ├── Root: /public_html/qft
│   ├── Files: index.js, db.js, node_modules
│   └── Data: MySQL database
│
└── Admin Dashboard (React)
    └── URL: https://perspectivetechnology.in/qft
        (Served from /public_html/qft/admin as static files)
```

### The Steps (In Order)

1. **Prepare** - Run script locally (5 min)
2. **Upload** - Send files to server via FTP (10 min)
3. **Configure** - Setup on cPanel (20 min)
4. **Test** - Verify everything works (10 min)

---

## Step-by-Step Instructions

### STEP 1: Prepare Your Files (Local Machine)

**Windows Users:**

1. Open Command Prompt in `d:\quarryforce` folder
2. Right-click → **Run as Administrator**
3. Run: `prepare-deployment.bat`

**What it does:**

- Builds React admin dashboard
- Copies files to `deployment/` folder
- Creates `.env.template` file

**Result:** `deployment/` folder ready to upload (3-4 minutes)

---

### STEP 2: Get Your Database Credentials

1. Log in to [Namecheap.com](https://namecheap.com)
2. Go to **Hosting** → Click **Manage** on your Stellar account
3. Click **cPanel Login**

**In cPanel:**

1. Find **MySQL Databases** section
2. Click **Create New Database**
3. Enter:
   - Name: `quarryforce_db`
   - Note the database name
4. Click **Create Database**
5. Create MySQL User:
   - Username: `quarryforce_user`
   - Password: (generate strong password - SAVE IT!)
6. Assign user to database with **ALL PRIVILEGES**

**Save these details:**

```
Database Host: [shown in cPanel, usually: localhost or hostname.namecheaphosting.com]
Database Name: quarryforce_db
Database User: quarryforce_user
Database Password: [your generated password]
```

---

### STEP 3: Prepare Environment File

1. Go to your local `deployment/` folder
2. Open `.env.template` file with Notepad
3. **Replace these values:**

```env
NODE_ENV=production
PORT=3000
DB_HOST=localhost                              # From cPanel
DB_USER=quarryforce_user                      # From Step 2
DB_PASSWORD=your_password_here                 # From Step 2
DB_NAME=quarryforce_db
DB_PORT=3306
API_URL=https://perspectivetechnology.in/qft
FRONTEND_URL=https://perspectivetechnology.in/qft
```

4. **Save as:** `.env` (not `.env.template`)
5. Place in `deployment/` folder (same level as `index.js`)

---

### STEP 4: Upload Files via FTP

**Option A: Using FileZilla (Easiest)**

1. Download FileZilla: https://filezilla-project.org/
2. Open FileZilla
3. In cPanel, go to **FTP Accounts** → Create new account:
   - Username: `deploy`
   - Password: (generate)
   - Directory: `/public_html`
4. In FileZilla:
   - **Host:** Your server IP (from cPanel)
   - **Username:** `deploy`
   - **Password:** (from above)
   - **Port:** `21`
   - Click **Quickconnect**
5. Upload folder structure:
   - Create `qft` folder in `/public_html/`
   - Upload `deployment/` contents **directly into** `/public_html/qft/`
   - Result should be:
     - `/public_html/qft/index.js` (Node.js app)
     - `/public_html/qft/admin/` (React dashboard)
     - `/public_html/qft/uploads/` (file uploads)
     - `/public_html/qft/.env` (configuration)
     - `/public_html/qft/.htaccess` (routing)

**Option B: Using cPanel File Manager**

1. In cPanel → **File Manager**
2. Navigate to `/public_html`
3. Upload zip file with `deployment/` contents
4. Extract in place

---

### STEP 5: Create Node.js Application

1. In cPanel → **Node.js Selector** (or Node.js App Manager)
2. Click **Create Application**
3. Fill in:
   - **Node.js Version:** 18.x or higher
   - **Application Root:** `/qft` (or `/public_html/qft` - path where index.js is located)
   - **Application Startup File:** `index.js`
   - **Application Mode:** `production`

4. Click **Create Application**
5. Verify it says **"Running"** (wait 1-2 minutes)

6. In cPanel → **AutoSSL**
7. Make sure all domains are enabled
8. Namecheap provides free Let's Encrypt SSL
9. After DNS propagates, certificates auto-generate

---

### STEP 9: Import Database

1. In cPanel → **phpMyAdmin**
2. Click your database `quarryforce_db`
3. Click **Import** tab
4. Upload `TEST_DATA.sql`:
   - Click **Choose File**
   - Select from `d:\quarryforce\TEST_DATA.sql`
   - Click **Go**
5. Wait for import (< 1 minute)

---

### STEP 10: Test Everything

Complete Testing Flow Diagram:

```
START TESTING
    │
    ├─────────────────────────────────────────────┐
    │                                             │
    v                                             v
┌─────────────────────────────┐   ┌────────────────────────────┐
│ CONNECTIVITY TESTS          │   │ FUNCTIONALITY TESTS        │
├─────────────────────────────┤   ├────────────────────────────┤
│ 1. API Endpoint             │   │ 1. Login Test              │
│    ✓ Responds to requests   │   │    ✓ Demo credentials work │
│    ✓ No 404/500 errors      │   │    ✓ Token generated      │
│                             │   │                            │
│ 2. Dashboard Access         │   │ 2. Dashboard Navigation   │
│    ✓ Loads without errors   │   │    ✓ Pages load quickly   │
│    ✓ React components work  │   │    ✓ No console errors    │
│                             │   │                            │
│ 3. Database Connection      │   │ 3. Data Display           │
│    ✓ Tables accessible      │   │    ✓ Customers show data  │
│    ✓ Queries return data    │   │    ✓ Currency shows ₹     │
│                             │   │                            │
│ 4. SSL Certificate          │   │ 4. File Operations       │
│    ✓ Valid HTTPS            │   │    ✓ Photos upload work   │
│    ✓ Green lock in browser  │   │    ✓ Downloads succeed    │
│                             │   │                            │
└────────────┬────────────────┘   └──────────────┬─────────────┘
             │                                   │
             └───────────────┬───────────────────┘
                             │
                             v
                    ┌─────────────────────┐
                    │ PERFORMANCE TESTS   │
                    ├─────────────────────┤
                    │ 1. Load Time        │
                    │    Dashboard < 2s   │
                    │    API Response <   │
                    │    300ms            │
                    │                     │
                    │ 2. Network Speed    │
                    │    Good latency     │
                    │    Stable connection│
                    │                     │
                    └──────────┬──────────┘
                               │
                               v
                        ┌──────────────┐
                        │ ALL PASSED?  │
                        └──────┬───────┘
              YES              │              NO
               │               │               │
               v               v               v
        ┌─────────────┐   ┌──────────────────────┐
        │ GO LIVE! 🎉 │   │ CHECK TROUBLESHOOTING│
        │             │   │ AND FIX ISSUES       │
        │ Production  │   │ Then re-test         │
        │ Ready       │   └──────┬───────────────┘
        └─────────────┘          │
                                 v
                           (Return to test)
```

---

**Pre-Deployment Testing Checklist:**

- [ ] `prepare-deployment.bat` runs without errors
- [ ] `deployment/` folder created with all files
- [ ] `.env` file prepared with credentials
- [ ] All dependencies listed in `package.json`

**Connectivity Tests (First):**

1. **Test API Health:**

   ```
   https://perspectivetechnology.in/qft/api/settings
   ```

   Expected: JSON response with system data

   ```json
   {
     "success": true,
     "data": [...]
   }
   ```

2. **Test Admin Dashboard:**

   ```
   https://perspectivetechnology.in/qft
   ```

   Expected: Dashboard loads (or login page, no errors in console)

3. **Test Database:**

   ```
   https://perspectivetechnology.in/qft/api/customers
   ```

   Expected: JSON array of customers

4. **Test SSL Certificate:**
   - Check browser address bar: Green lock icon ✅
   - Check certificate details (should be Let's Encrypt)

---

**Functionality Tests (After Connectivity):**

1. **Login Test:**
   - Navigate to: `https://perspectivetechnology.in/qft`
   - Email: `demo@quarryforce.local`
   - Password: (any password - demo mode)
   - Expected: Redirect to dashboard, session starts

2. **Dashboard Tests:**
   - [ ] Overview page loads
   - [ ] Customers tab shows data
   - [ ] Numbers/currency display correctly (₹)
   - [ ] No JavaScript errors in console
   - [ ] Sidebar navigation works
   - [ ] Analytics page loads

3. **Data Tests:**
   - [ ] Rep list shows demo reps
   - [ ] Customer locations visible
   - [ ] Sales history displays

4. **User Actions:**
   - [ ] Can click on customer → Details load
   - [ ] Can navigate between pages
   - [ ] Charts/graphs render (if applicable)

5. **File Upload Test (if photos enabled):**
   - [ ] Rep details → Upload photo
   - [ ] Select image from computer
   - [ ] Photo displays in preview
   - [ ] Click Save → Confirms saving
   - [ ] Photo persists after refresh

---

**Performance Tests:**

| Test            | Expected | Acceptable |
| --------------- | -------- | ---------- |
| Dashboard load  | <1.5 sec | <3 sec     |
| API response    | <200 ms  | <500 ms    |
| Database query  | <100 ms  | <300 ms    |
| Page navigation | Instant  | <1 sec     |

---

**Post-Deployment Verification:**

- [ ] SSL certificate valid (green lock)
- [ ] No 404 or 500 errors
- [ ] Database queries return data
- [ ] All pages responsive
- [ ] Photos upload/display
- [ ] Demo user can login
- [ ] Currency displays correctly (₹)
- [ ] No console errors

---

## Step-by-Step Test Execution

### Test 1: API Connectivity (5 minutes)

**In browser, visit:**

```
https://perspectivetechnology.in/api/settings
```

**Expected Response:**

```json
{
  "success": true,
  "data": [...]
}
```

**If fails:** Check TROUBLESHOOTING section → "API returns 404 error"

---

### Test 2: Dashboard Access (5 minutes)

**In browser, visit:**

```
https://perspectivetechnology.in
```

**Expected:** Dashboard loads (or redirects to login page) with:

- Dashboard content visible
- Navigation working
- No JavaScript errors (open DevTools: F12 → Console tab)

**If fails:** Check TROUBLESHOOTING section → "Dashboard shows blank page"

---

### Test 3: Login Functionality (5 minutes)

**Fill in:**

- Email: `demo@quarryforce.local`
- Password: `any` (demo bypass active)
- Click: Login

**Expected:**

- Redirects to dashboard
- Shows customer data
- Currency displays as ₹ (rupees)
- No errors in console

**If fails:** Check:

- Backend API responding (Test 1)
- Console for error messages (F12)
- Database connection

---

### Test 4: Database Verification (5 minutes)

**In cPanel → phpMyAdmin:**

1. Select database `quarryforce_db`
2. Check tables exist:
   - `users` (should have demo user)
   - `customers` (should have demo data)
   - `sales_history`
   - `rep_targets`
   - Others...

**Expected:** 7-10 tables with data

**If fails:** Re-import TEST_DATA.sql in Step 9

---

### Test 5: Navigation Test (5 minutes)

**In dashboard, test:**

| Action              | Expected             |
| ------------------- | -------------------- |
| Click "Overview"    | Page loads quickly   |
| Click "Customers"   | Customer table shows |
| Click on customer   | Details page opens   |
| Go back             | Returns to list      |
| Click "Rep Details" | Rep table shows      |
| Scroll table        | No freezing          |

**If fails:** Check browser console for errors (F12)

---

### Test 6: Full Workflow Test (10 minutes)

**Complete user journey:**

1. ✅ Visit `https://perspectivetechnology.in`
2. ✅ Login with demo credentials
3. ✅ Navigate to Overview → See data
4. ✅ Navigate to Customers → See list
5. ✅ Click a customer → See details
6. ✅ Navigate to Rep Details → See reps
7. ✅ Check all data displays correctly
8. ✅ Check currency shows ₹
9. ✅ Logout (session ends)
10. ✅ Login again (session works)

**If any step fails:** Note the issue and check troubleshooting

---

### Test 7: SSL Certificate Verification (2 minutes)

**Visual check:**

```
Browser address bar should show:
✅ Green lock icon
✅ "Secure" label
✅ Company name or "Let's Encrypt"
```

**Details check (click lock icon):**

```
✅ Issuer: Let's Encrypt Authority X3
✅ Subject: yourdomain.com
✅ Valid until: (future date)
```

**If missing:**

- Wait up to 24 hours for DNS propagation
- Try AutoSSL in cPanel again
- Verify DNS records are correct

---

### Test 8: Error Scenarios (5 minutes)

**Test error handling:**

1. **Bad login:**
   - Email: `invalid@email.com`
   - Password: `wrong`
   - Expected: Error message displayed

2. **Network error:**
   - Disconnect internet
   - Try API call
   - Expected: Timeout/error (reconnect for next test)

3. **Invalid data:**
   - Try API with bad parameters
   - Expected: 400/500 error response

---

**All Tests Complete When:**

- ✅ API responds to requests
- ✅ Dashboard loads without errors
- ✅ Login with demo user works
- ✅ Data displays correctly
- ✅ SSL certificate shows green lock
- ✅ Navigation and clicking work
- ✅ Currency shows ₹ symbol
- ✅ No JavaScript errors
- ✅ Page load times acceptable

---

## Troubleshooting

### "Admin dashboard shows blank page"

**Solution:**

1. Check FileZilla uploaded all React files
2. Verify `.htaccess` exists in `/public_html/admin/`
3. Rebuild: `npm run build` and re-upload

### "Cannot connect to database"

**Solution:**

1. Verify credentials in `.env` match cPanel
2. Test in Terminal:

```bash
mysql -h localhost -u quarryforce_user -p -D quarryforce_db
```

### "API returns 404 error"

**Solution:**

1. Check cPanel → Node.js Status = "Running"
2. Check cPanel logs for errors
3. Verify `index.js` uploaded correctly

### "SSL certificate error"

**Solution:**

1. Wait 24 hours for DNS to fully propagate
2. Try AutoSSL again in cPanel
3. Check DNS records are correct

---

## After Deployment

### Update Mobile App

Edit `lib/services/api_client.dart`:

```dart
const String baseUrl = 'https://api.yourdomain.com';
```

Rebuild and deploy mobile app.

### Backup Strategy

- Weekly: Download cPanel backup
- Monthly: Test database recovery
- Keep credentials in secure password manager

### Monitoring

- Check cPanel logs weekly for errors
- Monitor disk space (should have plenty)
- Update Node.js dependencies monthly

---

## Important Files to Save

Save these to a secure location:

```
cPanel Login: yourusername / *password*
FTP Login: deploy / *password*
Database: quarryforce_user / *password*
Admin Account: (your chosen credentials)
Domain: perspectivetechnology.in
App URL: https://perspectivetechnology.in/qft
API URL: https://perspectivetechnology.in/qft/api
```

---

## Support Resources

- **Namecheap Support:** https://www.namecheap.com/support/
- **cPanel Help:** https://docs.cpanel.net/
- **Node.js Docs:** https://nodejs.org/
- **Full Guide:** See `NAMECHEAP_STELLAR_DEPLOYMENT.md`

---

## Estimated Timeline

| Task                 | Time          |
| -------------------- | ------------- |
| Local preparation    | 5 min         |
| Create database      | 5 min         |
| Upload files         | 10 min        |
| Install dependencies | 5 min         |
| cPanel configuration | 15 min        |
| DNS propagation      | 1-24 hours    |
| Testing              | 10 min        |
| **Total**            | **1-2 hours** |

---

**Next:** Run `prepare-deployment.bat` to get started! 🚀
