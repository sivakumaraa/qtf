# Admin Dashboard - Rep Management System Redesign

**Status:** Design Phase  
**Date:** March 10, 2026  
**Scope:** Complete Rep lifecycle management with salary processing

---

## System Overview

Complete rep management flow from creation through monthly salary processing:

```
Create Rep → Bind Device → Configure Salary → Set Targets → Track Orders → Process Salary
     ↓           ↓              ↓              ↓              ↓              ↓
  Email      Manual/Auto    Components      Monthly       Payment        Generate
  Phone      via App        Settings        Goals         History        Slips
```

---

## 1. Rep Creation & Onboarding

### Fields Required

```
- Name (required)
- Email ID (required)
- Phone Number (required)
- Photo/Avatar
- Active Status
- Creation Date
```

### Device Binding Options

**Option A: Manual Binding (Admin)**

- Admin enters device UID manually
- Device gets locked to rep account
- Rep can activate remotely via mobile app

**Option B: Automatic Binding (Mobile App)**

- Rep installs mobile app
- Rep creates account with email/phone
- Mobile app sends device UID to backend
- Admin approves/confirms binding
- Device auto-registers to rep

### Database Schema

```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  mobile_no VARCHAR(20),
  role ENUM('admin', 'manager', 'supervisor', 'rep') DEFAULT 'rep',
  device_uid VARCHAR(255),
  device_bound_at TIMESTAMP NULL,
  photo LONGBLOB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## 2. Salary Configuration

### Salary Components Structure

```javascript
{
  rep_id: 1,
  fixed_salary: 15000,           // Monthly base salary
  petrol_allowance: 2000,         // Monthly petrol/transport
  salary_components: {
    fixed: 15000,
    petrol: 2000,
    bonus: 0,                      // Variable - based on sales
    fine: 0,                        // Variable - penalties
  },
  total_gross: 17000,              // fixed + petrol (constant)
  effective_salary: 17000,         // gross + bonus - fine (variable)
}
```

### Salary Components in Detail

| Component        | Type     | Source         | Frequency      |
| ---------------- | -------- | -------------- | -------------- |
| Fixed Salary     | Fixed    | Config         | Monthly        |
| Petrol Allowance | Fixed    | Config         | Monthly        |
| Bonus            | Variable | Sales > Target | Per Sale Entry |
| Fine             | Variable | Admin          | Per Incident   |
| Deduction        | Variable | System         | Per Rule       |

### API Endpoints Needed

```
GET    /api/admin/rep-salary/{repId}              - Get salary config
PUT    /api/admin/rep-salary/{repId}              - Update salary components
GET    /api/admin/rep-salary/{repId}/history      - Salary history
POST   /api/admin/rep-salary/{repId}/fine         - Apply fine
```

---

## 3. Target Management Integration

### Monthly Targets

```javascript
{
  rep_id: 1,
  month: '2026-03-01',
  monthly_sales_target_m3: 300,
  incentive_rate: 50,              // Bonus per m³ above target
  penalty_rate: 25,                // Penalty per m³ below target
  min_sales_for_bonus: 300,
  created_at: '2026-01-15',
  status: 'active'
}
```

---

## 4. Order Tracking

### Order Status Workflow

```
Pending → Confirmed → Delivered → Paid
   ↓          ↓            ↓         ↓
Create    Record     Complete    Payment
          Sales      Delivery    Received
```

### Order Details

```javascript
{
  id: 1,
  rep_id: 1,
  customer_id: 5,
  order_date: '2026-03-08',
  delivery_date: '2026-03-10',
  order_amount: 5000,
  paid_amount: 5000,
  payment_status: 'paid',           // pending, partial, paid
  order_status: 'delivered',        // pending, confirmed, delivered
  payment_date: '2026-03-12'
}
```

---

## 5. Monthly Salary Processing

### Salary Calculation Workflow

```
For each rep in current month:

1. Get Fixed Components
   - fixed_salary = 15000
   - petrol_allowance = 2000
   - gross_salary = 17000

2. Get Variable Components
   - bonus_earned = SUM(bonus from all sales)
   - fine_deducted = SUM(fines applied)
   - order_commission = SUM(commissions)

3. Calculate Net Salary
   - net_salary = gross_salary + bonus_earned - fine_deducted + commission

4. Generate Salary Slip
   - Create salary_slip record
   - Calculate tax/deductions (if applicable)
   - Calculate net payable
   - Mark as 'processed' or 'pending_payment'

5. Record Payment
   - When payment confirmed
   - Update payment_date
   - Mark as 'paid'
```

### Salary Components Calculation

```
GROSS SALARY
├── Fixed Salary        15,000
├── Petrol Allowance     2,000
└── Gross Total         17,000

VARIABLE COMPONENTS
├── Bonus Earned          1,250  (3 sales × 50 per m³)
├── Fine Deducted         -500   (Penalty applied)
└── Commission              300  (Order completion bonus)

DEDUCTIONS
├── Tax                   -1,700  (10% of gross)
├── Insurance             -500
└── Other                 -200

NET SALARY = 17,000 + 1,250 - 500 + 300 - 1,700 - 500 - 200 = 15,650
```

### Database Schema

```sql
CREATE TABLE salary_components (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  fixed_salary DECIMAL(10, 2),
  petrol_allowance DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id)
);

CREATE TABLE salary_slips (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  month DATE,
  gross_salary DECIMAL(10, 2),
  bonus_earned DECIMAL(10, 2),
  fine_deducted DECIMAL(10, 2),
  total_deductions DECIMAL(10, 2),
  net_salary DECIMAL(10, 2),
  payment_status ENUM('pending', 'processed', 'paid') DEFAULT 'pending',
  payment_date DATE NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id)
);

CREATE TABLE rep_fines (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  amount DECIMAL(10, 2),
  reason VARCHAR(255),
  month DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id)
);
```

---

## 6. Admin Dashboard Screens

### Updated Navigation

```
Dashboard Tabs:
├── Overview (Statistics)
├── User Management (Create/Edit Reps)
├── Rep Details (View All Reps with Salary Info)
├── Target Management (Set Monthly Targets)
├── Sales Recording (Record Sales & Bonuses)
├── Salary Configuration (NEW - Set Salary Components)
├── Order Management (Track Orders)
├── Salary Processing (NEW - Monthly Salary Calculation)
├── Salary Slips (NEW - View & Download Slips)
├── Payment Tracking (NEW - Record Payments)
├── Fraud Alerts (Fraud Detection)
└── Analytics (Performance Metrics)
```

### New Components Needed

#### 1. **SalaryConfiguration.js**

- Set fixed salary per rep
- Set petrol allowance
- Manage default values
- View salary history

#### 2. **SalaryProcessing.js**

- Select month to process
- Calculate salary for all reps
- Apply fines/bonuses
- Generate salary slips
- Bulk payment processing

#### 3. **SalarySlips.js**

- View all salary slips
- Filter by rep/month
- Download PDF slip
- View slip details
- Payment history

#### 4. **PaymentTracking.js**

- Record payments
- Track payment status
- View payment history
- Generate payment reports

#### 5. **Enhanced RepDetails.js**

- Show salary components
- Show current month earnings
- Apply fines
- View salary history
- Device binding status

---

## 7. Flow Diagrams

### Rep Onboarding Flow

```
Admin Creates Rep
    ↓
Set Email & Phone
    ↓
Choose Device Binding:
  ├→ Manual: Admin enters Device UID
  └→ Auto: Rep uses Mobile App
    ↓
Configure Salary (Fixed + Petrol)
    ↓
Set Monthly Targets
    ↓
Rep Ready for Operations
```

### Monthly Salary Processing Flow

```
Month End (e.g., 31st March)
    ↓
Admin: "Process Salary for March"
    ↓
System:
  ├─ Collects all sales recorded
  ├─ Applies calculated bonuses/penalties
  ├─ Retrieves fines applied
  ├─ Calculates deductions
    ↓
Generate Salary Slip for each Rep
    ↓
Display in "Salary Slips" tab
    ↓
Admin Reviews & Confirms
    ↓
Record Payment (manually or automated)
    ↓
Update Payment Status to "Paid"
```

---

## 8. Implementation Priority

### Phase 1 (Critical)

- [ ] Enhance RepDetails.js (add petrol, fine fields)
- [ ] Create SalaryConfiguration.js
- [ ] Create Rep fine recording system

### Phase 2 (High)

- [ ] Create SalaryProcessing.js (monthly calculation)
- [ ] Create SalarySlips.js (view & download)
- [ ] Create PaymentTracking.js

### Phase 3 (Medium)

- [ ] PDF salary slip generation
- [ ] Bulk payment processing
- [ ] Email notifications

### Phase 4 (Future)

- [ ] Mobile app device binding integration
- [ ] Automated payment gateway integration
- [ ] Tax/compliance calculations

---

## 9. API Endpoints Summary

```
REP MANAGEMENT
POST   /api/admin/users                     - Create rep
PUT    /api/admin/users/{id}                - Update rep
GET    /api/admin/users                     - Get all users
GET    /api/admin/users/{id}                - Get rep details

SALARY CONFIGURATION
POST   /api/admin/rep-salary                - Create salary config
GET    /api/admin/rep-salary/{repId}        - Get salary config
PUT    /api/admin/rep-salary/{repId}        - Update salary config

FINES & ADJUSTMENTS
POST   /api/admin/rep-fines                 - Apply fine
GET    /api/admin/rep-fines/{repId}         - Get rep fines

SALARY PROCESSING
POST   /api/admin/salary/process-month      - Process monthly salary
GET    /api/admin/salary-slips              - Get all salary slips
GET    /api/admin/salary-slips/{repId}      - Get rep's salary slips

PAYMENTS
POST   /api/admin/payments                  - Record payment
PUT    /api/admin/payments/{id}             - Update payment
GET    /api/admin/payments                  - Get all payments
```

---

## 10. UI/UX Considerations

### Rep Details Table Enhancements

- Add columns: Fixed Salary, Petrol, Current Month Earnings
- Add action buttons: Edit Salary, Apply Fine, View SalarySlips
- Device binding status indicator
- Quick view modal for salary breakdown

### Salary Processing Screen

- Month selector
- Preview calculations before confirmation
- Bulk action support
- Export to Excel
- Undo option for 24 hours

### Salary Slip Design

- Professional PDF layout
- Include: Fixed + Variable + Deductions
- QR code for verification
- Digital signature support
- Print & email options

---

## Success Criteria

✅ Rep creation with complete onboarding  
✅ Salary components configurable per rep  
✅ Device binding (manual & automatic)  
✅ Monthly salary calculation accurate  
✅ Salary slips generated and downloadable  
✅ Payment tracking functional  
✅ Admin panel shows all details  
✅ Mobile app integration ready

---
