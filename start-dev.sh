#!/bin/bash
# QuarryForce Local Development Startup Script (Linux/macOS)
# Starts PHP backend and React admin dashboard

echo ""
echo "===================================================="
echo "  QuarryForce Local Development Environment"
echo "===================================================="
echo ""

# Check if npm is installed (needed for React admin-dashboard only)
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm is not installed (required for React admin-dashboard)"
    echo "Please install Node.js (which includes npm) from https://nodejs.org/"
    exit 1
fi

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "ERROR: PHP is not installed"
    echo "Please install PHP from https://www.php.net/downloads"
    exit 1
fi

echo "[✓] npm and PHP are installed"
echo ""

# Get the root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install admin dashboard dependencies
if [ ! -d "$ROOT_DIR/admin-dashboard/node_modules" ]; then
    echo "[1/3] Installing admin-dashboard dependencies..."
    cd "$ROOT_DIR/admin-dashboard"
    npm install
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install admin-dashboard dependencies"
        exit 1
    fi
    echo "[✓] Admin dashboard dependencies installed"
    echo ""
fi

echo "[2/3] Checking PHP backend configuration..."
if [ ! -f "$ROOT_DIR/qft-deployment/.env" ]; then
    echo "WARNING: .env not found in qft-deployment"
    echo "Creating a default .env file..."
    cat > "$ROOT_DIR/qft-deployment/.env" << EOF
DB_HOST=localhost
DB_USER=root
DB_PASS=password
DB_NAME=quarryforce_db
EOF
    echo "[✓] Created .env with default settings"
    echo "Please update the database credentials in qft-deployment/.env"
fi
echo ""

echo "[3/3] Starting development servers..."
echo ""
echo "===================================================="
echo "  Starting PHP Backend Server (Port 8000)"
echo "===================================================="
echo "Backend: http://localhost:8000"
echo "API: http://localhost:8000/api/"
echo ""

# Start PHP built-in server in background
cd "$ROOT_DIR/qft-deployment"
php -S localhost:8000 &
PHP_PID=$!

# Wait for backend to start
sleep 2

echo ""
echo "===================================================="
echo "  Starting Admin Dashboard (React)"
echo "===================================================="
echo "Dashboard: http://localhost:3000"
echo ""

# Start React development server (foreground)
cd "$ROOT_DIR/admin-dashboard"
npm start

# Cleanup - kill PHP server when React exits
kill $PHP_PID 2>/dev/null

echo ""
echo "Development environment stopped."

