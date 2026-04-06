# QuarryForce Admin Dashboard - User Flow Diagrams

## 1. Authentication & Login Flow

```mermaid
graph TD
    A["User Access Admin Dashboard"] --> B{"Authenticated?"}
    B -->|No| C["Login Page"]
    C --> D["Enter Credentials"]
    D --> E["API Validates"]
    E -->|Valid| F["Create Session"]
    E -->|Invalid| G["Show Error"]
    G --> C
    F --> H["Store User Context"]
    H --> I["Redirect to Dashboard"]
    B -->|Yes| I
    I --> J["Dashboard Loads"]
    J --> K["Check User Privileges"]
    K --> L["Render Permitted Tabs"]
```

## 2. Customer Management Flow

```mermaid
graph LR
    A["Customers Tab"] --> B["Load Customers List"]
    B --> C{"Action?"}
    C -->|View| D["Expand Customer Details"]
    C -->|Edit| E["Open Edit Form"]
    C -->|Delete| F["Confirm & Delete"]
    C -->|Add Order| G["Customer Orders Panel"]
    D --> H["Show Orders & Info"]
    H --> I["Location Map Picker"]
    I --> J["Select/Update Location"]
    J --> K["Save Customer"]
    E --> L["Update Fields"]
    L --> K
    G --> M["Show Order List"]
    M --> N{"Order Action?"}
    N -->|Create| O["Order Creation Form"]
    N -->|Edit| P["Edit Order Form"]
    N -->|Delete| Q["Delete Order"]
    O --> R["Save to Database"]
    P --> R
    R --> S["Update Main List"]
```

## 3. Order Management Flow

```mermaid
graph TD
    A["Orders Tab"] --> B["Load All Orders"]
    B --> C["Display Order Table"]
    C --> D{"User Action?"}
    D -->|Create| E["Open New Order Form"]
    D -->|Edit| F["Open Edit Form"]
    D -->|Delete| G["Confirm Delete"]
    D -->|View| H["Show Order Details"]
    E --> I["Select Rep"]
    I --> J["Select Customer"]
    J --> K["Enter Amount & Date"]
    K --> L["Set Status"]
    L --> M["Submit Form"]
    F --> N["Pre-fill Form"]
    N --> M
    G --> O["Remove from Database"]
    M --> P["Save to Database"]
    O --> P
    P --> Q["Refresh Table"]
    Q --> C
```

## 4. Target Management & Progress Flow

```mermaid
graph TD
    A["Targets Tab"] --> B["Load All Targets"]
    B --> C["Calculate Rep Progress"]
    C --> D["Display Summary Stats"]
    D --> E["Show Rep Cards"]
    E --> F["Month Selector"]
    F -->|Change Month| G["Fetch New Progress Data"]
    G --> H["Update All Charts"]
    H --> E
    E --> I["Rep Action?"]
    I -->|Edit Target| J["Open Target Form"]
    I -->|Delete Target| K["Confirm & Remove"]
    I -->|View Progress| L["Show Progress Details"]
    J --> M["Update Target"]
    K --> N["Remove Target"]
    M --> O["Recalculate Progress"]
    N --> O
    O --> P["Refresh Display"]
```

## 5. Location Selection Flow

```mermaid
graph LR
    A["Location Picker"] --> B{"User Action?"}
    B -->|Search| C["Nominatim API"]
    C --> D["Show Results"]
    D --> E["Click Result"]
    E --> F["Update Map Center"]
    F --> G["Update Coordinates"]
    B -->|Use Current| H["Get Browser Location"]
    H --> I["Show Green Marker"]
    I --> G
    B -->|Click Map| J["Get Click Coords"]
    J --> G
    B -->|Manual Input| K["Edit Lat/Lng Fields"]
    K --> L["Validate Numbers"]
    L --> G
    G --> M["Parent Notified"]
    M --> N["Save to Form"]
```

## 6. Settings & Configuration Flow

```mermaid
graph TD
    A["Settings Tab"] --> B["Load Current Settings"]
    B --> C["Display Form"]
    C --> D{"Field Type?"}
    D -->|Text Input| E["Company Name"]
    D -->|File Upload| F["Company Logo"]
    D -->|Textarea| G["Company Address"]
    D -->|Email| H["Company Email"]
    D -->|Phone| I["Company Phone"]
    D -->|Array| J["Site Types List"]
    F --> K["FileReader API"]
    K --> L["Convert to Base64"]
    L --> M["Preview Image"]
    E --> N["Form Data Object"]
    G --> N
    H --> N
    I --> N
    M --> N
    J --> N
    N --> O["User Clicks Save"]
    O --> P["Validate Data"]
    P -->|Valid| Q["Send to API"]
    P -->|Invalid| R["Show Errors"]
    R --> C
    Q --> S["Update Database"]
    S --> T["Show Success"]
    T --> U["Refresh Settings"]
```

## 7. User & Role Management Flow

```mermaid
graph TD
    A["Users Tab"] --> B["Load Users List"]
    B --> C["Display User Table"]
    C --> D{"Action?"}
    D -->|Create User| E["Open User Form"]
    D -->|Edit User| F["Pre-fill Form"]
    D -->|Edit Privileges| G["Privilege Editor Modal"]
    D -->|Delete User| H["Confirm & Delete"]
    E --> I["Enter User Details"]
    I --> J["Select Role"]
    F --> K["Update User Fields"]
    K --> J
    J --> L{"Custom Privileges?"}
    L -->|Yes| M["Open Privilege Editor"]
    L -->|No| N["Use Role Defaults"]
    M --> O["Select Permissions"]
    G --> O
    O --> P["Confirm Privileges"]
    P --> Q["Save User"]
    N --> Q
    H --> R["Remove User"]
    Q --> S["Update Database"]
    R --> S
    S --> T["Refresh User List"]
```

## 8. Sales Recording Flow

```mermaid
graph TD
    A["Sales Recording Tab"] --> B["Load Reps List"]
    B --> C["Choose Rep"]
    C --> D["Fetch Rep's Targets"]
    D --> E["Display Form"]
    E --> F["Field: Select Target"]
    F --> G["Calculate Max Incentive"]
    G --> H["Field: Sales Amount"]
    H --> I["Real-time Commission Calc"]
    I --> J["Display Result Card"]
    J --> K{"User Ready?"}
    K -->|Submit| L["Save Record"]
    K -->|Clear| M["Reset Form"]
    L --> N["API Records Sale"]
    M --> E
    N --> O["Show Submitted Record"]
    O --> P["Load Sales History"]
    P --> Q["Display Completed Entries"]
```

## 9. Fraud Alerts Detection Flow

```mermaid
graph TD
    A["Fraud Alerts Tab"] --> B["Fetch Suspicious Entries"]
    B --> C{"Alert Criteria"}
    C -->|High variance| D["Sales vs Target"]
    C -->|Unusual pattern| E["Time-based Anomaly"]
    C -->|Location mismatch| F["GPS Inconsistency"]
    D --> G["Display Alert List"]
    E --> G
    F --> G
    G --> H["Alert Severity Level"]
    H --> I{"Level?"}
    I -->|High| J["Red Alert Card"]
    I -->|Medium| K["Yellow Alert Card"]
    I -->|Low| L["Blue Alert Card"]
    J --> M{"Investigate?"}
    K --> M
    L --> M
    M -->|Yes| N["View Full Details"]
    M -->|No| O["Dismiss Alert"]
    N --> P["Show Rep Info"]
    P --> Q["Show Sale Details"]
    Q --> R["Mark as Reviewed"]
```

## 10. Analytics & Reports Flow

```mermaid
graph TD
    A["Analytics Tab"] --> B["Calculate Statistics"]
    B --> C["Fetch Rep Performance"]
    C --> D["Calculate Target Achievement"]
    D --> E["Get Sales Trends"]
    E --> F["Generate Charts"]
    F --> G["Display Dashboard"]
    G --> H["Stats Cards"]
    G --> I["Performance Charts"]
    G --> J["Trend Graphs"]
    H --> K["Total Sales"]
    H --> L["Active Reps"]
    H --> M["Avg Commission"]
    I --> N["Rep Leaderboard"]
    I --> O["Target vs Actual"]
    J --> P["Sales Over Time"]
    J --> Q["Commission Trends"]
    K --> R["User Reviews"]
    L --> R
    M --> R
    N --> R
    O --> R
    P --> R
    Q --> R
```

---

## Quick Reference: Component State Management

### State Patterns Used

#### Pattern 1: Basic CRUD Operations

```javascript
const [items, setItems] = useState([]);
const [loading, setLoading] = useState(true);
const [error, setError] = useState(null);
const [showForm, setShowForm] = useState(false);
const [editingId, setEditingId] = useState(null);
const [formData, setFormData] = useState(initialState);
```

#### Pattern 2: Async Operations with Callbacks

```javascript
const fetchData = useCallback(async () => {
  try {
    setLoading(true);
    const response = await api.get();
    setItems(response.data);
  } catch (err) {
    setError(err.message);
  } finally {
    setLoading(false);
  }
}, [dependencies]);

useEffect(() => {
  fetchData();
}, [fetchData]);
```

#### Pattern 3: Form Handling with Validation

```javascript
const handleChange = (e) => {
  const { name, value } = e.target;
  setFormData((prev) => ({ ...prev, [name]: value }));
};

const handleSubmit = async (e) => {
  e.preventDefault();
  if (!validate(formData)) {
    setError("Validation failed");
    return;
  }
  await saveData(formData);
};
```

---

## Mermaid Diagram Legend

- **Rectangles** = Process/Action
- **Diamonds** = Decision Point
- **Rounded Boxes** = Start/End
- **Arrows** = Flow Direction
- **Colored Note** = Important Reference

---

## Notes

- All diagrams use standard user interactions
- API calls are handled asynchronously
- Loading states prevent race conditions
- Error handling shown in most flows
- Role-based access control enforced at component level
