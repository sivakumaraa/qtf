================================================================================
QUARRYFORCE DEPLOYMENT - QUICK START (3-STEP GUIDE)
================================================================================

You now have a complete, ready-to-deploy QFT package at:
d:\quarryforce\qft-deployment\

This folder contains:
✓ Backend (index.js, db.js, package.json)
✓ Admin Dashboard (React - production build)  
✓ Configuration templates
✓ Complete documentation

================================================================================
THREE SIMPLE STEPS TO DEPLOY
================================================================================

STEP 1️⃣: PREPARE ON YOUR LOCAL MACHINE (5 minutes)
─────────────────────────────────────────────────

[A] Open Command Prompt/Terminal in the qft-deployment folder:
cd d:\quarryforce\qft-deployment

[B] ⚠️ DO NOT RUN npm install LOCALLY
→ CloudLinux Node.js Selector will handle dependencies
→ node_modules folder is NOT included in ZIP

[C] Create .env file with your database credentials: 1. Open .env.template in Notepad 2. Copy all content 3. Create new file: .env (in same folder) 4. Paste content 5. UPDATE: DB_PASSWORD=your_actual_password_here 6. Save file

[D] Verify folder contents:
Should see: index.js, db.js, admin/, uploads/, .env, etc.
ℹ️ node_modules is NOT included - CloudLinux will create it
✓ DONE with Step 1

═══════════════════════════════════════════════════════════════════════════════

STEP 2️⃣: ZIP & UPLOAD TO SERVER (15 minutes)
──────────────────────────────────────────

[A] Create ZIP file: 1. Right-click qft-deployment folder 2. Select: "Send to" > "Compressed (zipped) folder" 3. Result: qft-deployment.zip (140-150 MB)

[B] Login to cPanel:
URL: https://cpanel.valviyal.com/ (or your cPanel)
Username: brutsaxr
Password: [Your cPanel password]

[C] Upload ZIP: 1. Click "File Manager" 2. Select "Public HTML" 3. Click "Upload" 4. Select qft-deployment.zip 5. Wait for upload (5-10 minutes for 140MB)

[D] Extract ZIP: 1. Right-click qft-deployment.zip 2. Select "Extract" 3. Wait 1-2 minutes 4. Verify /public_html/qft-deployment/ created

✓ DONE with Step 2

═══════════════════════════════════════════════════════════════════════════════

STEP 3️⃣: REORGANIZE & RESTART (5 minutes)
──────────────────────────────────────

[A] In cPanel File Manager, open qft-deployment folder

[B] Select and cut all files: 1. Click checkbox to "Select All" (8 items) 2. Right-click > "Cut"

[C] Navigate back to public_html and create qft folder: 1. Click "public_html" breadcrumb to go back 2. Right-click > "Create New" > "Folder" 3. Name: qft 4. Create

[D] Paste files into qft folder: 1. Open qft folder 2. Right-click > "Paste" 3. Wait for paste to complete

[E] Delete empty qft-deployment folder: 1. Go back to public_html 2. Right-click qft-deployment 3. Delete

[F] Restart your Node.js app: 1. In cPanel, click "Node.js Selector" 2. Find your app (path: /qft) 3. Click "RESTART" 4. Wait 1-2 minutes

✓ DONE with Step 3 - YOU'RE LIVE! 🎉

═══════════════════════════════════════════════════════════════════════════════

VERIFY YOUR DEPLOYMENT
═════════════════════════════════════════════════════════════════════════════

Test these URLs in your browser:

1. Main App: https://valviyal.com/qft/
   → Should see QuarryForce dashboard

2. API Health: https://valviyal.com/qft/api/settings
   → Should return JSON with system settings

3. Admin Dashboard: https://valviyal.com/qft/admin/
   → Should see admin login page

4. Root Route: https://valviyal.com/qft/
   → Should return API welcome message

If all 4 work → ✅ DEPLOYMENT SUCCESSFUL!

═══════════════════════════════════════════════════════════════════════════════

NEED HELP? COMMON ISSUES
═══════════════════════════════════════════════════════════════════════════════

❌ "Module not found" error?
Solution: Run "npm install" on server
SSH: ssh brutsaxr@valviyal.com
Then: cd /home/brutsaxr/public_html/qft && npm install

❌ Database connection failed?
Solution: Check .env file has correct DB_PASSWORD

❌ Blank admin page?
Solution: Hard refresh (Ctrl+F5)
Solution: Check browser console (F12) for errors

❌ 404 errors on /qft/\* pages?
Solution: Check .htaccess is in /public_html/qft/
Solution: Check Node.js app is running (cPanel Node.js Selector)

❌ App crashes after 5 minutes?
Solution: Database connection timeout
Contact: support@valviyal.com

═══════════════════════════════════════════════════════════════════════════════

NEXT: READ DETAILED DOCS
════════════════════════════════════════════════════════════════════════════════

For complete, step-by-step instructions with screenshots:
→ Read: DEPLOYMENT_CHECKLIST.md (in qft-deployment folder)

For troubleshooting and more details:
→ Read: README.md (in qft-deployment folder)

For file structure and contents:
→ Read: DEPLOYMENT_FOLDER_STRUCTURE.txt

═══════════════════════════════════════════════════════════════════════════════

SUMMARY
═══════════

Your deployment package is READY TO GO!

Files prepared:
✓ Backend API (Node.js/Express)
✓ Admin Dashboard (React - pre-built)
✓ Configuration (.env.template)
✓ Apache routing (.htaccess)
✓ Complete documentation

Next action:
→ Step 1: npm install (on your local machine)
→ Step 2: Create .env file with real database password
→ Step 3: ZIP folder and upload to server

Estimated total time: 30-40 minutes

═══════════════════════════════════════════════════════════════════════════════

Questions? See:

- DEPLOYMENT_CHECKLIST.md - Detailed steps
- README.md - Full documentation
- API_DOCUMENTATION.md - API reference (in main folder)

🚀 Ready to deploy? Let's go!

═══════════════════════════════════════════════════════════════════════════════
