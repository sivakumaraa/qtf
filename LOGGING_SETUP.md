# API Logging Setup Guide

## Overview

QuarryForce now supports comprehensive API logging that can be toggled on/off via the admin dashboard. This allows you to:

- 📊 **Debug API issues** - See all requests and responses
- 🐛 **Track errors** - Identify what went wrong and when
- 🔍 **Monitor activity** - Watch real-time API usage
- ⚡ **Performance tracking** - See API request timestamps

## How It Works

### Backend Logging

The backend (`index.js`) includes a centralized logging utility that:

```javascript
logger.info(message, data); // Log informational events
logger.warn(message, data); // Log warnings
logger.error(message, data); // Log errors
logger.debug(message, data); // Log debug information
```

**Logged Events:**

- Login attempts (success/failure)
- Check-in verifications (success/denied)
- Visit submissions
- Fuel submissions
- Admin operations (device resets, settings changes)
- Database errors
- Settings changes

### Toggle Logging from Dashboard

1. **Open Admin Dashboard** → Navigate to **Settings**
2. **Find "Enable API Logging"** toggle in the settings form
3. **Toggle ON/OFF** to enable or disable logging
4. **Click "Save Settings"** to apply changes
5. **Immediately takes effect** - no server restart needed

## Database Setup

### Add Logging Column (One-Time Setup)

If you're setting up logging for an existing system, run this SQL command:

```sql
-- Add logging_enabled column to system_settings
ALTER TABLE system_settings
ADD COLUMN logging_enabled BOOLEAN DEFAULT 1 AFTER fraud_detection_enabled;

-- Set default value to enabled
UPDATE system_settings SET logging_enabled = 1 WHERE logging_enabled IS NULL;
```

### Full system_settings Table Structure

```sql
CREATE TABLE IF NOT EXISTS system_settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  company_name VARCHAR(255) DEFAULT 'QuarryForce',
  gps_radius_limit INT DEFAULT 50,
  device_binding_enabled BOOLEAN DEFAULT 1,
  allow_mock_location BOOLEAN DEFAULT 0,
  fraud_detection_enabled BOOLEAN DEFAULT 0,
  logging_enabled BOOLEAN DEFAULT 1,
  currency_symbol VARCHAR(3) DEFAULT '₹',
  site_types JSON DEFAULT '["Quarry", "Site", "Dump"]',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Viewing Logs

### Server Console

When logging is enabled, all API activity appears in the server console:

```
[2026-03-02T10:15:30.123Z] [INFO] Login attempt { email: 'john@quarry.com', device_uid: 'ABC123...' }
[2026-03-02T10:15:31.456Z] [INFO] User login successful { user_id: 2, email: 'john@quarry.com' }
[2026-03-02T10:15:35.789Z] [INFO] Check-in attempt { rep_id: 2, customer_id: 5, rep_lat: 12.9716, rep_lng: 77.5946 }
[2026-03-02T10:15:36.234Z] [INFO] Check-in successful { rep_id: 2, customer_id: 5, distance: 45, allowedRadius: 50 }
[2026-03-02T10:16:00.567Z] [ERROR] Check-in error Connection refused
```

### Format

Each log entry contains:

- **Timestamp** - ISO 8601 format (UTC)
- **Level** - INFO, WARN, ERROR, or DEBUG
- **Message** - What happened
- **Data** - Relevant details (user_id, customer_id, etc.)

## Log Levels

### 📊 INFO

General informational messages about normal operations.

Examples:

- Login successful
- Check-in successful
- Visit recorded
- Settings updated
- Device reset

### ⚠️ WARN

Warning-level events that aren't errors but should be noted.

Examples:

- Login failed - invalid credentials
- Check-in denied - out of GPS range
- Territory protection violation
- Device mismatch detected

### ❌ ERROR

Error-level events indicating failures.

Examples:

- Database connection failed
- API endpoint error
- Settings update failed
- Login error

### 🔧 DEBUG

Detailed debugging information.

Examples:

- Fetching system settings
- Fetching all reps/customers
- Request details

## Endpoints That Log

### Authentication

- `POST /api/login` - Login attempts and results

### Mobile Operations

- `POST /api/checkin` - GPS check-in attempts
- `POST /api/visit/submit` - Visit submissions
- `POST /api/fuel/submit` - Fuel log submissions

### Admin Operations

- `GET /api/settings` - Settings retrieval
- `PUT /api/settings` - Settings updates (including logging toggle)
- `GET /api/admin/reps` - Fetch all reps
- `GET /api/admin/customers` - Fetch all customers
- `POST /api/admin/reset-device` - Device resets

## Performance Impact

**Logging Disabled:** ✅ Minimal overhead - checking an if statement

**Logging Enabled:** ~5-10ms per request for console output

For high-traffic scenarios, consider:

- Disabling logging during peak hours
- Using file-based logging (see Advanced section below)

## Best Practices

### Development

- ✅ Leave logging **ENABLED** to debug issues
- ✅ Check server console for API behavior
- ✅ Use `logger.debug()` calls for detailed tracing

### Staging/QA

- ✅ Keep logging **ENABLED** for testing
- ✅ Monitor for errors during testing cycles
- ✅ Review logs before production deployment

### Production

- 🔴 Disable logging for **normal operation**
- ✅ Enable temporarily to troubleshoot issues
- ⭐ Only errors will be logged even when disabled

## Advanced: File-Based Logging

To persist logs to a file instead of console, modify `index.js`:

```javascript
const fs = require("fs");
const logStream = fs.createWriteStream("logs/api.log", { flags: "a" });

const logger = {
  log: (level, message, data = null) => {
    if (!loggingEnabled) return;
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] [${level}] ${message} ${data ? JSON.stringify(data) : ""}`;

    logStream.write(logEntry + "\n");
    console.log(logEntry);
  },
  // ... rest of logger
};
```

## Troubleshooting

**Logs not appearing?**

1. Check if logging_enabled is true in Settings
2. Verify `logger.` calls are in the endpoint
3. Check server console (not just file)

**Too many logs cluttering console?**

1. Go to Settings → disable logging
2. Disable specific endpoints by removing logger calls
3. Filter console output to show only errors

**Logs showing old settings?**

1. Changes take effect immediately
2. Restart server if checking ENV var only
3. Verify database was updated with new setting

## Example Debugging Session

### Goal: Debug why a check-in is failing

1. Open **Admin Dashboard** → **Settings**
2. Enable **"Enable API Logging"** toggle
3. Have rep attempt check-in in mobile app
4. Check server console for logs like:
   ```
   [10:15:35.789Z] [INFO] Check-in attempt { rep_id: 2, customer_id: 5, rep_lat: 12.9716, rep_lng: 77.5946 }
   [10:15:35.890Z] [WARN] Check-in denied - out of range { rep_id: 2, customer_id: 5, distance: 250, allowedRadius: 50 }
   ```
5. See the distance is 250m but limit is 50m
6. Increase GPS radius in Settings if needed
7. Retry check-in
8. See success log
9. Disable logging when done

## Summary

✅ **Enabled** = Full debugging capability, monitor console for all API activity

✅ **Disabled** = Only errors logged, recommended for production

🎯 **Toggle anytime** = Change in Settings, no restart needed

💡 **Pro Tip** = Enable logging when troubleshooting, disable for normal operations
