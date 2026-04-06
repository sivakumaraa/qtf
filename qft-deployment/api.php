<?php
/**
 * QuarryForce API Router - PHP Backend
 * 
 * Main router for all API endpoints
 * Routes all requests to appropriate handlers
 * Integrated with Logger for comprehensive logging
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/Database.php';

// Init response headers
header('Content-Type: application/json; charset=utf-8');

// CORS Headers
$allowed_origins = [
    'https://valviyal.com',
    'http://localhost:3000',
    'http://localhost:19006',
    'http://localhost:8081',
    '*'
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
if (in_array($origin, $allowed_origins) || in_array('*', $allowed_origins)) {
    header('Access-Control-Allow-Origin: ' . $origin);
}

header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get request path and method
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/qft/api', '', $path);
$path = str_replace('/api', '', $path);
$path = rtrim($path, '/') ?: '/';

// Fallback: check for request query parameter (from .htaccess rewrite)
if ($path === '/' && isset($_GET['request'])) {
    $request = $_GET['request'];
    $request = str_replace('api/', '', $request);
    $request = str_replace('api', '', $request);
    $path = '/' . trim($request, '/');
    $path = $path === '/' ? '/' : $path;
}

// Parse query/body
$input = [];
if ($method === 'GET') {
    $input = $_GET;
} else {
    $raw = file_get_contents('php://input');
    if (!empty($raw)) {
        $input = json_decode($raw, true) ?? [];
    }
}

Logger::logRequest($path, $method, count($input) > 0 ? array_slice($input, 0, 3) : null);

// ==========================================
// ROUTING
// ==========================================

try {
    // ROOT ROUTE
    if ($path === '/' && $method === 'GET') {
        handleRoot();
    }
    // SETTINGS
    elseif ($path === '/settings' && $method === 'GET') {
        handleSettingsGet();
    }
    elseif ($path === '/settings' && $method === 'PUT') {
        handleSettingsPut($input);
    }
    // LOGIN
    elseif ($path === '/login' && $method === 'POST') {
        handleLogin($input);
    }
    // PROFILE - UPDATE
    elseif ($path === '/profile/update' && $method === 'POST') {
        handleProfileUpdate();
    }
    // CHECK-IN
    elseif ($path === '/checkin' && $method === 'POST') {
        handleCheckin($input);
    }
    // VISIT
    elseif ($path === '/visit/submit' && $method === 'POST') {
        handleVisitSubmit($input);
    }
    // FUEL
    elseif ($path === '/fuel/submit' && $method === 'POST') {
        handleFuelSubmit($input);
    }
    // REP - CUSTOMERS (Get customers assigned to this rep)
    elseif (preg_match('#^/rep/customers/(\d+)$#', $path, $matches) && $method === 'GET') {
        handleRepCustomers($matches[1]);
    }
    // REP - CREATE ORDER
    elseif ($path === '/rep/create-order' && $method === 'POST') {
        handleRepCreateOrder($input);
    }
    // REP - ORDERS (Get orders for this rep)
    elseif (preg_match('#^/rep/orders/(\d+)$#', $path, $matches) && $method === 'GET') {
        handleRepOrders($matches[1]);
    }
    // ADMIN - REPS
    elseif ($path === '/admin/reps' && $method === 'GET') {
        handleAdminReps();
    }
    // ADMIN - CUSTOMERS
    elseif ($path === '/admin/customers' && $method === 'GET') {
        handleAdminCustomers();
    }
    elseif ($path === '/admin/customers' && $method === 'POST') {
        handleAdminCustomersCreate($input);
    }
    elseif (preg_match('#^/admin/customers/(\d+)$#', $path, $matches) && $method === 'PUT') {
        handleAdminCustomersUpdate($matches[1], $input);
    }
    elseif (preg_match('#^/admin/customers/(\d+)$#', $path, $matches) && $method === 'DELETE') {
        handleAdminCustomersDelete($matches[1]);
    }
    // ADMIN - ORDERS
    elseif ($path === '/admin/orders' && $method === 'GET') {
        handleAdminOrdersList();
    }
    elseif (preg_match('#^/admin/orders/customer/(\d+)$#', $path, $matches) && $method === 'GET') {
        handleAdminOrdersByCustomer($matches[1]);
    }
    elseif ($path === '/admin/orders' && $method === 'POST') {
        handleAdminOrdersCreate($input);
    }
    elseif (preg_match('#^/admin/orders/(\d+)$#', $path, $matches) && $method === 'PUT') {
        handleAdminOrdersUpdate($matches[1], $input);
    }
    elseif (preg_match('#^/admin/orders/(\d+)$#', $path, $matches) && $method === 'DELETE') {
        handleAdminOrdersDelete($matches[1]);
    }
    // ADMIN - RESET DEVICE
    elseif ($path === '/admin/reset-device' && $method === 'POST') {
        handleAdminResetDevice($input);
    }
    // ADMIN - REP TARGETS
    elseif (preg_match('#^/admin/rep-targets(/(\d+))?$#', $path, $matches) && $method === 'GET') {
        $repId = $matches[2] ?? null;
        if ($repId) {
            handleAdminRepTargetsGet($repId);
        } else {
            handleAdminRepTargetsList();
        }
    }
    elseif ($path === '/admin/rep-targets' && $method === 'POST') {
        handleAdminRepTargetsCreate($input);
    }
    elseif (preg_match('#^/admin/rep-targets/(\d+)$#', $path, $matches) && $method === 'PUT') {
        handleAdminRepTargetsUpdate($matches[1], $input);
    }
    // ADMIN - REP PROGRESS
    elseif (preg_match('#^/admin/rep-progress/(\d+)$#', $path, $matches) && $method === 'GET') {
        $repId = $matches[1];
        $month = $_GET['month'] ?? null;
        handleAdminRepProgress($repId, $month);
    }
    elseif (preg_match('#^/admin/rep-progress-history/(\d+)$#', $path, $matches) && $method === 'GET') {
        handleAdminRepProgressHistory($matches[1]);
    }
    // ADMIN - REP PROGRESS UPDATE
    elseif ($path === '/admin/rep-progress/update' && $method === 'POST') {
        handleAdminRepProgressUpdate($input);
    }
    // ADMIN - USERS
    elseif ($path === '/admin/users' && $method === 'GET') {
        handleAdminUsersList();
    }
    elseif ($path === '/admin/users' && $method === 'POST') {
        handleAdminUsersCreate($input);
    }
    elseif (preg_match('#^/admin/users/(\d+)$#', $path, $matches) && $method === 'PUT') {
        $userId = $matches[1];
        // Check if it's device-uid endpoint
        if (isset($_GET['action']) && $_GET['action'] === 'set-device') {
            handleAdminUsersSetDevice($userId, $input);
        } else {
            handleAdminUsersUpdate($userId, $input);
        }
    }
    elseif (preg_match('#^/admin/users/(\d+)/device-uid$#', $path, $matches) && $method === 'PUT') {
        handleAdminUsersSetDevice($matches[1], $input);
    }
    elseif (preg_match('#^/admin/users/(\d+)$#', $path, $matches) && $method === 'DELETE') {
        handleAdminUsersDelete($matches[1]);
    }
    // TEST ROUTE
    elseif ($path === '/test' && $method === 'GET') {
        handleTest();
    }
    // 404 - Not Found
    else {
        http_response_code(404);
        Logger::logResponse($path, 404);
        jsonResponse(['success' => false, 'error' => 'Endpoint not found']);
    }

} catch (Exception $e) {
    Logger::error('Unhandled exception', ['path' => $path, 'error' => $e->getMessage()]);
    http_response_code(500);
    Logger::logResponse($path, 500);
    jsonResponse(['success' => false, 'error' => 'Server error: ' . $e->getMessage()]);
}

// ==========================================
// ENDPOINT HANDLERS
// ==========================================

/**
 * GET /
 * Root endpoint - API information
 */
function handleRoot() {
    Logger::debug('Root endpoint accessed');
    $response = [
        'success' => true,
        'message' => 'QuarryForce Backend API',
        'version' => '2.0.0',
        'status' => 'Online',
        'apis' => [
            'settings' => 'GET|PUT /api/settings',
            'login' => 'POST /api/login',
            'checkin' => 'POST /api/checkin',
            'visit' => 'POST /api/visit/submit',
            'fuel' => 'POST /api/fuel/submit',
            'admin_reps' => 'GET /api/admin/reps',
            'admin_customers' => 'GET /api/admin/customers',
            'admin_reset' => 'POST /api/admin/reset-device',
            'admin_rep_targets_all' => 'GET /api/admin/rep-targets',
            'admin_rep_targets_get' => 'GET /api/admin/rep-targets/:rep_id',
            'admin_rep_targets_create' => 'POST /api/admin/rep-targets',
            'admin_rep_targets_update' => 'PUT /api/admin/rep-targets/:id',
            'admin_rep_progress' => 'GET /api/admin/rep-progress/:rep_id',
            'admin_rep_sales_update' => 'POST /api/admin/rep-progress/update',
            'admin_users' => 'GET|POST|PUT|DELETE /api/admin/users',
            'health' => 'GET /api/test'
        ]
    ];
    Logger::logResponse('/', 200, ['message' => 'API info']);
    jsonResponse($response);
}

/**
 * GET /settings
 * Get system settings
 */
function handleSettingsGet() {
    Logger::debug('Fetching system settings');
    
    // Default settings
    $defaultSettings = [
        'id' => 1,
        'gps_radius_limit' => 50,
        'gps_update_interval' => 5000,  // milliseconds (5 seconds)
        'gps_min_distance' => 10,       // meters
        'company_name' => 'QuarryForce',
        'company_logo' => null,
        'company_address' => '',
        'company_email' => '',
        'company_phone' => '',
        'currency_symbol' => '₹',
        'site_types' => json_encode(['Quarry', 'Site', 'Dump']),
        'logging_enabled' => 0,
        'api_endpoint' => 'https://valviyal.com/qft/api',
        'api_timeout' => 60000,  // milliseconds
        'min_visit_duration' => 15,  // seconds for testing
    ];
    
    try {
        $db = new Database();
        $settings = $db->queryOne('SELECT * FROM system_settings LIMIT 1', []);
        
        // If no settings found, use defaults
        if (!$settings) {
            Logger::info('No settings found, returning defaults');
            Logger::logResponse('/settings', 200);
            jsonResponse(['success' => true, 'data' => $defaultSettings]);
            return;
        }
        
        // Decode site_types if it's JSON
        if (isset($settings['site_types']) && is_string($settings['site_types'])) {
            $settings['site_types'] = json_decode($settings['site_types'], true);
        }
        
        Logger::logResponse('/settings', 200);
        jsonResponse(['success' => true, 'data' => $settings]);
    } catch (Exception $e) {
        Logger::warn('Failed to fetch settings, returning defaults', ['error' => $e->getMessage()]);
        // Return default settings instead of error
        Logger::logResponse('/settings', 200);
        jsonResponse(['success' => true, 'data' => $defaultSettings]);
    }
}

/**
 * PUT /settings
 * Update system settings
 */
function handleSettingsPut($input) {
    Logger::info('Updating system settings', array_slice($input, 0, 3));
    
    // Default settings
    $defaultSettings = [
        'id' => 1,
        'gps_radius_limit' => 50,
        'gps_update_interval' => 5000,  // milliseconds (5 seconds)
        'gps_min_distance' => 10,       // meters
        'company_name' => 'QuarryForce',
        'company_logo' => null,
        'company_address' => '',
        'company_email' => '',
        'company_phone' => '',
        'currency_symbol' => '₹',
        'site_types' => json_encode(['Quarry', 'Site', 'Dump']),
        'logging_enabled' => 0,
        'api_endpoint' => 'https://valviyal.com/qft/api',
        'api_timeout' => 60000,  // milliseconds
        'min_visit_duration' => 15,  // seconds for testing
    ];
    
    try {
        $db = new Database();
        
        // First, ensure the settings table exists and has a record
        try {
            $existing = $db->queryOne('SELECT id FROM system_settings WHERE id = 1', []);
            if (!$existing) {
                Logger::info('Creating default system settings');
                $db->execute(
                    'INSERT INTO system_settings (id, gps_radius_limit, company_name, currency_symbol, site_types, logging_enabled) VALUES (?, ?, ?, ?, ?, ?)',
                    [1, 50, 'QuarryForce', '₹', json_encode(['Quarry', 'Site', 'Dump']), 0]
                );
            }
        } catch (Exception $e) {
            Logger::warn('Error checking/creating settings', ['error' => $e->getMessage()]);
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
            return;
        }
        
        // Collect updates
        $updates = [];
        $params = [];
        
        // Validate and collect updates
        if (isset($input['gps_radius_limit'])) {
            $radius = (int)$input['gps_radius_limit'];
            if ($radius < 10 || $radius > 500) {
                Logger::warn('Invalid GPS radius', ['value' => $radius]);
                http_response_code(400);
                jsonResponse(['success' => false, 'error' => 'GPS radius must be between 10 and 500 meters']);
                return;
            }
            $updates[] = 'gps_radius_limit = ?';
            $params[] = $radius;
        }

        // Handle GPS update interval (milliseconds, min 1000ms = 1 second, max 60000ms = 60 seconds)
        if (isset($input['gps_update_interval'])) {
            $interval = (int)$input['gps_update_interval'];
            if ($interval < 1000 || $interval > 60000) {
                Logger::warn('Invalid GPS interval', ['value' => $interval]);
                http_response_code(400);
                jsonResponse(['success' => false, 'error' => 'GPS update interval must be between 1000ms (1s) and 60000ms (60s)']);
                return;
            }
            $updates[] = 'gps_update_interval = ?';
            $params[] = $interval;
        }

        // Handle GPS minimum distance (meters)
        if (isset($input['gps_min_distance'])) {
            $minDist = (int)$input['gps_min_distance'];
            if ($minDist < 0 || $minDist > 1000) {
                Logger::warn('Invalid GPS min distance', ['value' => $minDist]);
                http_response_code(400);
                jsonResponse(['success' => false, 'error' => 'GPS min distance must be between 0 and 1000 meters']);
                return;
            }
            $updates[] = 'gps_min_distance = ?';
            $params[] = $minDist;
        }
        
        if (isset($input['company_name'])) {
            $updates[] = 'company_name = ?';
            $params[] = $input['company_name'];
        }
        
        if (isset($input['currency_symbol'])) {
            if (strlen($input['currency_symbol']) > 3) {
                Logger::warn('Invalid currency symbol', ['value' => $input['currency_symbol']]);
                http_response_code(400);
                jsonResponse(['success' => false, 'error' => 'Currency symbol must be 3 characters or less']);
                return;
            }
            $updates[] = 'currency_symbol = ?';
            $params[] = $input['currency_symbol'];
        }
        
        if (isset($input['site_types'])) {
            $updates[] = 'site_types = ?';
            $params[] = is_array($input['site_types']) ? json_encode($input['site_types']) : $input['site_types'];
        }
        
        if (isset($input['logging_enabled'])) {
            $updates[] = 'logging_enabled = ?';
            $params[] = $input['logging_enabled'] ? 1 : 0;
            Logger::setEnabled($input['logging_enabled']);
        }

        // Handle new company settings fields
        if (isset($input['company_logo'])) {
            $updates[] = 'company_logo = ?';
            $params[] = $input['company_logo'];
        }

        if (isset($input['company_address'])) {
            $updates[] = 'company_address = ?';
            $params[] = $input['company_address'];
        }

        if (isset($input['company_email'])) {
            $updates[] = 'company_email = ?';
            $params[] = $input['company_email'];
        }

        if (isset($input['company_phone'])) {
            $updates[] = 'company_phone = ?';
            $params[] = $input['company_phone'];
        }

        // Handle API endpoint configuration (for mobile app)
        if (isset($input['api_endpoint'])) {
            $url = filter_var($input['api_endpoint'], FILTER_VALIDATE_URL);
            if (!$url) {
                Logger::warn('Invalid API endpoint URL', ['value' => $input['api_endpoint']]);
                http_response_code(400);
                jsonResponse(['success' => false, 'error' => 'Invalid API endpoint URL']);
                return;
            }
            $updates[] = 'api_endpoint = ?';
            $params[] = $input['api_endpoint'];
            Logger::info('API endpoint updated', ['endpoint' => $input['api_endpoint']]);
        }

        // Handle API timeout (milliseconds, min 5000ms, max 120000ms)
        if (isset($input['api_timeout'])) {
            $timeout = (int)$input['api_timeout'];
            if ($timeout < 5000 || $timeout > 120000) {
                Logger::warn('Invalid API timeout', ['value' => $timeout]);
                http_response_code(400);
                jsonResponse(['success' => false, 'error' => 'API timeout must be between 5000ms and 120000ms']);
                return;
            }
            $updates[] = 'api_timeout = ?';
            $params[] = $timeout;
        }

        // Handle minimum visit duration (seconds)
        if (isset($input['min_visit_duration'])) {
            $duration = (int)$input['min_visit_duration'];
            if ($duration < 15 || $duration > 3600) {
                Logger::warn('Invalid min visit duration', ['value' => $duration]);
                http_response_code(400);
                jsonResponse(['success' => false, 'error' => 'Min visit duration must be between 15 and 3600 seconds']);
                return;
            }
            $updates[] = 'min_visit_duration = ?';
            $params[] = $duration;
        }
        
        if (empty($updates)) {
            http_response_code(400);
            jsonResponse(['success' => false, 'error' => 'No fields to update']);
            return;
        }
        
        // Execute update
        $params[] = 1;
        $query = 'UPDATE system_settings SET ' . implode(', ', $updates) . ' WHERE id = ?';
        
        Logger::debug('Executing update query', ['query' => $query, 'param_count' => count($params)]);
        
        try {
            $result = $db->execute($query, $params);
            Logger::info('Update query executed', ['affected_rows' => $result]);
            
            // Now retrieve the updated settings
            $settings = $db->queryOne('SELECT * FROM system_settings WHERE id = 1', []);
            
            if (!$settings) {
                Logger::error('Settings record not found after update');
                http_response_code(500);
                jsonResponse(['success' => false, 'error' => 'Settings record not found']);
                return;
            }
            
            // Decode site_types if it's JSON
            if (isset($settings['site_types']) && is_string($settings['site_types'])) {
                $settings['site_types'] = json_decode($settings['site_types'], true);
            }
            
            Logger::info('Settings updated successfully', ['updated_fields' => count($updates)]);
            Logger::logResponse('/settings', 200);
            jsonResponse(['success' => true, 'data' => $settings]);
            
        } catch (Exception $updateErr) {
            Logger::error('Update execution failed', ['error' => $updateErr->getMessage()]);
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Failed to update settings: ' . $updateErr->getMessage()]);
        }
        
    } catch (Exception $e) {
        Logger::error('Settings update failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        jsonResponse(['success' => false, 'error' => 'Settings update failed: ' . $e->getMessage()]);
    }
}

/**
 * POST /login
 * User login and device binding
 */
function handleLogin($input) {
    $email = $input['email'] ?? null;
    $device_uid = $input['device_uid'] ?? null;
    
    Logger::info('Login attempt', ['email' => $email, 'device_uid' => substr($device_uid ?? '', 0, 8)]);
    
    if (!$email || !$device_uid) {
        Logger::warn('Login failed - missing credentials', ['email' => $email]);
        http_response_code(400);
        Logger::logResponse('/login', 400);
        jsonResponse(['success' => false, 'message' => 'Email and Device UID required.']);
        return;
    }
    
    try {
        // Demo user bypass
        if ($email === 'demo@quarryforce.local' || $email === 'test@quarryforce.local') {
            Logger::info('Demo user login successful', ['email' => $email]);
            Logger::logResponse('/login', 200);
            jsonResponse([
                'success' => true,
                'message' => 'Device registered successfully!',
                'user' => [
                    'id' => 1,
                    'name' => 'Demo Rep',
                    'email' => $email,
                    'role' => 'rep'
                ]
            ]);
            return;
        }
        
        $db = new Database();
        $user = $db->queryOne(
            'SELECT id, name, email, role, device_uid, mobile_no FROM users WHERE email = ?',
            [$email]
        );
        
        if (!$user) {
            Logger::warn('User not found', ['email' => $email]);
            Logger::logResponse('/login', 200);
            jsonResponse(['success' => false, 'message' => 'User not found. Contact admin.']);
            return;
        }
        
        // Device binding logic
        if (!$user['device_uid']) {
            // First time: bind device
            $db->execute('UPDATE users SET device_uid = ? WHERE email = ?', [$device_uid, $email]);
            Logger::info('New device bound', ['user_id' => $user['id'], 'email' => $email]);
            Logger::logResponse('/login', 200);
            jsonResponse([
                'success' => true,
                'message' => 'Device registered successfully!',
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'role' => $user['role']
                ]
            ]);
        } else if ($user['device_uid'] === $device_uid) {
            // Returning user, same device
            Logger::info('User login successful', ['user_id' => $user['id'], 'email' => $email]);
            Logger::logResponse('/login', 200);
            jsonResponse([
                'success' => true,
                'message' => 'Login successful.',
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'role' => $user['role']
                ]
            ]);
        } else {
            // Device mismatch
            Logger::warn('Device mismatch - security violation', [
                'user_id' => $user['id'],
                'email' => $email,
                'stored_device' => substr($user['device_uid'], 0, 8),
                'provided_device' => substr($device_uid, 0, 8)
            ]);
            Logger::logResponse('/login', 200);
            jsonResponse([
                'success' => false,
                'message' => 'Security Error: This account is locked to another device. Contact admin to reset.'
            ]);
        }
        
    } catch (Exception $e) {
        Logger::error('Login error', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/login', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * POST /profile/update
 * Update rep profile (name, phone, photo)
 */
function handleProfileUpdate() {
    // Handle both JSON and multipart/form-data
    $rep_id = null;
    $name = null;
    $phone = null;
    
    // Check if multipart/form-data (with file)
    if (!empty($_POST)) {
        $rep_id = $_POST['rep_id'] ?? null;
        $name = $_POST['name'] ?? null;
        $phone = $_POST['phone'] ?? null;
    } else {
        // Parse JSON body
        $raw = file_get_contents('php://input');
        $json = json_decode($raw, true) ?? [];
        $rep_id = $json['rep_id'] ?? null;
        $name = $json['name'] ?? null;
        $phone = $json['phone'] ?? null;
    }
    
    Logger::info('Profile update attempt', ['rep_id' => $rep_id, 'name' => $name]);
    
    if (!$rep_id || !$name || !$phone) {
        Logger::warn('Profile update failed - missing fields', ['rep_id' => $rep_id]);
        http_response_code(400);
        Logger::logResponse('/profile/update', 400);
        jsonResponse(['success' => false, 'message' => 'rep_id, name, and phone are required.']);
        return;
    }
    
    try {
        $db = new Database();
        
        // Verify user exists
        $user = $db->queryOne('SELECT id, name, email FROM users WHERE id = ?', [$rep_id]);
        if (!$user) {
            Logger::warn('User not found for profile update', ['rep_id' => $rep_id]);
            Logger::logResponse('/profile/update', 404);
            jsonResponse(['success' => false, 'message' => 'User not found.']);
            return;
        }
        
        // Handle photo upload if provided
        $photoPath = null;
        if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
            $file = $_FILES['photo'];
            $allowedTypes = ['image/jpeg', 'image/png'];
            $maxSize = 5 * 1024 * 1024; // 5MB
            
            // Validate file
            if (!in_array($file['type'], $allowedTypes)) {
                Logger::warn('Invalid photo type', ['type' => $file['type']]);
                http_response_code(400);
                Logger::logResponse('/profile/update', 400);
                jsonResponse(['success' => false, 'message' => 'Only JPG and PNG photos are allowed.']);
                return;
            }
            
            if ($file['size'] > $maxSize) {
                Logger::warn('Photo too large', ['size' => $file['size']]);
                http_response_code(400);
                Logger::logResponse('/profile/update', 400);
                jsonResponse(['success' => false, 'message' => 'Photo must be less than 5MB.']);
                return;
            }
            
            // Create uploads directory if it doesn't exist
            $uploadsDir = __DIR__ . '/uploads/profiles';
            if (!is_dir($uploadsDir)) {
                mkdir($uploadsDir, 0755, true);
            }
            
            // Save photo with unique name
            $fileName = 'rep_' . $rep_id . '_' . time() . '_' . basename($file['name']);
            $filePath = $uploadsDir . '/' . $fileName;
            
            if (!move_uploaded_file($file['tmp_name'], $filePath)) {
                Logger::error('Failed to move upload file', ['path' => $filePath]);
                http_response_code(400);
                Logger::logResponse('/profile/update', 400);
                jsonResponse(['success' => false, 'message' => 'Failed to upload photo.']);
                return;
            }
            
            $photoPath = '/uploads/profiles/' . $fileName;
            Logger::info('Photo uploaded', ['rep_id' => $rep_id, 'file' => $fileName]);
        }
        
        // Update user in database
        if ($photoPath) {
            $db->execute(
                'UPDATE users SET name = ?, mobile_no = ?, photo = ? WHERE id = ?',
                [$name, $phone, $photoPath, $rep_id]
            );
        } else {
            $db->execute(
                'UPDATE users SET name = ?, mobile_no = ? WHERE id = ?',
                [$name, $phone, $rep_id]
            );
        }
        
        Logger::info('Profile updated successfully', ['rep_id' => $rep_id]);
        Logger::logResponse('/profile/update', 200);
        
        jsonResponse([
            'success' => true,
            'message' => 'Profile updated successfully!',
            'user' => [
                'id' => $user['id'],
                'name' => $name,
                'email' => $user['email'],
                'mobile_no' => $phone,
                'photo' => $photoPath
            ]
        ]);
        
    } catch (Exception $e) {
        Logger::error('Profile update error', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/profile/update', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * POST /checkin
 * GPS-based check-in
 */
function handleCheckin($input) {
    $rep_id = $input['rep_id'] ?? null;
    $customer_id = $input['customer_id'] ?? null;
    $rep_lat = $input['rep_lat'] ?? null;
    $rep_lng = $input['rep_lng'] ?? null;
    $device_uid = $input['device_uid'] ?? null;
    $timestamp = $input['timestamp'] ?? date('Y-m-d H:i:s');
    
    Logger::info('Check-in attempt', ['rep_id' => $rep_id, 'customer_id' => $customer_id]);
    
    // Simple device check-in (no customer)
    if ($rep_id && $device_uid && !$customer_id) {
        Logger::debug('Device check-in', ['rep_id' => $rep_id]);
        Logger::logResponse('/checkin', 200);
        jsonResponse([
            'success' => true,
            'message' => 'Check-in successful',
            'timestamp' => $timestamp
        ]);
        return;
    }
    
    // Full check-in with GPS
    if (!$rep_id || !$customer_id || $rep_lat === null || $rep_lng === null) {
        http_response_code(400);
        Logger::logResponse('/checkin', 400);
        jsonResponse(['success' => false, 'message' => 'Missing required fields.']);
        return;
    }
    
    try {
        $db = new Database();
        
        // Get GPS radius limit
        $settings = $db->queryOne(
            'SELECT gps_radius_limit FROM system_settings LIMIT 1',
            []
        );
        $allowedRadius = (int)($settings['gps_radius_limit'] ?? DEFAULT_GPS_RADIUS);
        
        // Get customer location
        $customer = $db->queryOne(
            'SELECT id, lat, lng, assigned_rep_id FROM customers WHERE id = ?',
            [$customer_id]
        );
        
        if (!$customer) {
            Logger::warn('Customer not found', ['customer_id' => $customer_id]);
            Logger::logResponse('/checkin', 200);
            jsonResponse(['success' => false, 'message' => 'Customer not found.']);
            return;
        }
        
        // Check territory ownership
        if ($customer['assigned_rep_id'] && $customer['assigned_rep_id'] != $rep_id) {
            Logger::warn('Territory protection violation', [
                'rep_id' => $rep_id,
                'customer_id' => $customer_id,
                'assigned_rep_id' => $customer['assigned_rep_id']
            ]);
            Logger::logResponse('/checkin', 200);
            jsonResponse([
                'success' => false,
                'message' => 'This location is assigned to another representative. Territory protected.'
            ]);
            return;
        }
        
        // Calculate distance (Haversine formula)
        $distance = calculateDistance(
            (float)$rep_lat,
            (float)$rep_lng,
            (float)$customer['lat'],
            (float)$customer['lng']
        );
        
        // Check if within radius
        if ($distance <= $allowedRadius) {
            Logger::info('Check-in successful', [
                'rep_id' => $rep_id,
                'customer_id' => $customer_id,
                'distance' => $distance,
                'limit' => $allowedRadius
            ]);
            Logger::logResponse('/checkin', 200);
            jsonResponse([
                'success' => true,
                'message' => "Location verified! You are {$distance}m from the site.",
                'distance' => $distance,
                'limit' => $allowedRadius
            ]);
        } else {
            Logger::warn('Check-in denied - out of range', [
                'rep_id' => $rep_id,
                'customer_id' => $customer_id,
                'distance' => $distance,
                'limit' => $allowedRadius
            ]);
            Logger::logResponse('/checkin', 200);
            jsonResponse([
                'success' => false,
                'message' => "Check-in denied. You are {$distance}m away. Limit is {$allowedRadius}m.",
                'distance' => $distance,
                'limit' => $allowedRadius
            ]);
        }
        
    } catch (Exception $e) {
        Logger::error('Check-in error', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/checkin', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * POST /visit/submit
 * Submit visit record
 */
function handleVisitSubmit($input) {
    $rep_id = $input['rep_id'] ?? null;
    $customer_id = $input['customer_id'] ?? null;
    $lat = $input['lat'] ?? null;
    $lng = $input['lng'] ?? null;
    $requirements = $input['requirements'] ?? null;
    $distance = $input['distance'] ?? null;
    
    Logger::info('Visit submission', ['rep_id' => $rep_id, 'customer_id' => $customer_id]);
    
    if (!$rep_id || !$customer_id) {
        http_response_code(400);
        Logger::logResponse('/visit/submit', 400);
        jsonResponse(['success' => false, 'message' => 'Missing required fields.']);
        return;
    }
    
    try {
        $db = new Database();
        $db->execute(
            'INSERT INTO visit_logs (customer_id, rep_id, check_in_time, requirements_json, lat_at_submission, lng_at_submission, distance_meters, gps_verified)
             VALUES (?, ?, NOW(), ?, ?, ?, ?, 1)',
            [$customer_id, $rep_id, json_encode($requirements), $lat, $lng, $distance]
        );
        
        Logger::info('Visit recorded successfully', ['rep_id' => $rep_id, 'customer_id' => $customer_id]);
        Logger::logResponse('/visit/submit', 200);
        jsonResponse(['success' => true, 'message' => 'Visit recorded successfully!']);
        
    } catch (Exception $e) {
        Logger::error('Visit submission error', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/visit/submit', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * POST /fuel/submit
 * Submit fuel log
 */
function handleFuelSubmit($input) {
    $rep_id = $input['rep_id'] ?? null;
    $odometer_reading = $input['odometer_reading'] ?? null;
    $fuel_quantity = $input['fuel_quantity'] ?? null;
    $amount = $input['amount'] ?? null;
    $lat = $input['lat'] ?? null;
    $lng = $input['lng'] ?? null;
    
    Logger::info('Fuel submission', ['rep_id' => $rep_id, 'fuel_quantity' => $fuel_quantity]);
    
    if (!$rep_id || !$odometer_reading || !$fuel_quantity) {
        http_response_code(400);
        Logger::logResponse('/fuel/submit', 400);
        jsonResponse(['success' => false, 'message' => 'Missing required fields.']);
        return;
    }
    
    try {
        $db = new Database();
        $db->execute(
            'INSERT INTO fuel_logs (rep_id, odometer_reading, fuel_quantity_liters, total_amount, lat, lng, logged_at)
             VALUES (?, ?, ?, ?, ?, ?, NOW())',
            [$rep_id, $odometer_reading, $fuel_quantity, $amount, $lat, $lng]
        );
        
        Logger::info('Fuel logged successfully', ['rep_id' => $rep_id]);
        Logger::logResponse('/fuel/submit', 200);
        jsonResponse(['success' => true, 'message' => 'Fuel log recorded successfully!']);
        
    } catch (Exception $e) {
        Logger::error('Fuel submission error', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/fuel/submit', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * GET /rep/customers/:rep_id
 * Get customers assigned to a specific rep
 */
function handleRepCustomers($rep_id) {
    Logger::info('Fetching customers for rep', ['rep_id' => $rep_id]);
    
    // Demo data for testing
    $demoCustomers = [
        ['id' => 1, 'name' => 'Green Quarry Ltd', 'location' => 'Bangalore', 'contact_person' => 'John Smith', 'phone' => '+91-9876543210', 'lat' => 12.9716, 'lng' => 77.5946, 'notes' => 'Primary quarry client', 'material_needs' => '["RMC"]', 'rmc_grade' => '10-40', 'aggregate_types' => null],
        ['id' => 2, 'name' => 'Metro Limestone Co', 'location' => 'Pune', 'contact_person' => 'Sarah Johnson', 'phone' => '+91-9876543211', 'lat' => 18.5204, 'lng' => 73.8567, 'notes' => 'Limestone supplier', 'material_needs' => '["Aggregates"]', 'rmc_grade' => null, 'aggregate_types' => '["6mm", "12mm", "20mm", "40mm"]'],
    ];
    
    try {
        $db = new Database();
        
        // Query customers assigned to this rep with material needs
        $customers = $db->query(
            'SELECT c.id, c.name, c.phone_no as phone, c.location, c.lat, c.lng, 
                    c.site_incharge_name as contact_person, c.notes,
                    c.material_needs, c.rmc_grade, c.aggregate_types, 
                    c.volume, c.volume_unit, c.required_date
             FROM customers c
             WHERE c.assigned_rep_id = ? OR (c.assigned_rep_id IS NULL AND ? > 0)
             ORDER BY c.name ASC',
            [$rep_id, $rep_id]
        );
        
        Logger::info('Customers fetched', ['rep_id' => $rep_id, 'count' => count($customers ?? [])]);
        Logger::logResponse('/rep/customers', 200);
        jsonResponse(['success' => true, 'data' => $customers ?? $demoCustomers]);
        
    } catch (Exception $e) {
        Logger::error('Failed to fetch rep customers', ['error' => $e->getMessage(), 'rep_id' => $rep_id]);
        Logger::logResponse('/rep/customers', 200);
        jsonResponse(['success' => true, 'data' => $demoCustomers]);
    }
}

/**
 * GET /rep/orders/{id}
 * Get orders assigned to a specific rep
 */
function handleRepOrders($rep_id) {
    Logger::info('Fetching orders for rep', ['rep_id' => $rep_id]);
    
    try {
        $db = new Database();
        
        $orders = $db->query(
            'SELECT o.id, o.rep_id, o.customer_id, c.name as customer_name,
                    o.order_amount, o.order_date, o.status, o.product_details
             FROM orders o
             LEFT JOIN customers c ON o.customer_id = c.id
             WHERE o.rep_id = ? 
             ORDER BY o.order_date DESC',
            [$rep_id]
        );

        if ($orders) {
            foreach ($orders as &$order) {
                $items = $db->query(
                    'SELECT id, product_name, quantity, unit_price, boom_pump_amount, material_type, volume_unit, required_date
                     FROM order_items 
                     WHERE order_id = ?',
                    [$order['id']]
                );
                $order['items'] = $items ?? [];
            }
        }

        Logger::logResponse('/rep/orders', 200);
        jsonResponse(['success' => true, 'data' => $orders ?? []]);
        
    } catch (Exception $e) {
        Logger::error('Failed to fetch rep orders', ['error' => $e->getMessage(), 'rep_id' => $rep_id]);
        Logger::logResponse('/rep/orders', 200);
        jsonResponse(['success' => false, 'error' => 'Failed to fetch orders', 'data' => []]);
    }
}

/**
 * POST /rep/create-order
 * Create an order with multiple items from mobile app
 */
function handleRepCreateOrder($input) {
    $repId = $input['rep_id'] ?? null;
    $customerId = $input['customer_id'] ?? null;
    $items = $input['items'] ?? [];
    
    Logger::info('Order creation request', [
        'rep_id' => $repId,
        'customer_id' => $customerId,
        'item_count' => count($items)
    ]);
    
    if (!$repId || !$customerId || empty($items)) {
        http_response_code(400);
        Logger::logResponse('/rep/create-order', 400);
        jsonResponse([
            'success' => false,
            'message' => 'rep_id, customer_id, and items are required'
        ]);
        return;
    }
    
    try {
        $db = new Database();
        
        // Begin transaction
        $db->execute('START TRANSACTION', []);
        
        // Calculate order total from items
        $orderAmount = 0;
        foreach ($items as $item) {
            $itemTotal = ($item['quantity'] ?? 0) * ($item['unit_price'] ?? 0);
            $orderAmount += $itemTotal;
        }
        
        // Create order
        $db->execute(
            'INSERT INTO orders (rep_id, customer_id, order_amount, order_date, status) 
             VALUES (?, ?, ?, NOW(), "pending")',
            [$repId, $customerId, $orderAmount]
        );
        
        $orderId = $db->lastId();
        
        // Insert order items
        foreach ($items as $item) {
            $totalPrice = ($item['quantity'] ?? 0) * ($item['unit_price'] ?? 0);
            $db->execute(
                'INSERT INTO order_items (order_id, product_name, quantity, unit_price, total_price) 
                 VALUES (?, ?, ?, ?, ?)',
                [
                    $orderId,
                    $item['product_name'] ?? '',
                    $item['quantity'] ?? 0,
                    $item['unit_price'] ?? 0,
                    $totalPrice
                ]
            );
        }
        
        // Commit transaction
        $db->execute('COMMIT', []);
        
        Logger::info('Order created successfully', [
            'order_id' => $orderId,
            'rep_id' => $repId,
            'customer_id' => $customerId,
            'total' => $orderAmount
        ]);
        
        Logger::logResponse('/rep/create-order', 200);
        jsonResponse([
            'success' => true,
            'message' => 'Order created successfully',
            'data' => [
                'order_id' => $orderId,
                'order_amount' => $orderAmount,
                'item_count' => count($items)
            ]
        ]);
        
    } catch (Exception $e) {
        // Rollback transaction on error
        try {
            $db->execute('ROLLBACK', []);
        } catch (Exception $rollbackEx) {
            Logger::error('Rollback failed', ['error' => $rollbackEx->getMessage()]);
        }
        
        Logger::error('Order creation failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/rep/create-order', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * GET /admin/reps
 * Get all reps
 */
function handleAdminReps() {
    Logger::debug('Fetching all reps');
    
    $demoReps = [
        [
            'id' => 1,
            'name' => 'Demo Rep',
            'email' => 'demo@quarryforce.local',
            'role' => 'rep',
            'fixed_salary' => 20000,
            'is_active' => 1,
            'phone' => null,
            'device_uid' => null
        ]
    ];
    
    try {
        $db = new Database();
        $reps = $db->query('SELECT id, email, name, role, device_uid, is_active, fixed_salary, petrol_allowance, mobile_no, photo FROM users WHERE role IN ("rep", "admin")', []);
        Logger::logResponse('/admin/reps', 200);
        jsonResponse(['success' => true, 'data' => $reps ?? $demoReps]);
    } catch (Exception $e) {
        Logger::warn('Admin reps query failed, returning demo data', ['error' => $e->getMessage()]);
        Logger::logResponse('/admin/reps', 200);
        jsonResponse(['success' => true, 'data' => $demoReps]);
    }
}

/**
 * GET /admin/customers
 * Get all customers
 */
function handleAdminCustomers() {
    Logger::debug('Fetching all customers');
    
    $demoCustomers = [
        ['id' => 1, 'name' => 'Green Quarry Ltd', 'lat' => 12.9716, 'lng' => 77.5946, 'status' => 'active', 'assigned_rep_id' => 1, 'assigned_rep_name' => 'Demo Rep'],
        ['id' => 2, 'name' => 'Metro Limestone Co', 'lat' => 12.9352, 'lng' => 77.6245, 'status' => 'active', 'assigned_rep_id' => 1, 'assigned_rep_name' => 'Demo Rep'],
        ['id' => 3, 'name' => 'City Construction Materials', 'lat' => 13.0827, 'lng' => 80.2707, 'status' => 'active', 'assigned_rep_id' => null, 'assigned_rep_name' => null]
    ];
    
    try {
        $db = new Database();
        $customers = $db->query(
            'SELECT c.id, c.name, c.phone_no, c.location, c.lat, c.lng, c.assigned_rep_id, u.name as assigned_rep_name,
                    c.site_type, c.site_incharge_name, c.site_incharge_phone, c.address, c.material_needs, c.rmc_grade,
                    c.aggregate_types, c.volume, c.volume_unit, c.required_date, c.amount_concluded_per_unit,
                    c.boom_pump_amount, c.status, c.created_at
             FROM customers c
             LEFT JOIN users u ON c.assigned_rep_id = u.id',
            []
        );
        Logger::logResponse('/admin/customers', 200);
        jsonResponse(['success' => true, 'data' => $customers ?? $demoCustomers]);
    } catch (Exception $e) {
        Logger::warn('Admin customers query failed, returning demo data', ['error' => $e->getMessage()]);
        Logger::logResponse('/admin/customers', 200);
        jsonResponse(['success' => true, 'data' => $demoCustomers]);
    }
}

/**
 * POST /admin/customers
 * Create a new customer
 */
function handleAdminCustomersCreate($input) {
    Logger::debug('Creating new customer');
    
    if (!isset($input['name']) || !isset($input['assigned_rep_id'])) {
        Logger::warn('Missing required customer fields');
        http_response_code(400);
        jsonResponse(['success' => false, 'error' => 'Name and Assigned Rep are required']);
        return;
    }
    
    try {
        $db = new Database();
        
        // Prepare fields for insertion
        $fields = ['name', 'assigned_rep_id'];
        $placeholders = ['?', '?'];
        $values = [$input['name'], $input['assigned_rep_id']];
        
        // Add optional fields
        $optionalFields = ['phone_no', 'location', 'lat', 'lng', 'site_type', 'site_incharge_name', 'site_incharge_phone', 'address', 
                          'material_needs', 'rmc_grade', 'aggregate_types', 'volume', 'volume_unit', 
                          'required_date', 'amount_concluded_per_unit', 'boom_pump_amount', 'status'];
        
        foreach ($optionalFields as $field) {
            if (isset($input[$field])) {
                $fields[] = $field;
                $placeholders[] = '?';
                $values[] = $input[$field];
            }
        }
        
        $sql = 'INSERT INTO customers (' . implode(', ', $fields) . ') VALUES (' . implode(', ', $placeholders) . ')';
        
        $result = $db->execute($sql, $values);
        
        if (!$result) {
            Logger::error('Failed to create customer');
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Failed to create customer']);
            return;
        }
        
        $customerId = $db->lastId();
        
        // Fetch the newly created customer with rep name
        $customer = $db->queryOne(
            'SELECT c.id, c.name, c.phone_no, c.location, c.lat, c.lng, c.assigned_rep_id, u.name as assigned_rep_name, 
                     c.site_type, c.site_incharge_name, c.site_incharge_phone, c.address, c.material_needs, c.rmc_grade,
                     c.aggregate_types, c.volume, c.volume_unit, c.required_date, c.amount_concluded_per_unit,
                     c.boom_pump_amount, c.status, c.created_at
             FROM customers c
             LEFT JOIN users u ON c.assigned_rep_id = u.id
             WHERE c.id = ?',
            [$customerId]
        );
        
        Logger::info('Customer created successfully', ['customer_id' => $customerId]);
        Logger::logResponse('/admin/customers', 201);
        jsonResponse(['success' => true, 'data' => $customer]);
        
    } catch (Exception $e) {
        Logger::error('Customer creation failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        jsonResponse(['success' => false, 'error' => 'Failed to create customer']);
    }
}

/**
 * PUT /admin/customers/{id}
 * Update a customer
 */
function handleAdminCustomersUpdate($customerId, $input) {
    Logger::debug('Updating customer', ['customer_id' => $customerId]);
    
    try {
        $db = new Database();
        
        // Check if customer exists
        $existing = $db->queryOne('SELECT id FROM customers WHERE id = ?', [$customerId]);
        if (!$existing) {
            Logger::warn('Customer not found', ['customer_id' => $customerId]);
            http_response_code(404);
            jsonResponse(['success' => false, 'error' => 'Customer not found']);
            return;
        }
        
        // Build update query
        $updates = [];
        $values = [];
        
        $updatableFields = ['name', 'phone_no', 'location', 'lat', 'lng', 'assigned_rep_id', 'site_type', 'site_incharge_name', 
                           'site_incharge_phone', 'address', 'material_needs', 'rmc_grade', 'aggregate_types',
                           'volume', 'volume_unit', 'required_date', 'amount_concluded_per_unit', 'boom_pump_amount', 'status'];
        
        foreach ($updatableFields as $field) {
            if (isset($input[$field])) {
                $updates[] = "$field = ?";
                $values[] = $input[$field];
            }
        }
        
        if (empty($updates)) {
            Logger::warn('No fields to update');
            http_response_code(400);
            jsonResponse(['success' => false, 'error' => 'No fields to update']);
            return;
        }
        
        $values[] = $customerId;
        $sql = 'UPDATE customers SET ' . implode(', ', $updates) . ' WHERE id = ?';
        
        $result = $db->execute($sql, $values);
        
        if (!$result) {
            Logger::error('Failed to update customer');
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Failed to update customer']);
            return;
        }
        
        // Fetch updated customer
        $customer = $db->queryOne(
            'SELECT c.id, c.name, c.phone_no, c.location, c.lat, c.lng, c.assigned_rep_id, u.name as assigned_rep_name,
                     c.site_type, c.site_incharge_name, c.site_incharge_phone, c.address, c.material_needs, c.rmc_grade,
                     c.aggregate_types, c.volume, c.volume_unit, c.required_date, c.amount_concluded_per_unit,
                     c.boom_pump_amount, c.status, c.created_at, c.updated_at
             FROM customers c
             LEFT JOIN users u ON c.assigned_rep_id = u.id
             WHERE c.id = ?',
            [$customerId]
        );
        
        Logger::info('Customer updated successfully', ['customer_id' => $customerId]);
        Logger::logResponse('/admin/customers', 200);
        jsonResponse(['success' => true, 'data' => $customer]);
        
    } catch (Exception $e) {
        Logger::error('Customer update failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        jsonResponse(['success' => false, 'error' => 'Failed to update customer']);
    }
}

/**
 * DELETE /admin/customers/{id}
 * Delete a customer
 */
function handleAdminCustomersDelete($customerId) {
    Logger::debug('Deleting customer', ['customer_id' => $customerId]);
    
    try {
        $db = new Database();
        
        // Check if customer exists
        $existing = $db->queryOne('SELECT id FROM customers WHERE id = ?', [$customerId]);
        if (!$existing) {
            Logger::warn('Customer not found', ['customer_id' => $customerId]);
            http_response_code(404);
            jsonResponse(['success' => false, 'error' => 'Customer not found']);
            return;
        }
        
        // Delete customer
        $result = $db->execute('DELETE FROM customers WHERE id = ?', [$customerId]);
        
        if (!$result) {
            Logger::error('Failed to delete customer');
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Failed to delete customer']);
            return;
        }
        
        Logger::info('Customer deleted successfully', ['customer_id' => $customerId]);
        Logger::logResponse('/admin/customers', 200);
        jsonResponse(['success' => true, 'message' => 'Customer deleted successfully']);
        
    } catch (Exception $e) {
        Logger::error('Customer deletion failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        jsonResponse(['success' => false, 'error' => 'Failed to delete customer']);
    }
}

/**
 * GET /admin/orders
 * Get all orders
 */
function handleAdminOrdersList() {
    Logger::debug('Fetching all orders');
    
    try {
        $db = new Database();
        $orders = $db->query(
            'SELECT o.id, o.rep_id, o.customer_id, o.order_amount, o.order_date, o.product_details, o.status, 
                     o.created_at, o.updated_at, u.name as rep_name, c.name as customer_name
             FROM orders o
             LEFT JOIN users u ON o.rep_id = u.id
             LEFT JOIN customers c ON o.customer_id = c.id
             ORDER BY o.created_at DESC',
            []
        );
        Logger::logResponse('/admin/orders', 200);
        jsonResponse(['success' => true, 'data' => $orders ?? []]);
    } catch (Exception $e) {
        Logger::warn('Admin orders query failed', ['error' => $e->getMessage()]);
        Logger::logResponse('/admin/orders', 200);
        jsonResponse(['success' => true, 'data' => []]);
    }
}

/**
 * GET /admin/orders/customer/{id}
 * Get orders for a specific customer
 */
function handleAdminOrdersByCustomer($customerId) {
    Logger::debug('Fetching orders for customer', ['customer_id' => $customerId]);
    
    try {
        $db = new Database();
        $orders = $db->query(
            'SELECT o.id, o.rep_id, o.customer_id, o.order_amount, o.order_date, o.product_details, o.status, 
                     o.created_at, o.updated_at, u.name as rep_name, c.name as customer_name
             FROM orders o
             LEFT JOIN users u ON o.rep_id = u.id
             LEFT JOIN customers c ON o.customer_id = c.id
             WHERE o.customer_id = ?
             ORDER BY o.created_at DESC',
            [$customerId]
        );
        Logger::logResponse('/admin/orders', 200);
        jsonResponse(['success' => true, 'data' => $orders ?? []]);
    } catch (Exception $e) {
        Logger::warn('Customer orders query failed', ['error' => $e->getMessage()]);
        Logger::logResponse('/admin/orders', 200);
        jsonResponse(['success' => true, 'data' => []]);
    }
}

/**
 * POST /admin/orders
 * Create a new order
 */
function handleAdminOrdersCreate($input) {
    Logger::debug('Creating new order');
    
    if (!isset($input['rep_id']) || !isset($input['customer_id']) || !isset($input['order_amount'])) {
        Logger::warn('Missing required order fields');
        http_response_code(400);
        jsonResponse(['success' => false, 'error' => 'Rep, Customer, and Order Amount are required']);
        return;
    }
    
    try {
        $db = new Database();
        
        // Prepare fields for insertion
        $fields = ['rep_id', 'customer_id', 'order_amount'];
        $placeholders = ['?', '?', '?'];
        $values = [$input['rep_id'], $input['customer_id'], $input['order_amount']];
        
        // Add optional fields
        $optionalFields = ['order_date', 'product_details', 'status'];
        
        foreach ($optionalFields as $field) {
            if (isset($input[$field])) {
                $fields[] = $field;
                $placeholders[] = '?';
                $values[] = $input[$field];
            }
        }
        
        $sql = 'INSERT INTO orders (' . implode(', ', $fields) . ') VALUES (' . implode(', ', $placeholders) . ')';
        
        $result = $db->execute($sql, $values);
        
        if (!$result) {
            Logger::error('Failed to create order');
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Failed to create order']);
            return;
        }
        
        $orderId = $db->lastId();
        
        // Fetch the newly created order
        $order = $db->queryOne(
            'SELECT o.id, o.rep_id, o.customer_id, o.order_amount, o.order_date, o.product_details, o.status, 
                     o.created_at, o.updated_at, u.name as rep_name, c.name as customer_name
             FROM orders o
             LEFT JOIN users u ON o.rep_id = u.id
             LEFT JOIN customers c ON o.customer_id = c.id
             WHERE o.id = ?',
            [$orderId]
        );
        
        Logger::info('Order created successfully', ['order_id' => $orderId]);
        Logger::logResponse('/admin/orders', 201);
        jsonResponse(['success' => true, 'data' => $order]);
        
    } catch (Exception $e) {
        Logger::error('Order creation failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        jsonResponse(['success' => false, 'error' => 'Failed to create order']);
    }
}

/**
 * PUT /admin/orders/{id}
 * Update an order
 */
function handleAdminOrdersUpdate($orderId, $input) {
    Logger::debug('Updating order', ['order_id' => $orderId]);
    
    try {
        $db = new Database();
        
        // Check if order exists
        $existing = $db->queryOne('SELECT id FROM orders WHERE id = ?', [$orderId]);
        if (!$existing) {
            Logger::warn('Order not found', ['order_id' => $orderId]);
            http_response_code(404);
            jsonResponse(['success' => false, 'error' => 'Order not found']);
            return;
        }
        
        // Build update query
        $updates = [];
        $values = [];
        
        $updatableFields = ['rep_id', 'customer_id', 'order_amount', 'order_date', 'product_details', 'status'];
        
        foreach ($updatableFields as $field) {
            if (isset($input[$field])) {
                $updates[] = "$field = ?";
                $values[] = $input[$field];
            }
        }
        
        if (empty($updates)) {
            Logger::warn('No fields to update');
            http_response_code(400);
            jsonResponse(['success' => false, 'error' => 'No fields to update']);
            return;
        }
        
        $values[] = $orderId;
        $sql = 'UPDATE orders SET ' . implode(', ', $updates) . ' WHERE id = ?';
        
        $result = $db->execute($sql, $values);
        
        if (!$result) {
            Logger::error('Failed to update order');
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Failed to update order']);
            return;
        }
        
        // Fetch updated order
        $order = $db->queryOne(
            'SELECT o.id, o.rep_id, o.customer_id, o.order_amount, o.order_date, o.product_details, o.status, 
                     o.created_at, o.updated_at, u.name as rep_name, c.name as customer_name
             FROM orders o
             LEFT JOIN users u ON o.rep_id = u.id
             LEFT JOIN customers c ON o.customer_id = c.id
             WHERE o.id = ?',
            [$orderId]
        );
        
        // Auto-update rep progress if order was delivered
        if (isset($input['status']) || isset($input['order_amount'])) {
            recalculateRepProgressForOrder($db, $orderId);
        }
        
        Logger::info('Order updated successfully', ['order_id' => $orderId]);
        Logger::logResponse('/admin/orders', 200);
        jsonResponse(['success' => true, 'data' => $order]);
        
    } catch (Exception $e) {
        Logger::error('Order update failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        jsonResponse(['success' => false, 'error' => 'Failed to update order']);
    }
}

/**
 * Helper to dynamically recalculate Rep Progress for a delivered order's month
 */
function recalculateRepProgressForOrder($db, $orderId) {
    try {
        $order = $db->queryOne('SELECT rep_id, order_date FROM orders WHERE id = ?', [$orderId]);
        if (!$order || !$order['rep_id']) return;
        
        $repId = $order['rep_id'];
        $orderDate = $order['order_date'] ?? date('Y-m-d');
        // Schema is VARCHAR(7) 'YYYY-MM'
        $targetMonth = substr($orderDate, 0, 7);
        $monthStart = $targetMonth . '-01';
        
        // Sum delivered items for this month for this rep
        $sales = $db->queryOne(
            "SELECT COALESCE(SUM(oi.quantity), 0) as total_m3 
             FROM order_items oi
             JOIN orders o ON oi.order_id = o.id
             WHERE o.rep_id = ? AND o.status = 'delivered' 
             AND o.order_date >= ? AND o.order_date < DATE_ADD(?, INTERVAL 1 MONTH)",
            [$repId, $monthStart, $monthStart]
        );
        
        $totalM3 = $sales ? (float)$sales['total_m3'] : 0.0;
        $target = $db->queryOne('SELECT * FROM rep_targets WHERE rep_id = ?', [$repId]);
        
        $bonus = 0; $penalty = 0; $targetAmt = 0;
        if ($target) {
            $targetAmt = $target['monthly_sales_target_m3'] ?? 0;
            if ($totalM3 > $targetAmt) {
                $bonus = ($totalM3 - $targetAmt) * ($target['incentive_rate_per_m3'] ?? 0);
            } else if ($totalM3 < $targetAmt) {
                $penalty = ($targetAmt - $totalM3) * ($target['penalty_rate_per_m3'] ?? 0);
            }
        }
        
        $netComp = $bonus - $penalty;
        
        $db->execute(
            'INSERT INTO rep_progress (rep_id, month, sales_achieved, target_amount, incentive_earned, penalty_deducted, final_bonus)
             VALUES (?, ?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE
             sales_achieved = VALUES(sales_achieved),
             target_amount = VALUES(target_amount),
             incentive_earned = VALUES(incentive_earned),
             penalty_deducted = VALUES(penalty_deducted),
             final_bonus = VALUES(final_bonus)',
            [$repId, $targetMonth, $totalM3, $targetAmt, $bonus, $penalty, $netComp]
        );
    } catch (Exception $e) {
        Logger::error('Failed to recalculate rep progress', ['error' => $e->getMessage()]);
    }
}

/**
 * DELETE /admin/orders/{id}
 * Delete an order
 */
function handleAdminOrdersDelete($orderId) {
    Logger::debug('Deleting order', ['order_id' => $orderId]);
    
    try {
        $db = new Database();
        
        // Check if order exists
        $existing = $db->queryOne('SELECT id FROM orders WHERE id = ?', [$orderId]);
        if (!$existing) {
            Logger::warn('Order not found', ['order_id' => $orderId]);
            http_response_code(404);
            jsonResponse(['success' => false, 'error' => 'Order not found']);
            return;
        }
        
        // Delete order
        $result = $db->execute('DELETE FROM orders WHERE id = ?', [$orderId]);
        
        if (!$result) {
            Logger::error('Failed to delete order');
            http_response_code(500);
            jsonResponse(['success' => false, 'error' => 'Failed to delete order']);
            return;
        }
        
        Logger::info('Order deleted successfully', ['order_id' => $orderId]);
        Logger::logResponse('/admin/orders', 200);
        jsonResponse(['success' => true, 'message' => 'Order deleted successfully']);
        
    } catch (Exception $e) {
        Logger::error('Order deletion failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        jsonResponse(['success' => false, 'error' => 'Failed to delete order']);
    }
}

/**
 * POST /admin/reset-device
 * Reset device lock for a user
 */
function handleAdminResetDevice($input) {
    $user_id = $input['user_id'] ?? null;
    
    Logger::info('Device reset request', ['user_id' => $user_id]);
    
    if (!$user_id) {
        http_response_code(400);
        Logger::logResponse('/admin/reset-device', 400);
        jsonResponse(['success' => false, 'message' => 'User ID required.']);
        return;
    }
    
    try {
        $db = new Database();
        $db->execute('UPDATE users SET device_uid = NULL WHERE id = ?', [$user_id]);
        
        // Fetch and return updated user data
        $updatedUser = $db->queryOne(
            'SELECT id, email, name, role, device_uid, is_active, fixed_salary, mobile_no, created_at FROM users WHERE id = ?',
            [$user_id]
        );
        
        Logger::info('Device reset successful', ['user_id' => $user_id]);
        Logger::logResponse('/admin/reset-device', 200);
        jsonResponse(['success' => true, 'message' => 'Device lock reset. Rep can register a new phone.', 'data' => $updatedUser]);
    } catch (Exception $e) {
        Logger::error('Device reset failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/reset-device', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * GET /admin/rep-targets
 * Get all rep targets
 */
function handleAdminRepTargetsList() {
    Logger::debug('Fetching all rep targets');
    
    try {
        $db = new Database();
        $targets = $db->query(
            'SELECT rt.*, u.name as rep_name, u.email
             FROM rep_targets rt
             JOIN users u ON rt.rep_id = u.id
             WHERE rt.status = "active"
             ORDER BY u.name',
            []
        );
        Logger::logResponse('/admin/rep-targets', 200);
        jsonResponse(['success' => true, 'data' => $targets]);
    } catch (Exception $e) {
        Logger::error('Rep targets fetch failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/rep-targets', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * GET /admin/rep-targets/:rep_id
 * Get specific rep targets
 */
function handleAdminRepTargetsGet($repId) {
    Logger::debug('Fetching rep targets', ['rep_id' => $repId]);
    
    $demoTarget = [
        'id' => 1,
        'rep_id' => (int)$repId,
        'rep_name' => 'Demo Rep',
        'email' => 'demo@quarryforce.local',
        'target_month' => date('Y-m'),
        'monthly_sales_target_m3' => 1000,
        'incentive_rate_per_m3' => 50,
        'incentive_rate_max_per_m3' => 2000,
        'penalty_rate_per_m3' => 25,
        'status' => 'active'
    ];
    
    try {
        $db = new Database();
        $target = $db->queryOne(
            'SELECT rt.*, u.name as rep_name, u.email
             FROM rep_targets rt
             JOIN users u ON rt.rep_id = u.id
             WHERE rt.rep_id = ?',
            [$repId]
        );
        Logger::logResponse('/admin/rep-targets', 200);
        jsonResponse(['success' => true, 'data' => $target ?? $demoTarget]);
    } catch (Exception $e) {
        Logger::warn('Rep targets query failed, returning demo data', ['error' => $e->getMessage()]);
        Logger::logResponse('/admin/rep-targets', 200);
        jsonResponse(['success' => true, 'data' => $demoTarget]);
    }
}

/**
 * POST /admin/rep-targets
 * Create/set rep targets
 */
function handleAdminRepTargetsCreate($input) {
    $rep_id = $input['rep_id'] ?? null;
    $target_month = $input['target_month'] ?? null;
    $monthly_sales_target_m3 = $input['monthly_sales_target_m3'] ?? null;
    $incentive_rate_per_m3 = $input['incentive_rate_per_m3'] ?? 5;
    $incentive_rate_max_per_m3 = $input['incentive_rate_max_per_m3'] ?? 9;
    $penalty_rate_per_m3 = $input['penalty_rate_per_m3'] ?? 50;
    $updated_by = $input['updated_by'] ?? 1;
    $force_override = $input['force_override'] ?? false;
    
    Logger::info('Rep target creation request', ['rep_id' => $rep_id, 'target_m3' => $monthly_sales_target_m3]);
    
    if (!$rep_id || $monthly_sales_target_m3 === null) {
        http_response_code(400);
        Logger::logResponse('/admin/rep-targets', 400);
        jsonResponse(['success' => false, 'message' => 'rep_id and monthly_sales_target_m3 required.']);
        return;
    }
    
    try {
        $db = new Database();
        $currentMonth = $target_month ?? date('Y-m');
        
        // Check if exists
        $existing = $db->queryOne(
            'SELECT id FROM rep_targets WHERE rep_id = ? AND target_month = ?',
            [$rep_id, $currentMonth]
        );
        
        if ($existing && !$force_override) {
            http_response_code(409);
            Logger::warn('Target already exists', ['rep_id' => $rep_id, 'month' => $currentMonth]);
            Logger::logResponse('/admin/rep-targets', 409);
            jsonResponse([
                'success' => false,
                'error' => 'Target already exists for this month',
                'existingTarget' => $existing,
                'requiresConfirmation' => true
            ]);
            return;
        }
        
        // Insert or update
        $db->execute(
            'INSERT INTO rep_targets (rep_id, target_month, monthly_sales_target_m3, incentive_rate_per_m3, incentive_rate_max_per_m3, penalty_rate_per_m3, updated_by)
             VALUES (?, ?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE
             monthly_sales_target_m3 = VALUES(monthly_sales_target_m3),
             incentive_rate_per_m3 = VALUES(incentive_rate_per_m3),
             incentive_rate_max_per_m3 = VALUES(incentive_rate_max_per_m3),
             penalty_rate_per_m3 = VALUES(penalty_rate_per_m3),
             updated_by = VALUES(updated_by),
             updated_at = NOW()',
            [$rep_id, $currentMonth, $monthly_sales_target_m3, $incentive_rate_per_m3, $incentive_rate_max_per_m3, $penalty_rate_per_m3, $updated_by]
        );
        
        // Fetch and return the created/updated target
        $createdTarget = $db->queryOne(
            'SELECT rt.*, u.name as rep_name FROM rep_targets rt
             LEFT JOIN users u ON rt.rep_id = u.id
             WHERE rt.rep_id = ? AND rt.target_month = ?',
            [$rep_id, $currentMonth]
        );
        
        Logger::info('Target set successfully', ['rep_id' => $rep_id, 'target_m3' => $monthly_sales_target_m3]);
        Logger::logResponse('/admin/rep-targets', 200);
        jsonResponse(['success' => true, 'message' => 'Target set successfully!', 'data' => $createdTarget]);
        
    } catch (Exception $e) {
        Logger::error('Target creation failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/rep-targets', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * PUT /admin/rep-targets/:id
 * Update rep targets
 */
function handleAdminRepTargetsUpdate($targetId, $input) {
    Logger::info('Rep target update request', ['target_id' => $targetId]);
    
    try {
        $db = new Database();
        $updates = [];
        $params = [];
        
        if (isset($input['monthly_sales_target_m3'])) {
            $updates[] = 'monthly_sales_target_m3 = ?';
            $params[] = $input['monthly_sales_target_m3'];
        }
        if (isset($input['incentive_rate_per_m3'])) {
            $updates[] = 'incentive_rate_per_m3 = ?';
            $params[] = $input['incentive_rate_per_m3'];
        }
        if (isset($input['incentive_rate_max_per_m3'])) {
            $updates[] = 'incentive_rate_max_per_m3 = ?';
            $params[] = $input['incentive_rate_max_per_m3'];
        }
        if (isset($input['penalty_rate_per_m3'])) {
            $updates[] = 'penalty_rate_per_m3 = ?';
            $params[] = $input['penalty_rate_per_m3'];
        }
        if (isset($input['status'])) {
            $updates[] = 'status = ?';
            $params[] = $input['status'];
        }
        
        if (empty($updates)) {
            http_response_code(400);
            jsonResponse(['success' => false, 'error' => 'No fields to update']);
            return;
        }
        
        $updates[] = 'updated_by = ?';
        $params[] = $input['updated_by'] ?? 1;
        $params[] = $targetId;
        
        $db->execute(
            'UPDATE rep_targets SET ' . implode(', ', $updates) . ' WHERE id = ?',
            $params
        );
        
        // Fetch and return updated target data
        $updatedTarget = $db->queryOne(
            'SELECT rt.*, u.name as rep_name FROM rep_targets rt
             LEFT JOIN users u ON rt.rep_id = u.id
             WHERE rt.id = ?',
            [$targetId]
        );
        
        Logger::info('Target updated successfully', ['target_id' => $targetId]);
        Logger::logResponse('/admin/rep-targets', 200);
        jsonResponse(['success' => true, 'message' => 'Targets updated successfully!', 'data' => $updatedTarget]);
        
    } catch (Exception $e) {
        Logger::error('Target update failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/rep-targets', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * GET /admin/rep-progress/:rep_id
 * Get rep monthly progress
 */
function handleAdminRepProgress($repId, $month = null) {
    Logger::debug('Fetching rep progress', ['rep_id' => $repId, 'month' => $month]);
    
    $fullMonth = $month ?? date('Y-m-01');
    $targetMonth = substr($fullMonth, 0, 7);
    
    $demoProgress = [
        'rep_id' => (int)$repId,
        'month' => $fullMonth,
        'sales_volume_m3' => 0,
        'bonus_earned' => 0,
        'penalty_amount' => 0,
        'net_compensation' => 0,
        'status' => 'pending',
        'monthly_sales_target_m3' => 1000,
        'incentive_rate_per_m3' => 50,
        'penalty_rate_per_m3' => 25,
        'rep_name' => 'Demo Rep'
    ];
    
    try {
        $db = new Database();
        $progress = $db->queryOne(
            'SELECT rp.*, rp.sales_achieved as sales_volume_m3, rp.incentive_earned as bonus_earned, rp.penalty_deducted as penalty_amount, rp.final_bonus as net_compensation,
                    rt.monthly_sales_target_m3, rt.incentive_rate_per_m3, rt.penalty_rate_per_m3, u.name as rep_name
             FROM rep_progress rp
             LEFT JOIN rep_targets rt ON rp.rep_id = rt.rep_id
             LEFT JOIN users u ON rp.rep_id = u.id
             WHERE rp.rep_id = ? AND rp.month = ?',
            [$repId, $targetMonth]
        );
        
        if (!$progress) {
            Logger::debug('No progress found, checking targets', ['rep_id' => $repId]);
            $target = $db->queryOne(
                'SELECT rt.*, u.name as rep_name FROM rep_targets rt
                 JOIN users u ON rt.rep_id = u.id
                 WHERE rt.rep_id = ?',
                [$repId]
            );
            Logger::logResponse('/admin/rep-progress', 200);
            jsonResponse([
                'success' => true,
                'data' => [
                    'rep_id' => $repId,
                    'month' => $fullMonth,
                    'sales_volume_m3' => 0,
                    'bonus_earned' => 0,
                    'penalty_amount' => 0,
                    'net_compensation' => 0,
                    'status' => 'pending',
                    'targets' => $target
                ]
            ]);
            return;
        }
        
        $progress['month'] = $fullMonth; // keep API interface consistent
        Logger::logResponse('/admin/rep-progress', 200);
        jsonResponse(['success' => true, 'data' => $progress]);
        
    } catch (Exception $e) {
        Logger::warn('Rep progress query failed, returning demo data', ['error' => $e->getMessage()]);
        Logger::logResponse('/admin/rep-progress', 200);
        jsonResponse(['success' => true, 'data' => $demoProgress]);
    }
}

/**
 * GET /admin/rep-progress-history/:rep_id
 * Get all historical progress for a rep
 */
function handleAdminRepProgressHistory($repId) {
    Logger::debug('Fetching rep progress history', ['rep_id' => $repId]);
    
    try {
        $db = new Database();
        $history = $db->query(
            'SELECT rp.*, u.name as rep_name
             FROM rep_progress rp
             LEFT JOIN users u ON rp.rep_id = u.id
             WHERE rp.rep_id = ?
             ORDER BY rp.month DESC',
            [$repId]
        );
        Logger::logResponse('/admin/rep-progress-history', 200);
        jsonResponse(['success' => true, 'data' => $history]);
    } catch (Exception $e) {
        Logger::error('Progress history fetch failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/rep-progress-history', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * POST /admin/rep-progress/update
 * Update rep sales and calculate bonus/penalty
 */
function handleAdminRepProgressUpdate($input) {
    $rep_id = $input['rep_id'] ?? null;
    $sales_volume_m3 = $input['sales_volume_m3'] ?? null;
    $month = $input['month'] ?? null;
    
    Logger::info('Rep progress update request', ['rep_id' => $rep_id, 'sales_volume_m3' => $sales_volume_m3]);
    
    if (!$rep_id || $sales_volume_m3 === null) {
        http_response_code(400);
        Logger::logResponse('/admin/rep-progress/update', 400);
        jsonResponse(['success' => false, 'message' => 'rep_id and sales_volume_m3 required.']);
        return;
    }
    
    try {
        $db = new Database();
        $targetMonth = $month ?? date('Y-m-01');
        
        // Get rep targets
        $target = $db->queryOne(
            'SELECT * FROM rep_targets WHERE rep_id = ?',
            [$rep_id]
        );
        
        if (!$target) {
            Logger::warn('Targets not found for rep', ['rep_id' => $rep_id]);
            http_response_code(400);
            Logger::logResponse('/admin/rep-progress/update', 400);
            jsonResponse(['success' => false, 'message' => 'Targets not found for this rep.']);
            return;
        }
        
        // Calculate bonus/penalty
        $bonus = 0;
        $penalty = 0;
        
        if ($sales_volume_m3 > $target['monthly_sales_target_m3']) {
            $excess = $sales_volume_m3 - $target['monthly_sales_target_m3'];
            $bonus = $excess * $target['incentive_rate_per_m3'];
        } else if ($sales_volume_m3 < $target['monthly_sales_target_m3']) {
            $shortfall = $target['monthly_sales_target_m3'] - $sales_volume_m3;
            $penalty = $shortfall * $target['penalty_rate_per_m3'];
        }
        
        $netComp = $bonus - $penalty;
        
        // Insert/update progress
        $db->execute(
            'INSERT INTO rep_progress (rep_id, month, sales_volume_m3, bonus_earned, penalty_amount, net_compensation)
             VALUES (?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE
             sales_volume_m3 = VALUES(sales_volume_m3),
             bonus_earned = VALUES(bonus_earned),
             penalty_amount = VALUES(penalty_amount),
             net_compensation = VALUES(net_compensation)',
            [$rep_id, $targetMonth, $sales_volume_m3, $bonus, $penalty, $netComp]
        );
        
        Logger::info('Progress updated with bonus/penalty calculation', [
            'rep_id' => $rep_id,
            'sales' => $sales_volume_m3,
            'bonus' => $bonus,
            'penalty' => $penalty
        ]);
        
        Logger::logResponse('/admin/rep-progress/update', 200);
        jsonResponse([
            'success' => true,
            'message' => 'Progress updated successfully!',
            'data' => [
                'rep_id' => $rep_id,
                'month' => $targetMonth,
                'sales_volume_m3' => $sales_volume_m3,
                'bonus_earned' => $bonus,
                'penalty_amount' => $penalty,
                'net_compensation' => $netComp,
                'target_m3' => $target['monthly_sales_target_m3'],
                'status' => 'pending'
            ]
        ]);
        
    } catch (Exception $e) {
        Logger::error('Progress update failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/rep-progress/update', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * GET /admin/users
 * Get all users
 */
function handleAdminUsersList() {
    Logger::debug('Fetching all users');
    
    try {
        $db = new Database();
        $users = $db->query(
            'SELECT id, email, name, role, device_uid, is_active, fixed_salary, mobile_no, created_at FROM users ORDER BY created_at DESC',
            []
        );
        Logger::logResponse('/admin/users', 200);
        jsonResponse(['success' => true, 'data' => $users]);
    } catch (Exception $e) {
        Logger::error('Users fetch failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/users', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * POST /admin/users
 * Create new user
 */
function handleAdminUsersCreate($input) {
    $email = $input['email'] ?? null;
    $name = $input['name'] ?? null;
    
    Logger::info('User creation request', ['email' => $email, 'name' => $name]);
    
    if (!$email || !$name) {
        http_response_code(400);
        Logger::logResponse('/admin/users', 400);
        jsonResponse(['success' => false, 'message' => 'Email and name are required.']);
        return;
    }
    
    try {
        $db = new Database();
        
        // Check if exists
        $existing = $db->queryOne('SELECT id FROM users WHERE email = ?', [$email]);
        if ($existing) {
            http_response_code(400);
            Logger::warn('User already exists', ['email' => $email]);
            Logger::logResponse('/admin/users', 400);
            jsonResponse(['success' => false, 'message' => 'User with this email already exists.']);
            return;
        }
        
        // Create user
        $db->execute(
            'INSERT INTO users (email, name, role, is_active) VALUES (?, ?, ?, ?)',
            [$email, $name, 'rep', 1]
        );
        
        $userId = $db->lastId();
        Logger::info('User created successfully', ['user_id' => $userId, 'email' => $email]);
        Logger::logResponse('/admin/users', 200);
        jsonResponse([
            'success' => true,
            'message' => 'User created successfully!',
            'data' => ['id' => $userId, 'email' => $email, 'name' => $name, 'role' => 'rep']
        ]);
        
    } catch (Exception $e) {
        Logger::error('User creation failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/users', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * PUT /admin/users/:id
 * Update user
 */
function handleAdminUsersUpdate($userId, $input) {
    $email = $input['email'] ?? null;
    $name = $input['name'] ?? null;
    $fixed_salary = $input['fixed_salary'] ?? null;
    $petrol_allowance = $input['petrol_allowance'] ?? null;
    $mobile_no = $input['mobile_no'] ?? null;
    
    Logger::info('User update request', ['user_id' => $userId, 'email' => $email]);
    
    if (!$email || !$name) {
        http_response_code(400);
        Logger::logResponse('/admin/users', 400);
        jsonResponse(['success' => false, 'message' => 'Email and name are required.']);
        return;
    }
    
    try {
        $db = new Database();
        $updates = ['email = ?', 'name = ?'];
        $params = [$email, $name];
        
        if ($fixed_salary !== null) {
            $updates[] = 'fixed_salary = ?';
            $params[] = $fixed_salary;
        }
        
        if ($petrol_allowance !== null) {
            $updates[] = 'petrol_allowance = ?';
            $params[] = $petrol_allowance;
        }
        
        if ($mobile_no !== null) {
            $updates[] = 'mobile_no = ?';
            $params[] = $mobile_no;
        }
        
        $params[] = $userId;
        $db->execute('UPDATE users SET ' . implode(', ', $updates) . ' WHERE id = ?', $params);
        
        // Fetch and return updated user data
        $updatedUser = $db->queryOne(
            'SELECT id, email, name, role, device_uid, is_active, fixed_salary, petrol_allowance, mobile_no, created_at FROM users WHERE id = ?',
            [$userId]
        );
        
        Logger::info('User updated successfully', ['user_id' => $userId]);
        Logger::logResponse('/admin/users', 200);
        jsonResponse(['success' => true, 'message' => 'User updated successfully!', 'data' => $updatedUser]);
        
    } catch (Exception $e) {
        Logger::error('User update failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/users', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * DELETE /admin/users/:id
 * Delete user
 */
function handleAdminUsersDelete($userId) {
    Logger::info('User deletion request', ['user_id' => $userId]);
    
    try {
        $db = new Database();
        $db->execute('DELETE FROM users WHERE id = ?', [$userId]);
        
        Logger::info('User deleted successfully', ['user_id' => $userId]);
        Logger::logResponse('/admin/users', 200);
        jsonResponse(['success' => true, 'message' => 'User deleted successfully!']);
        
    } catch (Exception $e) {
        Logger::error('User deletion failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/users', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * PUT /admin/users/:id/device-uid
 * Set device UID for user
 */
function handleAdminUsersSetDevice($userId, $input) {
    $device_uid = $input['device_uid'] ?? null;
    
    Logger::info('Device UID update request', ['user_id' => $userId]);
    
    if (!$device_uid) {
        http_response_code(400);
        Logger::logResponse('/admin/users', 400);
        jsonResponse(['success' => false, 'message' => 'Device UID is required.']);
        return;
    }
    
    try {
        $db = new Database();
        $db->execute('UPDATE users SET device_uid = ? WHERE id = ?', [$device_uid, $userId]);
        
        // Fetch and return updated user data
        $updatedUser = $db->queryOne(
            'SELECT id, email, name, role, device_uid, is_active, fixed_salary, mobile_no, created_at FROM users WHERE id = ?',
            [$userId]
        );
        
        Logger::info('Device UID updated successfully', ['user_id' => $userId]);
        Logger::logResponse('/admin/users', 200);
        jsonResponse(['success' => true, 'message' => 'Device UID updated successfully!', 'data' => $updatedUser]);
        
    } catch (Exception $e) {
        Logger::error('Device UID update failed', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/admin/users', 500);
        jsonResponse(['success' => false, 'error' => $e->getMessage()]);
    }
}

/**
 * GET /test
 * Health check
 */
function handleTest() {
    Logger::debug('Health check requested');
    
    try {
        $db = new Database();
        if ($db->isConnected()) {
            Logger::logResponse('/test', 200);
            jsonResponse(['server' => 'Online', 'database' => 'Connected', 'version' => '2.0.0']);
        } else {
            Logger::warn('Database not connected');
            http_response_code(500);
            Logger::logResponse('/test', 500);
            jsonResponse(['server' => 'Online', 'database' => 'Error', 'error' => 'Database connection failed']);
        }
    } catch (Exception $e) {
        Logger::error('Health check error', ['error' => $e->getMessage()]);
        http_response_code(500);
        Logger::logResponse('/test', 500);
        jsonResponse(['server' => 'Online', 'database' => 'Error', 'error' => $e->getMessage()]);
    }
}

// ==========================================
// UTILITIES
// ==========================================

/**
 * Send JSON response
 */
function jsonResponse($data) {
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
}

/**
 * Calculate distance between two points using Haversine formula
 * Returns distance in meters
 */
function calculateDistance($lat1, $lon1, $lat2, $lon2) {
    $earthRadius = 6371000; // meters
    $dLat = deg2rad($lat2 - $lat1);
    $dLon = deg2rad($lon2 - $lon1);
    $a = sin($dLat / 2) * sin($dLat / 2) +
         cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
         sin($dLon / 2) * sin($dLon / 2);
    $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    $distance = $earthRadius * $c;
    return round($distance); // Return as integer meters
}

?>
