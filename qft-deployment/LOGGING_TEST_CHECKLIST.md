# Logging Testing Checklist

Use this checklist to verify the logging system is working correctly.

## Quick Test

1. **Verify Logger.php exists**

   ```bash
   [ ] File exists: qft-deployment/Logger.php
   [ ] Contains Logger class with all methods
   ```

2. **Verify config.php has logging setup**

   ```bash
   [ ] File: qft-deployment/config.php
   [ ] Contains: Logger::init() call
   [ ] Contains: LOG_LEVEL, LOG_DIR, LOG_FILE constants
   ```

3. **Create test log entry**

   ```bash
   php -r "require 'qft-deployment/config.php'; Logger::info('Test entry'); echo 'Check logs/app.log';"
   ```

4. **Verify logs directory created**

   ```bash
   [ ] Directory exists: qft-deployment/logs/
   [ ] Is writable by PHP process
   [ ] Contains app.log file
   ```

5. **Check log format**
   ```bash
   [ ] Each line is valid JSON
   [ ] Contains: timestamp, level, message, request, data
   [ ] Can be parsed by json_decode()
   ```

## Test Scenarios

### Test 1: Basic Logging

```php
<?php
require_once 'qft-deployment/config.php';

Logger::debug('Debug message');
Logger::info('Info message');
Logger::warn('Warn message');
Logger::error('Error message');

echo "Check qft-deployment/logs/app.log\n";
?>
```

### Test 2: Logging with Data

```php
<?php
require_once 'qft-deployment/config.php';

Logger::info('User action', [
    'action' => 'login',
    'user_id' => 123,
    'email' => 'test@test.com',
    'timestamp' => date('Y-m-d H:i:s')
]);

echo "Check qft-deployment/logs/app.log\n";
?>
```

### Test 3: Logging with Different Levels

```php
<?php
require_once 'qft-deployment/config.php';

// Set log level to INFO (skip DEBUG)
Logger::setLogLevel('INFO');

Logger::debug('This should NOT appear');  // Skipped
Logger::info('This SHOULD appear');       // Appears
Logger::warn('This SHOULD appear');       // Appears
Logger::error('This SHOULD appear');      // Appears

echo "Check qft-deployment/logs/app.log\n";
echo "Should see 3 entries, not 4\n";
?>
```

### Test 4: Database Query Logging

```php
<?php
require_once 'qft-deployment/config.php';
require_once 'qft-deployment/Database.php';

try {
    $db = new Database();
    Logger::logQuery('SELECT * FROM users WHERE id = ?', [123]);

    // Simulate error
    Logger::logQueryError('INSERT INTO users ...', 'Duplicate entry');
} catch (Exception $e) {
    Logger::error('Test error', ['message' => $e->getMessage()]);
}

echo "Check qft-deployment/logs/app.log\n";
?>
```

### Test 5: Request/Response Logging

```php
<?php
require_once 'qft-deployment/config.php';

Logger::logRequest('/api/login', 'POST', ['email' => 'test@test.com']);
Logger::logResponse('/api/login', 200, ['user_id' => 1, 'name' => 'Test User']);

Logger::logRequest('/api/invalid', 'GET');
Logger::logResponse('/api/invalid', 404, ['error' => 'Not found']);

echo "Check qft-deployment/logs/app.log\n";
?>
```

## Expected Output

Each test should produce JSON lines in `qft-deployment/logs/app.log`:

```json
{"timestamp":"2026-03-05 10:30:45.1234","level":"INFO","message":"User action","request":{"method":"POST","uri":"/test","ip":"127.0.0.1"},"data":"{\"action\":\"login\",\"user_id\":123}"}
{"timestamp":"2026-03-05 10:30:46.5678","level":"ERROR","message":"Error message","request":{"method":"POST"}}
```

## Linux/Mac Command Tests

View recent logs:

```bash
tail -20 qft-deployment/logs/app.log
```

Follow logs in real-time:

```bash
tail -f qft-deployment/logs/app.log
```

Count errors:

```bash
grep 'ERROR' qft-deployment/logs/app.log | wc -l
```

Parse and pretty-print (requires jq):

```bash
tail -5 qft-deployment/logs/app.log | jq .
```

Filter by level:

```bash
grep '"level":"WARN"' qft-deployment/logs/app.log
```

## Windows PowerShell Tests

View recent logs:

```powershell
Get-Content qft-deployment/logs/app.log -Tail 20
```

Follow logs (PowerShell 7+):

```powershell
Get-Content qft-deployment/logs/app.log -Wait -Tail 0
```

Count errors:

```powershell
(Get-Content qft-deployment/logs/app.log | Select-String 'ERROR').Count
```

Filter by level:

```powershell
Get-Content qft-deployment/logs/app.log | Select-String 'WARN'
```

## Monitoring for Issues

### Verify JSON Validity

```bash
php -r "
$logs = file('qft-deployment/logs/app.log', FILE_IGNORE_NEW_LINES);
foreach ($logs as $line) {
    json_decode(\$line);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo 'Invalid JSON: ' . \$line . PHP_EOL;
    }
}
echo 'All lines are valid JSON';
"
```

### Check Log File Size

```bash
ls -lh qft-deployment/logs/app.log
```

### View Log Statistics

```bash
php -r "
require 'qft-deployment/config.php';
echo 'Log file size: ' . Logger::getLogFileSize() . ' MB' . PHP_EOL;

\$logs = Logger::getRecentLogs(100);
echo 'Recent log entries: ' . count(\$logs) . PHP_EOL;

\$levels = array_count_values(array_values(array_column(\$logs, 'level')));
echo 'Entries by level:' . PHP_EOL;
foreach (\$levels as \$level => \$count) {
    echo \"  \$level: \$count\" . PHP_EOL;
}
"
```

## Troubleshooting

### Problem: No logs/app.log file created

- [ ] Check if `qft-deployment/logs/` directory exists
- [ ] Check directory permissions: `chmod 755 qft-deployment/logs`
- [ ] Verify LOGGING_ENABLED=true in .env
- [ ] Check PHP error log for permission errors

### Problem: Empty or incomplete log lines

- [ ] Verify JSON encoding: Large data might be truncated
- [ ] Check max_string_length in Logger::formatData()
- [ ] Increase memory_limit in php.ini if data is very large

### Problem: Logs grow too quickly

- [ ] Start with LOG_LEVEL=WARN instead of DEBUG
- [ ] Reduce frequency of debug logging calls
- [ ] Check for infinite loops writing logs

## Performance Notes

- Logging adds ~1-2ms per entry (JSON encoding + file write)
- DEBUG level can impact performance (10-15% slower than WARN)
- File rotation happens automatically at 10MB
- Large data structures (full JSON responses) can slow logging

## Security Notes

- Never log passwords, API keys, or tokens
- Sanitize user input before logging
- Be careful with sensitive fields (email, phone, SSN)
- Rotate old logs periodically for privacy
- Restrict log file access: `chmod 600 logs/app.log`
