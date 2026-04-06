# Testing Guide - API Handler Updates & Data Persistence

## Overview

This guide walks through testing the critical fixes made to API handlers to ensure data persists correctly and updates display immediately in the UI.

---

## Pre-Testing Checklist

### ✅ Environment Verification

Before starting tests, verify your system is ready:

```powershell
# 1. Check XAMPP PHP server is running
curl http://localhost:8000/

# Expected: PHP index page or API welcome message

# 2. Check React app is running
# Visit: http://localhost:3000

# Expected: Admin Dashboard loads without errors

# 3. Check MySQL is running
# XAMPP Control Panel → MySQL "Start" button should show "Stop"

# 4. Verify .env files are correct
```

**Files to check:**

- ✅ `admin-dashboard/.env` - Contains `REACT_APP_API_URL=http://localhost:8000`
- ✅ `qft-deployment/.env` - Contains correct MySQL credentials (root, empty password, localhost:3306)

---

## Critical Test #1: Settings Page Persistence Fix ⭐

**What was fixed:** Settings page now returns actual database values instead of defaults.

**Duration:** 5 minutes

### Step-by-Step Test

#### Step 1: Clear Browser Cache

This is CRITICAL - old cached values may interfere:

```
Windows/Linux: Ctrl + Shift + Delete
Mac: Cmd + Shift + Delete  (or Cmd + Option + E)
```

In the cache clearing dialog:

- Select time range: **"All time"**
- Select items: Check "Cookies and cached images and files"
- Click "Clear data"

#### Step 2: Hard Refresh React App

After clearing cache:

```
Ctrl + Shift + R  (Windows/Linux)
Cmd + Shift + R   (Mac)
```

Or use DevTools:

- Press F12 to open DevTools
- Right-click refresh button → "Empty cache and hard refresh"

#### Step 3: Navigate to Settings

1. Open browser to `http://localhost:3000`
2. Click "Settings" in the admin dashboard
3. Wait for page to fully load
4. Check console (F12) for any errors

**Expected state:**

- Settings form displays with current values
- No error messages
- All form fields are populated

#### Step 4: Change a Setting

Choose one of these to change:

**Option A: Change GPS Radius (Easiest)**

1. Locate "GPS Radius Limit" field
2. Current value might be: 50
3. Change to: **75**
4. Click "Save Settings" button

**Option B: Change Company Name**

1. Locate "Company Name" field
2. Current value: "QuarryForce"
3. Change to: **"QuarryForce Test"**
4. Click "Save Settings" button

**Option C: Add Site Type**

1. Scroll to "Site Types" section
2. Enter new site type: **"Test Site"**
3. Click "Add Site Type" button
4. Click "Save Settings" button

#### Step 5: Verify Immediate Feedback

After clicking "Save Settings":

**Success Indicators:**
✅ Green banner appears: "Settings updated successfully!"
✅ Banner disappears after 5 seconds
✅ Form still shows your new values
✅ Browser console shows no errors

**If fails:**
❌ Red error banner appears
→ Check browser console (F12) for error message
→ Check PHP error log in XAMPP

#### Step 6: Critical Test - Page Reload

Now perform the critical test - reload the page:

```
Press: F5 (or Ctrl+R)
```

**Expected result (SUCCESS):** ✅

- Page reloads
- Settings form displays with YOUR CHANGED VALUES
- GPS radius shows 75 (not 50)
- Company name shows "QuarryForce Test"
- Site Types show your added type

**Failure result (FAILURE):** ❌

- Page reloads
- Settings form shows DEFAULT VALUES
- GPS radius reverted to 50
- Company name reverted to "QuarryForce"
- Your changes are gone

#### Step 7: Document Results

| Metric                             | Expected    | Actual | Status |
| ---------------------------------- | ----------- | ------ | ------ |
| Settings loaded on first visit     | ✅ Yes      | [ ]    | [ ]    |
| Changed value saved (immediate UI) | ✅ GPS = 75 | [ ]    | [ ]    |
| Success message displayed          | ✅ Yes      | [ ]    | [ ]    |
| Value persists after reload        | ✅ 75       | [ ]    | [ ]    |
| Database contains new value        | ✅ Yes      | [ ]    | [ ]    |

---

## Critical Test #2: User Management Updates ⭐

**What was fixed:** User updates now return actual updated data immediately.

**Duration:** 5 minutes

### Step-by-Step Test

#### Step 1: Navigate to User Management

1. Click "User Management" in dashboard
2. Verify user list loads
3. Look for a test user (or create one if needed)

#### Step 2: Reset a User's Device Binding

This tests the handleAdminResetDevice fix:

1. Find a user with a device binding (has "Smartphone" icon)
2. Click the "Refresh" icon (Reset Device Binding) button
3. Confirm the warning dialog: "Are you sure?"

**Immediate result (1-2 seconds):**
✅ User row updates
✅ Device binding changes from "UUID-..." to "Unbound (Pending App Login)"
✅ Green success message appears

**Database verification:**

- The user's `device_uid` column should now be NULL

#### Step 3: Create a New User

This tests the handleAdminUsersCreate fix:

1. Click "Add Representative" button
2. Fill in form:
   - Name: **"Test User 2024"**
   - Email: **"testuser2024@quarryforce.com"**
3. Click "Create User" button

**Immediate result:**
✅ Success message: "User created successfully..."
✅ Modal closes
✅ New user appears in the list immediately (no manual refresh needed!)
✅ User shows in table with correct name and email

#### Step 4: Document Results

| Metric                               | Expected            | Actual | Status |
| ------------------------------------ | ------------------- | ------ | ------ |
| Device reset shows success           | ✅ Yes              | [ ]    | [ ]    |
| Device UID updates immediately       | ✅ Null             | [ ]    | [ ]    |
| New user appears in list immediately | ✅ Yes              | [ ]    | [ ]    |
| New user data is correct             | ✅ Name/Email match | [ ]    | [ ]    |
| Page reload doesn't lose new user    | ✅ Still there      | [ ]    | [ ]    |

---

## Extended Test #3: Rep Targets Updates

**What was fixed:** Target updates and creation now return full target data.

**Duration:** 5 minutes

### Step-by-Step Test

#### Step 1: Navigate to Rep Targets (if available)

Some dashboard versions may not have this visible. If not available, skip to next test.

#### Step 2: Create/Update a Target

Through the UI or by examining the component:

**Create Target:**

1. Click "Add Target" or similar
2. Select a rep
3. Enter monthly sales target: **1500**
4. Save

**Expected:**
✅ Target appears in grid immediately
✅ All target data displays (target M3, rates, etc.)
✅ No manual refresh needed

**Update Target:**

1. Click existing target row
2. Change monthly target to: **1200**
3. Save

**Expected:**
✅ Row updates immediately with new value
✅ 1200 displays instead of previous value
✅ No refresh needed

---

## Extended Test #4: Data Persistence Across Sessions

**What this tests:** Data doesn't just appear temporarily - it's actually in the database.

**Duration:** 10 minutes

### Step-by-Step Test

#### Step 1: Make Multiple Changes

In your test session:

1. Settings - Change GPS radius to 85
2. User Management - Create test user
3. Settings - Change company name
4. User Management - Reset device for another user

#### Step 2: Close Browser Tab

```
Close the admin dashboard tab completely
```

#### Step 3: Wait 30 Seconds

This allows any pending database operations to complete.

#### Step 4: Open New Browser Tab

Navigate to: `http://localhost:3000`

#### Step 5: Check Each Change

Navigate through the app and verify each change persisted:

✅ Settings → GPS radius is 85 (not 50)
✅ Settings → Company name changed
✅ User Management → New test user still exists
✅ User Management → Device resets still show null

**This confirms changes are in the database, not just in browser memory!**

---

## Debugging Guide - If Tests Fail

### Settings Don't Persist

**Symptom:** Settings show new value, page reloads, value reverts to default

**Diagnostic Steps:**

1. **Check API Response**
   - Open DevTools (F12) → Network tab
   - Change a setting and save
   - Look for PUT request to `/api/settings`
   - Click the request
   - Check "Response" tab - does it include your data?

   **Should show:**

   ```json
   {
     "success": true,
     "message": "Settings updated successfully!",
     "data": {
       "id": 1,
       "gps_radius_limit": 75,
       "company_name": "QuarryForce Test",
       ...
     }
   }
   ```

   If response shows `"data": null` or missing → **API not returning data**

2. **Check Database**
   - Open terminal
   - Connect to MySQL:
     ```bash
     mysql -u root -p quarryforce_db
     ```
     (Press Enter when prompted for password - it's empty)
   - Check settings:
     ```sql
     SELECT * FROM system_settings WHERE id = 1\G
     ```
   - Does the database show your changed value?
   - If YES in DB but NO in UI → API not returning data
   - If NO in DB → API not saving properly

3. **Check PHP Logs**
   - Navigate to XAMPP installation
   - Open: `D:\xampp\apache\logs\error.log`
   - Look for recent errors with `/api/settings`
   - Any SQL errors? PDO errors?

4. **Common Fixes**
   - Restart XAMPP services (MySQL + Apache)
   - Clear React cache again (Ctrl+Shift+Delete)
   - Hard refresh React app (Ctrl+Shift+R)

---

### User Management Updates Don't Show

**Symptom:** Create user, it appears, but page reload loses it

1. **Check User in Database**

   ```sql
   SELECT * FROM users WHERE name = 'Test User 2024'\G
   ```

2. **Check API Response**
   - F12 → Network tab
   - Create user
   - Look for POST to `/api/admin/users`
   - Response should have:
     ```json
     {
       "success": true,
       "data": {
         "id": 8,
         "email": "...",
         "name": "...",
         "role": "rep"
       }
     }
     ```

---

### Device Reset Doesn't Work

**Symptom:** Click device reset, nothing happens or error appears

1. **Check Browser Console**
   - F12 → Console tab
   - Look for red error messages
   - Copy full error text

2. **Check API Response**
   - Network tab
   - Find POST to `/api/admin/reset-device`
   - Check response for errors

3. **Verify Device UID Exists**
   ```sql
   SELECT id, name, device_uid FROM users;
   ```
   Only users with non-null device_uid should have reset button enabled

---

## Performance Notes

**Expected Response Times:**

- Settings save: < 1 second
- User creation: < 1 second
- Device reset: < 1 second
- Settings reload: < 1 second

If taking longer:

- Check XAMPP MySQL isn't overloaded
- Check for slow network requests (F12 Network tab)
- Restart XAMPP services

---

## Success Criteria Summary

### ✅ Test Passed If:

- Settings page loads without "Failed to load settings" error
- Changing settings shows success message
- Settings values persist after page reload (F5)
- New users appear in list immediately without manual refresh
- Device reset updates device_uid to null immediately
- All data changes survive a complete browser close/reopen
- No error messages in browser console
- No error messages in PHP error log

### ❌ Test Failed If:

- Any "Failed to load settings" errors
- Settings revert to defaults after reload
- Changes require manual page refresh to display
- Database shows changes but UI doesn't
- API responses missing 'data' field
- PHP error log contains SQL errors

---

## Test Summary Sheet

**Print this page and check off as you complete tests:**

```
SETTINGS PAGE TEST
[ ] Settings page loads without errors
[ ] Can change GPS radius
[ ] Can change company name
[ ] Can add site types
[ ] Save button works and shows success
[ ] Settings persist after page reload   ⭐ CRITICAL

USER MANAGEMENT TEST
[ ] User list loads
[ ] Can create new user
[ ] New user appears immediately
[ ] Can reset device binding
[ ] Device reset shows success
[ ] Changes persist after page reload

OVERALL STATUS
[ ] All critical tests passed
[ ] Ready for production testing
[ ] Issues identified and documented
```

---

## Next Actions

**If All Tests Pass:** ✅
→ Proceed to full LOCAL_DEPLOYMENT_CHECKLIST.md
→ Test all remaining features
→ Prepare for production deployment

**If Some Tests Fail:** ⚠️
→ Document which specific test failed
→ Use debugging guide above
→ Check error logs
→ Create bug report with exact failure scenario

**If Many Tests Fail:** ❌
→ Check environment configuration (.env files)
→ Verify database connection
→ Restart XAMPP completely
→ Clear all caches and restart React dev server
→ Run tests again

---

**Test Date:** ******\_\_\_******
**Tester Name:** ******\_\_\_******
**Status:** [ ] PASS [ ] FAIL [ ] PARTIAL

**Issues Found:**

```
_________________________________
_________________________________
_________________________________
_________________________________
```

**Notes:**

```
_________________________________
_________________________________
_________________________________
_________________________________
```

---

_Last Updated: 2024-02-10_
_Based on Latest API Handler Updates_
