<?php
/**
 * QuarryForce Configuration
 * Load environment variables from .env file
 */

// Load .env file
$env_file = __DIR__ . '/.env';
if (file_exists($env_file)) {
    $env_lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($env_lines as $line) {
        if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            putenv("$key=$value");
            $_ENV[$key] = $value;
        }
    }
}

// Database configuration
defined('DB_HOST') or define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
defined('DB_USER') or define('DB_USER', getenv('DB_USER') ?: 'quarryforce_user');
defined('DB_PASS') or define('DB_PASS', getenv('DB_PASSWORD') ?: '');
defined('DB_NAME') or define('DB_NAME', getenv('DB_NAME') ?: 'quarryforce_db');
defined('DB_PORT') or define('DB_PORT', getenv('DB_PORT') ?: 3306);

// API configuration
defined('API_URL') or define('API_URL', getenv('API_URL') ?: 'https://valviyal.com/qft');
defined('FRONTEND_URL') or define('FRONTEND_URL', getenv('FRONTEND_URL') ?: 'https://valviyal.com/qft');

// Environment
defined('NODE_ENV') or define('NODE_ENV', getenv('NODE_ENV') ?: 'production');

// Logging configuration
defined('LOGGING_ENABLED') or define('LOGGING_ENABLED', getenv('LOGGING_ENABLED') !== 'false');
defined('LOG_LEVEL') or define('LOG_LEVEL', getenv('LOG_LEVEL') ?: 'DEBUG'); // DEBUG, INFO, WARN, ERROR
defined('LOG_DIR') or define('LOG_DIR', __DIR__ . '/logs');
defined('LOG_FILE') or define('LOG_FILE', 'app.log');
defined('LOG_MAX_SIZE') or define('LOG_MAX_SIZE', 10485760); // 10MB in bytes

// Initialize Logger class
require_once __DIR__ . '/Logger.php';
Logger::init([
    'enabled' => LOGGING_ENABLED,
    'logLevel' => LOG_LEVEL,
    'logDir' => LOG_DIR,
    'logFile' => LOG_FILE,
    'maxFileSize' => LOG_MAX_SIZE
]);

// Log startup
if (LOGGING_ENABLED) {
    Logger::debug('QuarryForce PHP Backend Starting', [
        'environment' => NODE_ENV,
        'timestamp' => date('Y-m-d H:i:s'),
        'php_version' => phpversion()
    ]);
}

// CORS Origins
define('ALLOWED_ORIGINS', [
    'https://valviyal.com',
    'http://localhost:3000',
    'http://localhost:19006',
    '*'
]);

// Settings defaults
define('DEFAULT_GPS_RADIUS', 100); // meters
define('DEFAULT_CURRENCY', '₹');
define('DEFAULT_COMPANY_NAME', 'QuarryForce');

?>
