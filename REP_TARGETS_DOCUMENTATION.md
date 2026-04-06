# Rep Targets & Compensation System

## Overview

QuarryForce now supports **personalized, editable sales targets** for each field rep. Each rep can have different targets based on territory, experience, or performance goals. The system automatically calculates bonuses and penalties based on actual sales.

---

## Database Schema

### 1. **rep_targets** Table - Personalized Target Settings

Stores customizable targets for each sales rep. Every field is **editable per rep**.

```sql
rep_id              INT     - Reference to user (unique per rep)
monthly_sales_target_m3   DECIMAL  - Minimum target in cubic meters (e.g., 300)
incentive_rate_per_m3     DECIMAL  - Bonus rate when exceeding target (₹ per m³, e.g., ₹5)
incentive_rate_max_per_m3 DECIMAL  - Optional: Max bonus rate (e.g., ₹9)
penalty_rate_per_m3       DECIMAL  - Fine rate for underperformance (₹ per m³, e.g., ₹50)
status                    ENUM     - 'active' or 'inactive'
```

**Example:**

```
Rep ID: 2 (John Doe)
├─ Target: 300 m³/month
├─ Bonus: ₹5/m³ above 300 m³
├─ Max Bonus: ₹9/m³ (if business wants to increase later)
└─ Penalty: ₹50/m³ below 300 m³

Rep ID: 3 (Jane Smith)
├─ Target: 300 m³/month  (same or different!)
├─ Bonus: ₹6/m³ above 300 m³
├─ Max Bonus: ₹10/m³
└─ Penalty: ₹60/m³ below 300 m³  (stricter penalties)
```

---

### 2. **rep_progress** Table - Monthly Sales & Compensation Tracking

Automatically tracks sales volume and calculates bonuses/penalties.

```sql
rep_id            INT     - Reference to user
month             DATE    - First day of month (e.g., 2026-02-01)
sales_volume_m3   DECIMAL - Total sales in cubic meters
bonus_earned      DECIMAL - AUTO-CALCULATED: excess × incentive_rate
penalty_amount    DECIMAL - AUTO-CALCULATED: shortfall × penalty_rate
net_compensation  DECIMAL - AUTO-CALCULATED: bonus - penalty
status            ENUM    - 'pending' (editable) or 'finalized' (locked)
```

**Auto-Calculation Example:**

```
If rep_id=2 (John Doe) achieves 350 m³:
├─ Target: 300 m³
├─ Excess: 350 - 300 = 50 m³
├─ Bonus: 50 × ₹5 = ₹250
├─ Penalty: ₹0 (met target)
└─ Net: ₹250

If rep_id=2 achieves 200 m³:
├─ Target: 300 m³
├─ Shortfall: 300 - 200 = 100 m³
├─ Penalty: 100 × ₹50 = ₹5,000
├─ Bonus: ₹0 (didn't exceed)
└─ Net: -₹5,000 (deducted from salary)
```

---

## API Endpoints

### 1. Get All Rep Targets

**Endpoint:** `GET /api/admin/rep-targets`

Returns all reps' targets with rep name and email.

```bash
curl -X GET http://localhost:3000/api/admin/rep-targets
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "rep_id": 2,
      "rep_name": "John Doe",
      "email": "john@example.com",
      "monthly_sales_target_m3": 300,
      "incentive_rate_per_m3": 5,
      "incentive_rate_max_per_m3": 9,
      "penalty_rate_per_m3": 50,
      "status": "active"
    }
  ]
}
```

---

### 2. Get Specific Rep Targets

**Endpoint:** `GET /api/admin/rep-targets/:rep_id`

```bash
curl -X GET http://localhost:3000/api/admin/rep-targets/2
```

---

### 3. Set Rep Targets (Create/Update)

**Endpoint:** `POST /api/admin/rep-targets`

Create new targets for a rep or update existing ones.

```bash
curl -X POST http://localhost:3000/api/admin/rep-targets \
  -H "Content-Type: application/json" \
  -d '{
    "rep_id": 2,
    "monthly_sales_target_m3": 300,
    "incentive_rate_per_m3": 5,
    "incentive_rate_max_per_m3": 9,
    "penalty_rate_per_m3": 50,
    "updated_by": 1
  }'
```

**Parameters:**

- `rep_id` (required) - Sales rep ID
- `monthly_sales_target_m3` (required) - Sales target in m³
- `incentive_rate_per_m3` (optional) - Bonus rate, default 5
- `incentive_rate_max_per_m3` (optional) - Max bonus rate, default 9
- `penalty_rate_per_m3` (optional) - Penalty rate, default 50
- `updated_by` (optional) - Admin ID who set targets

---

### 4. Update Rep Targets (Selective)

**Endpoint:** `PUT /api/admin/rep-targets/:rep_id`

Update specific fields without affecting others.

```bash
curl -X PUT http://localhost:3000/api/admin/rep-targets/2 \
  -H "Content-Type: application/json" \
  -d '{
    "monthly_sales_target_m3": 350,
    "penalty_rate_per_m3": 60,
    "updated_by": 1
  }'
```

---

### 5. Record Sales & View Progress

**Endpoint:** `POST /api/admin/rep-progress/update`

Record monthly sales volume. System auto-calculates bonus/penalty.

```bash
curl -X POST http://localhost:3000/api/admin/rep-progress/update \
  -H "Content-Type: application/json" \
  -d '{
    "rep_id": 2,
    "sales_volume_m3": 350,
    "month": "2026-02-01"
  }'
```

**Response:**

```json
{
  "success": true,
  "message": "Progress updated successfully!",
  "data": {
    "rep_id": 2,
    "month": "2026-02-01",
    "sales_volume_m3": 350,
    "bonus_earned": 250,
    "penalty_amount": 0,
    "net_compensation": 250,
    "target_m3": 300,
    "status": "pending"
  }
}
```

---

### 6. Get Rep Monthly Progress

**Endpoint:** `GET /api/admin/rep-progress/:rep_id`

View sales volume and compensation for a specific month.

```bash
curl -X GET 'http://localhost:3000/api/admin/rep-progress/2?month=2026-02-01'
```

**Parameters:**

- `month` (optional) - Format: YYYY-MM-01 (defaults to current month)

---

## Use Cases

### Scenario 1: Variable Targets for Different Reps

```
John Doe (new rep):
├─ Target: 300 m³/month
├─ Bonus: ₹5/m³
└─ Penalty: ₹50/m³

Jane Smith (experienced rep):
├─ Target: 500 m³/month  (higher target)
├─ Bonus: ₹8/m³  (higher reward)
└─ Penalty: ₹75/m³  (higher accountability)
```

### Scenario 2: Seasonal Adjustments

```
February (slow season):
├─ rep_id: 2
└─ Target: 300 m³

March (peak season):
├─ rep_id: 2
└─ Target: 450 m³  (increased)
```

### Scenario 3: Performance-Based Incentives

```
Rep exceeds target consistently:
├─ Increase incentive_rate_max_per_m3 to ₹10/m³
└─ Motivates higher performance

Rep underperforms:
├─ Increase penalty_rate_per_m3 to ₹75/m³
└─ Increases accountability
```

---

## Admin Dashboard Screen

The admin should see a screen like:

```
┌─────────────────────────────────────────────┐
│         REP TARGETS & COMPENSATION          │
├─────────────────────────────────────────────┤
│ Rep Name          │ Target │ Bonus │ Penalty │
├─────────────────────────────────────────────┤
│ John Doe          │ 300m³  │ ₹5   │ ₹50     │
│ Jane Smith        │ 300m³  │ ₹5   │ ₹50     │
│ Mike Johnson      │ 300m³  │ ₹5   │ ₹50     │
├─────────────────────────────────────────────┤
│ [Edit] [View Progress] [Set New Targets]    │
└─────────────────────────────────────────────┘
```

---

## SQL Setup Instructions

1. Go to **phpMyAdmin** (http://localhost/phpMyAdmin)
2. Select the **quarryforce** database
3. Click **SQL** tab
4. Copy and paste the contents of `REP_TARGETS_SETUP.sql`
5. Click **Go** to execute

The script will create both tables and insert default targets for existing reps.

---

## Testing with Postman

1. **Create Targets for Rep 2:**
   - Method: `POST`
   - URL: `http://localhost:3000/api/admin/rep-targets`
   - Body:
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

2. **Record Sales:**
   - Method: `POST`
   - URL: `http://localhost:3000/api/admin/rep-progress/update`
   - Body:
     ```json
     {
       "rep_id": 2,
       "sales_volume_m3": 350,
       "month": "2026-02-01"
     }
     ```

3. **View Progress:**
   - Method: `GET`
   - URL: `http://localhost:3000/api/admin/rep-progress/2?month=2026-02-01`

---

## Key Features

✅ **Personalized Targets** - Each rep has different goals  
✅ **Editable Anytime** - Update targets without code changes  
✅ **Auto-Calculation** - Bonuses and penalties computed automatically  
✅ **Audit Trail** - Track who updated targets and when  
✅ **Flexible Rates** - Adjust incentive/penalty rates per rep  
✅ **Status Tracking** - Mark months as 'pending' or 'finalized'

---

## Next Steps

1. ✅ Create database tables (run SQL script)
2. ✅ Test APIs with Postman
3. 🔲 Build Admin Dashboard UI
4. 🔲 Integrate with Mobile App
5. 🔲 Add reports & analytics
