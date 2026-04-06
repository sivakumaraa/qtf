# QuarryForce Namecheap Stellar - Quick Deployment Checklist

## Pre-Deployment (Local Machine)

### Preparation Phase

- [ ] Run `prepare-deployment.bat` script
  ```
  Right-click → Run as Administrator
  ```
- [ ] Verify `deployment/` folder created with:
  - [ ] `index.js`, `db.js`, `package.json`
  - [ ] `admin/` folder with React build files
  - [ ] `.env.template` file
  - [ ] `admin/.htaccess` file

### Environment Setup

- [ ] Create `deployment/.env` file (copy from `.env.template`)
- [ ] Fill in your Namecheap database credentials:
  - [ ] `DB_HOST`: (provided by Namecheap)
  - [ ] `DB_USER`: (created in next phase)
  - [ ] `DB_PASSWORD`: (created in next phase)
  - [ ] `DB_NAME`: `quarryforce_db`
- [ ] Fill in your domain info:
  - [ ] `API_URL`: `https://api.yourdomain.com`
  - [ ] `FRONTEND_URL`: `https://admin.yourdomain.com`

---

## Phase 1: Namecheap Control Panel Setup

### Access Control Panel

- [ ] Log in to Namecheap.com
- [ ] Go to **Hosting** → Find your Stellar account
- [ ] Click **Manage**
- [ ] Note down your cPanel URL and credentials
- [ ] Save these URLs:
  - [ ] cPanel: `https://________`
  - [ ] Server IP: `________`

### Create Database

- [ ] In cPanel, go to **MySQL Databases**
- [ ] Create new database:
  - [ ] Name: `quarryforce_db`
  - [ ] Note: `quarryforce_db`
- [ ] Create MySQL user:
  - [ ] Username: `quarryforce_user`
  - [ ] Password: (Generate strong password - save it!)
  - [ ] Note: `quarryforce_user` / `_________`
- [ ] Assign user to database with **ALL PRIVILEGES**

### Setup FTP Access

- [ ] In cPanel, go to **FTP Accounts**
- [ ] Create FTP account:
  - [ ] Username: `api_upload` (or your choice)
  - [ ] Password: (Generate strong - save it!)
  - [ ] Home Directory: `/public_html` (default)
  - [ ] Note: `api_upload` / `_________` @ `your-server-ip`

---

## Phase 2: Upload Files via FTP

### Option A: Using FileZilla (Recommended)

- [ ] Download FileZilla from https://filezilla-project.org/
- [ ] Open FileZilla
- [ ] Enter FTP credentials:
  - [ ] Host: `your-server-ip`
  - [ ] Username: `api_upload`
  - [ ] Password: `__________`
  - [ ] Port: `21`
- [ ] Connect

### Upload Backend

- [ ] Navigate to `/public_html` on server (right pane)
- [ ] Create folder: `api`
- [ ] Upload backend files:
  - [ ] Drag `index.js` to `/public_html/api/`
  - [ ] Drag `db.js` to `/public_html/api/`
  - [ ] Drag `package.json` to `/public_html/api/`
  - [ ] Drag `package-lock.json` to `/public_html/api/`
  - [ ] Drag `.env` to `/public_html/api/` (NOT in git!)
  - [ ] Drag `uploads/` folder to `/public_html/api/`
  - [ ] **Don't upload `node_modules/` folder** (server will install it)

### Upload Admin Dashboard

- [ ] In `/public_html`, create folder: `admin`
- [ ] Drag all files from `deployment/admin/` to `/public_html/admin/`
  - [ ] This includes: `index.html`, `manifest.json`, `static/`, `.htaccess`

### Verification

- [ ] Check all files uploaded:
  ```
  /public_html/
  ├── api/
  │   ├── index.js
  │   ├── db.js
  │   ├── package.json
  │   ├── package-lock.json
  │   ├── .env
  │   └── uploads/
  └── admin/
      ├── index.html
      ├── .htaccess
      ├── static/
      └── manifest.json
  ```

---

## Phase 3: Server-Side Configuration

### Install Backend Dependencies (via SSH/Terminal)

- [ ] In cPanel, open **Terminal**
- [ ] Run:
  ```bash
  cd ~/public_html/api
  npm install --production
  ```
- [ ] Wait for completion (2-3 minutes)
- [ ] Verify: `ls -la node_modules | head -10` (should show packages)

### Create Node.js Application in cPanel

- [ ] In cPanel, go to **Node.js Selector** (or Node.js App Manager)
- [ ] Click **Create Application**
- [ ] Configure:
  - [ ] Node.js Version: `18+` (select latest available)
  - [ ] Application Root: `/home/yourusername/public_html/api`
  - [ ] Application URL: `api.yourdomain.com` (or IP:port)
  - [ ] Application Startup File: `index.js`
  - [ ] Application Mode: `production`
  - [ ] **Environment Variables** (click Edit):
    - [ ] `DB_HOST`: (from database info)
    - [ ] `DB_USER`: `quarryforce_user`
    - [ ] `DB_PASSWORD`: (saved earlier)
    - [ ] `DB_NAME`: `quarryforce_db`
    - [ ] `NODE_ENV`: `production`
    - [ ] `API_URL`: `https://api.yourdomain.com`
    - [ ] `FRONTEND_URL`: `https://admin.yourdomain.com`
- [ ] Click **Create Application**
- [ ] Note the assigned port/URL

### Verify Applications Running

- [ ] Check Node.js app status (should show "Running" in cPanel)
- [ ] Open Terminal and test:
  ```bash
  curl http://localhost:XXXX/test
  ```
  Should return API info

---

## Phase 4: DNS & SSL Configuration

### Update DNS Records

- [ ] In Namecheap, go to **Domain List** → Find your domain
- [ ] Click **Manage Domain** → **Advanced DNS**
- [ ] Add/Update A records:
  - [ ] `api` → Your server IP
  - [ ] `admin` → Your server IP
  - [ ] `www` → Your server IP
  - [ ] `@` (root) → Your server IP
- [ ] **DNS Propagation:** Wait up to 24 hours (usually 1-2 hours)

### Enable SSL/TLS certificates

- [ ] In cPanel, go to **AutoSSL**
- [ ] Verify SSL is enabled for all domains
- [ ] Namecheap provides free Let's Encrypt SSL
- [ ] Check status:
  ```bash
  curl https://api.yourdomain.com/test
  ```
  Should work with secure connection

---

## Phase 5: Database Setup

### Import Database Schema

- [ ] In cPanel, go to **phpMyAdmin**
- [ ] Select database `quarryforce_db`
- [ ] Click **Import** tab
- [ ] Upload `TEST_DATA.sql` from your project:
  - [ ] Click **Choose File**
  - [ ] Select from `d:\quarryforce\TEST_DATA.sql`
  - [ ] Click **Go**
- [ ] Wait for import to complete
- [ ] Verify tables created:
  - [ ] Should see: `users`, `customers`, `sales_history`, etc.

### Verify Demo User

- [ ] Still in phpMyAdmin, go to `users` table
- [ ] Look for `demo@quarryforce.local` user
- [ ] If not present, demo login falls back to hardcoded response (still works)

---

## Phase 6: Testing & Verification

### Test API Endpoints

- [ ] Open browser, test:

  ```
  https://api.yourdomain.com/test
  ```

  Should return JSON with API info

- [ ] Test login endpoint:
  ```
  https://api.yourdomain.com/api/login
  ```
  (POST request with demo@quarryforce.local should work)

### Test Admin Dashboard

- [ ] Open in browser:
  ```
  https://admin.yourdomain.com
  ```
- [ ] Should load without errors
- [ ] Try login with credentials:
  - [ ] Email: `demo@quarryforce.local`
  - [ ] Password: (default/demo)
- [ ] Navigate dashboard:
  - [ ] Overview page loads
  - [ ] Customers tab shows data
  - [ ] Rep Details accessible
  - [ ] Analytics displays currency as ₹

### Test Mobile App Integration

- [ ] Update mobile app API URL to production
- [ ] Test mobile app login (if deployed)
- [ ] Verify data syncs correctly

---

## Phase 7: Monitoring & Maintenance

### Regular Checks

- [ ] Weekly: Check cPanel logs for errors
- [ ] Monthly: Update Node.js dependencies
- [ ] Monthly: Review SSL certificate expiration
- [ ] Daily: Monitor uptime

### Common Issues & Solutions

**Admin dashboard shows blank page:**

- [ ] Verify `.htaccess` exists in `/public_html/admin/`
- [ ] Check browser console for 404 errors
- [ ] Rebuild and re-upload React build

**API returns 404:**

- [ ] Verify Node.js app is running in cPanel
- [ ] Check cPanel logs for errors
- [ ] Verify `.env` file has correct database credentials

**Database connection error:**

- [ ] Test DB credentials in cPanel Terminal:
  ```bash
  mysql -h DB_HOST -u quarryforce_user -p -D quarryforce_db
  ```
- [ ] Verify user permissions on database

**SSL certificate error:**

- [ ] Wait 24 hours for DNS propagation
- [ ] Try AutoSSL in cPanel again
- [ ] Check domain is pointing correctly

---

## Post-Deployment Checklist

### Security

- [ ] Password-protect cPanel (2FA)
- [ ] Change FTP password
- [ ] Delete `.env.template` from server (keep only `.env`)
- [ ] Set proper file permissions (644 for files, 755 for folders)

### Backup & Recovery

- [ ] Enable cPanel daily backups
- [ ] Download backup locally weekly
- [ ] Document database credentials securely

### Documentation

- [ ] Save all credentials in password manager:
  - [ ] cPanel login
  - [ ] Database credentials
  - [ ] FTP credentials
  - [ ] Admin account credentials
- [ ] Document any custom configurations
- [ ] Record deployment date and version

### Final Steps

- [ ] Test complete user workflow:
  - [ ] Login → Dashboard → View data → Edit → Save
- [ ] Test on mobile devices
- [ ] Share production URL with stakeholders
- [ ] Set up monitoring/uptime alerts

---

## Quick Reference: Important URLs & Credentials

```
Domain: yourdomain.com

cPanel URL: https://yourdomain.com:2083
cPanel User: _______________
cPanel Pass: _______________

FTP Host: _______________
FTP User: api_upload
FTP Pass: _______________

Database Host: _______________
Database Name: quarryforce_db
Database User: quarryforce_user
Database Pass: _______________

API URL: https://api.yourdomain.com
Admin URL: https://admin.yourdomain.com

Demo Login:
Email: demo@quarryforce.local
Password: (check with team)
```

---

## Support Links

- **Namecheap Help:** https://www.namecheap.com/support/
- **cPanel Docs:** https://docs.cpanel.net/
- **Node.js Docs:** https://nodejs.org/en/docs/
- **MySQL Docs:** https://dev.mysql.com/doc/

---

**Status:** [ ] Ready to Deploy | [ ] Deployed | [ ] Testing | [ ] In Production

**Deployed On:** ******\_\_\_******  
**Deployed By:** ******\_\_\_******  
**Notes:** ******\_\_\_******
