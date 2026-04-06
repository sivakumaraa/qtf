# QuarryForce Backend API Documentation

## 🚀 Quick Start

```bash
# Terminal 1: Start your backend server
cd d:\quarryforce
node index.js

# Terminal 2: Start XAMPP MySQL
# (Keep XAMPP running with MySQL and Apache enabled)
```

The server will run on: **http://localhost:3000**

---

## 📋 API Endpoints

### 1. GET Settings (App Configuration)

**Endpoint:** `/api/settings`
**Method:** GET
**Purpose:** Mobile app fetches company name, GPS radius, and security settings

**cURL Example:**

```bash
curl http://localhost:3000/api/settings
```

**Response:**

```json
{
  "success": true,
  "data": {
    "company_name": "QuarryForce Logistics",
    "gps_radius_limit": "50",
    "device_binding_enabled": "true",
    "allow_mock_location": "false"
  }
}
```

---

### 2. POST Login & Device Binding

**Endpoint:** `/api/login`
**Method:** POST
**Purpose:** Authenticate user and lock account to their device

**Request Body:**

```json
{
  "email": "admin@quarryforce.local",
  "device_uid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

**cURL Example:**

```bash
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@quarryforce.local","device_uid":"device-123"}'
```

**Response (First Login):**

```json
{
  "success": true,
  "message": "Device registered successfully!",
  "user": {
    "id": 1,
    "name": "Master Admin",
    "email": "admin@quarryforce.local",
    "role": "admin"
  }
}
```

**Response (Device Mismatch):**

```json
{
  "success": false,
  "message": "Security Error: This account is locked to another device. Contact admin to reset."
}
```

---

### 3. POST Check-in (GPS Verification)

**Endpoint:** `/api/checkin`
**Method:** POST
**Purpose:** Verify rep is within GPS radius of customer location

**Request Body:**

```json
{
  "rep_id": 2,
  "customer_id": 1,
  "rep_lat": 12.9716,
  "rep_lng": 77.5946
}
```

**cURL Example:**

```bash
curl -X POST http://localhost:3000/api/checkin \
  -H "Content-Type: application/json" \
  -d '{"rep_id":2,"customer_id":1,"rep_lat":12.9716,"rep_lng":77.5946}'
```

**Response (Success):**

```json
{
  "success": true,
  "message": "Location verified! You are 25m from the site.",
  "distance": 25,
  "limit": 50
}
```

**Response (Too Far Away):**

```json
{
  "success": false,
  "message": "Check-in denied. You are 150m away. Limit is 50m.",
  "distance": 150,
  "limit": 50
}
```

---

### 4. POST Submit Visit

**Endpoint:** `/api/visit/submit`
**Method:** POST
**Purpose:** Save completed site visit with requirements

**Request Body:**

```json
{
  "rep_id": 2,
  "customer_id": 1,
  "lat": 12.9716,
  "lng": 77.5946,
  "distance": 25,
  "requirements": {
    "material_type": "M-Sand",
    "tonnage": 500,
    "frequency": "weekly",
    "project_deadline": "2026-03-31"
  }
}
```

**Response:**

```json
{
  "success": true,
  "message": "Visit recorded successfully!"
}
```

---

### 5. POST Submit Fuel Log

**Endpoint:** `/api/fuel/submit`
**Method:** POST
**Purpose:** Record fuel purchase with GPS validation

**Request Body:**

```json
{
  "rep_id": 2,
  "odometer_reading": 45250,
  "fuel_quantity": 40,
  "amount": 2000,
  "lat": 12.9716,
  "lng": 77.5946
}
```

**Response:**

```json
{
  "success": true,
  "message": "Fuel log recorded successfully!"
}
```

---

### 6. GET All Reps (Admin)

**Endpoint:** `/api/admin/reps`
**Method:** GET
**Purpose:** Admin dashboard - view all field reps

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 2,
      "name": "John Doe",
      "email": "john@quarry.com",
      "role": "rep",
      "is_active": 1
    }
  ]
}
```

---

### 7. GET All Customers (Admin)

**Endpoint:** `/api/admin/customers`
**Method:** GET
**Purpose:** Admin dashboard - view all customer locations

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Test Site - Office",
      "lat": 12.9716,
      "lng": 77.5946,
      "status": "verified",
      "assigned_rep_id": 2,
      "assigned_rep_name": "John Doe"
    }
  ]
}
```

---

### 8. POST Reset Device Lock (Admin)

**Endpoint:** `/api/admin/reset-device`
**Method:** POST
**Purpose:** Unlock rep to use a new phone

**Request Body:**

```json
{
  "user_id": 2
}
```

**Response:**

```json
{
  "success": true,
  "message": "Device lock reset. Rep can register a new phone."
}
```

---

## 🧪 Quick Testing Steps

### Step 1: Verify Server Status

```bash
# Check if server is running
curl http://localhost:3000/test
```

### Step 2: Get Settings

```bash
curl http://localhost:3000/api/settings
```

### Step 3: Test Login

```bash
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@quarryforce.local","device_uid":"device-001"}'
```

### Step 4: Test Check-in (Use test customer coordinates)

First, add test data to your database in phpMyAdmin:

- Customer ID: 1
- Location: 12.9716, 77.5946
- Rep: admin

Then test:

```bash
curl -X POST http://localhost:3000/api/checkin \
  -H "Content-Type: application/json" \
  -d '{"rep_id":1,"customer_id":1,"rep_lat":12.9716,"rep_lng":77.5946}'
```

---

## 📂 Folder Structure

```
d:\quarryforce\
├── .env                       # Database credentials
├── db.js                      # Database connection
├── index.js                   # Main server file (all APIs)
├── package.json               # NPM dependencies
├── node_modules/              # Installed packages
└── API_DOCUMENTATION.md       # This file
```

---

## 🔧 Environment Variables (.env)

```
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASS=
DB_NAME=quarryforce
JWT_SECRET=your_secret_key_here
```

---

## 🛠️ Next Steps for Development

### Phase 1: Mobile App Integration

1. Set up Flutter project
2. Implement `/api/login` for authentication
3. Implement `/api/settings` to fetch GPS radius
4. Build camera screens for site photos and selfies

### Phase 2: Photo Upload

1. Enable multer for image uploads
2. Create `/api/upload/visit` endpoint
3. Store photos in `/uploads/` folder
4. Update database with photo paths

### Phase 3: Admin Dashboard

1. Create `/admin/` routes for web interface
2. Build real-time GPS map showing rep locations
3. Add settings editor for configurable values
4. Create commission calculator

### Phase 4: Deployment to Namecheap

1. Export database from XAMPP
2. Set up Node.js on Namecheap (via cPanel)
3. Push code to GitHub
4. Configure production `.env` file

---

## 🐛 Troubleshooting

### "Cannot connect to database"

- ✅ Check XAMPP MySQL is running (green in Control Panel)
- ✅ Verify database name is `quarryforce`
- ✅ Check `.env` file has correct credentials

### "Cannot find module 'geolib'"

```bash
npm install geolib
```

### "Address already in use :3000"

- Kill the running process: `netstat -ano | findstr :3000`
- Then: `taskkill /PID [PID_NUMBER] /F`

---

## 📊 Database Tables Reference

| Table             | Purpose                                  |
| ----------------- | ---------------------------------------- |
| `system_settings` | App configuration (branding, GPS radius) |
| `users`           | Admin & rep accounts with device binding |
| `customers`       | Customer locations and rep assignment    |
| `visit_logs`      | Visit records with GPS verification      |
| `fuel_logs`       | Fuel purchase records with photos        |

---

## ✅ Development Checklist

- [x] Database tables created in XAMPP
- [x] Node.js server setup
- [x] `/api/settings` endpoint working
- [x] `/api/login` endpoint ready
- [x] `/api/checkin` GPS verification ready
- [ ] Photo upload functionality
- [ ] Mobile app integration
- [ ] Admin dashboard creation
- [ ] Namecheap deployment

---

**Last Updated:** February 27, 2026
**Backend Version:** 1.0.0
