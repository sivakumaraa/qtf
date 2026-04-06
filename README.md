# QuarryForce - Local Development Setup

## ✅ Current Status

Your backend is now **fully functional** with the following features:

### ✅ Completed

- Database setup (5 tables created in XAMPP)
- Node.js Express server with 11 API endpoints
- Device binding security (one phone per user)
- GPS geofencing (50m radius check-in)
- Settings management system
- Admin dashboard APIs

---

## 🚀 How to Run (Now and Every Time)

### Terminal 1: Start XAMPP

1. Open XAMPP Control Panel
2. Click **Start** next to MySQL
3. Click **Start** next to Apache
4. Go to http://localhost/phpmyadmin to verify database

### Terminal 2: Start Backend Server

```bash
cd d:\quarryforce\qft-deployment
php -S localhost:8000
```

You should see:

```
✅ Development Servers Started!
📍 PHP Backend: http://localhost:8000
📍 Admin Dashboard: http://localhost:3000
📊 API Docs: http://localhost:8000/
🔐 Backend is ready
```

---

## 🧪 Quick Testing (Without Mobile App)

### Method 1: Browser

Simply visit these URLs in your browser:

- **Settings:** http://localhost:3000/api/settings
- **Test:** http://localhost:3000/test

### Method 2: Postman (Recommended)

1. Download [Postman](https://www.postman.com/downloads/)
2. Open Postman
3. **Import** → Select file → `d:\quarryforce\postman_collection.json`
4. Click on any request and click **Send**

### Method 3: cURL Commands

```bash
# Test server
curl http://localhost:3000/test

# Get settings
curl http://localhost:3000/api/settings

# Login
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@quarryforce.local\",\"device_uid\":\"device-001\"}"

# Check-in at exact location
curl -X POST http://localhost:3000/api/checkin \
  -H "Content-Type: application/json" \
  -d "{\"rep_id\":1,\"customer_id\":1,\"rep_lat\":12.9716,\"rep_lng\":77.5946}"
```

---

## 📁 Project Files

```
d:\quarryforce\
├── qft-deployment/            ← PHP Backend with all APIs
│   ├── api.php                (Main API router)
│   ├── Database.php           (MySQL connection)
│   ├── .env                   (Database credentials)
│   └── [other handlers]
├── admin-dashboard/           ← React Admin Dashboard
│   ├── src/
│   ├── package.json           (React dependencies)
│   └── .env                   (API URL)
├── API_DOCUMENTATION.md       ← Full API reference
├── postman_collection.json    ← For easy testing
└── README.md                  ← This file
```

---

## 🔑 Key API Endpoints

| Feature              | Endpoint                  | Method |
| -------------------- | ------------------------- | ------ |
| Get Settings         | `/api/settings`           | GET    |
| Login/Device Bind    | `/api/login`              | POST   |
| GPS Check-in         | `/api/checkin`            | POST   |
| Submit Visit         | `/api/visit/submit`       | POST   |
| Submit Fuel          | `/api/fuel/submit`        | POST   |
| Admin: Get Reps      | `/api/admin/reps`         | GET    |
| Admin: Get Customers | `/api/admin/customers`    | GET    |
| Admin: Reset Device  | `/api/admin/reset-device` | POST   |

---

## 🧠 How It Works (Simple Explanation)

### Rep's Journey:

1. **Open App** → Calls `/api/settings` → Gets company name & 50m radius
2. **Login** → Calls `/api/login` → Device binds to account (one phone only!)
3. **Navigate to Customer** → Walks to site
4. **Check-in** → Calls `/api/checkin` → GPS checks: "Are you within 50m?"
   - ✅ YES → Can take photos & enter requirements
   - ❌ NO → "Too far away, blocked!"
5. **Submit** → Calls `/api/visit/submit` → Visit saved to database

### Owner's Dashboard:

1. **View Settings** → Calls `/api/admin/customers` → Sees all GPS pins on map
2. **Verify Visits** → Calls `/api/admin/reps` → Sees who worked today & how much
3. **Reset Device** → If rep loses phone → Calls `/api/admin/reset-device`

---

## 🐛 Troubleshooting

### Server won't start

```
Error: Cannot find module 'geolib'?
→ Run: npm install geolib
```

### Cannot connect to database

```
Error: ER_ACCESS_DENIED_FOR_USER
→ Check: Is MySQL running in XAMPP? (Green button)
→ Check: Is database named 'quarryforce'?
```

### Port 3000 already in use

```
PS > netstat -ano | findstr :3000
PS > taskkill /PID [PID_NUMBER] /F
```

---

## 🎯 Next Steps

### Option A: Continue Backend Development

**Add Photo Upload Functionality**

- Create `/uploads/` folder structure (visits, fuel, selfies, claims)
- Add multer middleware for file uploads
- Create `/api/upload/visit` and `/api/upload/fuel` endpoints
- Store image paths in database

### Option B: Start Mobile App

**Integrate Flutter with Backend**

- Set up Flutter project
- Create login screen → calls `/api/login`
- Create GPS map screen → calls `/api/checkin`
- Create camera screen → calls `/api/visit/submit`
- Test on real phone (must be on same Wi-Fi as laptop)

### Option C: Create Admin Dashboard

**Build Web Interface**

- Create HTML/CSS/JavaScript dashboard
- Display all reps on a map (using their GPS from database)
- Allow settings changes
- Show daily visit counts

---

## 💾 Database Reference

### users table

- Stores rep accounts
- `device_uid` = locks account to one phone
- First login auto-binds device
- Second device = BLOCKED

### customers table

- Store customer locations (lat/lng)
- `assigned_rep_id` = which rep owns this customer
- Prevents other reps from visiting

### visit_logs table

- Records every site visit
- Stores GPS coordinates at submission time
- Stores requirements (material, tonnage, etc.)

### fuel_logs table

- Records fuel purchases
- Two photos: odometer + pump display
- One selfie: rep's face
- GPS locked to fuel station location

### system_settings table

- `gps_radius_limit` = change from 50m to whatever you want
- Change in database → instantly affects all apps
- No code changes needed!

---

## 📱 Mobile App Connection

When you build the Flutter app, it needs these settings:

```
API_BASE_URL = "http://192.168.1.XXX:3000"
(Replace XXX with your laptop's IP address)

Your phone and laptop must be on SAME Wi-Fi!
```

To find your laptop's IP:

```bash
ipconfig
# Look for IPv4 Address: 192.168.x.x
```

---

## 🔐 Security Features

- ✅ **Device Binding:** One account = One phone (unbreakable)
- ✅ **GPS Lock:** Must be within 50m of site to check-in
- ✅ **Territory Lock:** Other reps can't visit assigned customers
- ✅ **Photo Proof:** Can't submit without site photo + rep selfie
- ✅ **Timestamp Proof:** Every action has GPS + timestamp

---

## 📊 Testing Checklist

- [ ] PHP Backend runs without errors: `cd qft-deployment && php -S localhost:8000`
- [ ] `http://localhost:8000/api/settings` returns company name
- [ ] `http://localhost:8000/test` shows "Database Connected"
- [ ] `http://localhost:8000/api/login` binds device on first login
- [ ] `http://localhost:8000/api/login` blocks different device
- [ ] `http://localhost:8000/api/checkin` passes when at exact location
- [ ] `http://localhost:8000/api/checkin` blocks when far away
- [ ] `http://localhost:8000/api/visit/submit` saves visit to database
- [ ] `http://localhost:8000/api/admin/customers` shows all locations

---

## 📞 Common Questions

**Q: How do I change the 50m GPS radius?**
A: Edit in phpMyAdmin:

1. Go to `system_settings` table
2. Find `gps_radius_limit`
3. Change value from 50 to (e.g., 100)
4. App instantly uses new radius (no code changes!)

**Q: Can a rep use two phones?**
A: NO. First phone binds their account. Second phone = BLOCKED.
To fix: Admin runs `/api/admin/reset-device` → Rep can register new phone

**Q: How are photos stored?**
A: Currently the database stores file paths. Next phase adds multer for actual image uploads.

**Q: What about the mobile app?**
A: That's Phase 2. This backend is ready to connect to any Flutter app that calls these APIs.

---

## ✨ What's Working Now

- [x] User authentication with device binding
- [x] GPS verification using Haversine formula
- [x] Configurable settings (50m radius, company name, etc.)
- [x] Territory management (one rep per customer)
- [x] Visit logging to database
- [x] Fuel logging to database
- [x] Admin dashboard APIs
- [ ] Photo upload system (next phase)
- [ ] Mobile app integration (next phase)
- [ ] Admin web dashboard (next phase)

---

## 🎓 Learning Resources

- **Haversine Formula:** GPS distance calculation used for 50m check
- **JWT:** For future authentication enhancement
- **OAuth2:** For social login (Google/Facebook)
- **Multer:** For photo/file uploads (phase 2)
- **Socket.io:** For real-time rep tracking (phase 3)

---

**Version:** 1.0.0 Beta  
**Last Updated:** February 27, 2026  
**Status:** ✅ Backend Ready for Mobile Integration
