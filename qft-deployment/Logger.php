<?php
/**
 * Logger.php - Comprehensive logging system for PHP backend
 * 
 * Usage:
 *   Logger::info('User login', ['user_id' => 1, 'email' => 'test@test.com']);
 *   Logger::error('Database connection failed', ['error' => $e->getMessage()]);
 *   Logger::debug('Processing request', ['method' => $_SERVER['REQUEST_METHOD']]);
 *   Logger::warn('Authentication attempt failed', ['attempts' => 3]);
 * 
 * Logs are stored in: logs/app.log (or custom path from config)
 */

class Logger {
    private static $logFile = null;
    private static $logDir = null;
    private static $enabled = true;
    private static $logLevel = 'DEBUG'; // DEBUG, INFO, WARN, ERROR
    private static $maxFileSize = 10485760; // 10MB

    const LEVEL_DEBUG = 'DEBUG';
    const LEVEL_INFO = 'INFO';
    const LEVEL_WARN = 'WARN';
    const LEVEL_ERROR = 'ERROR';

    /**
     * Initialize logger with custom configuration
     * 
     * @param array $config Configuration array:
     *   - logDir: Directory for log files (default: ./logs)
     *   - logFile: Log filename (default: app.log)
     *   - enabled: Enable/disable logging (default: true)
     *   - logLevel: Minimum log level to record (default: DEBUG)
     *   - maxFileSize: Max log file size before rotation (default: 10MB)
     */
    public static function init($config = []) {
        self::$logDir = $config['logDir'] ?? __DIR__ . '/logs';
        self::$logFile = $config['logFile'] ?? 'app.log';
        self::$enabled = $config['enabled'] ?? true;
        self::$logLevel = $config['logLevel'] ?? self::LEVEL_DEBUG;
        self::$maxFileSize = $config['maxFileSize'] ?? 10485760;

        // Create logs directory if it doesn't exist
        if (!is_dir(self::$logDir)) {
            @mkdir(self::$logDir, 0755, true);
        }
    }

    /**
     * Get the full log file path
     */
    private static function getLogPath() {
        if (self::$logFile === null) {
            self::init(); // Auto-initialize with defaults
        }
        return self::$logDir . '/' . self::$logFile;
    }

    /**
     * Check if this log level should be recorded
     */
    private static function shouldLog($level) {
        $levels = [self::LEVEL_DEBUG => 0, self::LEVEL_INFO => 1, self::LEVEL_WARN => 2, self::LEVEL_ERROR => 3];
        return $levels[$level] >= $levels[self::$logLevel];
    }

    /**
     * Get current timestamp in ISO 8601 format
     */
    private static function getTimestamp() {
        return date('Y-m-d H:i:s.') . substr((string)microtime(true), -4);
    }

    /**
     * Get request context information
     */
    private static function getRequestContext() {
        $context = [];
        
        if (isset($_SERVER['REQUEST_METHOD'])) {
            $context['method'] = $_SERVER['REQUEST_METHOD'];
        }
        
        if (isset($_SERVER['REQUEST_URI'])) {
            $context['uri'] = $_SERVER['REQUEST_URI'];
        }
        
        if (isset($_SERVER['REMOTE_ADDR'])) {
            $context['ip'] = $_SERVER['REMOTE_ADDR'];
        }
        
        if (isset($_SESSION['user_id'])) {
            $context['user_id'] = $_SESSION['user_id'];
        }

        return !empty($context) ? $context : null;
    }

    /**
     * Format data for logging
     */
    private static function formatData($data) {
        if ($data === null) {
            return null;
        }
        
        if (is_array($data) || is_object($data)) {
            return json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
        
        return (string)$data;
    }

    /**
     * Rotate log file if it exceeds max size
     */
    private static function rotateLogIfNeeded() {
        $logPath = self::getLogPath();
        
        if (file_exists($logPath) && filesize($logPath) > self::$maxFileSize) {
            $timestamp = date('Y-m-d_H-i-s');
            $rotatedPath = self::$logDir . '/' . pathinfo(self::$logFile, PATHINFO_FILENAME) 
                         . '.' . $timestamp . '.' 
                         . pathinfo(self::$logFile, PATHINFO_EXTENSION);
            
            if (rename($logPath, $rotatedPath)) {
                // Optionally gzip the rotated file
                if (function_exists('gzopen')) {
                    gzcompress(file_get_contents($rotatedPath));
                }
            }
        }
    }

    /**
     * Write formatted log entry to file and optionally to error_log
     */
    private static function write($level, $message, $data = null) {
        if (!self::$enabled || !self::shouldLog($level)) {
            return;
        }

        // Rotate log if needed
        self::rotateLogIfNeeded();

        $timestamp = self::getTimestamp();
        $logPath = self::getLogPath();
        $requestContext = self::getRequestContext();
        
        // Format the log entry
        $logEntry = [
            'timestamp' => $timestamp,
            'level' => $level,
            'message' => $message,
        ];

        if ($requestContext) {
            $logEntry['request'] = $requestContext;
        }

        if ($data !== null) {
            $logEntry['data'] = self::formatData($data);
        }

        // JSON format for structured logging
        $jsonEntry = json_encode($logEntry, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        // Write to file
        if (is_writable(self::$logDir) || is_writable(dirname($logPath))) {
            file_put_contents($logPath, $jsonEntry . PHP_EOL, FILE_APPEND | LOCK_EX);
        }

        // Also log errors to PHP error_log
        if ($level === self::LEVEL_ERROR) {
            error_log("[$timestamp] [$level] $message" . ($data ? ' | ' . self::formatData($data) : ''));
        }
    }

    /**
     * Log DEBUG level message
     */
    public static function debug($message, $data = null) {
        self::write(self::LEVEL_DEBUG, $message, $data);
    }

    /**
     * Log INFO level message
     */
    public static function info($message, $data = null) {
        self::write(self::LEVEL_INFO, $message, $data);
    }

    /**
     * Log WARN level message
     */
    public static function warn($message, $data = null) {
        self::write(self::LEVEL_WARN, $message, $data);
    }

    /**
     * Log ERROR level message
     */
    public static function error($message, $data = null) {
        self::write(self::LEVEL_ERROR, $message, $data);
    }

    /**
     * Log API request
     */
    public static function logRequest($endpoint, $method = null, $data = null) {
        $method = $method ?? ($_SERVER['REQUEST_METHOD'] ?? 'UNKNOWN');
        self::info("API Request: $method $endpoint", $data);
    }

    /**
     * Log API response
     */
    public static function logResponse($endpoint, $statusCode, $data = null) {
        $level = ($statusCode >= 400) ? self::LEVEL_WARN : self::LEVEL_INFO;
        self::write($level, "API Response: $endpoint [$statusCode]", $data);
    }

    /**
     * Log database query
     */
    public static function logQuery($query, $params = null) {
        self::debug("Database Query", [
            'query' => $query,
            'params' => $params
        ]);
    }

    /**
     * Log database error
     */
    public static function logQueryError($query, $error) {
        self::error("Database Error", [
            'query' => $query,
            'error' => $error
        ]);
    }

    /**
     * Log user action (login, logout, etc)
     */
    public static function logAction($action, $userId = null, $details = null) {
        $data = ['action' => $action];
        if ($userId) {
            $data['user_id'] = $userId;
        }
        if ($details) {
            $data['details'] = $details;
        }
        self::info("User Action", $data);
    }

    /**
     * Get recent log entries
     * 
     * @param int $lines Number of lines to retrieve (default: 100)
     * @return array Array of parsed log entries
     */
    public static function getRecentLogs($lines = 100) {
        $logPath = self::getLogPath();
        
        if (!file_exists($logPath)) {
            return [];
        }

        $file = new SplFileObject($logPath);
        $file->seek(PHP_INT_MAX);
        $totalLines = $file->key();
        $file = null; // Close file

        $startLine = max(0, $totalLines - $lines);
        $logs = [];

        $handle = fopen($logPath, 'r');
        $currentLine = 0;

        while (!feof($handle)) {
            $line = fgets($handle);
            
            if ($line && $currentLine >= $startLine) {
                $decoded = json_decode(trim($line), true);
                if ($decoded) {
                    $logs[] = $decoded;
                }
            }
            
            $currentLine++;
        }

        fclose($handle);
        return $logs;
    }

    /**
     * Clear log file
     */
    public static function clearLog() {
        $logPath = self::getLogPath();
        if (file_exists($logPath)) {
            file_put_contents($logPath, '');
            self::info('Log file cleared');
        }
    }

    /**
     * Get log file size in MB
     */
    public static function getLogFileSize() {
        $logPath = self::getLogPath();
        if (!file_exists($logPath)) {
            return 0;
        }
        return round(filesize($logPath) / 1048576, 2);
    }

    /**
     * Enable/disable logging
     */
    public static function setEnabled($enabled) {
        self::$enabled = (bool)$enabled;
    }

    /**
     * Set minimum log level
     */
    public static function setLogLevel($level) {
        if (in_array($level, [self::LEVEL_DEBUG, self::LEVEL_INFO, self::LEVEL_WARN, self::LEVEL_ERROR])) {
            self::$logLevel = $level;
        }
    }
}

// Auto-initialize on include
Logger::init();
