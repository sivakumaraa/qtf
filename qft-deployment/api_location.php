<?php
// ================================================================
// File: qft-deployment/api_location.php
// Phase 4.1: Location Tracking & Device Binding
// Purpose: API endpoints for rep login, device binding, and live location tracking
// ================================================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Include required files
require_once 'Database.php';
require_once 'Logger.php';

// Initialize database
$db = new Database();

// ================================================================
// UTILITY FUNCTIONS
// ================================================================

/**
 * Send JSON response
 */
function sendResponse($success, $message = '', $data = [], $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit;
}

/**
 * Get all headers including Authorization
 */
function getAuthorizationHeader() {
    $headers = null;
    if (isset($_SERVER['Authorization'])) {
        $headers = trim($_SERVER["Authorization"]);
    }
    elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
    }
    elseif (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();
        $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
        if (isset($requestHeaders['Authorization'])) {
            $headers = trim($requestHeaders["Authorization"]);
        }
    }
    return $headers;
}

/**
 * Get bearer token from Authorization header
 */
function getBearerToken() {
    $header = getAuthorizationHeader();
    if (!empty($header)) {
        if (preg_match('/Bearer\s+([a-zA-Z0-9\-_\.]+)/', $header, $matches)) {
            return $matches[1];
        }
    }
    return null;
}

/**
 * Generate JWT Token
 */
function generateJWT($payload, $secret = 'your-secret-key') {
    $header = base64_encode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
    $payload['iat'] = time();
    $payload['exp'] = time() + (24 * 60 * 60); // 24 hours validity
    $payload = base64_encode(json_encode($payload));
    
    $signature = hash_hmac('SHA256', "$header.$payload", $secret, true);
    $signature = base64_encode($signature);
    
    return "$header.$payload.$signature";
}

/**
 * Verify JWT Token and return payload
 */
function verifyJWT($token, $secret = 'your-secret-key') {
    try {
        $parts = explode('.', $token);
        if (count($parts) != 3) {
            return null;
        }
        
        list($header, $payload, $signature) = $parts;
        
        $valid_signature = base64_encode(
            hash_hmac('SHA256', "$header.$payload", $secret, true)
        );
        
        if ($signature !== $valid_signature) {
            return null;
        }
        
        $decoded = json_decode(base64_decode($payload), true);
        
        if ($decoded['exp'] < time()) {
            return null;
        }
        
        return $decoded;
    } catch (Exception $e) {
        return null;
    }
}

/**
 * Sanitize input
 */
function sanitize($data) {
    if (is_array($data)) {
        return array_map('sanitize', $data);
    }
    return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
}

/**
 * Validate email format
 */
function isValidEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

/**
 * Validate coordinates
 */
function isValidCoordinates($lat, $lng) {
    $lat = floatval($lat);
    $lng = floatval($lng);
    return $lat >= -90 && $lat <= 90 && $lng >= -180 && $lng <= 180;
}

/**
 * Get client IP address
 */
function getClientIP() {
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP'];
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    } else {
        $ip = $_SERVER['REMOTE_ADDR'];
    }
    return $ip;
}

// ================================================================
// ENDPOINT: POST /login
// Purpose: Authenticate rep with email/password and bind device
// ================================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['action']) && $_GET['action'] === 'login') {
    
    $email = sanitize($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    $device_uid = sanitize($_POST['device_uid'] ?? '');
    
    // Validation
    if (empty($email) || empty($password)) {
        Logger::warn('Login failed: Missing email or password');
        sendResponse(false, 'Email and password are required', [], 400);
    }
    
    if (!isValidEmail($email)) {
        Logger::warn("Login failed: Invalid email format - $email");
        sendResponse(false, 'Invalid email format', [], 400);
    }
    
    try {
        // Get user by email
        $user = $db->queryOne(
            "SELECT id, name, email, password, role, mobile_no, device_uid, device_bound, is_active 
             FROM users WHERE email = ? AND is_active = 1",
            [$email]
        );
        
        if (!$user) {
            Logger::warn("Login failed: User not found - $email");
            sendResponse(false, 'Invalid credentials', [], 401);
        }
        
        // Verify password
        if (!password_verify($password, $user['password'])) {
            Logger::warn("Login failed: Invalid password for user - {$user['id']}");
            sendResponse(false, 'Invalid credentials', [], 401);
        }
        
        // Check device binding
        if (!$user['device_uid']) {
            // First time login - generate device_uid
            $new_device_uid = bin2hex(random_bytes(16));
            $db->execute(
                "UPDATE users SET device_uid = ?, device_bound = 1, last_login = NOW() 
                 WHERE id = ?",
                [$new_device_uid, $user['id']]
            );
            $user['device_uid'] = $new_device_uid;
            $device_status = 'new_binding';
            
            // Log device binding
            $db->execute(
                "INSERT INTO device_bind_log (user_id, device_uid, device_model, bind_status, ip_address, user_agent) 
                 VALUES (?, ?, ?, ?, ?, ?)",
                [
                    $user['id'],
                    $new_device_uid,
                    sanitize($_POST['device_model'] ?? 'Unknown'),
                    'success',
                    getClientIP(),
                    $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
                ]
            );
            
            Logger::info("Device binding created for user: {$user['id']}");
        } else if (!empty($device_uid) && $device_uid !== $user['device_uid']) {
            // Device mismatch - prevent login with different device
            Logger::warn("Login failed: Device mismatch for user - {$user['id']}");
            
            $db->execute(
                "INSERT INTO device_bind_log (user_id, device_uid, bind_status, ip_address, user_agent) 
                 VALUES (?, ?, ?, ?, ?)",
                [
                    $user['id'],
                    $device_uid,
                    'mismatch',
                    getClientIP(),
                    $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
                ]
            );
            
            sendResponse(false, 'Device mismatch detected. Contact admin to rebind device.', [
                'code' => 'DEVICE_MISMATCH',
                'bound_device' => substr($user['device_uid'], 0, 8) . '****'
            ], 403);
        } else {
            // Same device - update last login
            $db->execute(
                "UPDATE users SET last_login = NOW() WHERE id = ?",
                [$user['id']]
            );
            $device_status = 'existing_binding';
        }
        
        // Generate JWT token
        $secret = getenv('JWT_SECRET') ?: 'your-secret-key';
        $token = generateJWT([
            'user_id' => $user['id'],
            'email' => $user['email'],
            'role' => $user['role'],
            'device_uid' => $user['device_uid'],
            'name' => $user['name']
        ], $secret);
        
        // Log successful login
        Logger::info("Login successful for user: {$user['id']} ({$user['email']})");
        
        sendResponse(true, 'Login successful', [
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'role' => $user['role'],
                'mobile_no' => $user['mobile_no'],
                'device_uid' => $user['device_uid']
            ],
            'token' => $token,
            'device_status' => $device_status,
            'expires_in' => 86400 // 24 hours in seconds
        ], 200);
        
    } catch (Exception $e) {
        Logger::error("Login error: " . $e->getMessage());
        sendResponse(false, 'Login failed. Please try again later.', [], 500);
    }
}

// ================================================================
// ENDPOINT: POST /api/location/update
// Purpose: Update rep's live location (called every 30 seconds)
// Requires: JWT token in Authorization header
// ================================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['action']) && $_GET['action'] === 'location_update') {
    
    // Verify JWT token
    $token = getBearerToken();
    if (!$token) {
        Logger::warn('Location update failed: No token provided');
        sendResponse(false, 'Authorization required', [], 401);
    }
    
    $secret = getenv('JWT_SECRET') ?: 'your-secret-key';
    $decoded = verifyJWT($token, $secret);
    
    if (!$decoded) {
        Logger::warn('Location update failed: Invalid token');
        sendResponse(false, 'Invalid or expired token', [], 401);
    }
    
    $rep_id = $decoded['user_id'];
    $lat = floatval($_POST['lat'] ?? 0);
    $lng = floatval($_POST['lng'] ?? 0);
    $accuracy = floatval($_POST['accuracy'] ?? 0);
    $timestamp = $_POST['timestamp'] ?? date('Y-m-d H:i:s');
    
    // Validation
    if (!isValidCoordinates($lat, $lng)) {
        Logger::warn("Location update failed: Invalid coordinates for rep $rep_id");
        sendResponse(false, 'Invalid coordinates', [], 400);
    }
    
    try {
        // Update or insert into live_locations
        // Always keep only the latest location per rep
        $db->execute(
            "INSERT INTO live_locations (rep_id, lat, lng, accuracy, timestamp, synced)
             VALUES (?, ?, ?, ?, ?, 1)
             ON DUPLICATE KEY UPDATE
             lat = VALUES(lat), 
             lng = VALUES(lng), 
             accuracy = VALUES(accuracy), 
             timestamp = VALUES(timestamp),
             synced = 1,
             updated_at = NOW()",
            [$rep_id, $lat, $lng, $accuracy, $timestamp]
        );
        
        // Also archive to location_history
        $db->execute(
            "INSERT INTO location_history (rep_id, lat, lng, accuracy, timestamp, date_key)
             VALUES (?, ?, ?, ?, ?, DATE(?))",
            [$rep_id, $lat, $lng, $accuracy, $timestamp, $timestamp]
        );
        
        Logger::info("Location updated for rep $rep_id: $lat, $lng");
        
        sendResponse(true, 'Location updated successfully', [
            'synced' => true,
            'timestamp' => $timestamp,
            'coordinates' => ['lat' => $lat, 'lng' => $lng],
            'accuracy' => $accuracy
        ], 200);
        
    } catch (Exception $e) {
        Logger::error("Location update error for rep $rep_id: " . $e->getMessage());
        sendResponse(false, 'Failed to update location', [], 500);
    }
}

// ================================================================
// ENDPOINT: GET /api/reps/locations
// Purpose: Get all active rep locations (for admin dashboard)
// Requires: JWT token with Admin role
// ================================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'reps_locations') {
    
    // Verify JWT token
    $token = getBearerToken();
    if (!$token) {
        sendResponse(false, 'Authorization required', [], 401);
    }
    
    $secret = getenv('JWT_SECRET') ?: 'your-secret-key';
    $decoded = verifyJWT($token, $secret);
    
    if (!$decoded) {
        sendResponse(false, 'Invalid or expired token', [], 401);
    }
    
    // Check role - only admin can see all locations
    if ($decoded['role'] !== 'Admin') {
        Logger::warn("Unauthorized location access attempt by user: {$decoded['user_id']}");
        sendResponse(false, 'Only admins can view all locations', [], 403);
    }
    
    try {
        $locations = $db->query(
            "SELECT 
                ll.id,
                ll.rep_id,
                u.name,
                u.email,
                u.mobile_no,
                u.role,
                ll.lat,
                ll.lng,
                ll.accuracy,
                ll.timestamp,
                TIMESTAMPDIFF(MINUTE, ll.timestamp, NOW()) as minutes_ago,
                IF(TIMESTAMPDIFF(MINUTE, ll.timestamp, NOW()) <= 5, 'online', 'offline') as status,
                CONCAT(ROUND(ll.lat, 6), ', ', ROUND(ll.lng, 6)) as coordinates
             FROM live_locations ll
             RIGHT JOIN users u ON ll.rep_id = u.id
             WHERE u.is_active = 1 AND u.role = 'Rep'
             ORDER BY u.name ASC"
        );
        
        // Log access
        $db->execute(
            "INSERT INTO location_access_log (admin_id, rep_id, access_type, ip_address)
             SELECT ?, 0, 'all_locations', ?",
            [$decoded['user_id'], getClientIP()]
        );
        
        Logger::info("Admin {$decoded['user_id']} accessed all rep locations");
        
        sendResponse(true, 'Locations retrieved successfully', [
            'total_reps' => count($locations),
            'online_count' => count(array_filter($locations, fn($r) => $r['status'] === 'online')),
            'offline_count' => count(array_filter($locations, fn($r) => $r['status'] === 'offline')),
            'locations' => $locations
        ], 200);
        
    } catch (Exception $e) {
        Logger::error("Error fetching locations: " . $e->getMessage());
        sendResponse(false, 'Failed to fetch locations', [], 500);
    }
}

// ================================================================
// ENDPOINT: GET /api/reps/location/:rep_id
// Purpose: Get specific rep's current location
// Requires: JWT token
// ================================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'rep_location') {
    
    $rep_id = intval($_GET['rep_id'] ?? 0);
    
    if (!$rep_id) {
        sendResponse(false, 'Invalid rep ID', [], 400);
    }
    
    // Verify JWT token
    $token = getBearerToken();
    if (!$token) {
        sendResponse(false, 'Authorization required', [], 401);
    }
    
    $secret = getenv('JWT_SECRET') ?: 'your-secret-key';
    $decoded = verifyJWT($token, $secret);
    
    if (!$decoded) {
        sendResponse(false, 'Invalid or expired token', [], 401);
    }
    
    // Check authorization - user can only see their own location, admin can see all
    if ($decoded['role'] !== 'Admin' && $decoded['user_id'] != $rep_id) {
        sendResponse(false, 'Unauthorized', [], 403);
    }
    
    try {
        $location = $db->queryOne(
            "SELECT 
                ll.id,
                ll.rep_id,
                u.name,
                u.email,
                u.mobile_no,
                ll.lat,
                ll.lng,
                ll.accuracy,
                ll.timestamp,
                TIMESTAMPDIFF(MINUTE, ll.timestamp, NOW()) as minutes_ago,
                IF(TIMESTAMPDIFF(MINUTE, ll.timestamp, NOW()) <= 5, 'online', 'offline') as status
             FROM live_locations ll
             JOIN users u ON ll.rep_id = u.id
             WHERE ll.rep_id = ?",
            [$rep_id]
        );
        
        if (!$location) {
            sendResponse(false, 'Location not found for this rep', [], 404);
        }
        
        sendResponse(true, 'Location retrieved successfully', $location, 200);
        
    } catch (Exception $e) {
        Logger::error("Error fetching rep location: " . $e->getMessage());
        sendResponse(false, 'Failed to fetch location', [], 500);
    }
}

// ================================================================
// ENDPOINT: GET /api/location/history
// Purpose: Get location history for a rep on a specific date
// Requires: JWT token
// ================================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'location_history') {
    
    $rep_id = intval($_GET['rep_id'] ?? 0);
    $date = sanitize($_GET['date'] ?? date('Y-m-d'));
    
    if (!$rep_id) {
        sendResponse(false, 'Invalid rep ID', [], 400);
    }
    
    // Verify JWT token
    $token = getBearerToken();
    if (!$token) {
        sendResponse(false, 'Authorization required', [], 401);
    }
    
    $secret = getenv('JWT_SECRET') ?: 'your-secret-key';
    $decoded = verifyJWT($token, $secret);
    
    if (!$decoded) {
        sendResponse(false, 'Invalid or expired token', [], 401);
    }
    
    try {
        $history = $db->query(
            "SELECT 
                id,
                rep_id,
                lat,
                lng,
                accuracy,
                timestamp,
                DATE(timestamp) as date
             FROM location_history
             WHERE rep_id = ? AND DATE(timestamp) = ?
             ORDER BY timestamp ASC",
            [$rep_id, $date]
        );
        
        sendResponse(true, 'Location history retrieved', [
            'rep_id' => $rep_id,
            'date' => $date,
            'total_records' => count($history),
            'history' => $history
        ], 200);
        
    } catch (Exception $e) {
        Logger::error("Error fetching location history: " . $e->getMessage());
        sendResponse(false, 'Failed to fetch history', [], 500);
    }
}

// ================================================================
// DEFAULT: No valid action found
// ================================================================

sendResponse(false, 'Invalid API action', [], 400);
?>
