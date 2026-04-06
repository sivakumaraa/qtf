<?php
/**
 * QuarryForce PHP Backend Entry Point
 * 
 * This is the main entry point for all requests
 * Routes to api.php for API handling
 * Serves React admin dashboard from admin/ folder
 */

require_once __DIR__ . '/config.php';

// Get request path
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$base_path = '/qft';

// Remove base path
$route = str_replace($base_path, '', $path);
$route = '/' . ltrim($route, '/');

// ==========================================
// ROUTING LOGIC
// ==========================================

// API routes - pass to api.php
if (strpos($route, '/api') === 0 || strpos($route, '/admin') === 0) {
    $_SERVER['REQUEST_URI'] = $route;
    require_once __DIR__ . '/api.php';
} 
// Root route - show admin dashboard
elseif ($route === '/' || $route === '' || $route === '/index.html') {
    header('Content-Type: text/html; charset=utf-8');
    require_once __DIR__ . '/admin/index.html';
}
// Static files (CSS, JS, etc)
else {
    $file = __DIR__ . str_replace('..', '', $route);
    
    if (file_exists($file) && is_file($file)) {
        // Serve static file
        $ext = pathinfo($file, PATHINFO_EXTENSION);
        $mimeTypes = [
            'css' => 'text/css',
            'js' => 'text/javascript',
            'json' => 'application/json',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'svg' => 'image/svg+xml',
            'ico' => 'image/x-icon',
            'woff' => 'font/woff',
            'woff2' => 'font/woff2',
            'ttf' => 'font/ttf'
        ];
        
        if (isset($mimeTypes[$ext])) {
            header('Content-Type: ' . $mimeTypes[$ext]);
        }
        
        readfile($file);
    } else {
        // Let .htaccess handle 404 routing if it exists, otherwise return 404
        http_response_code(404);
        header('Content-Type: application/json');
        echo json_encode(['error' => 'Not found']);
    }
}

?>
