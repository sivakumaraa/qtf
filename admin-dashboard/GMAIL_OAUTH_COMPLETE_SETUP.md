# ⚡ Gmail OAuth Quick Start - Complete Setup (5 Minutes)

## 🎯 What You'll Do

```
1 min  → Get Google OAuth Client ID (from Google Cloud)
2 min  → Update .env file with Client ID
1 min  → Install dependencies (if not already done)
1 min  → Start development server
```

---

## ✅ Prerequisites Check

Before starting, verify you have:

- ✅ Node.js installed (`node --version` should show v14+)
- ✅ npm installed (`npm --version` should show v6+)
- ✅ A Google account (for OAuth setup)
- ✅ Admin Dashboard code in `d:\quarryforce\admin-dashboard\`

---

## 🚀 Start Here

### Option 1: Automated Setup (Recommended for Windows)

```powershell
# Open PowerShell and navigate to admin-dashboard
cd d:\quarryforce\admin-dashboard

# Run the quick start script
.\quick-start.bat

# Script will:
# 1. Check if dependencies are installed
# 2. Show you the Google OAuth setup steps
# 3. Wait for you to update .env
# 4. Start npm start automatically
```

### Option 2: Manual Steps (if script doesn't work)

Follow the steps in this guide below ↓

---

## 📝 Step 1: Get Google OAuth Client ID (1 Minute)

### 1.1 Open Google Cloud Console

```
URL: https://console.cloud.google.com
Sign in with your Google account
```

### 1.2 Create New Project

```
1. Click "Select a Project" (top left)
2. Click "NEW PROJECT"
3. Name: "QuarryForce"
4. Click "CREATE"
5. Wait ~30 seconds for project to be created
```

### 1.3 Enable Google+ API

```
1. Go to "APIs & Services" → "Library"
2. Search: "Google+ API"
3. Click the result
4. Click "ENABLE"
5. Wait a few seconds
```

### 1.4 Create OAuth 2.0 Credential

```
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials"
3. Select "OAuth Client ID"
4. Choose "Web application"
5. Fill in Name: "QuarryForce Dashboard"
6. Under "Authorized JavaScript origins" click "ADD URI"
   - Add: http://localhost:3001
7. Under "Authorized redirect URIs" click "ADD URI"
   - Add: http://localhost:3001/
8. Click "CREATE"
9. 📋 COPY the "Client ID" (looks like: 123456.apps.googleusercontent.com)
10. Click "OK"
```

**✅ You now have a Client ID!**

---

## 🔧 Step 2: Update .env File (1 Minute)

### 2.1 Current .env Contents

Your `.d:\quarryforce\admin-dashboard\.env` file currently has:

```env
# Google OAuth2 Configuration
REACT_APP_GOOGLE_CLIENT_ID=YOUR_GOOGLE_OAUTH_CLIENT_ID_HERE

# Backend API Configuration
REACT_APP_API_BASE_URL=http://localhost:3000

# App Configuration
REACT_APP_APP_NAME=QuarryForce
REACT_APP_APP_VERSION=1.0.0
```

### 2.2 Update It

Open the `.env` file and replace:

```
YOUR_GOOGLE_OAUTH_CLIENT_ID_HERE
```

With the Client ID you copied in Step 1:

```
123456789012-abcdefghijklmnop.apps.googleusercontent.com
```

**Result should look like:**

```env
REACT_APP_GOOGLE_CLIENT_ID=123456789012-abcdefghijklmnop.apps.googleusercontent.com
REACT_APP_API_BASE_URL=http://localhost:3000
REACT_APP_APP_NAME=QuarryForce
REACT_APP_APP_VERSION=1.0.0
```

**Save the file.**

✅ Configuration complete!

---

## 📦 Step 3: Install Dependencies (30 Seconds - 2 Minutes)

Node dependencies should already be installed, but if not:

```powershell
cd d:\quarryforce\admin-dashboard
npm install
```

Expected output:

```
added 500+ packages in 45s
```

If it's already installed:

```
✅ up to date, audited XXX packages
```

---

## 🚀 Step 4: Start Development Server (1 Minute)

```powershell
cd d:\quarryforce\admin-dashboard
npm start
```

You should see:

```
Compiled successfully!

You can now view quarryforce-admin-dashboard in the browser.

  Local:    http://localhost:3001
  On Your Network: http://192.168.x.x:3001

Note that the development build is not optimized.
To create a production build, use npm run build.

webpack compiled with 1 warning
```

---

## 🌐 Step 5: Test Gmail Login (30 Seconds)

1. **Open Browser:** `http://localhost:3001`

2. **You should see:**
   - QuarryForce login page
   - Google login button
   - Demo login button

3. **Click "Sign in with Google"**

4. **Select Your Google Account**

5. **Grant Permissions** (if prompted)

6. **✅ You're logged in!**
   - Dashboard should load
   - Your name/email shown in top right
   - See "Logout" button

---

## 🎉 Success! What's Next?

You now have:

- ✅ Gmail authentication working
- ✅ Admin dashboard running
- ✅ User session management
- ✅ Logout functionality

### Explore the Dashboard

```
Available sections:
- Overview Dashboard
- User Management
- Rep Details
- Device Activation ← Try this!
- Rep Targets & Progress
- Customers
- Orders
- Fraud Alerts
- Visit Logs
- Settings
```

### Test Different Roles

Try logging in with different email addresses:

- `admin@gmail.com` → Admin role
- `supervisor@gmail.com` → Supervisor role (if you set up)
- `manager@gmail.com` → Manager role (if you set up)

---

## 🧪 Development Testing

### Demo Login (No Google Account Needed)

1. On login page, click **"Demo Login (Development Only)"**
2. Auto-logs in as admin
3. Perfect for UI testing

### Multiple Users

Create multiple Google accounts to test different roles:

1. Create test Gmail accounts
2. Log out: Click the logout button (top right)
3. Log in with different account
4. System automatically assigns role based on email

---

## 🐛 Troubleshooting

| Issue                           | Solution                                                                    |
| ------------------------------- | --------------------------------------------------------------------------- |
| **"Invalid Client ID"**         | Check `.env` file has correct ID from Google Console                        |
| **"Callback URL not valid"**    | Add `http://localhost:3001` to "Authorized redirect URIs" in Google Console |
| **Login button doesn't appear** | Restart dev server after updating `.env`                                    |
| **"Google+ API not enabled"**   | Go to Google Console → Enable it in APIs & Services → Library               |
| **npm start fails**             | Try: `npm cache clean --force` then `npm install` again                     |

---

## 📚 Additional Resources

- **Full Setup Guide:** [GMAIL_OAUTH_SETUP.md](./GMAIL_OAUTH_SETUP.md)
- **Troubleshooting:** [GMAIL_OAUTH_SETUP.md#-troubleshooting](./GMAIL_OAUTH_SETUP.md)
- **Google OAuth Docs:** https://developers.google.com/identity/protocols/oauth2
- **Google Cloud Console:** https://console.cloud.google.com

---

## ✨ Summary

| Step      | Time      | What You Do                            |
| --------- | --------- | -------------------------------------- |
| 1         | 1 min     | Get Google Client ID from Google Cloud |
| 2         | 1 min     | Update `.env` file with Client ID      |
| 3         | 2 min     | Run `npm install` (if needed)          |
| 4         | 1 min     | Run `npm start`                        |
| **Total** | **5 min** | **Complete!** ✅                       |

---

## 🎯 You're Ready!

Your admin dashboard now has Gmail login.

🚀 **Next:** Start the backend and mobile app to complete the full QuarryForce system!

See: [LOCAL_DEVELOPMENT_SETUP.md](../LOCAL_DEVELOPMENT_SETUP.md)

---

**Questions?** Check the full guide or see troubleshooting section above.

_Last Updated: March 9, 2026_
