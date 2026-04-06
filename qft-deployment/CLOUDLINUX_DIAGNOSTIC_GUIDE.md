================================================================================
CLOUDLINUX NODE.JS SELECTOR - DIAGNOSTIC & FIX GUIDE
================================================================================

⚠️ "Cannot GET /qft/" means the app is NOT responding correctly
Status shows "Running" but app is likely CRASHING on startup

This guide will help you diagnose and fix the issue.

================================================================================
STEP 1: CHECK NODE.JS SELECTOR LOGS (CRITICAL!)
================================================================================

[ ] In cPanel, open Node.js Selector
[ ] Find your app: /home/brutsaxr/public_html/qft
[ ] Look for "View Logs" or "Logs" button
[ ] Click it to see application output

LOOK FOR ERRORS LIKE:
❌ "PHP Parse error in api.php"
❌ "Database connection failed"
❌ "ENOENT: no such file or directory, open '.env'"
❌ "Error: connect ECONNREFUSED" (database error)
❌ "Unable to connect to MySQL server"

COMMON ERRORS & FIXES:

If you see: "PHP Parse error" in logs
→ Syntax error in api.php
→ Check API_DOCUMENTATION.md for correct syntax
→ Verify api.php uses proper PHP syntax

If you see: "Cannot find .env"
→ .env file is missing in qft-deployment folder
→ Create .env with database credentials
→ Required fields: DB_HOST, DB_USER, DB_NAME, DB_PASSWORD
→ See Configuration section below

If you see: "SQLSTATE[HY000]: General error"
→ Database connection failure
→ Check MySQL is running
→ Check .env credentials match MySQL setup
→ Verify database exists: quarryforce_db

================================================================================
STEP 2: QUICK TEST - IS THE APP REALLY RUNNING?
================================================================================

Via SSH/Terminal, try to test the app directly:

[ ] SSH to your server:
ssh brutsaxr@valviyal.com

[ ] Navigate to app:
cd /home/brutsaxr/public_html/qft-deployment

[ ] Try to start PHP server manually (to see real errors):
php -S localhost:8000

    This will show YOU the actual error preventing the app from starting!

    Expected output on success:
    ✅ Development Server Started
    📍 Server: http://localhost:8000

    If you see errors here → This is what you need to fix!

[ ] If it works manually, press Ctrl+C to stop, and restart via Node.js Selector

================================================================================
STEP 3: FIX DEPENDENCY INSTALLATION (IF SHOWING MODULE ERRORS)
================================================================================

If logs show "Cannot find module":

[ ] In cPanel, select PHP version:
[ ] Go to "Select PHP Version" in cPanel
[ ] Ensure PHP 8.2 or higher is selected
[ ] Required extensions: mysqli, pdo_mysql
[ ] Click "Update" if changes made

[ ] Verify PHP configuration:
[ ] Via SSH, test PHP: php -v
[ ] Should show 8.2 or higher
[ ] Also test: php -r "phpinfo();" | grep -i "Loaded Configuration"

[ ] Reconfigure the app:
[ ] Via SSH, test PHP directly from app folder:
[ ] cd qft-deployment && php -S localhost:8000
[ ] This will show if there are syntax errors in api.php
[ ] Fix any reported errors

[ ] Check error logs:
[ ] Via cPanel: Main error log or Raw Access Log
[ ] Via SSH: tail -f /var/log/apache2/error_log

================================================================================
STEP 4: CREATE/FIX .ENV FILE (MOST COMMON ISSUE!)
================================================================================

The .env file must exist in qft-deployment folder with correct credentials.

[ ] In cPanel File Manager:
[ ] Navigate to /public_html/qft-deployment/
[ ] Look for .env file

    IF .env DOESN'T EXIST:
    [ ] Right-click in empty space
    [ ] Select "Create New" > "File"
    [ ] Name: .env
    [ ] Create file

[ ] Edit .env file:
[ ] Right-click .env
[ ] Select "Edit"
[ ] Copy and paste this content:

        DB_HOST=localhost
        DB_USER=quarryforce_user
        DB_PASSWORD=your_actual_db_password_here
        DB_NAME=quarryforce_db
        DB_PORT=3306
        API_URL=https://valviyal.com/api
        FRONTEND_URL=https://valviyal.com
        LOGGING_ENABLED=1

    [ ] REPLACE: your_actual_db_password_here with REAL PASSWORD
    [ ] Save file

[ ] Verify PHP can read .env:
[ ] Via SSH: cat qft-deployment/.env (should show file contents)
[ ] Test API: https://valviyal.com/api/settings

================================================================================
STEP 5: VERIFY DATABASE CONNECTION
================================================================================

If logs show database errors:

[ ] Check database is actually running:
[ ] In cPanel, look for "MySQL" or "Databases"
[ ] Check if MySQL service is running
[ ] If stopped, start it

[ ] Verify credentials are correct:
[ ] In cPanel, go to "MySQL Databases"
[ ] Look for database: quarryforce_db
[ ] Look for user: quarryforce_user
[ ] Check password in .env matches this user

[ ] Test connection manually via SSH:
mysql -h localhost -u quarryforce_user -p quarryforce_db
(Enter password when prompted)

    If it connects: mysql> prompt appears
    If it fails: "Access denied" or "Can't connect"

[ ] If connection fails:
[ ] Re-check .env DB_PASSWORD
[ ] Reset password in cPanel > MySQL Databases
[ ] Update .env with new password
[ ] Restart app

================================================================================
STEP 6: COMPLETE RESTART PROCEDURE
================================================================================

If you've made changes above, do a COMPLETE restart:

[ ] In cPanel Node.js Selector:
[ ] Click STOP button
[ ] Wait 30 seconds
[ ] Status shows: "Stopped"

[ ] Check files are in correct place:
[ ] File Manager > /public_html/qft/
[ ] Verify: index.js, db.js, .env, admin/, uploads/
[ ] If missing files, re-copy them

[ ] In Node.js Selector:
[ ] Click RESTART button
[ ] Watch status change to: "Running"
[ ] Wait full 2 minutes

[ ] Check logs:
[ ] Click "View Logs"
[ ] Look for startup messages
[ ] Should see: "🚀 QuarryForce Backend Server Started!"

[ ] Test in browser:
[ ] Open: https://valviyal.com/qft/
[ ] Hard refresh: Ctrl+F5
[ ] Should load the dashboard

================================================================================
STEP 7: IF STILL NOT WORKING - ADVANCED DEBUGGING
================================================================================

[ ] Check port assignment:
In Node.js Selector, your app might not be on port 3000
Check if it shows: port 8080 or 8081 instead
Then test: https://valviyal.com:8081/qft (with port)

[ ] Check if .htaccess is correct:
File Manager > /public_html/qft/
Open .htaccess file
Should contain RewriteEngine rules
If empty or missing, copy from .htaccess.template

[ ] Check applist file:
Via SSH: cat /usr/local/cpanel/whm-app-list
Or: ls -la ~/.passenger
Make sure your app is registered there

[ ] Check file permissions:
Via SSH:
chmod 644 /home/brutsaxr/public_html/qft/.env
chmod 755 /home/brutsaxr/public_html/qft/uploads
chmod 755 /home/brutsaxr/public_html/qft/admin

[ ] Check if ports are open:
Via SSH: netstat -tuln | grep 3000
Or check cPanel Firewall settings

================================================================================
STEP 8: VERIFY ROUTES ARE ACTUALLY WORKING
================================================================================

Once app shows "Running" and loads without 404:

[ ] Test root endpoint:
https://valviyal.com/qft/
Should return JSON API welcome message

[ ] Test API endpoint:
https://valviyal.com/qft/api/settings
Should return JSON with system settings

    If returns 404: Backend routing issue
    If returns 500: Database error

[ ] Check admin dashboard:
https://valviyal.com/qft/admin/
Should load React app

[ ] If still getting 404:
Check Node.js Selector logs again
App might still be crashing

================================================================================
FINAL CHECKLIST
================================================================================

Go through each item:

[ ] .env file exists in /public_html/qft/
[ ] .env has correct DB_PASSWORD
[ ] Database is running (check in cPanel)
[ ] Node.js Selector shows "Running" (green)
[ ] Node.js version is 18.x or 20.x
[ ] File permissions are correct (644 for .env, 755 for folders)
[ ] admin/ folder has index.html
[ ] index.js and db.js exist
[ ] No "Cannot find module" in logs
[ ] No database connection errors in logs
[ ] https://valviyal.com/qft/ returns JSON response

✅ If all checked → DEPLOYMENT IS WORKING!

If still not working:
→ Provide the error message from Node.js Selector logs
→ Provide output from: node index.js (manual test)
→ Provide .env file contents (hide password)

================================================================================
QUICK REFERENCE: COMMON ERRORS & FIXES
================================================================================

ERROR CAUSE FIX
─────────────────────────────────────────────────────────────────────────────
Cannot GET /qft App not running Check logs, restart
Cannot find module 'express' Dependencies failed Reinstall via Node.js Sel
.env not found Missing .env file Create .env from template
ECONNREFUSED localhost:3306 DB can't connect Check DB running, pwd
Admin page blank Static files issue Check admin/ folder exists
api/settings returns 404 Route error Check index.js exists
api/settings returns 500 DB error Check .env credentials

================================================================================
IF YOU'RE STUCK
================================================================================

Collect this info and contact support@valviyal.com:

1. Full error message from Node.js Selector logs
2. Output from running: node index.js manually
3. Your .env file (hide DB_PASSWORD, just show format)
4. Current /public_html/qft/ folder contents
5. Node.js version you selected in Selector
6. Exact URL you're testing (https://valviyal.com/qft/)
7. Steps you've already tried

================================================================================
