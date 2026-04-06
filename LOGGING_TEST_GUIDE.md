# API Logging Feature - Testing Guide

## Test Scenarios

### Scenario 1: Enable Logging and Watch Check-in

**Setup:**

```
Backend running: node index.js
Admin Dashboard running: npm start (from admin-dashboard)
Mobile app: Running in Chrome
```

**Steps:**

1. Open Admin Dashboard → Settings
2. Toggle "Enable API Logging" → **ON**
3. Click "Save Settings"
4. Open mobile app in another window
5. Log in with: `demo@quarryforce.local`
6. Navigate to any customer
7. Click "Check-in" button

**Expected Console Output:**

```
[2026-03-02T10:15:30.123Z] [INFO] Login attempt { email: 'demo@quarryforce.local', device_uid: '...' }
[2026-03-02T10:15:31.456Z] [INFO] Demo user login successful { email: 'demo@quarryforce.local' }
[2026-03-02T10:15:35.789Z] [INFO] Check-in attempt { rep_id: 1, customer_id: 1, rep_lat: ..., rep_lng: ... }
[2026-03-02T10:15:36.234Z] [INFO] Check-in successful { rep_id: 1, customer_id: 1, distance: ..., allowedRadius: 50 }
```

**Verify:**

- ✅ All events are logged
- ✅ Data includes relevant IDs and values
- ✅ Timestamps are in ISO format

---

### Scenario 2: Disable Logging

**Setup:**
Continue from previous scenario

**Steps:**

1. Go back to Admin Dashboard → Settings
2. Toggle "Enable API Logging" → **OFF**
3. Click "Save Settings"
4. Check server console - no logs should appear anymore
5. Perform operations: login, check-in, submit visit
6. Server console should remain clean (no API logs)

**Expected:**

```
[Only error logs, no info/warn/debug logs]
```

**Verify:**

- ✅ Console is clean (no API activity logs)
- ✅ Operations still work normally
- ✅ Errors still appear (if any)

---

### Scenario 3: Check-in Failure Logging

**Setup:**
Logging enabled

**Steps:**

1. Mobile app: Open a customer location far away (e.g., 500m)
2. Try to check-in
3. Check server console for logs

**Expected Console Output:**

```
[2026-03-02T10:15:35.789Z] [INFO] Check-in attempt { rep_id: 1, customer_id: 1, rep_lat: 12.97, rep_lng: 77.59 }
[2026-03-02T10:15:36.234Z] [WARN] Check-in denied - out of range { rep_id: 1, customer_id: 1, distance: 500, allowedRadius: 50 }
```

**Verify:**

- ✅ WARN level log shows denial reason
- ✅ Shows actual distance vs. allowed radius
- ✅ User sees error message in app

---

### Scenario 4: Settings Change Logging

**Setup:**
Logging enabled

**Steps:**

1. Admin Dashboard → Settings
2. Change "GPS Radius Limit" from 50 to 100
3. Change "Enable API Logging" to OFF
4. Click "Save Settings"
5. Check server console

**Expected Console Output:**

```
[2026-03-02T10:16:00.123Z] [INFO] Updating system settings { gps_radius_limit: 100, logging_enabled: false }
[2026-03-02T10:16:00.456Z] [INFO] Logging status changed { logging_enabled: false }
[2026-03-02T10:16:00.789Z] [INFO] Settings updated successfully
```

**Verify:**

- ✅ Logging state change is captured
- ✅ New settings values are logged
- ✅ After this, console becomes quiet (logging disabled)

---

### Scenario 5: Database Verification

**Setup:**
cPanel/phpMyAdmin access

**Steps:**

1. Open phpMyAdmin
2. Select database: `quarryforce`
3. Select table: `system_settings`
4. View data
5. Check `logging_enabled` column

**Expected:**

```
| id | company_name | gps_radius_limit | logging_enabled | ... |
|----|--------------|------------------|-----------------|-----|
| 1  | QuarryForce  | 100              | 0 (or 1)        | ... |
```

**Verify:**

- ✅ Column exists: `logging_enabled`
- ✅ Value changes when toggling in dashboard
- ✅ 1 = enabled, 0 = disabled

---

## Log Interpretation Guide

### INFO Level Logs

```
[2026-03-02T10:15:31.456Z] [INFO] User login successful { user_id: 2, email: 'john@quarry.com' }
```

✅ Normal operation - no action needed

### WARN Level Logs

```
[2026-03-02T10:15:36.234Z] [WARN] Check-in denied - out of range { rep_id: 2, customer_id: 5, distance: 250, allowedRadius: 50 }
```

⚠️ Validation failure - check business logic:

- Distance 250m > Radius 50m = Check-in blocked
- User not at location? Adjust GPS radius or verify coordinates

### ERROR Level Logs

```
[2026-03-02T10:15:40.789Z] [ERROR] Login error Connection refused
```

❌ System failure - take action:

- Database not running? Start MySQL
- Network issue? Check connection
- API down? Restart backend

### DEBUG Level Logs

```
[2026-03-02T10:15:30.123Z] [DEBUG] Fetching system settings
```

🔧 Detailed tracing - helpful when debugging:

- Shows all API calls being made
- Useful during development

---

## Troubleshooting Test Failures

### Problem: Toggle button doesn't appear in Settings

**Checklist:**

- [ ] Browser cache cleared? (Ctrl+Shift+R)
- [ ] React dashboard restarted? (npm start)
- [ ] No JavaScript errors? (Browser DevTools → Console)
- [ ] Settings.js file saved? (Check timestamp)

**Fix:**

```bash
cd admin-dashboard
npm start
```

### Problem: Changing logging doesn't affect console output

**Checklist:**

- [ ] Backend restarted after database column added?
- [ ] Correct backend process (node index.js) running?
- [ ] Logging_enabled in database changed? (Check phpMyAdmin)
- [ ] API response shows success?

**Fix 1: Add database column**

```bash
node add-logging-column.js
node index.js  # Restart
```

**Fix 2: Check database value**

```sql
SELECT logging_enabled FROM system_settings WHERE id = 1;
```

### Problem: No logs printing to console

**Checklist:**

- [ ] Logging is enabled in Settings? (Toggle shows "Enabled")
- [ ] Making API calls? (Not just viewing pages)
- [ ] Running correct backend? (node index.js)
- [ ] Endpoint has logger calls? (Check index.js code)

**Fix:**

```bash
# Check backend is running
node index.js

# Make a login attempt from mobile app
# Should see logs in console

# If not, grep for logger calls
grep -n "logger\." index.js | head -20
```

---

## Performance Testing

### Test Logging Overhead

**Setup:**
Create a test script that makes 100 API calls

**With Logging Enabled:**

```
Total time: ~500-1000ms
Average per request: 5-10ms
```

**With Logging Disabled:**

```
Total time: ~300-500ms
Average per request: 3-5ms
```

**Verdict:**

- Overhead is minimal (~2-5ms per request)
- Safe to leave enabled in development
- Disable in production for clean console
- No database performance impact

---

## Integration Test Checklist

- [ ] Migration script runs: `node add-logging-column.js`
- [ ] Backend starts: `node index.js`
- [ ] Dashboard loads: `npm start` (from admin-dashboard)
- [ ] Settings page loads and shows toggle
- [ ] Toggling works (shows enabled/disabled)
- [ ] Settings save successfully
- [ ] Console shows/hides logs when toggled
- [ ] Mobile app still works normally
- [ ] All existing features unaffected
- [ ] No console errors in browser DevTools

---

## Example Test Data

### Successful Login Log

```json
{
  "timestamp": "2026-03-02T10:15:31.456Z",
  "level": "INFO",
  "message": "User login successful",
  "data": {
    "user_id": 2,
    "email": "john@quarry.com"
  }
}
```

### Denied Check-in Log

```json
{
  "timestamp": "2026-03-02T10:15:36.234Z",
  "level": "WARN",
  "message": "Check-in denied - out of range",
  "data": {
    "rep_id": 2,
    "customer_id": 5,
    "distance": 250,
    "allowedRadius": 50
  }
}
```

### Database Error Log

```json
{
  "timestamp": "2026-03-02T10:15:40.789Z",
  "level": "ERROR",
  "message": "Login error",
  "data": "Connection refused at 127.0.0.1:3306"
}
```

---

## Success Criteria

✅ **All tests passed** when:

1. ✅ Logging toggle visible in Admin Settings
2. ✅ Toggle saves to database correctly
3. ✅ Console shows logs when enabled
4. ✅ Console stays clean when disabled
5. ✅ All endpoints still work normally
6. ✅ No performance degradation
7. ✅ Logs are readable and helpful
8. ✅ No database errors
9. ✅ Mobile app unaffected
10. ✅ Can enable/disable without restart

---

For complete setup, see: **LOGGING_SETUP.md**
