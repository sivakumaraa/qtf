# ⚡ QuarryForce Local Setup - Quick Reference

## 🚀 Fastest Way to Get Started (5 minutes)

```powershell
# Run this in PowerShell
.\START_LOCAL_DEVELOPMENT.ps1

# Then choose option 7: "Full setup: Install + Start everything"
```

Or on Windows Command Prompt:

```batch
START_LOCAL_DEVELOPMENT.bat
```

---

## 📋 Pre-Flight Checklist

Before running the setup script:

```
✓ MySQL/XAMPP is running with database "quarryforce" created
  - Go to http://localhost/phpmyadmin to verify

✓ Node.js is installed
  - Run: node --version (v14+ required)

✓ npm is installed
  - Run: npm --version

✓ (Optional) Flutter SDK for mobile development
  - Run: flutter --version
```

---

## 🎯 Manual Setup (If Preferred)

### Step 1: Install Backend

```powershell
cd d:\quarryforce\qft-deployment
npm install
```

### Step 2: Install Dashboard

```powershell
cd d:\quarryforce\admin-dashboard
npm install
```

### Step 3: Get Flutter Dependencies

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter pub get
```

---

## 🚀 Running Services

### Open 3 Terminals / Command Prompts

**Terminal 1 - Backend API (Port 3000):**

```powershell
cd d:\quarryforce\qft-deployment
npm start
```

**Terminal 2 - Admin Dashboard (Port 3001):**

```powershell
cd d:\quarryforce\admin-dashboard
npm start
```

**Terminal 3 - Flutter Web (Port 3002):**

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter run -d web-server
```

---

## 🌐 Access Points

Once all services are running:

```
Backend API:        http://localhost:3000
Admin Dashboard:    http://localhost:3001
Mobile Web App:     http://localhost:3002
Database Admin:     http://localhost/phpmyadmin
```

---

## 🧪 Quick Test

```powershell
# Test backend is running
curl http://localhost:3000/api/settings

# Should return JSON with company settings
```

---

## 🛠️ Directory Structure

```
d:\quarryforce
├── qft-deployment/          ← Backend (Node.js)
├── admin-dashboard/         ← React Dashboard
├── quarryforce_mobile/      ← Flutter Mobile App
├── LOCAL_DEVELOPMENT_SETUP.md    ← Full guide (you are reading related file)
├── START_LOCAL_DEVELOPMENT.ps1   ← PowerShell setup script
└── START_LOCAL_DEVELOPMENT.bat   ← Batch setup script
```

---

## ❌ Common Issues & Quick Fixes

### Port Already in Use

```powershell
# Find and kill process using port 3000
netstat -ano | findstr :3000
taskkill /PID <number> /F
```

### Database Connection Failed

1. Start XAMPP MySQL
2. Verify `.env` file in `qft-deployment/`:
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=quarryforce
   ```

### npm install Fails

```powershell
npm cache clean --force
rm -r node_modules package-lock.json
npm install
```

### Still Having Issues?

1. Read the full guide: `LOCAL_DEVELOPMENT_SETUP.md`
2. Check `API_DOCUMENTATION.md` for API details
3. Open an issue or check logs for detailed errors

---

## 📚 Documentation Files

- **LOCAL_DEVELOPMENT_SETUP.md** - Complete setup guide (you should read this!)
- **API_DOCUMENTATION.md** - Complete API reference
- **TESTING_GUIDE_API_HANDLERS.md** - How to test APIs
- **postman_collection.json** - Ready-made API tests (import into Postman)

---

## 🎯 What You Get

✅ **Backend API** (11 endpoints ready to use)

- User authentication
- GPS check-in
- Visit tracking
- Fuel logging
- Admin controls

✅ **Admin Dashboard** (React)

- User management
- Real-time tracking
- Analytics
- Reports

✅ **Mobile Web App** (Flutter)

- Field rep interface
- GPS verification
- Visit logging
- Photo capture

---

## ✨ Next Steps

1. Run the setup script
2. Verify all services start without errors
3. Test the API endpoints (use Postman or curl)
4. Explore the Dashboard
5. Start developing features

---

**Ready? Let's go!** 🚀

`.\START_LOCAL_DEVELOPMENT.ps1` or `START_LOCAL_DEVELOPMENT.bat`
