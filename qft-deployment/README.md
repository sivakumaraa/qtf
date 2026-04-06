================================================================================
QUARRYFORCE DEPLOYMENT PACKAGE - README
================================================================================

🚀 QUICK START

This folder contains everything you need to deploy QuarryForce to your server.

STEPS:

1. Run: npm install (in this folder)
2. Create .env file from .env.template with your database credentials
3. ZIP this entire folder as qft-deployment.zip
4. Upload to cPanel public_html/
5. Extract and reorganize into /qft/ folder
6. Restart Node.js app
7. Test at https://valviyal.com/qft

For detailed instructions, see DEPLOYMENT_CHECKLIST.md

================================================================================
📦 WHAT'S INCLUDED
================================================================================

BACKEND FILES:
✓ index.js - Main Node.js Express server (all API endpoints)
✓ db.js - MySQL database connection pool
✓ package.json - Node.js dependencies list

FRONTEND FILES:
✓ admin/ - Pre-built React admin dashboard (production build)
✓ static/js/ - Minified JavaScript bundles
✓ static/css/ - Compiled CSS stylesheets
✓ index.html - React app entry point

CONFIGURATION FILES:
✓ .env.template - Environment variables template
✓ .env - Environment variables (CREATE THIS - see section below)
✓ .htaccess - Apache routing rules

DIRECTORY FOR UPLOADS:
✓ uploads/ - File upload destination (empty, will populate at runtime)

DOCUMENTATION:
✓ DEPLOYMENT_FOLDER_STRUCTURE.txt - File structure overview
✓ DEPLOYMENT_CHECKLIST.md - Step-by-step deployment guide (YOU ARE HERE)
✓ README.md - This file

================================================================================
⚙️ CRITICAL: CREATE .ENV FILE BEFORE DEPLOYING
================================================================================

This folder includes .env.template which is a TEMPLATE ONLY.
You MUST create a .env file with your actual credentials.

STEPS:

1. Open .env.template in a text editor
2. Copy all content
3. Create new file called ".env" in this folder
4. Paste the content
5. Update these values with YOUR actual credentials:

   NODE_ENV=production
   PORT=3000
   DB_HOST=localhost (or your database server)
   DB_USER=quarryforce_user (or actual username)
   DB_PASSWORD=your_actual_password_here ← CHANGE THIS!
   DB_NAME=quarryforce_db
   DB_PORT=3306
   API_URL=https://valviyal.com/qft
   FRONTEND_URL=https://valviyal.com/qft

6. Save the file
7. Keep .env secure - DO NOT COMMIT to Git!

================================================================================
📋 BEFORE UPLOADING - CHECKLIST
================================================================================

Before creating ZIP and uploading to server, verify:

[ ] .env file created with your database credentials
[ ] DO NOT run npm install - CloudLinux will manage dependencies
[ ] index.js file exists
[ ] admin/index.html exists
[ ] admin/static/js/ folder has .js files
[ ] admin/static/css/ folder has .css files
[ ] uploads/ folder exists (empty is okay)
[ ] .htaccess file exists
[ ] package.json has all required dependencies listed

If any are missing, STOP and check DEPLOYMENT_FOLDER_STRUCTURE.txt

================================================================================
🚀 DEPLOYMENT STEPS (SUMMARY)
================================================================================

STEP 1 - PREPARE (Local Machine):
$ cd d:\quarryforce\qft-deployment
$ npm install
$ [Create .env file with real credentials]
$ [ZIP the folder as qft-deployment.zip]

STEP 2 - UPLOAD (cPanel):

- Login to cPanel
- File Manager > public_html
- Upload qft-deployment.zip
- Wait for upload to complete (5-10 min)

STEP 3 - EXTRACT (cPanel):

- Right-click qft-deployment.zip
- Select Extract
- Result: /public_html/qft-deployment/ created

STEP 4 - REORGANIZE (cPanel):

- Open qft-deployment folder
- Cut ALL files (Ctrl+A, then Cut)
- Go back to public_html
- Create new folder: qft
- Paste all files INTO qft folder
- Delete empty qft-deployment folder

STEP 5 - RESTART (cPanel Node.js Selector):

- Find your application
- Click RESTART button
- Wait 1-2 minutes

STEP 6 - TEST:

- Open https://valviyal.com/qft/
- Should load QuarryForce dashboard
- Test API: https://valviyal.com/qft/api/settings

================================================================================
📊 API ENDPOINTS INCLUDED
================================================================================

Once deployed, these endpoints will be available:

AUTH:
POST /api/login - Mobile app login
POST /api/checkin - GPS-based check-in

MOBILE APP:
POST /api/visit/submit - Record customer visit
POST /api/fuel/submit - Log fuel consumption

ADMIN DASHBOARD:
GET /api/admin/reps - List all sales reps
GET /api/admin/customers - List all customers

REP TARGETS:
GET /api/admin/rep-targets - Get all targets
POST /api/admin/rep-targets - Create target
PUT /api/admin/rep-targets/:id - Update target

SALES PROGRESS:
GET /api/admin/rep-progress/:rep_id - Get rep's sales progress
POST /api/admin/rep-progress/update - Record sales

USER MANAGEMENT:
GET /api/admin/users - List all users
POST /api/admin/users - Create user
PUT /api/admin/users/:id - Update user
DELETE /api/admin/users/:id - Delete user

For full API documentation, see API_DOCUMENTATION.md

================================================================================
🔧 CONFIGURATION OPTIONS
================================================================================

In your .env file, you can also set:

LOGGING_ENABLED=true/false - Enable/disable request logging

All options with full documentation are in .env.template

================================================================================
🐛 COMMON ISSUES & SOLUTIONS
================================================================================

❌ "Cannot find module 'mysql2'"
✓ Solution: Run npm install on server (node_modules not included in ZIP)

❌ "Database connection failed"
✓ Solution: Check .env has correct DB_PASSWORD and DB_HOST

❌ "404 on /qft/\* pages"
✓ Solution: Check .htaccess is in /public_html/qft/
✓ Solution: Make sure mod_rewrite is enabled

❌ "Blank admin page"
✓ Solution: Check admin/index.html exists
✓ Solution: Check browser console (F12) for JavaScript errors
✓ Solution: Hard refresh (Ctrl+F5)

❌ "Application crashes after 5 min"
✓ Solution: Database connection timing out
✓ Solution: Check MySQL server is running

For more troubleshooting, see DEPLOYMENT_CHECKLIST.md section 5

================================================================================
📚 RELATED DOCUMENTS
================================================================================

In the main quarryforce folder, see:

• SYSTEM_ARCHITECTURE_GUIDE.md - Full system architecture
• API_DOCUMENTATION.md - Complete API reference
• DEPLOYMENT_ARCHITECTURE.md - Deployment design & planning
• DATABASE_SCHEMA.sql - Database structure (if available)
• PHASE_2_MOBILE_APP_PLAN.md - Mobile app architecture
• SALES_HISTORY_USER_GUIDE.md - Feature documentation

================================================================================
✅ DEPLOYMENT VERIFICATION
================================================================================

After deployment, verify these to confirm success:

1. Application loads: https://valviyal.com/qft/
2. API responds: https://valviyal.com/qft/api/settings
3. Admin dashboard: https://valviyal.com/qft/admin/
4. Root route returns welcome message: https://valviyal.com/qft/
5. No console errors (F12 Developer Tools)
6. No "Cannot GET" errors
7. Database connection successful (if DB is configured)

If all pass, deployment is successful! ✅

================================================================================
❓ SUPPORT & HELP
================================================================================

Before contacting support, check:

1. Read DEPLOYMENT_CHECKLIST.md completely
2. Check troubleshooting section below in this file
3. Check .env file has correct credentials
4. Check all files exist in /qft/ folder
5. Check Node.js app status in cPanel

Then contact: support@valviyal.com

Mention:

- Date/time of deployment
- Any error messages
- Steps already tried
- Current URL

================================================================================
🎯 NEXT STEPS AFTER DEPLOYMENT
================================================================================

1. Configure database if not already done
   - Create required tables
   - Load initial users/customers/targets
   - See SYSTEM_ARCHITECTURE_GUIDE.md for SQL

2. Test with mobile app
   - Login with demo@quarryforce.local
   - Verify data syncs correctly
   - Test all core features

3. Create admin users
   - Create admin dashboard accounts
   - Set rep targets and sales data
   - Configure system settings

4. Monitor performance
   - Check logs regularly
   - Monitor database queries
   - Watch for errors in Node.js output

5. Plan Phase 2 features
   - See PHASE_2_MOBILE_APP_PLAN.md
   - Plan additional features
   - Schedule development

================================================================================
📝 VERSION INFO
================================================================================

Deployment Package Version: 1.0.0
Created: March 2025
Server: Namecheap (cPanel)
Domain: valviyal.com
Path: /home/brutsaxr/public_html/qft

Backend: Node.js + Express 4.18
Database: MySQL 8.0
Frontend: React (production build)
API: RESTful with JSON responses

================================================================================

Good luck with your deployment! 🚀

For questions or issues, refer to DEPLOYMENT_CHECKLIST.md or contact support.

================================================================================
