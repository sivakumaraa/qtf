================================================================================
QUARRYFORCE DEPLOYMENT CHECKLIST - CLOUDLINUX VERSION
================================================================================

IMPORTANT: This guide is for CloudLinux hosting with Node.js Selector
Do NOT run npm install locally - CloudLinux manages dependencies

================================================================================
SECTION 1: PREPARE THE DEPLOYMENT PACKAGE (LOCAL MACHINE)
================================================================================

[ ] Step 1: Open Command Prompt in the deployment folder
Command: cd d:\quarryforce\qft-deployment

[ ] Step 2: DO NOT run npm install
⚠️ CloudLinux Node.js Selector handles this automatically
⚠️ node_modules is NOT included in deployment ZIP

[ ] Step 3: Create .env file with actual database credentials - Copy .env.template to create .env file - Open .env and update these values:
DB_HOST=localhost
DB_USER=quarryforce_user  
 DB_PASSWORD=[YOUR ACTUAL PASSWORD]
DB_NAME=quarryforce_db - Save the file
WARNING: Do NOT commit .env to Git. Keep it local only.

[ ] Step 4: Verify qft-deployment folder contains:
✓ index.js
✓ db.js
✓ package.json
✓ .env (with your credentials)
✓ .env.template
✓ .htaccess
✓ admin/ (folder with React dashboard files)
✓ uploads/ (empty folder for file uploads)
✓ Documentation files (README.md, QUICK_START.md, etc.)
⚠️ EXCLUDE: node_modules/ folder (CloudLinux creates this)

[ ] Step 5: ZIP the qft-deployment folder - Right-click qft-deployment folder - Select "Send to" > "Compressed (zipped) folder" - Result: qft-deployment.zip file created
Note: File size should be ~15-20 MB (node_modules NOT included)

================================================================================
SECTION 2: UPLOAD TO SERVER (CPANEL)
================================================================================

[ ] Step 1: Login to cPanel
URL: https://cpanel.valviyal.com/ (or your cPanel URL)
Username: brutsaxr
Password: [Your cPanel password]

[ ] Step 2: Open File Manager - Click "File Manager" in cPanel - Select "Public HTML" folder - Click "Go"

[ ] Step 3: Upload qft-deployment.zip - Click "Upload" button - Select qft-deployment.zip file from your computer - Wait for upload to complete (1-2 minutes) - Verify file appears in /public_html/

[ ] Step 4: Extract the ZIP file - Right-click qft-deployment.zip - Select "Extract" - Click "Extract File(s)" - Wait for extraction (30 seconds) - Verify /public_html/qft-deployment/ folder is created

================================================================================
SECTION 3: REORGANIZE FOLDER STRUCTURE (CPANEL)
================================================================================

[ ] Step 1: Navigate into qft-deployment folder - Click on qft-deployment folder to open it

[ ] Step 2: Select ALL files in qft-deployment - Click checkbox at top to "Select All" - Should select 8-10 items (index.js, db.js, package.json, etc.)

[ ] Step 3: Cut the files - Right-click selected files - Click "Cut"

[ ] Step 4: Go back to public_html folder - Click "public_html" in the breadcrumb navigation - Or click back button to go up one level

[ ] Step 5: Create new folder "qft" - Right-click in empty space - Select "Create New" > "Folder" - Name: qft - Click "Create New Folder"

[ ] Step 6: Enter qft folder and paste files - Double-click qft folder to open it - Right-click in empty space - Select "Paste" - Wait for files to paste (should be quick)

[ ] Step 7: Verify qft folder contains ALL files:
✓ index.js
✓ db.js
✓ package.json
✓ .env
✓ .env.template
✓ .htaccess
✓ admin/ (folder)
✓ uploads/ (folder)
⚠️ node_modules/ will appear AFTER Step 4 (created by CloudLinux)

[ ] Step 8: Delete the empty qft-deployment folder - Go back to public_html - Right-click qft-deployment folder - Select "Delete" - Confirm deletion - Delete qft-deployment.zip file too (optional, to save space)

================================================================================
SECTION 4: CONFIGURE NODE.JS VIA CLOUDLINUX SELECTOR (CRITICAL!)
================================================================================

⚠️ THIS IS THE MOST IMPORTANT STEP - DO NOT SKIP

[ ] Step 1: Go to Node.js Selector - In cPanel, click "Node.js Selector" - Or search for "Node.js" in cPanel search bar

[ ] Step 2: Find your application - Look for application path: /home/brutsaxr/public_html/qft - Click on it to select it

[ ] Step 3: Set Node.js version - Select Node.js 18.x or 20.x (18.x recommended) - Click "Install" or "Configure" - CloudLinux creates:
→ Virtual environment with all dependencies
→ Symlink: /qft/node_modules → /virtual_env/ - Wait 1-2 minutes for installation

[ ] Step 4: Restart the application - Click "RESTART" button - Wait 1-2 minutes for restart to complete - Status should change to "Running" (green)

[ ] Step 5: Verify installation - Go to File Manager - Navigate to /public_html/qft/ - Look for: node_modules (should be a symlink, not a folder) - Right-click node_modules > Properties - Should show link to virtual environment path

================================================================================
SECTION 5: TEST THE DEPLOYMENT
================================================================================

[ ] Step 1: Test in browser
URL: https://valviyal.com/qft/ - Hard refresh: Ctrl+F5 (or Cmd+Shift+R on Mac) - Should see QuarryForce Dashboard loading

[ ] Step 2: Test API endpoints
Root API: https://valviyal.com/qft/api/settings - Should return JSON response with system settings

    Login Test: POST https://valviyal.com/qft/api/login
    - Email: demo@quarryforce.local
    - Device UID: test-device-123
    - Should return successful login response

[ ] Step 3: Check admin dashboard
URL: https://valviyal.com/qft/admin/ - Should see admin login page - Try connecting to validate React app is working

[ ] Step 4: Check server logs (if available) - Go back to cPanel > Node.js Selector - Click on your application - Look for "View Logs" or "Output" section - Check for any error messages

================================================================================
TROUBLESHOOTING SECTION
================================================================================

PROBLEM: "Cannot find module 'mysql2' or other modules"
SOLUTION:

- Check CloudLinux Node.js Selector properly installed dependencies
- Verify Node.js version is set (18.x or 20.x)
- Click "RESTART" in Node.js Selector
- Check cPanel error logs for details
- In Node.js Selector > View Logs to see dependency install output

PROBLEM: "Cannot find folder node_modules"
SOLUTION:

- This is NORMAL - node_modules is a symlink, not a folder
- In File Manager, it should show: node_modules → /virtual_env/...
- Check Node.js Selector status is "Running"
- Restart the application again

PROBLEM: Database connection failed
SOLUTION:

- Verify .env file has correct database credentials
- Check database is running on server
- Verify user "quarryforce_user" exists in MySQL
- Try: mysql -u quarryforce_user -p quarryforce_db
- Check .env file in /qft/ folder has correct DB_PASSWORD

PROBLEM: 404 errors on /qft/\* pages
SOLUTION:

- Check .htaccess file is in /public_html/qft/
- Check apache mod_rewrite is enabled
- Restart Node.js app again

PROBLEM: Admin dashboard returns blank page
SOLUTION:

- Check admin/index.html exists
- Check admin/static/js/ and admin/static/css/ folders exist
- Hard refresh browser: Ctrl+F5
- Check browser console for errors (F12)

PROBLEM: Application crashes after 5-10 minutes
SOLUTION:

- Likely database connection timeout
- Check database server is running
- Check firewall allows MySQL connection
- Ask support@valviyal.com for help

PROBLEM: "Error: listen EADDRINUSE :::3000"
SOLUTION:

- Port 3000 already in use
- CloudLinux may have assigned different port
- Check Node.js Selector for actual port assigned
- Restart application

================================================================================
SECTION 6: POST-DEPLOYMENT CONFIGURATION
================================================================================

[ ] Step 1: Verify .env file on server - Via cPanel File Manager: Open .env - Should contain your database credentials:
DB_PASSWORD=your_actual_password - If missing, create it (copy from .env.template)

[ ] Step 2: Verify environment variables are set - File Manager: Right-click .env > Edit - Verify all values are correct:
NODE_ENV=production
DB_HOST=localhost
DB_USER=quarryforce_user
DB_PASSWORD=\*\*\*
DB_NAME=quarryforce_db

[ ] Step 3: Configure database if first deployment - Run migration scripts (if not already done) - Create required tables - Load initial data - See SYSTEM_ARCHITECTURE_GUIDE.md for DB schema

================================================================================
FINAL VERIFICATION CHECKLIST
================================================================================

After completing all steps above, verify:

[ ] Application is running at https://valviyal.com/qft/
[ ] Root API endpoint returns success: https://valviyal.com/qft/api/settings
[ ] Login API works: POST /api/login
[ ] Admin dashboard loads: https://valviyal.com/qft/admin/
[ ] No "Module not found" errors in logs
[ ] No database connection errors
[ ] React app loads without blank page
[ ] API endpoints respond with JSON data
[ ] File uploads work in uploads/ folder
[ ] .htaccess is properly routing requests
[ ] Node.js Selector shows status: "Running"

✅ IF ALL PASS → DEPLOYMENT SUCCESSFUL!

================================================================================
IMPORTANT NOTES FOR CLOUDLINUX
================================================================================

• CloudLinux manages node_modules via virtual environments
• Never try to upload node_modules folder - it won't work
• node_modules appears as symlink in File Manager
• Always use Node.js Selector to manage Node.js version
• Dependencies are installed in isolated virtual environment
• Restarting app in Node.js Selector is required after config changes
• Each Node.js version has its own virtual environment

KEY DIFFERENCE FROM OTHER HOSTING:
✗ DON'T manually run: npm install
✗ DON'T upload node_modules folder
✓ DO use CloudLinux Node.js Selector
✓ DO restart app after version changes
✓ DO check Node.js Selector logs for errors

================================================================================
SUPPORT CONTACT:
================================================================================

If you encounter issues:

1. Check all checklist items above
2. Review .env file for correct credentials
3. Check Node.js Selector status and logs
4. Check cPanel Error Logs (cPanel → Error Log)
5. Verify /public_html/qft/ folder structure matches requirements

Contact support:
Email: support@valviyal.com
Phone: [Your phone number]
Hours: Business hours IST (UTC+5:30)

When contacting support, mention:

- Date/time of deployment
- Error messages you see
- Node.js version you selected
- Steps you've already tried

================================================================================
