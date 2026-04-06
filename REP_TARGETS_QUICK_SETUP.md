# Rep Targets - Quick Setup & Usage Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Create Database Tables

1. Open **phpMyAdmin**: http://localhost/phpMyAdmin
2. Select database: **quarryforce**
3. Click **SQL** tab
4. Open `REP_TARGETS_SETUP.sql` from your project folder
5. Copy ALL content and paste into SQL editor
6. Click **Go** ➜ Tables created! ✅

### Step 2: Verify API is Running

```bash
# In PowerShell, run:
Invoke-WebRequest http://localhost:3000/ | Select-Object -ExpandProperty Content
```

Should show 16 APIs including new targets endpoints ✅

---

## 📋 Compensation Structure

### How It Works

```
Sales Achievement → Auto-Calculate Bonus/Penalty

Example - John Doe (Rep ID: 2)
├─ Monthly Target: 300 m³
├─ Bonus Rate: ₹5 per m³ (above target)
├─ Penalty Rate: ₹50 per m³ (below target)
│
Scenario A: Achieves 350 m³
├─ Excess: 350 - 300 = 50 m³
├─ Bonus: 50 × ₹5 = ₹250 ✓
├─ Penalty: ₹0
└─ Net: +₹250

Scenario B: Achieves 200 m³
├─ Shortfall: 300 - 200 = 100 m³
├─ Penalty: 100 × ₹50 = ₹5,000 ✗
├─ Bonus: ₹0
└─ Net: -₹5,000 (deducted from salary)
```

---

## 🔧 Admin Operations

### 1️⃣ Set Targets for a Rep

```
POST /api/admin/rep-targets
```

**Body:**

```json
{
  "rep_id": 2,
  "monthly_sales_target_m3": 300,
  "incentive_rate_per_m3": 5,
  "incentive_rate_max_per_m3": 9,
  "penalty_rate_per_m3": 50,
  "updated_by": 1
}
```

✅ Can be different for each rep!

---

### 2️⃣ View All Reps' Targets

```
GET /api/admin/rep-targets
```

Response shows all reps with their personalized targets.

---

### 3️⃣ Update Specific Rep's Targets

```
PUT /api/admin/rep-targets/2
```

**Body (only update what you want):**

```json
{
  "monthly_sales_target_m3": 350,
  "penalty_rate_per_m3": 60,
  "updated_by": 1
}
```

---

### 4️⃣ Record Monthly Sales

```
POST /api/admin/rep-progress/update
```

**Body:**

```json
{
  "rep_id": 2,
  "sales_volume_m3": 350,
  "month": "2026-02-01"
}
```

✅ System auto-calculates bonus & penalty!

**Response:**

```json
{
  "bonus_earned": 250,
  "penalty_amount": 0,
  "net_compensation": 250
}
```

---

### 5️⃣ View Rep's Monthly Progress

```
GET /api/admin/rep-progress/2?month=2026-02-01
```

See sales volume, bonus, penalty, and net compensation.

---

## 📊 Personalization Examples

### Different Targets Per Territory

```
John Doe (Territory A):
├─ Target: 300 m³
├─ Bonus: ₹5/m³
└─ Penalty: ₹50/m³

Jane Smith (Territory B - higher potential):
├─ Target: 500 m³
├─ Bonus: ₹8/m³
└─ Penalty: ₹75/m³

Mike Johnson (Territory C - new rep):
├─ Target: 200 m³
├─ Bonus: ₹3/m³
└─ Penalty: ₹30/m³
```

---

### Seasonal Adjustments

```
February (Slow):
├─ All Reps: 300 m³ target

March (Busy):
├─ All Reps: 450 m³ target (increased 50%)

April-May (Peak):
├─ All Reps: 600 m³ target (doubled)
```

---

### Performance-Based Changes

```
Month 1: Sales = 200 m³ (underperforming)
├─ Update: Increase penalty to ₹75/m³

Month 3: Sales = 400 m³ (exceeding target)
├─ Reward: Increase bonus rate to ₹8/m³
├─ Update: Increase target to 450 m³
```

---

## ✅ Editable Fields Per Rep

| Field                       | Type            | Default | Editable? |
| --------------------------- | --------------- | ------- | --------- |
| `monthly_sales_target_m3`   | Decimal         | 300     | ✅ Yes    |
| `incentive_rate_per_m3`     | Decimal         | ₹5      | ✅ Yes    |
| `incentive_rate_max_per_m3` | Decimal         | ₹9      | ✅ Yes    |
| `penalty_rate_per_m3`       | Decimal         | ₹50     | ✅ Yes    |
| `status`                    | active/inactive | active  | ✅ Yes    |

Every field can be different for each rep! 🎯

---

## 🧪 Test with Postman

### Collection Endpoints:

1. **POST** `/api/admin/rep-targets` - Set targets
2. **GET** `/api/admin/rep-targets` - View all
3. **GET** `/api/admin/rep-targets/:rep_id` - View specific rep
4. **PUT** `/api/admin/rep-targets/:rep_id` - Update targets
5. **POST** `/api/admin/rep-progress/update` - Record sales
6. **GET** `/api/admin/rep-progress/:rep_id` - View progress

---

## 🎯 Common Use Cases

### Case 1: Monthly Compensation Review

```
Admin Job:
1. Get all reps' targets → GET /api/admin/rep-targets
2. Receive sales data for month
3. Record sales → POST /api/admin/rep-progress/update
4. System calculates bonuses automatically ✅
5. View results → GET /api/admin/rep-progress/:rep_id
6. Generate salary sheet
```

### Case 2: Adjust Targets Based on Performance

```
John Doe consistently exceeds target:
1. Current target: 300 m³, Bonus: ₹5/m³
2. Achievements: 350, 380, 400 m³
3. Decision: Increase target to 450 m³ (higher bar)
4. Action: PUT /api/admin/rep-targets/2 with new value
5. Feb target becomes 450 m³
```

### Case 3: Territory-Specific Targets

```
High-potential area (Jane):
├─ Target: 500 m³
├─ Bonus: ₹8/m³
└─ Penalty: ₹75/m³

Developing area (Mike):
├─ Target: 250 m³
├─ Bonus: ₹4/m³
└─ Penalty: ₹40/m³
```

---

## 📱 Mobile App Integration

The Flutter app will:

1. Fetch rep's targets → GET `/api/admin/rep-targets/:rep_id`
2. Display target vs achievement
3. Show bonus/penalty calculation in real-time
4. Admin updates targets from web dashboard
5. Mobile shows updated targets next refresh

---

## 🎓 API Response Examples

### Get Targets Response

```json
{
  "success": true,
  "data": {
    "id": 1,
    "rep_id": 2,
    "rep_name": "John Doe",
    "email": "john@example.com",
    "monthly_sales_target_m3": 300,
    "incentive_rate_per_m3": 5,
    "incentive_rate_max_per_m3": 9,
    "penalty_rate_per_m3": 50,
    "status": "active",
    "created_at": "2026-02-27T10:00:00Z",
    "updated_at": "2026-02-27T10:00:00Z"
  }
}
```

### Progress Response

```json
{
  "success": true,
  "data": {
    "rep_id": 2,
    "month": "2026-02-01",
    "sales_volume_m3": 350,
    "bonus_earned": 250,
    "penalty_amount": 0,
    "net_compensation": 250,
    "status": "pending",
    "target_m3": 300,
    "rep_name": "John Doe"
  }
}
```

---

## ⚠️ Important Notes

- ✅ Each rep can have **different targets** and rates
- ✅ Update targets **anytime** via API
- ✅ System **auto-calculates** bonuses/penalties
- ✅ Changes take effect **immediately**
- ✅ Use `updated_by` field to track who changed targets
- ✅ Set status to `'inactive'` to pause a rep

---

## 📞 Troubleshooting

**Q: Tables not created?**
A: Make sure you ran the SQL script in phpMyAdmin and got success message.

**Q: API not finding targets?**
A: Verify rep_id exists in `users` table and targets were created in `rep_targets` table.

**Q: Bonus/penalty not calculating?**
A: Check that target and rates are set. POST to `/api/admin/rep-progress/update` to record sales and trigger calculation.

---

## ✨ Next Phase: Remaining Pending Features

After targets are working:

1. Photo uploads (verify check-ins)
2. Flutter mobile app
3. Admin dashboard UI
4. Real-time tracking
5. Reports & analytics

This gives you **measurement and accountability** for reps before continuing! 🎯
