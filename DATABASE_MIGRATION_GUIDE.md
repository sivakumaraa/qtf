# Database Migration Guide - Add Mobile and Photo Fields

## Problem

The rep details form includes `mobile_no` and `photo` fields, but the database tables don't have these columns yet.

## Solution

Run this migration to add the columns to the `users` table.

---

## Method 1: Using phpMyAdmin (Easiest)

1. **Open phpMyAdmin**:
   - Go to http://localhost/phpmyadmin
   - Select your `quarryforce_db` database

2. **Execute SQL Query**:
   - Click the "SQL" tab
   - Copy and paste this SQL:

```sql
ALTER TABLE users
ADD COLUMN IF NOT EXISTS mobile_no VARCHAR(20) NULL COMMENT 'Mobile phone number of the rep',
ADD COLUMN IF NOT EXISTS photo LONGTEXT NULL COMMENT 'Base64 encoded profile photo';
```

3. **Click "Go"** to execute
4. You should see: "Alter statement executed successfully"

---

## Method 2: Using Command Line

1. **Open Command Prompt** and run:

```powershell
cd D:\xampp\mysql\bin
mysql.exe -u root
```

2. **Select your database**:

```sql
USE quarryforce_db;
```

3. **Run the migration**:

```sql
ALTER TABLE users
ADD COLUMN IF NOT EXISTS mobile_no VARCHAR(20) NULL,
ADD COLUMN IF NOT EXISTS photo LONGTEXT NULL;
```

4. **Verify success**:

```sql
DESCRIBE users;
```

You should see `mobile_no` and `photo` columns in the output.

---

## Method 3: Using Migration File (Optional)

1. Place the file: `d:\quarryforce\qft-deployment\migrations\001_add_mobile_photo_to_users.sql`
2. Import using phpMyAdmin:
   - Click "Import" tab
   - Select the file
   - Click "Go"

---

## Verification

After running the migration, verify in phpMyAdmin:

1. Go to `quarryforce_db` → `users`
2. Click "Structure" tab
3. You should see these new columns:
   - `mobile_no` (varchar, 20)
   - `photo` (longtext)

---

## If You Get an Error

### "Column already exists"

- No action needed, columns are already there
- The migration uses `IF NOT EXISTS`, so it's safe to run multiple times

### "Table 'quarryforce_db.users' doesn't exist"

- Create the users table first by importing the initial database structure
- Check `qft-deployment/` for setup files

### "Access denied"

- Make sure MySQL is running in XAMPP Control Panel
- Verify your username/password in `qft-deployment/.env`
- Default XAMPP: `root` with no password

---

## What This Does

- **mobile_no**: Stores rep phone numbers (up to 20 characters)
- **photo**: Stores base64-encoded profile photos

Both fields are **optional** (NULL allowed), so you can leave them blank.

---

## Testing

After running the migration:

1. Start development: `start-dev.bat`
2. Go to http://localhost:3000
3. Navigate to "Rep Details"
4. Edit a rep and add:
   - Mobile number
   - Profile photo
5. Click "Save"
6. Verify data is saved and displayed in the table

---

## Still Having Issues?

1. **Check database connectivity**:
   - Run `start-dev.bat` and check backend logs
   - Look for database connection errors

2. **Verify columns exist**:
   - Use phpMyAdmin Structure tab
   - Run `DESCRIBE users;` in SQL command line

3. **Check API response**:
   - Open browser console (F12)
   - Check Network tab for API errors
   - Look for 500/502 errors from backend

4. **Restart services**:
   - Close all console windows
   - Run `start-dev.bat` again
   - Refresh browser (Ctrl+F5)
