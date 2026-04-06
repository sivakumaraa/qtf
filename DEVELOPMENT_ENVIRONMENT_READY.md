# ✅ QuarryForce - Development Environment Running

## 🚀 Services Status

### ✅ Backend API (Port 3000)

```
Status: RUNNING ✅
Location: d:\quarryforce\qft-deployment\
Command: node index.js
API Base: http://localhost:3000
```

**Available Endpoints:**

- `GET /api/settings` - System settings
- `POST /api/login` - User login with device binding
- `POST /api/checkin` - Device check-in
- `POST /api/visit/submit` - Submit visit logs
- `POST /api/fuel/submit` - Submit fuel logs
- `GET /api/admin/reps` - List all reps
- `GET /api/admin/customers` - List customers
- `POST /api/admin/reset-device` - Reset device binding

### ✅ Admin Dashboard (Port 3001)

```
Status: RUNNING ✅
Location: d:\quarryforce\admin-dashboard\
Command: npm start
URL: http://localhost:3001
Authentication: Gmail OAuth2
```

**Available Features:**

- ✅ Gmail login with Google OAuth2
- ✅ User Management
- ✅ Rep Details & Management
- ✅ Device Activation & Binding
- ✅ Rep Targets & Progress
- ✅ Customer Management
- ✅ Order Management
- ✅ Real-time Analytics
- ✅ Fraud Alerts

### ⏳ Flutter Mobile App (Not Started)

```
Status: NOT STARTED
Location: d:\quarryforce\quarryforce_mobile\
To run: flutter run -d web-server
Port: 3002
```

---

## 🌐 Access URLs

| Service             | URL                                | Purpose                               |
| ------------------- | ---------------------------------- | ------------------------------------- |
| **Admin Dashboard** | http://localhost:3001              | Main admin interface with Gmail login |
| **Backend API**     | http://localhost:3000              | REST API endpoints                    |
| **API Settings**    | http://localhost:3000/api/settings | Test backend connectivity             |
| **Postman**         | Import postman_collection.json     | API testing                           |
| **Database**        | http://localhost/phpmyadmin        | MySQL management                      |

---

## 🔐 Admin Dashboard Login

### Option 1: Gmail Login

1. Go to http://localhost:3001
2. Click "Sign in with Google"
3. Use your Google account
4. **Requires:** Google OAuth Client ID in `.env`

### Option 2: Demo Login (No Setup Needed)

1. Go to http://localhost:3001
2. Click "Demo Login (Development Only)"
3. Logs in as Demo Admin automatically

### Required Environment Variable

```
.env file location: d:\quarryforce\admin-dashboard\.env
REACT_APP_GOOGLE_CLIENT_ID=your-client-id-here
```

If not set, demo login will still work.

---

## 📋 Next Steps

### Step 1: Test Backend Connectivity

```powershell
# Open PowerShell and test the API
curl http://localhost:3000/api/settings

# Should return JSON with system settings
```

### Step 2: Access Admin Dashboard

```
1. Open browser: http://localhost:3001
2. Use Demo Login (no email setup needed)
3. Explore the dashboard
```

### Step 3: (Optional) Set Up Gmail Login

```
1. Go to: https://console.cloud.google.com
2. Create OAuth 2.0 credentials
3. Update d:\quarryforce\admin-dashboard\.env
4. REACT_APP_GOOGLE_CLIENT_ID=your-id-here
5. Restart dashboard: npm start
```

### Step 4: Start Mobile App (Optional)

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter run -d web-server
# Will run on http://localhost:3002
```

---

## 🧪 Testing the System

### Test 1: Backend Health Check

```powershell
curl http://localhost:3000/api/settings
```

Expected: JSON response with system settings

### Test 2: Admin Dashboard

- URL: http://localhost:3001
- Click: Demo Login
- Should see: Dashboard with overview

### Test 3: Dashboard Features

- Click menu items on left sidebar
- Try User Management
- Check Rep Details
- Open Device Activation

### Test 4: Rep Device Binding

1. Go to: Device Activation menu
2. View list of reps
3. Click Details on a rep
4. Try: Bind Device
5. Try: Reset Device Lock

### Test 5: Postman API Testing

1. Import: `d:\quarryforce\postman_collection.json`
2. Test endpoints like:
   - `GET /api/settings`
   - `GET /api/admin/reps`
   - etc.

---

## 🔧 Troubleshooting

### Issue: Admin Dashboard shows blank page

**Solution:**

1. Check that Backend API is running: http://localhost:3000
2. Open DevTools (F12) → Console → Check for errors
3. Verify `.env` file has correct settings
4. Try: Hard refresh (Ctrl+Shift+R)

### Issue: Gmail login doesn't work

**Solution:**

1. Ensure `REACT_APP_GOOGLE_CLIENT_ID` is set in `.env`
2. Client ID must be from Google Cloud Console OAuth credentials
3. Use Demo Login instead to test dashboard

### Issue: Backend doesn't respond

**Solution:**

1. Check MySQL/XAMPP is running
2. Verify database "quarryforce" exists
3. Check `.env` file in qft-deployment:
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=quarryforce
   ```
4. Restart: `node index.js`

### Issue: npm start fails

**Solution:**

1. Try: `npm cache clean --force`
2. Delete `node_modules` and `package-lock.json`
3. Run: `npm install`
4. Then: `npm start`

---

## 📊 Database Status

The following database tables are created and ready:

```
Database: quarryforce

Tables:
- system_settings   (Config & settings)
- users             (Admin/Rep accounts with device binding)
- customers         (Customer locations with GPS)
- visit_logs        (Visit records with GPS verification)
- fuel_logs         (Fuel purchases with GPS)
```

**Access:** http://localhost/phpmyadmin

---

## 📂 Project Structure

```
d:\quarryforce\
├── qft-deployment/           ← Backend Node.js server (PORT 3000)
│   ├── index.js              ← Main server file
│   ├── db.js                 ← Database connection
│   ├── .env                  ← Database config
│   └── package.json
│
├── admin-dashboard/          ← React admin panel (PORT 3001)
│   ├── src/
│   │   ├── components/
│   │   │   ├── LoginPage.js  ← Gmail login page
│   │   │   ├── Dashboard.js
│   │   │   ├── RepDeviceActivation.js ← Device binding
│   │   │   └── ...
│   │   ├── context/
│   │   │   └── AuthContext.js ← Auth state
│   │   └── App.js
│   ├── .env                  ← Google OAuth config
│   └── package.json
│
├── quarryforce_mobile/       ← Flutter mobile app (PORT 3002)
│   ├── lib/
│   ├── web/
│   └── pubspec.yaml
│
└── [Documentation & Guides]
    ├── LOCAL_DEVELOPMENT_SETUP.md
    ├── GMAIL_OAUTH_COMPLETE_SETUP.md
    ├── API_DOCUMENTATION.md
    ├── postman_collection.json
    └── ...
```

---

## 🎯 What You Can Do Now

✅ **View Admin Dashboard** → http://localhost:3001  
✅ **Manage Users** → User Management menu  
✅ **View Reps** → Rep Details menu  
✅ **Manage Device Binding** → Device Activation menu ⭐ NEW  
✅ **Test API** → Use curl or Postman  
✅ **Monitor Database** → phpMyAdmin  
✅ **Review Logs** → Check console output

---

## 📝 Important Notes

1. **Demo Login Works Without Setup**
   - No gmail/Google account needed
   - Logs in as Demo Admin
   - Full dashboard access

2. **Gmail Login Requires One-Time Setup**
   - Need Google OAuth Client ID
   - Takes 5 minutes to set up
   - See: GMAIL_OAUTH_COMPLETE_SETUP.md

3. **Database Connection**
   - Make sure MySQL/XAMPP is running
   - Database tables auto-created on first run
   - See: LOCAL_DEPLOYMENT_GUIDE.md

4. **Mobile App** (Optional)
   - Not required for testing dashboard
   - Can be started separately
   - Uses same backend API

---

## 🚀 Summary

| Component       | Status      | Port | URL                   |
| --------------- | ----------- | ---- | --------------------- |
| Backend API     | ✅ Running  | 3000 | http://localhost:3000 |
| Admin Dashboard | ✅ Running  | 3001 | http://localhost:3001 |
| Database        | ✅ Ready    | 3306 | phpmyadmin            |
| Mobile App      | ⏸️ Optional | 3002 | -                     |

**All core systems ready!** 🎉

---

## 🆘 Need Help?

See these guides:

- **Setup Issues:** [LOCAL_DEVELOPMENT_SETUP.md](../LOCAL_DEVELOPMENT_SETUP.md)
- **Gmail Login:** [GMAIL_OAUTH_COMPLETE_SETUP.md](./GMAIL_OAUTH_COMPLETE_SETUP.md)
- **API Details:** [API_DOCUMENTATION.md](../API_DOCUMENTATION.md)
- **Troubleshooting:** [Various setup guides]

---

## 📞 Quick Commands Reference

```powershell
# Start Backend
cd d:\quarryforce\qft-deployment
node index.js

# Start Dashboard
cd d:\quarryforce\admin-dashboard
npm start

# Start Mobile App
cd d:\quarryforce\quarryforce_mobile
flutter run -d web-server

# Test API
curl http://localhost:3000/api/settings

# Database
# Open: http://localhost/phpmyadmin
```

---

**Your QuarryForce development environment is ready! 🎉**

_Last Updated: March 9, 2026 - 3:00 PM_
