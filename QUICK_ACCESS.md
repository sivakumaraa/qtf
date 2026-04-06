# 🎯 Quick Access Guide - Your Dev Environment

## ✅ What's Currently Running

```
Backend API:      http://localhost:3000  ✅
Admin Dashboard:  http://localhost:3001  ✅
Database:         http://localhost/phpmyadmin
```

---

## 🌐 Click Here to Access

### Main Admin Dashboard (Most Important)

👉 **http://localhost:3001**

**What you'll see:**

- Login page with two options
- Option 1: Click "Sign in with Google" (requires setup)
- Option 2: Click "Demo Login (Development Only)" ← USE THIS

### Backend API Health Check

👉 **http://localhost:3000/api/settings**

**What you'll see:**

```json
{
  "success": true,
  "data": {
    "gps_radius_limit": 50,
    "company_name": "QuarryForce",
    "currency_symbol": "₹"
  }
}
```

### Database Management

👉 **http://localhost/phpmyadmin**

**Log in with:**

- Username: `root`
- Password: (leave blank for XAMPP default)

---

## 🚀 First Thing to Do

1. **Open your browser**
2. **Go to:** http://localhost:3001
3. **Click:** "Demo Login (Development Only)"
4. **✅ You're in the admin dashboard!**

---

## 📱 Dashboard Features You Can Try

After logging in, click these in the left sidebar:

- **Overview Dashboard** - See analytics
- **User Management** - Create/manage users
- **Rep Details** - View field representatives
- **Device Activation** ⭐ - NEW! Manage device binding
- **Rep Targets & Progress** - Sales targets
- **Customers** - Customer management
- **Orders** - Order tracking
- **Fraud Alerts** - Security monitoring
- **Visit Logs** - Field visit history
- **Settings** - System configuration

---

## 🔐 About Gmail Login

**Current Status:** Not configured yet  
**Setup Time:** 5 minutes  
**Requirement:** Google account + Google Cloud OAuth setup

**To enable Gmail login:**

1. Follow: [GMAIL_OAUTH_COMPLETE_SETUP.md](./admin-dashboard/GMAIL_OAUTH_COMPLETE_SETUP.md)
2. Get Google OAuth Client ID
3. Update `.env` file
4. Restart dashboard

**For now:** Use "Demo Login" to test everything

---

## 🧪 Testing the API

### Test with Browser

```
Visit: http://localhost:3000/api/settings
```

### Test with Postman

1. Download: [Postman](https://www.postman.com/downloads/)
2. Import: `d:\quarryforce\postman_collection.json`
3. Test any endpoint

### Test with PowerShell

```powershell
curl http://localhost:3000/api/settings
```

---

## 📊 Troubleshooting

| Problem               | Solution                                             |
| --------------------- | ---------------------------------------------------- |
| Dashboard shows blank | Refresh page (Ctrl+R) or hard refresh (Ctrl+Shift+R) |
| API returns error     | Check MySQL is running, database exists              |
| Can't log in          | Try Demo Login or check .env file                    |
| Port already in use   | Kill existing process using the port                 |

---

## 📂 Important Files

```
d:\quarryforce\
├── admin-dashboard/
│   ├── .env ←  Edit this for Gmail setup
│   ├── src/components/LoginPage.js ← Gmail login page
│   └── GMAIL_OAUTH_COMPLETE_SETUP.md ← Setup guide
│
├── qft-deployment/
│   ├── .env ← Database config
│   └── index.js ← Backend server
│
├── DEVELOPMENT_ENVIRONMENT_READY.md ← What's running
├── LOCAL_DEVELOPMENT_SETUP.md ← Full setup guide
└── API_DOCUMENTATION.md ← API reference
```

---

## 🎯 Next Steps

### Option A: Test & Explore (5 min)

1. Go to: http://localhost:3001
2. Click: Demo Login
3. Click around the dashboard
4. Try different features

### Option B: Set Up Gmail Login (5 min)

1. Read: [GMAIL_OAUTH_COMPLETE_SETUP.md](./admin-dashboard/GMAIL_OAUTH_COMPLETE_SETUP.md)
2. Get Google OAuth Client ID
3. Update `.env` with Client ID
4. Restart dashboard

### Option C: Test API Endpoints (5 min)

1. Download Postman
2. Import: `postman_collection.json`
3. Test endpoints
4. See responses

### Option D: Start Mobile App (10 min)

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter run -d web-server
# Will run on http://localhost:3002
```

---

## 💾 Database Status

- **Database:** quarryforce
- **Tables:** 5 (system_settings, users, customers, visit_logs, fuel_logs)
- **Status:** Ready to use ✅
- **Admin URL:** http://localhost/phpmyadmin

---

## 🎉 You're All Set!

Everything is running. Time to explore:

👉 **Start here:** http://localhost:3001

**Questions?** See the full setup guides in `d:\quarryforce\`

---

## 🔧 Handy Commands

```powershell
# Test if backend is running
curl http://localhost:3000

# Test if dashboard is running
curl http://localhost:3001

# Check backend logs (if running in terminal)
# Should show: "Server running on http://localhost:3000"
```

---

**Happy coding!** 🚀

_Last Updated: March 9, 2026_
