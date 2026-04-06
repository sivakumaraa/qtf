# 🚀 DEPLOYMENT SCRIPTS - QUICK START

## Two Deployment Options:

### Option A: Batch File (Windows CMD)

**File:** `DEPLOY.bat`
**Best for:** Users comfortable with batch files
**How to run:** Double-click `DEPLOY.bat` or run in Command Prompt

```cmd
cd d:\quarryforce\qft-deployment
DEPLOY.bat
```

---

### Option B: PowerShell Script (Recommended)

**File:** `Deploy-Now.ps1`
**Best for:** Faster, more colorful output, better error handling
**How to run:**

#### Method 1: Interactive Menu (Recommended)

```powershell
cd d:\quarryforce\qft-deployment
.\Deploy-Now.ps1
```

Then choose option from menu:

- **1** = Create ZIP only
- **2** = Create ZIP + Setup .env
- **3** = Create ZIP + Show cPanel instructions
- **4** = Full deployment (everything + open cPanel)
- **5** = Exit

#### Method 2: Command Line (Automated)

```powershell
# Just create ZIP
.\Deploy-Now.ps1 -Action zip

# Create .env setup
.\Deploy-Now.ps1 -Action env

# Full deployment with all steps
.\Deploy-Now.ps1 -Action deploy

# Full deployment + open cPanel
.\Deploy-Now.ps1 -Action deploy -OpenCPanel
```

---

## ⚡ Quick Deploy (Fastest Way)

### Windows PowerShell:

```powershell
cd d:\quarryforce\qft-deployment
.\Deploy-Now.ps1 -Action deploy -OpenCPanel
```

This will:

1. ✅ Create qft-php-deploy.zip automatically
2. ✅ Copy .env.template to .env (open in editor)
3. ✅ Show step-by-step cPanel upload instructions
4. ✅ Open cPanel login page in browser

### Then Manually:

1. Upload ZIP to cPanel (copy/paste path from script output)
2. Extract ZIP in /public_html/qft/
3. Create .env with database credentials
4. Test: https://valviyal.com/qft

---

## 📋 What Each Script Does

### DEPLOY.bat

- Menu-driven interface
- Creates ZIP using PowerShell or 7-Zip
- Generates .env from template
- Shows detailed cPanel instructions
- Opens browser to cPanel if requested

**Pros:**

- Native Windows batch
- Works on all Windows versions
- No PowerShell restrictions

**Cons:**

- Text-only output (no colors)
- Slightly slower startup

---

### Deploy-Now.ps1

- Modern PowerShell script
- Color-coded output
- Better error messages
- Automatic environment checking
- Multiple action modes

**Pros:**

- Beautiful colored output
- Flexible command-line options
- Better documentation
- Faster execution

**Cons:**

- Requires PowerShell (installed by default on modern Windows)
- May require execution policy adjustment (one-time)

**If you get "execution policy" error:**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run script again.

---

## 🎯 Recommended Workflow

### FASTEST (5 minutes):

```powershell
cd d:\quarryforce\qft-deployment
.\Deploy-Now.ps1 -Action deploy -OpenCPanel
```

### STEP-BY-STEP (10 minutes):

```powershell
# Step 1: Create ZIP
.\Deploy-Now.ps1 -Action zip

# Step 2: Setup .env
.\Deploy-Now.ps1 -Action env

# Step 3: Show instructions
.\Deploy-Now.ps1 -Action deploy

# Step 4: Upload to cPanel manually
```

### TRADITIONAL (use .bat):

```cmd
DEPLOY.bat
```

Then choose options from menu.

---

## 📦 Files Created

After running the script, you'll have:

**In d:\quarryforce\qft-deployment:**

- `qft-php-deploy.zip` ← Upload this to Namecheap!
- `.env` ← Edit with database credentials (if option 2 chosen)

**Size of ZIP:**

- ~2-3 MB (all PHP code + docs)
- Does NOT include node_modules/ (saves 35MB!)

---

## ✅ Deployment Checklist

After running the script:

- [ ] qft-php-deploy.zip created
- [ ] .env file created (if chosen)
- [ ] Credentials edited in .env
- [ ] Login to cPanel with script's help
- [ ] Upload ZIP to /public_html/qft/
- [ ] Extract ZIP in File Manager
- [ ] Create .env on server
- [ ] Set logs/ to 755 permissions
- [ ] Set uploads/ to 755 permissions
- [ ] Test: https://valviyal.com/qft
- [ ] Test: https://valviyal.com/qft/api/test

---

## 🔧 Troubleshooting

### ZIP not created?

- Ensure you're in: `d:\quarryforce\qft-deployment`
- Check that `api.php` exists in that folder
- Try: `.\Deploy-Now.ps1 -Action zip` first

### .env not opening?

- Script uses `notepad` to edit
- If that fails, manually edit .env with your editor

### Can't execute PowerShell script?

- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Or use DEPLOY.bat instead

### Still having issues?

- Check PHP_DEPLOYMENT_GUIDE.md (700+ lines of detailed help)
- Check DEPLOY_NOW.md for common cPanel issues

---

## 📞 Support Materials

If you run into trouble, check these documents:

1. **PHP_DEPLOYMENT_GUIDE.md** (700+ lines)
   - Detailed cPanel how-to
   - Screenshot steps
   - Troubleshooting section

2. **DEPLOY_NOW.md** (457 lines)
   - Common errors & fixes
   - Post-deployment checklist
   - Performance notes

3. **PHP_CONVERSION_COMPLETE.md** (400+ lines)
   - What changed from Node.js
   - All endpoints listed
   - Features matrix

---

## ⏱️ Time Estimates

- **Create ZIP:** 10 seconds
- **Edit .env locally:** 2 minutes
- **Upload to Namecheap:** 2-3 minutes
- **Extract on server:** 20 seconds
- **Set permissions:** 1 minute
- **Test endpoints:** 1 minute

**Total:** ~5-10 minutes for full deployment!

---

## 🚀 Ready to Deploy?

Choose your method:

### For PowerShell (Recommended):

```powershell
cd d:\quarryforce\qft-deployment
.\Deploy-Now.ps1 -Action deploy -OpenCPanel
```

### For Batch File:

```cmd
cd d:\quarryforce\qft-deployment
DEPLOY.bat
```

Then follow the on-screen instructions!

---

**Version:** 2.0 (March 5, 2026)
**Status:** Production Ready ✅
**Support:** See PHP_DEPLOYMENT_GUIDE.md
