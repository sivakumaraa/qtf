# GitHub Setup Guide for QuarryForce

## 🎯 Why Use GitHub?

1. **Backup** - Your code is safe in the cloud
2. **Version Control** - Track every change you make
3. **Deployment** - Easy deploy from GitHub to Namecheap
4. **Collaboration** - Work with other developers
5. **History** - Revert changes if something breaks

---

## 🚀 Quick Setup (5 minutes)

### Step 1: Create GitHub Account

- Go to https://github.com
- Click "Sign up" (if you don't have account)
- Verify email

### Step 2: Create a Private Repository

- Click "+" → "New repository"
- **Name:** `quarryforce-backend`
- **Private:** YES (don't make it public!)
- **Initialize with:** README
- Click "Create repository"

### Step 3: Clone to Your Laptop

```bash
cd d:\
git clone https://github.com/YOUR_USERNAME/quarryforce-backend.git
```

### Step 4: Copy Your Files

```bash
# Copy your working files to the git folder
copy d:\quarryforce\*.js d:\quarryforce-backend\
copy d:\quarryforce\*.json d:\quarryforce-backend\
copy d:\quarryforce\.env d:\quarryforce-backend\
copy d:\quarryforce\*.md d:\quarryforce-backend\
```

### Step 5: Push to GitHub

```bash
cd d:\quarryforce-backend
git add .
git commit -m "Initial backend setup with 11 APIs"
git push origin main
```

---

## 📝 What NOT to Push to GitHub

Create a `.gitignore` file:

```bash
# Save this as .gitignore in your repo

node_modules/
.env
.DS_Store
*.log
.idea/
.vscode/
uploads/
```

This prevents:

- Private database passwords (`.env`)
- Large node_modules folder
- Local configuration files

---

## 🔄 Workflow Going Forward

### Every time you make changes:

```bash
cd d:\quarryforce-backend

# See what changed
git status

# Add changes
git add .

# Save with message
git commit -m "Fixed GPS calculation bug"

# Push to GitHub
git push origin main
```

---

## 📊 Branching Strategy

Best practice for team work:

```bash
# Main branch = Production ready (never break this!)
git branch

# Create feature branch
git checkout -b feature/photo-upload

# Make changes, commit
git add .
git commit -m "Add photo upload endpoint"

# Push feature branch
git push origin feature/photo-upload

# On GitHub, create Pull Request
# Once reviewed, merge to main
```

---

## 🚢 Deployment Flow: GitHub → Namecheap

When ready to go live:

```
1. Code on laptop (d:\quarryforce)
   ↓
2. Push to GitHub (quarryforce-backend)
   ↓
3. SSH into Namecheap
   ↓
4. git clone (pull latest code)
   ↓
5. npm install (on Namecheap)
   ↓
6. Configure .env (production credentials)
   ↓
7. Start Node.js (via cPanel)
   ↓
8. Live! 🎉
```

---

## 🔑 Git Commands Reference

```bash
# See commits
git log

# See changed files
git status

# Compare changes
git diff

# Undo last commit (before push)
git reset --soft HEAD~1

# See all branches
git branch -a

# Create branch
git checkout -b branch-name

# Switch branch
git checkout branch-name

# Delete branch
git branch -d branch-name

# See who changed what
git blame filename.js

# See specific commit
git show commit-id
```

---

## 📁 Repository Structure for GitHub

```
quarryforce-backend/
├── .gitignore              ← Don't push these files!
├── .env.example            ← Template (no real password!)
├── .env                    ← Real config (DON'T COMMIT!)
├── package.json
├── package-lock.json
├── index.js                ← Main server
├── db.js                   ← Database connection
├── README.md               ← Project description
├── API_DOCUMENTATION.md    ← API reference
├── DEVELOPMENT_STATUS.md   ← What's done/what's next
├── TEST_DATA.sql           ← Sample data script
├── postman_collection.json ← API testing
└── uploads/                ← Photos (DON'T COMMIT, large files!)
    ├── visits/
    ├── fuel/
    ├── selfies/
    └── claims/
```

---

## ⚠️ Important: Protect Passwords!

### Never Commit Secrets:

```bash
# ❌ WRONG - This exposes your password
DB_HOST=localhost
DB_USER=root
DB_PASS=super_secret_password  # EXPOSED PUBLICLY!

# ✅ RIGHT - Create .env.example with no real values
DB_HOST=localhost
DB_USER=root
DB_PASS=
```

### .gitignore will prevent:

```
# Ignored files
.env              # Your real passwords
uploads/          # Large image files
node_modules/     # 50MB+ folder
.DS_Store         # Mac files
*.log             # Error logs
```

---

## 🔄 Syncing Multiple Devices

If you work on multiple computers:

```bash
# Computer 1: Make changes and push
git add .
git commit -m "Added new API"
git push origin main

# Computer 2: Get latest changes
git pull origin main

# Now Computer 2 has all changes from Computer 1
```

---

## 🆘 Common Issues

### Issue: Changed secret .env file by accident?

```bash
# Undo last commit
git reset --soft HEAD~1

# Remove from staging
git reset HEAD .env

# Commit without .env
git commit -m "Fix without exposing secrets"
```

### Issue: Want to see what changed?

```bash
git diff            # All changes
git diff filename   # Specific file
git log -p          # All commits with changes
```

### Issue: Need to revert bad changes?

```bash
git revert commit-id   # Safe - creates new commit
git reset commit-id    # Dangerous - deletes history
```

---

## 📋 Commit Message Best Practices

### Good Commit Messages:

```
✅ "Added GPS verification API"
✅ "Fixed device binding logic for Android"
✅ "Updated SQL schema with audit fields"
```

### Bad Commit Messages:

```
❌ "Updated stuff"
❌ "Work in progress"
❌ "asdfadfs"
```

---

## 🔐 GitHub Security

### Enable 2-Factor Authentication:

1. GitHub Settings → Security
2. Enable "Two-factor authentication"
3. Use authenticator app or SMS

### Create Personal Access Token (for CLI):

1. GitHub Settings → Developer settings → Personal access tokens
2. Generate new token
3. Copy token (use instead of password for git commands)

---

## 📊 Useful GitHub Features

### Issues (Bug Tracking):

```
Create issues for:
- Bugs to fix
- Features to add
- Questions about code

Can assign to team members, set deadlines
```

### Pull Requests (Code Review):

```
Before merging features to main:
1. Create Pull Request
2. Describe changes
3. Request review
4. Fix any issues
5. Merge when approved
```

### Releases:

```
When you have a stable version:
- Create Release v1.0, v1.1, etc.
- Document what changed
- Mark as "Production Ready"
```

---

## 🎯 Next Steps

1. **Create private GitHub repository**
2. **Clone to your laptop**
3. **Copy all files from d:\quarryforce**
4. **Create .gitignore file** (copy from above)
5. **First commit:** `git add . && git commit -m "Initial backend setup" && git push`
6. **Share link** with any team members (if working with others)

---

## 💡 Pro Tips

1. **Commit Often** - Every working feature (not every 5 minutes)
2. **Good Messages** - Describe what YOU changed, not what the code does
3. **Small Commits** - 1 feature = 1 commit (easier to debug)
4. **Pull Before Push** - Always `git pull` before `git push` to avoid conflicts
5. **Backup Important Branches** - Tag releases: `git tag v1.0`

---

## 🚀 When Ready for Namecheap:

```bash
# On Namecheap via SSH:
cd /home/your-account/public_html

# Clone your code
git clone https://github.com/YOUR_USERNAME/quarryforce-backend.git .

# Install dependencies
npm install

# Create production .env
nano .env
# Add production database credentials here

# Start server (via cPanel Node.js setup)
node index.js

# Verify: Visit your-namecheap-domain.com/api/settings
```

---

**Remember:** GitHub is your safety net. Use it!

Version: 1.0 | Date: Feb 27, 2026
