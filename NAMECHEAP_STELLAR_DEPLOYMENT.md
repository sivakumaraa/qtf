# QuarryForce Deployment to Namecheap Stellar Shared Hosting

## Overview

This guide helps you deploy the complete QuarryForce application (Backend API, Admin Dashboard, and Database) to Namecheap Stellar shared hosting.

**Your Setup:**

- Hosting: Namecheap Stellar (Shared Hosting)
- Domain: Registered at Namecheap ✅
- Components: Full stack (Backend + Dashboard + Database)

---

## Phase 1: Preparation (Local)

### Step 1: Prepare Production Environment Files

Create a `.env.production` file in the backend root:

```env
NODE_ENV=production
PORT=3000
DB_HOST=localhost
DB_USER=quarryforce_user
DB_PASSWORD=your_db_password
DB_NAME=quarryforce_db
DB_PORT=3306
API_URL=https://perspectivetechnology.in/qft
FRONTEND_URL=https://perspectivetechnology.in/qft
```

### Step 2: Build Admin Dashboard

```bash
cd d:\quarryforce\admin-dashboard
npm run build
```

This creates an optimized production build in the `build/` folder.

### Step 3: Prepare Backend for Production

Ensure `d:\quarryforce\package.json` has proper start script:

```json
{
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  }
}
```

---

## Phase 2: Namecheap Control Panel Setup

### Step 1: Access Your Hosting Control Panel

1. Log in to [Namecheap.com](https://namecheap.com)
2. Go to **Dashboard** → **Hosting**
3. Click **Manage** next to your Stellar account

### Step 2: Access cPanel

In the hosting control panel:

- Click **cPanel Login** (or direct link provided)
- Save cPanel URL: `https://your-ip:2083` or `https://your-domain:2083`

### Step 3: Create MySQL Database

In cPanel:

1. **MySQL Databases**
   - Database name: `quarryforce_db`
   - Username: `quarryforce_user`
   - Password: (Generate strong password)
   - Click **Create Database**

2. **Add User to Database**
   - Select user and database
   - Grant **ALL PRIVILEGES**

**Save credentials** - you'll need these for `.env`

### Step 4: Setup File Manager Access

In cPanel:

- **File Manager** → **Home Directory**
- You'll upload files here

---

## Phase 3: Upload Backend API

### Option A: Using FTP/SFTP (Recommended)

1. **Get FTP Credentials from cPanel:**
   - In cPanel → **FTP Accounts**
   - Create account: `deploy_user`
   - Home directory: `/public_html`

2. **Using Windows File Explorer (SFTP):**

   ```
   sftp://ftp-username:password@your-server-ip
   ```

   Or use [FileZilla](https://filezilla-project.org/) (free)

3. **Upload Backend & Frontend Files:**

   Create this folder structure in `/public_html`:

   ```
   /public_html/
   ├── node_modules/           (installed by npm install)
   ├── admin/                  (React dashboard - static files)
   │   ├── index.html
   │   ├── static/
   │   └── ...
   ├── uploads/                (for file uploads)
   ├── index.js                (Node.js backend entry)
   ├── db.js                   (Database config)
   ├── package.json
   ├── package-lock.json
   ├── .env                    (Production credentials)
   └── .htaccess               (Routing configuration)
   ```

4. **Upload steps:**
   - Connect via FTP to **public_html**
   - Upload all files from `deployment/` folder
   - Do NOT upload `node_modules` (install on server)
   - Upload `.env` with production credentials

### Option B: Using cPanel File Manager

1. Go to **File Manager** in cPanel
2. Navigate to `public_html`
3. Create folder: `api`
4. Upload zip file with backend code
5. Extract zip in `api` folder

---

## Phase 4: Install Node.js Dependencies on Server

### Step 1: Connect via SSH/Terminal

In cPanel → **Terminal** or use SSH:

```bash
ssh your-username@your-server-ip
cd ~/public_html
```

### Step 2: Install Dependencies

```bash
npm install --production
```

This installs only production packages (faster).

### Step 3: Verify Installation

```bash
ls -la node_modules
node -v
npm -v
```

---

## Phase 5: Setup Node.js Application Runner

Namecheap Stellar requires using **Node.js Application Manager** in cPanel:

### Step 1: In cPanel → Node.js Selector (or Node.js App Manager)

1. **Create Application:**
   - **Node.js Version:** 18 or higher
   - **Application Root:** `/home/yourusername/public_html`
   - **Application Startup File:** `index.js`

2. **Environment Variables:**
   - Application reads from `.env` file automatically
   - Ensure `.env` is uploaded with correct credentials

3. **Click Create**

4. **Verify Status:**
   - Should show "Running" status after 1-2 minutes
   - Check logs if there are issues
     DB_HOST=your-host
     DB_USER=your-user
     DB_PASSWORD=your-password
     DB_NAME=quarryforce_db
     NODE_ENV=production

     ```

     ```

5. **Click "Create Application"**

The system will:

- Start your Node.js app
- Create reverse proxy
- Assign a port (usually 3000+)

### Step 2: Verify Application is Running

```bash
curl http://localhost:8000/test
```

Should return welcome message with API info.

---

## Phase 6: Deploy Admin Dashboard

### Step 1: Upload Built Dashboard

The React build is already optimized in `admin-dashboard/build/`

Upload to `/public_html/admin/`

**Steps:**

1. Via FTP: Upload entire `build/` folder contents to `/public_html/admin`
2. Via cPanel File Manager: Same as above
3. Directory structure should be:
   ```
   /public_html/admin/
   ├── index.html
   ├── manifest.json
   ├── static/
   ├── favicon.ico
   └── ...
   ```

### Step 2: Configure Routing (.htaccess)

The `.htaccess` file is already included in your `deployment/` folder. It's placed at `/public_html/`

This configures:

- API routes (`/api/*`) → Handled by Node.js
- React routes → Served from `/admin/index.html`
- Static files served as-is

**No additional setup needed** - the `.htaccess` handles routing automatically.

---

## Phase 7: Setup DNS & SSL

### Step 1: Point Domain to Namecheap (If needed)

If your domain is already at Namecheap:

In Namecheap Control Panel → **Domain List** → **Manage Domain**:

1. **Nameservers:** (Usually already set)
   - NS1.NAMECHEAPHOSTING.COM
   - NS2.NAMECHEAPHOSTING.COM

2. **Advanced DNS:** Setup main domain A record:
   ```
   @    A Record  → Your server IP
   www  A Record  → Your server IP
   ```

### Step 2: Enable SSL Certificate

In cPanel:

- **AutoSSL** → Enable for main domain
- Namecheap includes free SSL (Let's Encrypt)

Both `perspectivetechnology.in` and `www.perspectivetechnology.in` should work with HTTPS.

---

## Phase 8: Test Application

Verify in browser:

- `https://perspectivetechnology.in` → Dashboard loads
- `https://perspectivetechnology.in/api/settings` → API responds with JSON

---

## Phase 8: Testing the Application

### Step 1: Dashboard API URL

The dashboard is already configured to use `https://perspectivetechnology.in` in the production build (updated in `admin-dashboard/src/config/constants.js`)

This was pre-configured during the build process.

### Step 2: Backend CORS

In backend `index.js`, CORS is already configured to accept requests from:

- Same origin (https://perspectivetechnology.in)
- Localhost for testing

No additional configuration needed.

---

## Phase 9: Testing the Application

Restart Node.js app from cPanel.

---

## Phase 9: Database Migration

### Step 1: Import Database Schema

Get SQL files from your project:

- `TEST_DATA.sql`
- `REP_TARGETS_SETUP.sql`

In cPanel → **phpMyAdmin**:

1. Select database `quarryforce_db`
2. Click **Import**
3. Upload each SQL file
4. Click **Go**

### Step 2: Verify Tables Created

```
Tables should include:
- users
- customers
- sales_history
- rep_targets
- visits
- repairs
- fuel_logs
```

---

## Phase 10: Testing & Verification

### Test Backend API

```bash
curl https://perspectivetechnology.in/api/settings
```

Should return:

```json
{
  "success": true,
  "data": [...]
}
```

### Test Login Endpoint

```bash
curl https://perspectivetechnology.in/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@quarryforce.local","password":"demo"}'
```

Should return auth token.

### Test Admin Dashboard

Open in browser:

```
https://perspectivetechnology.in
```

## Should load with QuarryForce dashboard (or login page), try login with demo credentials.

## Phase 9: Database Migration

---

## Phase 11: Monitor & Troubleshoot

### Check Application Logs

In cPanel:

1. **Node.js App Manager** → Click app name
2. **Logs** tab shows real-time output
3. Check for errors

### Common Issues

**404 Error on Dashboard:**

- Ensure `.htaccess` is in `/public_html/admin/`
- Rebuild React: `npm run build`
- Redeploy `build/` folder

**API Connection Failed:**

- Check CORS settings in backend
- Verify API URL in dashboard config
- Check Node.js app is running in cPanel

**Database Connection Failed:**

- Verify credentials in `.env`
- Check DB host is correct
- Test DB connection from cPanel Terminal:
  ```bash
  mysql -h db-host -u db-user -p db-name
  ```

**SSL Certificate Issues:**

- Wait 24 hours for DNS propagation
- Run AutoSSL again from cPanel
- Check `https://sslchecker.com`

---

## Phase 12: Production Checklist

- [ ] Domain registered at Namecheap
- [ ] Stellar hosting account created
- [ ] cPanel access working
- [ ] MySQL database created with credentials
- [ ] Backend uploaded to `/api` folder
- [ ] Admin dashboard uploaded to `/admin` folder
- [ ] Node.js app created in cPanel
- [ ] `.env` file configured with production values
- [ ] DNS records pointing to Namecheap servers
- [ ] SSL/TLS enabled for both subdomains
- [ ] Tested API endpoints respond correctly
- [ ] Admin dashboard loads successfully
- [ ] Database imported with schema
- [ ] Demo user can login (demo@quarryforce.local)

---

## Post-Deployment

### Regular Maintenance

```bash
# Monitor logs regularly
# Update packages monthly
npm audit
npm update

# Backup database weekly
# Check SSL expiration
```

### Mobile App Update

In mobile app, update API base URL:

`lib/services/api_client.dart`:

```dart
const String baseUrl = 'https://perspectivetechnology.in';
```

Rebuild and deploy mobile app.

---

## Support Resources

- **Namecheap Stellar Docs:** https://www.namecheap.com/support/knowledgebase/
- **Node.js on Shared Hosting:** https://www.namecheap.com/hosting/nodejs-hosting/
- **cPanel Tutorials:** https://docs.cpanel.net/
- **MySQL Management:** https://dev.mysql.com/doc/

---

## Next Steps After Deployment

1. **Set up monitoring** for uptime
2. **Configure email** for system notifications
3. **Setup automated backups** in cPanel
4. **Create admin user** account for production
5. **Enable two-factor authentication** for cPanel
6. **Document access credentials** securely
7. **Monitor usage** - CPU, bandwidth, disk space

---

Need help with specific steps? Let me know! 🚀
