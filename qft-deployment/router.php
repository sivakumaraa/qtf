<?php
/**
 * Router for PHP Built-in Server
 * Handles routing for the development server
 */

// Get the requested URI
$requested_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Remove leading slash for file checking
$file = __DIR__ . $requested_uri;

// If requesting a real file or directory, serve it
if (file_exists($file) && is_file($file)) {
    return false; // Serve the file directly
}

// If it's an API request or admin request, route to api.php
if (strpos($requested_uri, '/api/') === 0 || 
    strpos($requested_uri, '/admin/') === 0 || 
    $requested_uri === '/api' ||
    $requested_uri === '/admin') {
    require __DIR__ . '/api.php';
    return true;
}

// Otherwise route to index.php (for admin dashboard)
if ($requested_uri === '/' || $requested_uri === '' || strpos($requested_uri, '/admin') === 0) {
    require __DIR__ . '/index.php';
    return true;
}

// If nothing matches, let the server handle the 404
return false;
?>
