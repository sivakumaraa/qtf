# QuarryForce Local Testing - Quick Start with XAMPP

## 5-Minute Setup

### Step 1: Start XAMPP MySQL

1. Open XAMPP Control Panel (`D:\xampp\xampp-control.exe`)
2. Click **START** next to MySQL
3. Wait for status to show "Running"

### Step 2: Create Database

1. Open http://localhost/phpmyadmin in browser
2. Click "New" (left sidebar)
3. Database name: `quarryforce_db`
4. Click "Create"

### Step 3: Configure Backend

1. Edit `d:\quarryforce\qft-deployment\.env`:
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=
   DB_NAME=quarryforce_db
   ```

### Step 4: Start Development

1. Open Command Prompt
2. Navigate: `cd d:\quarryforce`
3. Run: `start-dev.bat`
4. Two console windows will open

### Step 5: Access Applications

- **Backend API**: http://localhost:8000/api/
- **Admin Dashboard**: http://localhost:3000

---

## Testing the New Features

### Test 1: Customer Management

1. Go to http://localhost:3000
2. Navigate to "Customers Management"
3. Click "Add Customer"
4. Fill in:
   - Customer Name
   - Phone Number (new field)
   - Location
   - Site In-Charge details
   - Material needs (RMC or Aggregates)
   - Volume and required date
   - Pricing information
5. Click "Save"
6. Verify data appears in table

### Test 2: Rep Mobile Number

1. Navigate to "Rep Details"
2. Click "Edit" on a rep
3. Add mobile number
4. Click "Save"
5. Verify number displays in table

---

## Stop Development

**Windows**: Close each console window or press Ctrl+C

---

## If Something Goes Wrong

| Problem                    | Solution                                                            |
| -------------------------- | ------------------------------------------------------------------- |
| "Can't connect to MySQL"   | Check XAMPP Control Panel - MySQL must be "Running"                 |
| "Port 8000 in use"         | Close PHP server, wait 5 sec, restart                               |
| "npm: command not found"   | Install Node.js (for React admin-dashboard npm) https://nodejs.org/ |
| "Database doesn't exist"   | Use phpMyAdmin to create `quarryforce_db`                           |
| Database credentials error | Check `.env` file and phpMyAdmin default (root/no password)         |

---

## Useful XAMPP Commands

```powershell
# Open XAMPP Control Panel
D:\xampp\xampp-control.exe

# Access phpMyAdmin (when XAMPP is running)
# http://localhost/phpmyadmin

# MySQL command line (if needed)
D:\xampp\mysql\bin\mysql.exe -u root
```

---

## What's Running After `start-dev.bat`

| Service         | URL                         | Port |
| --------------- | --------------------------- | ---- |
| PHP Backend     | http://localhost:8000       | 8000 |
| React Dashboard | http://localhost:3000       | 3000 |
| MySQL           | localhost                   | 3306 |
| phpMyAdmin      | http://localhost/phpmyadmin | 80   |
