# QuarryForce Tracker - Complete System Architecture & Implementation Guide

**Date:** February 27, 2026  
**Version:** 1.0.0  
**Status:** Backend Core Complete, Ready for Dashboard UI & Mobile App

---

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [Technology Stack](#technology-stack)
3. [Database Schema](#database-schema)
4. [Core Features](#core-features)
5. [API Documentation](#api-documentation)
6. [Setup Instructions](#setup-instructions)
7. [Rep Targets & Compensation](#rep-targets--compensation)
8. [Fraud Detection System](#fraud-detection-system)
9. [Admin Dashboard Requirements](#admin-dashboard-requirements)
10. [Testing & Deployment](#testing--deployment)

---

## 🎯 System Overview

**QuarryForce Tracker** is a comprehensive field sales accountability system designed for quarry marketing teams. It combines:

- **GPS-verified check-ins** with geofencing
- **Device binding security** (one phone per rep)
- **Personalized sales targets** with automatic compensation calculations
- **Fraud detection** to prevent cheating and fake claims
- **Territory management** to prevent customer conflicts
- **Real-time monitoring** for management oversight

### Business Goals

✅ Ensure reps actually visit customer sites (GPS verification)  
✅ Prevent account sharing (device binding)  
✅ Measure performance fairly (sales targets + fraud detection)  
✅ Calculate compensation accurately (bonus/penalty system)  
✅ Prevent loss from fraud (AI-powered detection)  
✅ Build accountability and trust (audit trails)

---

## 🏗️ Technology Stack

| Layer               | Technology         | Purpose                    |
| ------------------- | ------------------ | -------------------------- |
| **Frontend**        | Flutter            | Mobile app for field reps  |
| **Backend**         | PHP 8.2+ (XAMPP)   | API & business logic       |
| **Database**        | MySQL              | Data persistence           |
| **GPS Library**     | geolib (Haversine) | Distance calculation       |
| **Hosting**         | Namecheap Stellar  | Production deployment      |
| **Local Dev**       | XAMPP              | MySQL + Apache for testing |
| **Testing**         | Postman            | API validation             |
| **Version Control** | GitHub             | Code repository            |

### Environment Setup

```
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASS=
DB_NAME=quarryforce
```

---

## 💾 Database Schema

### Overview

```
6 Tables:
├─ system_settings (Configuration)
├─ users (Field reps + Admin)
├─ customers (Quarry sites)
├─ visit_logs (Daily check-ins)
├─ fuel_logs (Fuel tracking)
├─ rep_targets (Personalized targets)
└─ rep_progress (Monthly compensation tracking)
```

### Table Specifications

#### 1. **system_settings** - Global Configuration

```sql
id                          INT PRIMARY KEY
company_name                VARCHAR - e.g., "QuarryForce"
gps_radius_limit            INT - Default 50 meters for geofencing
device_binding_enabled      BOOLEAN - Force one phone per account
allow_mock_location         BOOLEAN - Block fake GPS apps
fraud_detection_enabled     BOOLEAN - Enable AI fraud checks
```

#### 2. **users** - Field Reps & Admin

```sql
id                          INT PRIMARY KEY AUTO_INCREMENT
name                        VARCHAR
email                       VARCHAR UNIQUE
password_hash               VARCHAR - Hashed password
role                        ENUM - 'rep', 'admin', 'owner'
device_uid                  VARCHAR - Unique phone identifier
device_uid_binding_time     TIMESTAMP - When device was bound
is_active                   BOOLEAN - Account active/inactive
created_at                  TIMESTAMP
updated_at                  TIMESTAMP
created_by                  INT - Foreign key to users
is_deleted                  BOOLEAN - Soft delete flag
```

#### 3. **customers** - Quarry Sites

```sql
id                          INT PRIMARY KEY AUTO_INCREMENT
name                        VARCHAR - Site name
latitude                    DECIMAL(10,8) - GPS coordinates
longitude                   DECIMAL(11,8)
assigned_rep_id             INT - Territory lock (one rep per site)
status                      ENUM - 'active', 'inactive', 'prospect'
created_by                  INT - Foreign key
created_at                  TIMESTAMP
is_deleted                  BOOLEAN
```

#### 4. **visit_logs** - Daily Check-ins

```sql
id                          INT PRIMARY KEY AUTO_INCREMENT
customer_id                 INT - Which site visited
rep_id                      INT - Which rep
check_in_time               TIMESTAMP
requirements_json           JSON - Visit notes/requirements
site_photo_path             VARCHAR - Photo of site
rep_selfie_path             VARCHAR - Rep selfie for verification
lat_at_submission           DECIMAL - GPS at check-in
lng_at_submission           DECIMAL
distance_meters             DECIMAL - Distance from site (Haversine)
gps_verified                BOOLEAN - Within geofence?
fraud_score                 INT - Fraud detection score (0-100)
fraud_alert                 BOOLEAN - Flagged for review?
created_at                  TIMESTAMP
UNIQUE (customer_id, rep_id, DATE(check_in_time)) - Prevent duplicates
```

#### 5. **fuel_logs** - Fuel Tracking

```sql
id                          INT PRIMARY KEY AUTO_INCREMENT
rep_id                      INT
odometer_reading            INT - Vehicle mileage
fuel_quantity_liters        DECIMAL
total_amount                DECIMAL - Cost in ₹
odometer_photo              VARCHAR - Photo of odometer
pump_reading_photo          VARCHAR - Photo of pump display
rep_selfie_path             VARCHAR - Rep verification photo
lat                         DECIMAL - Location where fuel purchased
lng                         DECIMAL
logged_at                   TIMESTAMP
fraud_score                 INT
fraud_alert                 BOOLEAN
created_at                  TIMESTAMP
```

#### 6. **rep_targets** - Personalized Sales Targets (NEW)

```sql
id                          INT PRIMARY KEY AUTO_INCREMENT
rep_id                      INT UNIQUE - One target set per rep
monthly_sales_target_m3     DECIMAL(10,2) - e.g., 300 cubic meters
incentive_rate_per_m3       DECIMAL(10,2) - e.g., ₹5 bonus per m³
incentive_rate_max_per_m3   DECIMAL(10,2) - e.g., ₹9 max incentive
penalty_rate_per_m3         DECIMAL(10,2) - e.g., ₹50 per m³ shortfall
status                      ENUM - 'active', 'inactive'
created_at                  TIMESTAMP
updated_at                  TIMESTAMP
updated_by                  INT - Who made the change
FOREIGN KEY (rep_id) REFERENCES users(id)
FOREIGN KEY (updated_by) REFERENCES users(id)
```

#### 7. **rep_progress** - Monthly Compensation Tracking (NEW)

```sql
id                          INT PRIMARY KEY AUTO_INCREMENT
rep_id                      INT - Which rep
month                       DATE - First day of month (2026-02-01)
sales_volume_m3             DECIMAL(10,2) - Actual sales achieved
bonus_earned                DECIMAL(10,2) - AUTO-CALCULATED
penalty_amount              DECIMAL(10,2) - AUTO-CALCULATED
net_compensation            DECIMAL(10,2) - AUTO-CALCULATED (bonus - penalty)
status                      ENUM - 'pending' (editable), 'finalized' (locked)
created_at                  TIMESTAMP
updated_at                  TIMESTAMP
UNIQUE (rep_id, month) - One entry per rep per month
FOREIGN KEY (rep_id) REFERENCES users(id)
```

---

## ✨ Core Features

### 1. GPS Verification with Geofencing

**Problem:** Reps claim to visit sites they never actually go to.

**Solution:**

```javascript
// Haversine formula for distance calculation
const distance = geolib.getDistance(
  { latitude: rep_lat, longitude: rep_lng },
  { latitude: site_lat, longitude: site_lng },
);

// Check if within geofence (default 50m)
if (distance <= gps_radius_limit) {
  gps_verified = true;
  distance_meters = distance;
} else {
  fraud_alert = true;
  fraud_score += 40;
}
```

**API Endpoint:**

```
POST /api/checkin
Body: { rep_id, customer_id, rep_lat, rep_lng }
Response: { gps_verified, distance_meters, success, location_name }
```

### 2. Device Binding Security

**Problem:** One account can be used on multiple phones simultaneously.

**Solution:**

```javascript
// First login: Bind device
if (!user.device_uid) {
  UPDATE user SET device_uid = incoming_device_uid;
  // "Device registered successfully"
}

// Returning user: Must use same device
else if (user.device_uid === incoming_device_uid) {
  LOGIN_ALLOWED;
} else {
  LOGIN_BLOCKED;
  fraud_alert = true;
  fraud_score = 100;
  // "Account locked to another device. Contact admin."
}
```

**API Endpoint:**

```
POST /api/login
Body: { email, device_uid }
Response: { success, user, message }
```

### 3. Territory Locking

**Problem:** Multiple reps compete for same sites, creating conflicts.

**Solution:**

```sql
-- One rep per customer (unique constraint)
ALTER TABLE customers ADD UNIQUE(assigned_rep_id, id);

-- When checking in:
SELECT assigned_rep_id FROM customers WHERE id = customer_id;
IF assigned_rep_id != current_rep_id THEN
  DENY_CHECKIN;
  fraud_score += 50;
END IF;
```

### 4. Personalized Sales Targets with Auto-Compensation

**Problem:** Need to measure performance fairly and prevent cheating.

**Solution:**

```
Each rep has personalized targets:
┌─ John Doe (Rep 2)
│  ├─ Target: 300 m³/month
│  ├─ Bonus: ₹5/m³ above target
│  ├─ Penalty: ₹50/m³ below target
│  └─ Example: Achieves 350 m³
│     ├─ Excess: 50 m³
│     ├─ Bonus: 50 × ₹5 = ₹250 ✓
│     └─ Net: +₹250
│
└─ Jane Smith (Rep 3)
   ├─ Target: 300 m³/month (can be different!)
   ├─ Bonus: ₹6/m³ above target
   ├─ Penalty: ₹60/m³ below target
   └─ Example: Achieves 200 m³
      ├─ Shortfall: 100 m³
      ├─ Penalty: 100 × ₹60 = ₹6,000 ✗
      └─ Net: -₹6,000 (deducted from salary)
```

**Auto-Calculation Logic:**

```javascript
if (sales_volume_m3 > target_m3) {
  excess = sales_volume_m3 - target_m3;
  bonus = excess * incentive_rate_per_m3;
  penalty = 0;
} else if (sales_volume_m3 < target_m3) {
  shortfall = target_m3 - sales_volume_m3;
  bonus = 0;
  penalty = shortfall * penalty_rate_per_m3;
}

net_compensation = bonus - penalty;
// Update rep_progress table
```

**Key Features:**

- ✅ Every rep can have DIFFERENT targets
- ✅ All fields are EDITABLE anytime
- ✅ Changes take effect IMMEDIATELY
- ✅ No code changes needed (database-driven)
- ✅ Audit trail tracks who changed what

### 5. Fraud Detection System

**Problem:** Reps can cheat in multiple ways:

- Use fake GPS apps (GPS spoofing)
- Claim fake photos
- Report impossible travel speeds
- Stay in one location but claim multiple visits

**Detection Methods:**

```
1. GPS Spoofing Detection
   └─ Check if mock locations are active on device
      └─ Fraud Score: +50 if detected

2. Impossible Travel Speed
   └─ Calculate speed between visits
   └─ If speed > 200 km/h: Fraud alert
   └─ Fraud Score: +40

3. Distance Validation
   └─ If visits >> distance (20 visits in 8km)
   └─ Physically impossible
   └─ Fraud Score: +60

4. Photo Verification
   └─ Check for duplicate photos
   └─ AI verification of photo relevance
   └─ Fraud Score: +45 if duplicates

5. Pattern Recognition
   └─ Machine learning models detect anomalies
   └─ Stationary location for 2+ hours
   └─ Fraud Score: +30

6. Time Analysis
   └─ Visit duration too short (<5 min)
   └─ Too many visits in short time
   └─ Fraud Score: +20
```

**Fraud Score Thresholds:**

```
0-30:   Green ✅ - Verified (Low risk)
31-70:  Yellow ⚠️  - Suspicious (Review recommended)
71-100: Red 🚫 - Fraud Detected (Block account)
```

---

## 📡 API Documentation

### Complete API List (16 Endpoints)

#### Settings & Security

```
1. GET /api/settings
   → Returns system configuration
   Response: { gps_radius_limit, device_binding_enabled, ... }

2. POST /api/login
   → Device binding login
   Body: { email, device_uid }
   Response: { success, user, message }

3. POST /api/admin/reset-device
   → Admin unlocks rep's phone binding
   Body: { rep_id, updated_by }
   Response: { success }
```

#### Field Operations

```
4. POST /api/checkin
   → GPS verification before visit
   Body: { rep_id, customer_id, rep_lat, rep_lng }
   Response: { gps_verified, distance_meters, location_name }

5. POST /api/visit/submit
   → Record visit with photos
   Body: {
     customer_id, rep_id,
     requirements_json,
     site_photo_path, rep_selfie_path,
     lat_at_submission, lng_at_submission
   }
   Response: { success, visit_id }

6. POST /api/fuel/submit
   → Log fuel purchase
   Body: {
     rep_id, odometer_reading, fuel_quantity_liters,
     total_amount, odometer_photo, pump_reading_photo,
     rep_selfie_path, lat, lng
   }
   Response: { success, fuel_log_id }
```

#### Admin Management

```
7. GET /api/admin/reps
   → List all field reps
   Response: { data: [{ id, name, email, role, ... }] }

8. GET /api/admin/customers
   → List all customer sites
   Response: { data: [{ id, name, lat, lng, assigned_rep_id, ... }] }
```

#### Rep Targets (New)

```
9. GET /api/admin/rep-targets
   → View all reps' targets
   Response: { data: [{ rep_id, monthly_sales_target_m3, incentive_rate_per_m3, ... }] }

10. GET /api/admin/rep-targets/:rep_id
    → View specific rep's targets
    Response: { data: { rep_id, rep_name, ... all target fields } }

11. POST /api/admin/rep-targets
    → Set/create targets for a rep
    Body: {
      rep_id, monthly_sales_target_m3,
      incentive_rate_per_m3, incentive_rate_max_per_m3,
      penalty_rate_per_m3, updated_by
    }
    Response: { success, message }

12. PUT /api/admin/rep-targets/:rep_id
    → Update specific target fields (partial update)
    Body: { monthly_sales_target_m3, penalty_rate_per_m3, ... }
    Response: { success, message }
```

#### Progress & Compensation (New)

```
13. POST /api/admin/rep-progress/update
    → Record monthly sales, auto-calculate bonus/penalty
    Body: { rep_id, sales_volume_m3, month: "2026-02-01" }
    Response: {
      success, data: {
        sales_volume_m3, bonus_earned,
        penalty_amount, net_compensation
      }
    }

14. GET /api/admin/rep-progress/:rep_id
    → View rep's monthly progress
    Query: ?month=2026-02-01 (optional, defaults to current)
    Response: { data: { sales_volume_m3, bonus_earned, penalty_amount, ... } }
```

#### Diagnostics

```
15. GET /test
    → Health check endpoint
    Response: { success: true, message: "Server is running" }

16. GET /
    → Welcome page with all APIs listed
    Response: { success, version, apis: { ... all endpoints } }
```

---

## 🚀 Setup Instructions

### Step 1: Create Database Tables

**Location:** `d:\quarryforce\REP_TARGETS_SETUP.sql`

1. Open phpMyAdmin: http://localhost/phpMyAdmin
2. Select database: **quarryforce**
3. Click **SQL** tab
4. Copy ALL content from `REP_TARGETS_SETUP.sql`
5. Paste into SQL editor
6. Click **Go**

Tables created:

- ✅ `rep_targets` - Personalized sales targets
- ✅ `rep_progress` - Monthly compensation tracking

### Step 2: Verify Existing Tables

These should already exist from previous setup:

- ✅ `system_settings` - Configuration
- ✅ `users` - Field reps & admin
- ✅ `customers` - Quarry sites
- ✅ `visit_logs` - Check-in records
- ✅ `fuel_logs` - Fuel records

### Step 3: Verify Backend is Running

```bash
# In PowerShell, navigate to project directory
cd d:\quarryforce

# Start server
php -S localhost:8000

# Expected output:
# Server running on port 3000
# Database connected successfully
```

### Step 4: Test Welcome Endpoint

```bash
# In PowerShell
Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing | Select-Object -ExpandProperty Content

# Should show all 16 APIs ✅
```

---

## 💰 Rep Targets & Compensation System

### Overview

```
Admin sets personalized targets for each rep
    ↓
Rep works in field (visits customers, records sales)
    ↓
Admin records monthly sales volume
    ↓
System auto-calculates bonus/penalty
    ↓
Compensation report generated for payroll
```

### Workflow Example

**Setup (January):**

```bash
# Admin sets John Doe's targets for 2026
POST /api/admin/rep-targets
{
  "rep_id": 2,
  "monthly_sales_target_m3": 300,
  "incentive_rate_per_m3": 5,
  "incentive_rate_max_per_m3": 9,
  "penalty_rate_per_m3": 50,
  "updated_by": 1
}

Response: "Targets set successfully!"
```

**Month End (February 28):**

```bash
# Admin receives sales data for February
# Records John Doe's actual sales: 350 m³
POST /api/admin/rep-progress/update
{
  "rep_id": 2,
  "sales_volume_m3": 350,
  "month": "2026-02-01"
}

Response: {
  "sales_volume_m3": 350,
  "bonus_earned": 250,        // (350-300) × ₹5
  "penalty_amount": 0,
  "net_compensation": 250     // Added to paycheck
}
```

**Mid-Month Update (If needed):**

```bash
# Admin discovers John needs higher targets
PUT /api/admin/rep-targets/2
{
  "monthly_sales_target_m3": 350,
  "penalty_rate_per_m3": 60,
  "updated_by": 1
}

Response: "Targets updated successfully!"
```

### Key Features

✅ **Per-rep customization** - Each rep has different targets  
✅ **Editable anytime** - Update without code changes  
✅ **Auto-calculation** - No manual math needed  
✅ **Real-time updates** - Changes effective immediately  
✅ **Audit trail** - Track who changed what and when  
✅ **Flexible rates** - Adjust incentives based on territory/experience

---

## 🚨 Fraud Detection System

### Integration Points

The fraud detection system works with all field operations:

```
Visit Check-in:
├─ GPS Spoofing Detection
├─ Device Binding Verification
├─ Territory Lock Check
└─ Calculate Fraud Score

Visit Submission:
├─ Photo Duplicate Detection
├─ Distance Validation
├─ Time Analysis
├─ Pattern Recognition
└─ Update Fraud Score

Fuel Log:
├─ Impossible Travel Speed Check
├─ Location Verification
├─ Pattern Analysis
└─ Fraud Alert if suspicious
```

### Fraud Score Calculation

```javascript
fraudScore = 0;

// GPS Spoofing Check
if (mockLocationDetected) fraudScore += 50;

// Impossible Travel Speed
if (speedBetweenVisits > 200) fraudScore += 40;

// Impossible Distance-to-Visits Ratio
if (visits > distance / 5) fraudScore += 60;

// Duplicate Photos
if (photoIsDuplicate) fraudScore += 45;

// Stationary Duration
if (durationInOneLocation > 120) fraudScore += 30;

// Short Visit Duration
if (visitDuration < 5) fraudScore += 20;

// Final Status
if (fraudScore >= 71) STATUS = "FRAUD_DETECTED";
else if (fraudScore >= 31) STATUS = "SUSPICIOUS";
else STATUS = "VERIFIED";
```

### Admin Dashboard Monitoring

The admin needs to see:

```
Dashboard Overview:
├─ Active Executives: 4/5
├─ Total Visits Today: 45
├─ Distance Covered: 145.8 km
├─ Suspicious Flags: 1
└─ Fraud Detected: 1

Executive Cards:
├─ Status: Active/Suspicious/Fraud Detected
├─ Fraud Score: 0-100
├─ Current Location (GPS coordinates)
├─ Today's Stats: Visits, Leads, Distance, Calls
└─ Active Alerts with severity levels

Visit Verification Log:
├─ Executive name
├─ Customer
├─ Location
├─ Time & Duration
├─ Distance traveled
├─ Photo verification
├─ GPS verification
└─ Final status (VERIFIED/FRAUD)

Analytics:
├─ Fraud attempts blocked: N
├─ GPS spoofing detected: N
├─ Fake photos caught: N
├─ Money saved (prevented losses): ₹X
└─ Verification rates (GPS: %, Photos: %, Distance: %)
```

---

## 📊 Admin Dashboard Requirements

### Screenshots from HTML File

The admin dashboard displays:

1. **Overview Tab**
   - Quick stats (active execs, visits, distance, suspicious, fraud)
   - Executive cards with fraud scores
   - Current locations and daily stats
   - Active alerts

2. **Fraud Alerts Tab**
   - Detected fraud patterns
   - Anti-cheating protocols status
   - Pattern severity levels

3. **Visit Logs Tab**
   - Detailed table of all visits
   - Verification status for each visit
   - Easy fraud identification

4. **Analytics Tab**
   - Fraud prevention metrics
   - Verification rates
   - Cost savings from prevented losses

### UI Components Needed

- Real-time location maps with GPS coordinates
- Fraud score indicators (color-coded)
- Alert system with severity levels
- Visit log tables with filtering
- Compensation calculator display
- Executive performance cards

---

## 🧪 Testing & Deployment

### Local Testing with Postman

**Collection Endpoints:**

1. **Test Health Check**

```
GET http://localhost:3000/test
Expected: { success: true }
```

2. **Create Rep Target**

```
POST http://localhost:3000/api/admin/rep-targets
Body: {
  "rep_id": 2,
  "monthly_sales_target_m3": 300,
  "incentive_rate_per_m3": 5,
  "incentive_rate_max_per_m3": 9,
  "penalty_rate_per_m3": 50,
  "updated_by": 1
}
Expected: { success: true, message: "Targets set successfully!" }
```

3. **Record Sales (Auto-Calculate Bonus)**

```
POST http://localhost:3000/api/admin/rep-progress/update
Body: {
  "rep_id": 2,
  "sales_volume_m3": 350,
  "month": "2026-02-01"
}
Expected: { success: true, data: { bonus_earned: 250, ... } }
```

4. **View Progress**

```
GET http://localhost:3000/api/admin/rep-progress/2?month=2026-02-01
Expected: Monthly sales and compensation details
```

### Production Deployment

**Step 1: Prepare Code**

```bash
# In project root directory
git add .
git commit -m "Add rep targets and fraud detection"
git push origin main
```

**Step 2: Deploy to Namecheap Stellar Hosting**

```bash
# SSH into Namecheap Stellar hosting
ssh user@hosting.com

# Clone repository
git clone https://github.com/yourname/quarryforce.git

cd quarryforce/qft-deployment

# Create .env file with production credentials
cat > .env << EOF
DB_HOST=localhost
DB_USER=produser
DB_PASS=strongpassword
DB_NAME=quarryforce_prod
EOF

# PHP runs via Apache - no separate startup needed
# Apache automatically processes .php files
```

**Step 3: Configure Apache**

```bash
# .htaccess automatically routes traffic to api.php
# Make sure API routing is configured in api.php
# Add to .htaccess:

RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^api/(.*)$ api.php?route=$1 [QSA,L]
```

**Step 4: Verify Production**

```bash
# Test from your machine
curl https://yourapi.quarryforce.com/api/settings
```

---

````
## 📈 Implementation Phases

### ✅ Phase 1: Core Backend (COMPLETE)

- GPS verification with geofencing
- Device binding security
- Territory locking
- Rep targets system
- Auto-compensation calculation
- Fraud detection framework
- 16 production APIs

### 🔄 Phase 2: Dashboard UI (NEXT)

- React admin dashboard
- Real-time location tracking
- Fraud monitoring interface
- Visit verification logs
- Compensation calculator display

### 🔄 Phase 3: Mobile App (AFTER)

- Flutter field rep app
- GPS check-in interface
- Photo upload (with verification)
- Real-time target progress display
- Fuel logging

### 🔄 Phase 4: Advanced Features

- AI photo verification
- Real-time GPS tracking
- Commission reports
- Territory heat maps
- Predictive analytics

---

## 🎯 Quick Reference

### Common Admin Tasks

**Task 1: Set different targets for two reps**

```
POST /api/admin/rep-targets (John Doe - Rep 2)
POST /api/admin/rep-targets (Jane Smith - Rep 3)
Each can have different target, bonus rate, penalty rate
```

**Task 2: Record monthly sales and track compensation**

```
POST /api/admin/rep-progress/update (Record sales)
GET /api/admin/rep-progress/:rep_id (View bonus/penalty calculations)
```

**Task 3: Update target mid-month**

```
PUT /api/admin/rep-targets/:rep_id (Only the fields you want to change)
Changes take effect immediately
```

**Task 4: View fraud alerts**

```
Look for fraud_score > 70 in visit_logs
Review fraud_alert = true entries
Check visit fraud patterns
```

---

## 📞 Troubleshooting

**Q: Tables not created?**
A: Make sure you ran `REP_TARGETS_SETUP.sql` in phpMyAdmin and got success message.

**Q: API not finding targets?**
A: Check that rep_id exists in `users` table and targets were created in `rep_targets` table.

**Q: Bonus/penalty not calculating?**
A: Verify target and rates are set. POST to `/api/admin/rep-progress/update` to trigger calculation.

**Q: Server won't start?**
A: Check port 3000 isn't in use: `netstat -ano | findstr :3000`
Kill existing PHP: `taskkill /F /IM php.exe`

---

## ✨ Summary

**What's Working:**
✅ GPS verification (Haversine formula)
✅ Device binding security
✅ Territory locking
✅ 6 rep target & compensation APIs
✅ Fraud detection framework
✅ 16 total production APIs
✅ Auto-bonus/penalty calculation
✅ Database with 7 tables

**What's Next:**
🔲 Admin dashboard UI (React)
🔲 Real-time monitoring
🔲 Mobile app (Flutter)
🔲 Production deployment
🔲 Advanced fraud detection (AI)

**Status:** ✅ **READY FOR NEXT PHASE**

---

## 📚 Documentation Files

- `REP_TARGETS_SETUP.sql` - Database schema SQL script
- `REP_TARGETS_QUICK_SETUP.md` - 5-minute setup guide
- `REP_TARGETS_DOCUMENTATION.md` - Complete API reference
- This file - Complete system architecture guide

---

**Version:** 1.0.0
**Last Updated:** February 27, 2026
**Next Review:** After Phase 2 (Dashboard UI)
````
