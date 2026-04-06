# Orders & Products Implementation - Admin Dashboard

## Overview

The admin dashboard implements a **conditional product/material selection system** based on customer requirements. Products are not a pre-defined catalog but rather dynamically available based on customer type and material needs.

---

## 1. Main Components & Architecture

### 1.1 OrdersManagement.js

**Location:** `admin-dashboard/src/components/OrdersManagement.js`

**Purpose:** Main component for managing all orders across customers

**Key Features:**

- Create new orders
- Edit existing orders
- Delete orders
- Display all orders in table format with customer/rep details

**Data Structure:**

```javascript
{
  rep_id: number,
  customer_id: number,
  order_amount: decimal,
  order_date: date,
  product_details: string (text field),
  status: enum ['pending', 'confirmed', 'delivered', 'cancelled']
}
```

**Product Selection:**

```javascript
// product_details field is just a textarea for free text
<textarea
  value={formData.product_details}
  onChange={(e) =>
    setFormData({ ...formData, product_details: e.target.value })
  }
  className="w-full px-4 py-2 border border-gray-300 rounded-lg..."
  placeholder="e.g., 50 tons quarry stone, grade A"
  rows="3"
/>
```

**No Variations:** Currently, products are entered as free text in the `product_details` field. There is no structured product catalog or variation system in the orders component itself.

---

### 1.2 CustomerOrdersPanel.js

**Location:** `admin-dashboard/src/components/CustomerOrdersPanel.js`

**Purpose:** Expandable panel within customer detail rows showing order history and new order form

**Key Features:**

- Display previous orders for a customer
- Create new orders specific to that customer
- Delete orders
- Order status color coding

**Data Flow:**

```javascript
// Props received
{
  (customerId, customerName, reps, onClose);
}

// Fetches orders for specific customer
const response = await adminAPI.getOrdersByCustomer(customerId);

// Creates order with customer_id pre-filled
const orderData = {
  ...newOrder,
  customer_id: customerId, // Pre-set from parent
  rep_id: parseInt(newOrder.rep_id, 10),
  order_amount: parseFloat(newOrder.order_amount),
};
```

**Products/Variations:** Same as OrdersManagement - simple text field, no structured catalog.

---

### 1.3 CustomersManagement.js

**Location:** `admin-dashboard/src/components/CustomersManagement.js`

**Purpose:** Customer management with **conditional product/material selection based on customer needs**

**KEY IMPLEMENTATION:** This is where product variation is triggered!

#### Material Needs System

**Checkbox Options (Material Type):**

```javascript
{
  // Two main categories
  'RMC': boolean,
  'Aggregates': boolean
}
```

**Conditional Display - RMC:**

```javascript
{
  (formData.material_needs || []).includes("RMC") && (
    <div>
      <label className="block text-sm font-semibold text-gray-700 mb-2">
        RMC Grade
      </label>
      <select
        value={formData.rmc_grade}
        onChange={(e) =>
          setFormData({ ...formData, rmc_grade: e.target.value })
        }
        className="w-full px-4 py-2 border border-gray-300 rounded-lg..."
      >
        <option value="">-- Select Grade --</option>
        <option value="Grade 10">Grade 10</option>
        <option value="Grade 15">Grade 15</option>
        <option value="Grade 20">Grade 20</option>
        <option value="Grade 25">Grade 25</option>
        <option value="Grade 30">Grade 30</option>
        <option value="Grade 35">Grade 35</option>
        <option value="Grade 40">Grade 40</option>
      </select>
    </div>
  );
}
```

**Conditional Display - Aggregates:**

```javascript
{
  (formData.material_needs || []).includes("Aggregates") && (
    <div>
      <label className="block text-sm font-semibold text-gray-700 mb-2">
        Aggregate Types
      </label>
      <div className="space-y-2">
        {["M sand", "40 mm", "20 mm", "12 mm", "6 mm", "P sand"].map((type) => (
          <label key={type} className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={(formData.aggregate_types || []).includes(type)}
              onChange={(e) => {
                if (e.target.checked) {
                  setFormData({
                    ...formData,
                    aggregate_types: [
                      ...(formData.aggregate_types || []),
                      type,
                    ],
                  });
                } else {
                  setFormData({
                    ...formData,
                    aggregate_types: (formData.aggregate_types || []).filter(
                      (t) => t !== type,
                    ),
                  });
                }
              }}
              className="w-4 h-4 rounded"
            />
            <span className="text-sm">{type}</span>
          </label>
        ))}
      </div>
    </div>
  );
}
```

**Material Needs Checkbox Logic:**

```javascript
// RMC checkbox
<label className="flex items-center gap-2">
  <input
    type="checkbox"
    checked={(formData.material_needs || []).includes('RMC')}
    onChange={(e) => {
      if (e.target.checked) {
        setFormData({ ...formData, material_needs: [...(formData.material_needs || []), 'RMC'] });
      } else {
        // Clear RMC-specific fields when unchecked
        setFormData({
          ...formData,
          material_needs: (formData.material_needs || []).filter(m => m !== 'RMC'),
          rmc_grade: ''
        });
      }
    }}
    className="w-4 h-4 rounded"
  />
  <span className="text-sm">RMC</span>
</label>

// Aggregates checkbox
<label className="flex items-center gap-2">
  <input
    type="checkbox"
    checked={(formData.material_needs || []).includes('Aggregates')}
    onChange={(e) => {
      if (e.target.checked) {
        setFormData({ ...formData, material_needs: [...(formData.material_needs || []), 'Aggregates'] });
      } else {
        // Clear Aggregates-specific fields when unchecked
        setFormData({
          ...formData,
          material_needs: (formData.material_needs || []).filter(m => m !== 'Aggregates'),
          aggregate_types: []
        });
      }
    }}
    className="w-4 h-4 rounded"
  />
  <span className="text-sm">Aggregates</span>
</label>
```

---

## 2. Database Schema

### Orders Table

```sql
CREATE TABLE IF NOT EXISTS orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  customer_id INT NOT NULL,
  order_amount DECIMAL(12,2),
  order_date DATE,
  product_details TEXT,
  status ENUM('pending','confirmed','delivered','cancelled') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Customers Table (Key Fields)

```sql
CREATE TABLE IF NOT EXISTS customers (
  ...
  material_needs JSON,              -- ['RMC', 'Aggregates']
  rmc_grade VARCHAR(50),             -- 'Grade 20', 'Grade 25', etc.
  aggregate_types JSON,              -- ['M sand', '40 mm', '20 mm', ...]
  site_types JSON,                   -- ['Quarry', 'Site', 'Dump']
  ...
)
```

### Order Items Table (Defined but Currently Unused)

```sql
CREATE TABLE IF NOT EXISTS order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
)
```

---

## 3. Product/Variation Triggers

### What Determines Product Availability?

**Trigger:** Customer's `material_needs` selection

| When Selected | Available Products                     | Data Stored                  |
| ------------- | -------------------------------------- | ---------------------------- |
| RMC           | RMC Grades: 10, 15, 20, 25, 30, 35, 40 | `rmc_grade` field            |
| Aggregates    | M sand, 40mm, 20mm, 12mm, 6mm, P sand  | `aggregate_types` JSON array |

### Site Type (Additional Context)

```javascript
// Site type selector in customer form
<select value={formData.site_type} ...>
  <option value="Quarry">Quarry</option>
  <option value="Site">Site</option>
  <option value="Dump">Dump</option>
</select>
```

---

## 4. Product Selection Flow

### Customer Perspective

1. **Admin creates/edits customer**
2. **Checks "Material Type" checkboxes:**
   - Check RMC → RMC Grade dropdown appears
   - Check Aggregates → Aggregate Types checkboxes appear
3. **Selects specific grades/types**
4. **Saves customer with material preferences**

### Order Perspective

1. **Admin creates order** via OrdersManagement or CustomerOrdersPanel
2. **Selects Rep and Customer**
3. **Enters order amount**
4. **Enters product details** (free text field)
   - Could reference customer's material needs, but not enforced
   - Example: "50 tons of Grade 20 RMC" or "30 tons aggregate mix (M sand, 20mm)"
5. **Saves order**

---

## 5. Data Structure Examples

### Customer with RMC Need Only

```json
{
  "id": 1,
  "name": "Acme Construction Ltd",
  "material_needs": ["RMC"],
  "rmc_grade": "Grade 25",
  "aggregate_types": [],
  "site_type": "Site"
}
```

### Customer with Aggregates Need

```json
{
  "id": 2,
  "name": "Quarry Resources Inc",
  "material_needs": ["Aggregates"],
  "rmc_grade": "",
  "aggregate_types": ["M sand", "40 mm", "20 mm"],
  "site_type": "Quarry"
}
```

### Customer with Both Needs

```json
{
  "id": 3,
  "name": "Mixed Materials Site",
  "material_needs": ["RMC", "Aggregates"],
  "rmc_grade": "Grade 30",
  "aggregate_types": ["M sand", "12 mm", "6 mm"],
  "site_type": "Site"
}
```

### Corresponding Order

```json
{
  "id": 101,
  "customer_id": 3,
  "rep_id": 5,
  "order_amount": 250000,
  "order_date": "2026-03-24",
  "product_details": "100 cubic meters Grade 30 RMC, 50 tons M sand and 12mm aggregate mix",
  "status": "confirmed"
}
```

---

## 6. API Integration

### API Endpoints

```javascript
// Get all orders
GET /api/admin/orders

// Get orders by customer
GET /api/admin/orders/customer/:customerId

// Create order
POST /api/admin/orders
Body: {
  customer_id, rep_id, order_amount,
  order_date, product_details, status
}

// Update order
PUT /api/admin/orders/:id

// Delete order
DELETE /api/admin/orders/:id
```

### API Client Methods

```javascript
export const adminAPI = {
  getAllOrders: () => apiClient.get("/api/admin/orders"),
  getOrdersByCustomer: (customerId) =>
    apiClient.get(`/api/admin/orders/customer/${customerId}`),
  createOrder: (data) => apiClient.post("/api/admin/orders", data),
  updateOrder: (id, data) => apiClient.put(`/api/admin/orders/${id}`, data),
  deleteOrder: (id) => apiClient.delete(`/api/admin/orders/${id}`),
};
```

---

## 7. Current Limitations & Future Enhancements

### Current State

- ✅ Customer material preferences stored and filtered
- ✅ Orders linked to customers
- ✅ Basic order CRUD operations
- ❌ No product catalog management
- ❌ No order line items (order_items table exists but unused)
- ❌ No pricing logic or automatic calculations
- ❌ No quantity/unit tracking per product

### Future Enhancements

1. **Product Catalog:** Define products with pricing, specifications
2. **Order Line Items:** Break orders into multiple product line items
3. **Inventory Management:** Track stock levels per material type and grade
4. **Dynamic Pricing:** Price per material type, grade, and volume
5. **Auto-population:** Auto-suggest products based on customer's material_needs
6. **Validation:** Enforce product selection from customer's available materials
7. **Reporting:** Orders by product type, volume trends per material

---

## 8. Key Code Snippets Summary

### Material Needs Trigger Logic

```javascript
// Check if RMC is selected → show RMC Grade dropdown
if (includes 'RMC') → show RMC Grade options (10-40)

// Check if Aggregates is selected → show Aggregate checkboxes
if (includes 'Aggregates') → show checkboxes for (M sand, 40mm, 20mm, 12mm, 6mm, P sand)
```

### Product Details Entry

```javascript
// Orders use free text for product details
product_details: textarea input (no structured catalog)
```

### Customer Material Storage

```javascript
// JSON fields in customers table
material_needs: JSON array ['RMC', 'Aggregates']
rmc_grade: VARCHAR (single value)
aggregate_types: JSON array [list of selected types]
```

---

## 9. Files & Locations

| File                                                    | Purpose                                     |
| ------------------------------------------------------- | ------------------------------------------- |
| `admin-dashboard/src/components/OrdersManagement.js`    | Main orders management UI                   |
| `admin-dashboard/src/components/CustomerOrdersPanel.js` | Expandable orders panel in customer rows    |
| `admin-dashboard/src/components/CustomersManagement.js` | Customer CRUD with material needs selection |
| `admin-dashboard/src/api/client.js`                     | API integration                             |
| `qft-deployment/CREATE_TABLES.sql`                      | Database schema                             |
| `qft-deployment/index.js`                               | Node.js backend API endpoints               |
| `qft-deployment/api.php`                                | PHP backend API handlers                    |

---

## 10. Conclusion

The system implements **product variation through customer-level filters** rather than order-level product catalog:

- **Variation Trigger:** Customer's selected material needs
- **Available Products:** Dependent on customer's material_needs choices
- **Product Types:** RMC (with grades) and Aggregates (with types)
- **Current Implementation:** Simple, text-based order details
- **Future Potential:** Structured line items, pricing, inventory management
