# Phase 4.1: Quick Reference Card

**Date:** March 14, 2026  
**Feature:** Rep Login + Live Location Tracking

---

## 📁 Files Created Today

```
d:\quarryforce\
├── PHASE_4_LOCATION_MIGRATION.sql           (Database schema)
├── PHASE_4_1_IMPLEMENTATION_GUIDE.md         (Complete setup guide)
├── PHASE_4_1_IMPLEMENTATION_SUMMARY.md       (What was built)
│
├── qft-deployment/
│   └── api_location.php                      (Backend API endpoints)
│
├── quarryforce_mobile/lib/
│   ├── services/
│   │   ├── device_service.dart               (Device binding)
│   │   └── auth_service.dart                 (JWT authentication)
│   └── screens/
│       └── login_screen.dart                 (Updated - see guide)
│
└── admin-dashboard/src/
    └── pages/
        └── RepLocations.jsx                  (Live map + list)
```

---

## 🚀 5-Minute Setup

### 1. Database

```bash
mysql -u quarryforce -p quarryforce < PHASE_4_LOCATION_MIGRATION.sql
```

### 2. PHP

- Copy `api_location.php` to `qft-deployment/`
- Update base URL in config
- Deploy to server

### 3. Flutter

```bash
cd quarryforce_mobile
flutter pub get
# Update pubspec.yaml with new packages
```

### 4. React

- Add `RepLocations.jsx` route to App.jsx
- Add navigation menu item
- Deploy to server

### 5. Test

- Rep logs in with email/password
- Location appears on dashboard map
- ✅ Done!

---

## 🔑 Key Endpoints

| Endpoint                                        | Method | Purpose                   |
| ----------------------------------------------- | ------ | ------------------------- |
| `/login?action=login`                           | POST   | Device binding + auth     |
| `/api/location/update?action=location_update`   | POST   | Send location             |
| `/api/reps/locations?action=reps_locations`     | GET    | All rep locations (admin) |
| `/api/reps/location?action=rep_location`        | GET    | Single rep location       |
| `/api/location/history?action=location_history` | GET    | Location history          |

---

## 📱 Mobile Flow

```
Login Screen
    ↓
Device UUID generated (one-time)
    ↓
Server authenticates email/password
    ↓
JWT token returned
    ↓
Location tracking starts (every 30 sec)
    ↓
Runs in background
    ↓
On logout, tracking stops
```

---

## 🗺️ Admin Dashboard

```
Rep Locations Page
    ├── Statistics Cards (Online/Offline/Total)
    ├── Leaflet Map (12 zoom)
    │   └── Markers with status
    ├── Rep List (sortable)
    │   └── Status, coordinates, accuracy
    └── Auto-refresh (every 10 sec)
```

---

## 📊 Database Tables

### live_locations

- Latest location per rep (1 record per rep)
- Updated every 30 seconds

### location_history

- All locations (archived)
- For analytics and reporting

### device_bind_log

- Device binding audit trail
- When device was bound

### location_access_log

- Who accessed location data when
- For compliance/security

---

## 🔐 Security

| Feature         | How It Works                           |
| --------------- | -------------------------------------- |
| Device Binding  | UUID generated once, stored securely   |
| JWT Token       | Signed with secret, 24hr validity      |
| Admin Only      | Location list requires admin role      |
| Offline Support | Locations queued, synced automatically |
| Audit Trail     | All activities logged with timestamp   |

---

## ⚙️ Configuration

Set these environment variables:

```bash
# PHP
JWT_SECRET=your-secret-key-here

# Flutter
API_BASE_URL=https://your-api.com/

# Database
DB_HOST=localhost
DB_USER=quarryforce
DB_PASS=secure_password
DB_NAME=quarryforce
```

---

## 🧪 Test Commands

### Backend Test

```bash
# Login
curl -X POST 'http://localhost/login?action=login' \
  -d 'email=test@example.com&password=password123'

# Update location (with token)
curl -X POST 'http://localhost/api/location/update?action=location_update' \
  -H 'Authorization: Bearer <TOKEN>' \
  -F 'lat=28.6139' -F 'lng=77.2090' -F 'accuracy=15.5'
```

### Mobile Test

- [ ] Login: Email + Password
- [ ] Verify: Device UID generated
- [ ] Check: Location permission granted
- [ ] Monitor: Location updates in logs
- [ ] Test: Offline → Online transition

### Dashboard Test

- [ ] Open: Rep Locations page
- [ ] Verify: Map loads with markers
- [ ] Check: List shows all reps
- [ ] Confirm: Auto-refreshes every 10 sec
- [ ] Test: Click on marker → shows popup

---

## 📈 Performance Notes

| Action          | Frequency    | Impact            |
| --------------- | ------------ | ----------------- |
| GPS Update      | Every 30 sec | ~5MB/hour per rep |
| API Call        | Every 30 sec | ~1KB per update   |
| Dashboard Poll  | Every 10 sec | ~2KB per request  |
| Database Insert | Every 30 sec | Depends on reps   |

**Optimization:** Archive old location_history monthly

---

## 🎯 What Works After Implementation

✅ Rep email/password login  
✅ One-time device binding  
✅ Automatic location tracking  
✅ Live admin dashboard map  
✅ Online/offline status  
✅ Location history  
✅ Offline queue support  
✅ Secure audit trails

---

## ⚠️ Common Issues

| Problem               | Solution                           |
| --------------------- | ---------------------------------- |
| Device mismatch error | Use same device, or clear app data |
| Location not updating | Check permissions, network, token  |
| Map not showing       | Install leaflet, check imports     |
| No location history   | Check `live_locations` table       |
| Slow dashboard        | Archive old location_history       |

---

## 📞 Important Files

Read these for complete context:

1. **PHASE_4_1_IMPLEMENTATION_GUIDE.md** ← Start here for setup
2. **PHASE_4_1_IMPLEMENTATION_SUMMARY.md** ← What was built
3. **api_location.php** ← Backend API code
4. **device_service.dart** ← Device binding logic
5. **auth_service.dart** ← JWT authentication
6. **RepLocations.jsx** ← Admin dashboard

---

## 🚢 Deployment Sequence

1. Database migration
2. API deployment
3. Flutter build & upload
4. React build & deploy
5. Test all endpoints
6. Train users
7. Monitor logs

**Total time:** ~2-3 hours

---

## 📞 Support

**Questions?** Check PHASE_4_1_IMPLEMENTATION_GUIDE.md  
**Issues?** See Troubleshooting section in guide  
**API Docs?** Check PHASE_4_1_IMPLEMENTATION_GUIDE.md (Step 2)

---

**Status:** ✅ Ready to Deploy  
**Created:** March 14, 2026  
**Version:** 1.0
