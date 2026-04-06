# Local Deployment Guide - QuarryForce

This guide explains how to run the backend, React admin dashboard, and Flutter web app locally.

## Architecture

```
Backend (Node.js)          → Port 3000
  ↓
React Admin Dashboard      → Port 3001
  ↓
Flutter Web App            → Port 3002
```

## Prerequisites

- **Node.js** (v14+) - For backend and React dashboard
- **Flutter SDK** (with web support enabled)
- **MySQL/MariaDB** - Database (should already be running)

## Setup Instructions

### 1. Backend Server (Node.js) - PORT 3000

```bash
cd d:\quarryforce

# Install dependencies
npm install

# Start the backend server
npm start
# Or: node index.js
```

**Expected Output:**

```
Server running on http://localhost:3000
```

### 2. React Admin Dashboard - PORT 3001

In a **new terminal**:

```bash
cd d:\quarryforce\admin-dashboard

# Install dependencies
npm install

# Start the React development server
npm start
```

**Expected Output:**

```
Compiled successfully!
You can now view quarryforce-admin-dashboard in the browser.

Local:            http://localhost:3001
```

**Access at:** http://localhost:3001

### 3. Flutter Web App - PORT 3002

In a **new terminal**:

```bash
cd d:\quarryforce\quarryforce_mobile

# Build Flutter web
flutter build web

# Run Flutter web dev server
flutter run -d web-server
```

Or use the Chrome browser device:

```bash
flutter run -d chrome
```

**Expected Output:**

```
Running with sound null safety
Flutter web app running at:
http://localhost:3002
```

**Access at:** http://localhost:3002

## Access the Applications

| Service             | URL                     | Purpose                     |
| ------------------- | ----------------------- | --------------------------- |
| **Backend API**     | `http://localhost:3000` | REST API endpoints          |
| **Admin Dashboard** | `http://localhost:3001` | Management interface        |
| **Mobile Web**      | `http://localhost:3002` | Field rep app (web version) |

## API Endpoints

All endpoints are available at:

- `http://localhost:3000/api/login`
- `http://localhost:3000/api/admin/reps`
- `http://localhost:3000/api/admin/customers`
- etc.

## Database Requirements

Make sure your MySQL database is running with:

- Database: `quarryforce` (or your configured name)
- User: Check `.env` file for credentials
- Port: 3306 (default) or configured port

## Troubleshooting

### Port Already in Use

If a port is already in use, you can change it:

**Backend:**

```bash
set PORT=3000 && node index.js  # PowerShell: $env:PORT=3000; node index.js
```

**React:**

```bash
set PORT=3001 && npm start  # PowerShell: $env:PORT=3001; npm start
```

**Flutter Web:**

```bash
flutter run -d web-server --web-port=3002
```

### Dependencies Not Installed

```bash
# Backend
npm install --legacy-peer-deps

# Admin Dashboard
npm install --legacy-peer-deps
```

### Flutter Web Not Available

```bash
flutter channel stable
flutter upgrade
flutter config --enable-web
```

## Development Workflow

1. **Terminal 1:** Backend server (runs continuously)
2. **Terminal 2:** Admin dashboard (auto-reloads on file changes)
3. **Terminal 3:** Flutter web app (auto-reloads with hot reload)

Make changes to any component and save - they'll reload automatically.

## Stop All Services

Press `Ctrl+C` in each terminal to stop the services.

## Next Steps

- Log in with test credentials
- Create reps and customers
- Test the mobile web app
- Monitor API calls in the admin dashboard
