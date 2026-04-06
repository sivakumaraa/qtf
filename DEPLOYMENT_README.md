# QuarryForce Namecheap Stellar Deployment - Complete Package

## 📋 What's Included

You now have everything needed to deploy QuarryForce to Namecheap Stellar shared hosting:

### Documentation Files Created

1. **DEPLOYMENT_QUICKSTART.md** ⭐ **START HERE**
   - 5-minute overview
   - Step-by-step instructions
   - Troubleshooting guide
   - Estimated: 1-2 hours total

2. **NAMECHEAP_STELLAR_DEPLOYMENT.md**
   - Detailed technical guide
   - All phases explained
   - Database migration
   - Advanced configuration

3. **DEPLOYMENT_CHECKLIST.md**
   - Checkbox format
   - Don't-forget items
   - Credential storage template
   - Common issues solutions

### Automation Scripts

4. **prepare-deployment.bat** (Windows)
   - Builds React dashboard
   - Packages all files
   - Creates `.env.template`
   - **Run this first locally**

5. **prepare-deployment.sh** (Linux/Mac)
   - Same as .bat for Unix systems

---

## 🚀 Quick Start (5 Steps)

### 1. Prepare Your Files

```
Windows: Double-click prepare-deployment.bat
Builds: admin-dashboard/
Creates: deployment/ folder (ready to upload)
Time: 5 minutes
```

### 2. Create Database & FTP Access

```
Login: Namecheap.com → Your Hosting Section
Create: MySQL database (quarryforce_db)
Create: Database user (quarryforce_user)
Create: FTP account (deploy)
Time: 10 minutes
```

### 3. Upload Files

```
Tool: FileZilla (free FTP client)
Upload: deployment/ folder contents to /public_html/
Add: Create .env file with your credentials
Time: 10 minutes
```

### 4. Configure Server

```
cPanel: Node.js Selector → Create App
- Root: /public_html
- Startup: index.js
- Environment vars: (from .env)
Time: 15 minutes
```

### 5. Test & Deploy

```
Browser: https://perspectivetechnology.in
Login: demo@quarryforce.local
Verify: All pages load correctly
Time: 10 minutes
```

**Total Time: 1-2 hours**

---

## 📂 Your Project Structure

```
d:\quarryforce\
├── DEPLOYMENT_QUICKSTART.md         👈 Read this first
├── NAMECHEAP_STELLAR_DEPLOYMENT.md  (Detailed reference)
├── DEPLOYMENT_CHECKLIST.md          (Verification items)
├── prepare-deployment.bat           (Run this to prepare)
│
├── admin-dashboard/
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── build/                       (Created by prepare-deployment.bat)
│
├── index.js                         (Backend API)
├── db.js                            (Database config)
├── package.json                     (Dependencies)
│
└── deployment/                      (Created by prepare-deployment.bat)
    ├── index.js                     (Backend API at root)
    ├── db.js
    ├── package.json
    ├── .env.template
    ├── .htaccess                    (Routes /api to Node.js)
    ├── admin/                       (React build served as static files)
    └── uploads/
```

---

## ✅ Pre-Deployment Checklist

Before you start, ensure you have:

- [ ] **Namecheap Account** - Active and logged in
- [ ] **Stellar Hosting** - Purchased and active
- [ ] **Domain Registered** - At Namecheap (or pointing there)
- [ ] **FTP Client** - FileZilla installed (https://filezilla-project.org/)
- [ ] **Text Editor** - For .env file (Notepad is fine)
- [ ] **Command Prompt** - For running prepare-deployment.bat
- [ ] **Credentials Ready:**
  - [ ] Namecheap login
  - [ ] cPanel access info
  - [ ] Your domain name
  - [ ] Server IP address

---

## 📝 What Gets Deployed

### Backend API (Node.js)

- **Location:** `https://perspectivetechnology.in/api/*`
- **Port:** 3000
- **Root:** `/public_html` (main domain)
- **Files:** `index.js`, `db.js`, `package.json`
- **Database:** MySQL 8.0+ (Namecheap managed)
- **Features:**
  - Login endpoint
  - Customer management
  - Sales recording
  - Rep targets & progress
  - Analytics data

### Admin Dashboard (React)

- **Location:** `https://perspectivetechnology.in/qft` (main domain + /qft folder)
- **Port:** Served by Node.js as static files from `/qft/admin`
- **Files:** React production build in `/qft/admin/` folder
- **Features:**
  - User management
  - Customer management
  - Sales recording
  - Analytics & reports
  - Rep details & photos
  - Targets management

### Database (MySQL)

- **Database:** `quarryforce_db`
- **Tables:**
  - `users` (reps & admin)
  - `customers` (sites)
  - `sales_history` (transactions)
  - `rep_targets` (goals)
  - `visits` (field visits)
  - `repairs` (maintenance)
  - `fuel_logs` (expenses)

---

## 🔐 Security Notes

### Before Starting

1. Change default passwords
2. Use strong credentials for DB & FTP
3. Keep `.env` file secret (never in git)
4. Enable 2FA on Namecheap account

### After Deployment

1. Delete `.env.template` from server
2. Set file permissions correctly (644 files, 755 folders)
3. Enable cPanel firewall
4. Setup automated backups
5. Monitor access logs

---

```
Main Domain:      https://perspectivetechnology.in/qft
API Endpoint:     https://perspectivetechnology.in/qft/api/*
cPanel Login:     https://perspectivetechnology.in:2083
SSH Access:       ssh deploy@perspectivetechnology.incom
API Endpoint:     https://api.yourdomain.com
cPanel Login:     https://yourdomain.com:2083
SSH Access:       ssh deploy@yourdomain.com

Demo Credentials:
Email:     demo@quarryforce.local
Password:  (any - demo mode active)
```

---

## 📞 Support & Resources

### Quick Help

- **Namecheap Support:** https://www.namecheap.com/support/
- **cPanel Tutorials:** https://docs.cpanel.net/
- **Node.js Docs:** https://nodejs.org/docs/

### If You Get Stuck

1. Check **DEPLOYMENT_CHECKLIST.md** "Troubleshooting" section
2. Review **NAMECHEAP_STELLAR_DEPLOYMENT.md** Phase 11
3. Check cPanel logs for error messages
4. Contact Namecheap support with error details

---

## 📅 Recommended Timeline

| Day               | Action                          |
| ----------------- | ------------------------------- |
| Day 1 - Morning   | Read DEPLOYMENT_QUICKSTART.md   |
| Day 1 - Afternoon | Run prepare-deployment.bat      |
| Day 1 - Evening   | Create database & FTP in cPanel |
| Day 2 - Morning   | Upload files via FTP            |
| Day 2 - Midday    | Configure Node.js in cPanel     |
| Day 2 - Afternoon | Setup DNS & SSL                 |
| Day 3 - Morning   | Test after DNS propagates (24h) |
| Day 3 - Afternoon | Final verification & go live    |

---

## ⚡ Quick Commands Reference

### Prepare Locally (Windows)

```batch
cd d:\quarryforce
prepare-deployment.bat
```

### Check Backend via SSH

```bash
cd ~/public_html/api
npm install --production
curl http://localhost/test
```

### Test Database Connection

```bash
mysql -h localhost -u quarryforce_user -p quarryforce_db
```

### View Application Logs

```bash
tail -f ~/public_html/api/logs.txt
```

---

## 🎯 Success Criteria

Your deployment is successful when:

- [ ] Dashboard loads at `https://perspectivetechnology.in/qft`
- [ ] Can login with demo@quarryforce.local
- [ ] Dashboard shows customer data
- [ ] Currency displays as ₹ (rupees)
- [ ] API responds at `https://perspectivetechnology.in/qft/api/settings`
- [ ] Database has all tables imported
- [ ] Photos upload/display in rep details
- [ ] SSL certificate valid (no security warnings)
- [ ] Mobile app can reach backend API at `https://perspectivetechnology.in`

---

## 📊 File Sizes Reference

When uploading via FTP, expect:

```
Backend files:       ~100 KB (without node_modules)
Admin dashboard:     ~3-4 MB (React build)
node_modules:        ~500 MB (installed on server, not uploaded)
Database SQL:        ~5-10 KB
Total upload:        ~4 MB (very manageable)
```

---

## 🔄 Post-Deployment Workflow

### Daily Tasks

- Monitor error logs (if any)
- Test API endpoints
- Verify admin dashboard accessibility

### Weekly Tasks

- Download backup from cPanel
- Review user activity logs
- Check disk space usage

### Monthly Tasks

- Update Node.js packages: `npm update`
- Review security logs
- Test backup restoration

### Annual Tasks

- Review and optimize database
- Update SSL certificates (auto-renews)
- Audit user accounts

---

## 📚 Document Guide

Choose which document to read based on your need:

| Document                            | When to Read                     | Length         |
| ----------------------------------- | -------------------------------- | -------------- |
| **DEPLOYMENT_QUICKSTART.md**        | First thing, or need quick steps | 5-10 min read  |
| **NAMECHEAP_STELLAR_DEPLOYMENT.md** | Need detailed explanation        | 20-30 min read |
| **DEPLOYMENT_CHECKLIST.md**         | During deployment, verification  | 30-60 min use  |

---

## 🚨 Common Issues & Quick Fixes

### Admin dashboard blank

- Check `.htaccess` exists in admin folder
- Rebuild React: `npm run build` locally
- Re-upload build files

### API 404 errors

- Verify Node.js app is running in cPanel
- Check `.env` has correct DB credentials
- Restart app from cPanel

### Database connection fails

- Test credentials with MySQL client
- Verify DB user has all privileges
- Check DB host is correct (localhost or hostname)

### DNS not resolving

- Wait up to 24 hours for propagation
- Check Namecheap Advanced DNS settings
- Flush DNS: `ipconfig /flushdns` (Windows)

---

## ✨ You're All Set!

Everything you need is prepared. Next step:

👉 **Read DEPLOYMENT_QUICKSTART.md** and follow the 5-step process.

Estimated total time: **1-2 hours** from start to go-live.

---

**Questions?** Check the detailed guides or contact Namecheap support.

**Ready?** Let's deploy! 🚀
