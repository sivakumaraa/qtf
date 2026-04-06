# QuarryForce: Node.js Backup & PHP Logging Guide

## Overview

This guide explains the backup of the original Node.js implementation and the comprehensive logging system set up for the new PHP backend.

---

## 1. Node.js Implementation Backup

### Location

```
qft-deployment/nodejs-backup/
├── api.php           (Complete PHP backend with all 15+ endpoints)
├── Database.php      (MySQL connection configuration)
└── .env              (Configuration: DB credentials, API settings)
```

### Purpose

- **Preserve Original Code**: Complete backup of the working Node.js implementation using Express.js
- **Reference Implementation**: Use as reference for converting endpoints to PHP
- **Fallback**: Restore if PHP conversion encounters issues
- **Documentation**: Shows all API contracts that PHP version must maintain

### Files Included

**api.php (1000+ lines)**

- All 15+ API endpoints implemented in PHP 8.2+
- Complete request/response handling
- GPS distance calculations using Haversine formula
- Database connections via PDO
- Error handling and logging
- RESTful routing with switch statement

**Database.php**

- PHP PDO connection pool configuration
- Prepared statement execution for security
- Environment variable integration
- Query execution with error handling

**.env**

- Database configuration (host, user, password, database name)
- API settings and logging enabled flag
- Environment-specific credentials

### Restoring PHP Backend (if deleted)

```bash
# 1. Copy backup files back to qft-deployment folder
cp -r qft-deployment-backup/* ./qft-deployment/

# 2. Ensure .env file exists with database credentials in qft-deployment/.env
# 3. Start PHP server
php -S localhost:8000
```

---

## 2. PHP Logging System

### Overview

A comprehensive, structured logging system for the PHP backend with:

- **Multiple Log Levels**: DEBUG, INFO, WARN, ERROR
- **Structured JSON Logs**: Machine-readable format
- **File Rotation**: Automatic log rotation when size limit exceeded
- **Context Tracking**: Automatic request context capture
- **Easy Integration**: Single-line logging calls

### Logger Class Location

```
qft-deployment/Logger.php
```

### Configuration in config.php

```php
// Enable/disable logging
defined('LOGGING_ENABLED') or define('LOGGING_ENABLED', getenv('LOGGING_ENABLED') !== 'false');

// Log level (DEBUG, INFO, WARN, ERROR)
defined('LOG_LEVEL') or define('LOG_LEVEL', getenv('LOG_LEVEL') ?: 'DEBUG');

// Log directory
defined('LOG_DIR') or define('LOG_DIR', __DIR__ . '/logs');

// Log filename
defined('LOG_FILE') or define('LOG_FILE', 'app.log');

// Max file size before rotation (10MB)
defined('LOG_MAX_SIZE') or define('LOG_MAX_SIZE', 10485760);
```

### .env Configuration

```bash
# Logging settings
LOGGING_ENABLED=true
LOG_LEVEL=DEBUG
# LOG_LEVEL can be: DEBUG, INFO, WARN, ERROR
```

---

## 3. Using the Logger

### Basic Logging

**INFO Level** (general information)

```php
Logger::info('User logged in', ['user_id' => 123, 'email' => 'demo@test.com']);
Logger::info('Settings updated');
```

**DEBUG Level** (detailed debugging info)

```php
Logger::debug('Processing check-in', ['rep_id' => 1, 'customer_id' => 5]);
Logger::debug('Database query executed');
```

**WARN Level** (warnings, non-critical issues)

```php
Logger::warn('Device mismatch detected', ['stored' => 'uuid1', 'provided' => 'uuid2']);
Logger::warn('GPS distance exceeded limit', ['distance' => 150, 'limit' => 100]);
```

**ERROR Level** (critical errors)

```php
Logger::error('Database connection failed', ['error' => $e->getMessage()]);
Logger::error('Login failed', ['reason' => 'User not found', 'email' => $email]);
```

### API Request/Response Logging

```php
// Log incoming API request
Logger::logRequest('/api/login', 'POST', ['email' => 'demo@test.com']);

// Log API response
Logger::logResponse('/api/login', 200, ['user_id' => 1]);
Logger::logResponse('/api/login', 401, ['error' => 'Invalid credentials']);
```

### Database Logging

```php
// Log database query (for debugging)
Logger::logQuery('SELECT * FROM users WHERE id = ?', [123]);

// Log database error
Logger::logQueryError('INSERT INTO users ...', $pdo->errorInfo()[2]);
```

### User Action Logging

```php
// Log user actions (login, logout, data changes)
Logger::logAction('login', 123, ['method' => 'email', 'device' => 'mobile']);
Logger::logAction('rep_target_update', 456, ['target_m3' => 1000, 'incentive' => 50]);
Logger::logAction('logout', 123);
```

---

## 4. Log File Structure

### Log Location

```
qft-deployment/logs/
└── app.log          (Main application log - JSON format)
```

### Log Entry Format

Each line is a complete JSON object:

```json
{
  "timestamp": "2026-03-05 10:30:45.1234",
  "level": "INFO",
  "message": "User logged in",
  "request": {
    "method": "POST",
    "uri": "/api/login",
    "ip": "192.168.1.1",
    "user_id": 123
  },
  "data": {
    "user_id": 123,
    "email": "demo@test.com"
  }
}
```

### Log Levels Explained

- **DEBUG**: Detailed technical information for debugging (most verbose)
- **INFO**: General informational messages (recommended for production)
- **WARN**: Warning messages - potential issues
- **ERROR**: Error messages - serious issues (least verbose)

---

## 5. Log Rotation

### Automatic Rotation

- When log file exceeds 10MB, it's automatically renamed with timestamp
- Original filename pattern: `app.log`
- Rotated filename pattern: `app.2026-03-05_10-30-45.log`

### Manual Log Management

**Get recent log entries:**

```php
$recentLogs = Logger::getRecentLogs(100); // Get last 100 entries
foreach ($recentLogs as $entry) {
    echo $entry['timestamp'] . ' [' . $entry['level'] . '] ' . $entry['message'];
}
```

**Get log file size:**

```php
$sizeInMB = Logger::getLogFileSize();
echo "Log file size: $sizeInMB MB";
```

**Clear log file:**

```php
Logger::clearLog(); // Clear all logs and log the action
```

**Enable/disable logging:**

```php
Logger::setEnabled(false);  // Disable logging
Logger::setEnabled(true);   // Enable logging
```

**Change log level at runtime:**

```php
Logger::setLogLevel('WARN');    // Only log WARN and ERROR
Logger::setLogLevel('DEBUG');   // Log everything
```

---

## 6. Testing the Logging System

### Quick Test Script

Create `test-logging.php`:

```php
<?php
require_once 'config.php';  // Loads Logger automatically

echo "Testing Logger...\n\n";

// Test all log levels
Logger::debug('This is a DEBUG message');
Logger::info('This is an INFO message');
Logger::warn('This is a WARN message');
Logger::error('This is an ERROR message');

// Test with data
Logger::info('User action', ['action' => 'login', 'user_id' => 123]);
Logger::error('Database error', ['query' => 'SELECT * FROM users', 'error' => 'Connection timeout']);

// Get recent logs
$recentLogs = Logger::getRecentLogs(5);
echo "\nRecent logs:\n";
echo json_encode($recentLogs, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

echo "\nLog file size: " . Logger::getLogFileSize() . " MB\n";
?>
```

**Run test:**

```bash
php test-logging.php
```

**View log file:**

```bash
tail -f logs/app.log
```

---

## 7. Production Logging Best Practices

### Recommended Settings

```bash
# .env for production
LOGGING_ENABLED=true
LOG_LEVEL=INFO      # INFO level: skip DEBUG messages, fewer logs
```

### What to Log

✅ **DO Log:**

- User login/logout
- API request/response (especially errors)
- Database errors
- Authentication failures
- Data changes (updates, deletes)
- Configuration changes

❌ **DON'T Log:**

- Passwords, tokens, sensitive data
- Full request bodies with credentials
- Raw database queries with sensitive data
- Excessive DEBUG-level messages in production

### Example: Secure Login Logging

```php
Logger::info('Login attempt', [
    'email' => $email,
    'device_uid' => 'hidden',    // Don't log device IDs
    'success' => true
]);
// Don't log: password, full auth tokens
```

---

## 8. Reading and Analyzing Logs

### Using Command Line

```bash
# View last 50 lines
tail -50 logs/app.log

# Follow logs in real-time
tail -f logs/app.log

# Filter by log level
grep '"level":"ERROR"' logs/app.log

# Count errors
grep -c '"level":"ERROR"' logs/app.log

# View logs from specific time
grep "2026-03-05 10:" logs/app.log

# Parse JSON and format nicely (requires jq)
tail -20 logs/app.log | jq .
```

### Parse Logs Programmatically

```php
<?php
require_once 'config.php';

// Get all errors from today
$logsFile = LOG_DIR . '/' . LOG_FILE;
$logs = file($logsFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

$errors = [];
foreach ($logs as $line) {
    $entry = json_decode($line, true);
    if ($entry && $entry['level'] === 'ERROR') {
        $errors[] = $entry;
    }
}

echo "Found " . count($errors) . " errors\n";
foreach ($errors as $error) {
    echo $error['timestamp'] . ': ' . $error['message'] . "\n";
}
?>
```

---

## 9. Integration with API.php

When creating `api.php`, use logging like this:

```php
<?php
require_once 'config.php';
require_once 'Database.php';

// Log incoming request
Logger::logRequest(
    $_SERVER['REQUEST_URI'],
    $_SERVER['REQUEST_METHOD'],
    ['content_type' => $_SERVER['CONTENT_TYPE'] ?? 'None']
);

// In each endpoint:
try {
    $db = new Database();
    $result = $db->query('SELECT * FROM users WHERE id = ?', [$_GET['id']]);

    Logger::logResponse('/api/users', 200, ['rows' => count($result)]);
    echo json_encode(['success' => true, 'data' => $result]);

} catch (Exception $e) {
    Logger::error('API Error', ['endpoint' => $_SERVER['REQUEST_URI'], 'error' => $e->getMessage()]);
    Logger::logResponse('/api/users', 500, ['error' => 'Database error']);
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database error']);
}
?>
```

---

## 10. Monitoring for Issues

### Key Metrics to Track

- **Login Failures**: Count `Logger::error` with "Login"
- **Database Errors**: Count entries with `"type":"database_error"`
- **API Response Times**: Manual log entry on slow queries
- **Device Binding Issues**: Search for "device mismatch"

### Alert Thresholds

Set up monitoring for:

- More than 5 login failures in 5 minutes → Possible brute force
- Any database connection error → Check database status
- Log file exceeds 50MB → Disk space issue

---

## 11. Troubleshooting Logging

### Logs Not Being Written

**Problem**: No logs/ directory or logs not appearing

**Solutions**:

1. Check permissions: `chmod 755 qft-deployment/logs`
2. Verify LOGGING_ENABLED=true in .env
3. Check PHP has write permissions to logs/ directory
4. Test manually: `Logger::info('Test'); echo file_exists('logs/app.log');`

### Log File Growing Too Large

**Problem**: logs/app.log exceeds 10MB frequently

**Solutions**:

1. Change LOG_LEVEL to 'WARN' to reduce DEBUG messages
2. Increase LOG_MAX_SIZE in config.php
3. Set up automated log archival script
4. Clear old logs periodically

### Sensitive Data in Logs

**Problem**: Passwords or tokens appearing in logs

**Solutions**:

1. Never use `Logger::debug()` with raw POST data
2. Filter data before logging: `Logger::info('Login', ['email' => $email])` (no password)
3. Use request context functions to avoid logging sensitive headers
4. Review all Logger calls in api.php before deployment

---

## Summary

| Component        | Location         | Purpose                         |
| ---------------- | ---------------- | ------------------------------- |
| **Backup**       | `nodejs-backup/` | Complete Node.js implementation |
| **Logger Class** | `Logger.php`     | Structured logging utility      |
| **Config**       | `config.php`     | Logging configuration           |
| **Logs**         | `logs/app.log`   | Application logs (JSON format)  |

### Next Steps

1. ✅ Backup created (nodejs-backup/)
2. ✅ Logger class created and ready
3. ⏳ Integrate logging into api.php (next)
4. ⏳ Test all endpoints with logging (next)
5. ⏳ Deploy and monitor logs on server (next)
