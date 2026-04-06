# 🔐 Gmail/Google OAuth2 Setup Guide

Complete guide to set up Google OAuth2 authentication for the QuarryForce Admin Dashboard.

---

## 📋 Quick Start

1. **Get Google OAuth2 Client ID** from Google Cloud Console
2. **Add to `.env` file** in admin-dashboard directory
3. **Install dependencies** with `npm install`
4. **Start the dashboard** with `npm start`

---

## 🎯 Step 1: Create Google Cloud Project

### 1.1 Go to Google Cloud Console

- Visit: https://console.cloud.google.com
- Sign in with your Google account

### 1.2 Create a New Project

```
1. Click "Select a Project" dropdown (top left)
2. Click "NEW PROJECT"
3. Enter Project Name: "QuarryForce"
4. Click "CREATE"
5. Wait for project to be created
```

### 1.3 Enable Google OAuth2 API

```
1. Go to "APIs & Services" → "Library"
2. Search for "Google+ API"
3. Click on it
4. Click "ENABLE"
5. Go back to "APIs & Services"
```

---

## 📝 Step 2: Create OAuth2 Credentials

### 2.1 Create OAuth2 ID

```
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth Client ID"
3. Select "Web application"
4. Click "CREATE"
```

### 2.2 Configure OAuth Consent Screen

```
If redirected to consent screen:
1. Choose "External" user type
2. Click "CREATE"
3. Fill in the form:
   - App name: "QuarryForce Admin Dashboard"
   - Support email: your-email@gmail.com
   - Developer email: your-email@gmail.com
4. Click "SAVE AND CONTINUE"
5. On Scopes page, click "SAVE AND CONTINUE"
6. On Summary page, click "BACK TO DASHBOARD"
```

---

## 🔑 Step 3: Add Authorized Redirect URIs

### 3.1 Configure URIs

```
1. Go to OAuth 2.0 Client IDs
2. Click on your created credential
3. Under "Authorized JavaScript origins", click "ADD URI"
4. Add these URIs:
   - http://localhost:3001
   - http://localhost:3000
   - http://192.168.x.x:3001 (your local IP for mobile testing)
5. Under "Authorized redirect URIs", click "ADD URI"
6. Add these URIs:
   - http://localhost:3001/
   - http://localhost:3001/callback
7. Click "SAVE"
```

### 3.2 Copy Client ID

```
1. On the Credentials page, look for your OAuth 2.0 Client ID
2. Copy the "Client ID" (looks like: YOUR_ID.apps.googleusercontent.com)
3. Save it somewhere safe
```

---

## 🛠️ Step 4: Configure Admin Dashboard

### 4.1 Create Environment File

```bash
# In admin-dashboard directory
cp .env.example .env
```

### 4.2 Add Google Client ID to .env

```
# Open .env file and replace:
REACT_APP_GOOGLE_CLIENT_ID=YOUR_GOOGLE_OAUTH_CLIENT_ID_HERE

# With your actual Client ID:
REACT_APP_GOOGLE_CLIENT_ID=123456789012-abcdefghijklmnopqrstuvwxyz1234.apps.googleusercontent.com
```

---

## 📦 Step 5: Install Dependencies

```bash
cd d:\quarryforce\admin-dashboard

# Install new dependencies
npm install

# This will install:
# - @react-oauth/google (Google OAuth React component)
# - jwt-decode (Decode Google JWT tokens)
```

---

## 🚀 Step 6: Run the Dashboard

### 6.1 Start Development Server

```bash
npm start
```

### 6.2 Test Gmail Login

```
1. Open http://localhost:3001
2. You should see the login page with Google button
3. Click "Sign in with Google"
4. Select your Google account
5. You should be logged in!
```

---

## 🔓 Demo Login (Development)

For testing without Google OAuth:

```
Button: "Demo Login (Development Only)"
- Name: Demo Admin
- Email: demo@quarryforce.local
- Role: admin
```

---

## ✅ Authorized Email Domains

By default, these email domains are authorized:

- `@quarryforce.local` - Internal testing
- `@quarryforce.com` - Production domain
- `@gmail.com` - For development testing

### Customize Authorized Domains

Edit [LoginPage.js](src/components/LoginPage.js):

```javascript
const AUTHORIZED_DOMAINS = [
  "quarryforce.local",
  "quarryforce.com",
  "gmail.com",
  // Add your custom domain here
  "yourdomain.com",
];
```

---

## 🔐 Role Assignment

Users are automatically assigned roles based on their email:

```javascript
// Admin (default)
- Any authorized email without keywords

// Supervisor
- Emails containing "supervisor"

// Manager
- Emails containing "manager"
```

Edit [LoginPage.js](src/components/LoginPage.js) to customize role assignment:

```javascript
// Determine user role based on email
let role = "admin"; // Default

if (email.includes("supervisor")) {
  role = "supervisor";
} else if (email.includes("manager")) {
  role = "manager";
}
```

---

## 🐛 Troubleshooting

### Issue: "Invalid Client ID" Error

**Solution:**

1. Verify Client ID is correct in `.env`
2. Check that it ends with `.apps.googleusercontent.com`
3. Restart the development server after changing `.env`

### Issue: "Unauthorized Domain" Error

**Solution:**

1. Go to Google Cloud Console
2. Check if `localhost:3001` is in "Authorized JavaScript origins"
3. Add it if missing and save

### Issue: "Email Not Verified"

**Solution:**

1. Make sure to verify your Google account email
2. Some test accounts may not have verified emails
3. Use a personal Gmail account for testing

### Issue: "Domain Not Authorized"

**Solution:**

1. Check the email domain in your Google account
2. Add the domain to `AUTHORIZED_DOMAINS` in LoginPage.js
3. Use @gmail.com for testing (it's pre-authorized)

### Issue: npm install Fails

**Solution:**

```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and package-lock.json
rm -r node_modules package-lock.json

# Reinstall
npm install
```

---

## 🔒 Security Considerations

### Production Deployment

Before deploying to production:

1. **Create OAuth Credentials for Production**
   - Create a NEW OAuth client for production domain
   - Use your actual domain (e.g., quarryforce.com)

2. **Update Authorized Domains**
   - Remove `localhost` entries
   - Add your production domain
   - Remove @gmail.com if not needed

3. **Use Backend OAuth**
   - For production, implement server-side OAuth validation
   - Don't pass tokens directly from frontend
   - Use refresh tokens for long sessions

4. **Environment Variables**
   - Never commit `.env` with real credentials
   - Use `.env.example` as template
   - Rotate Client IDs if leaked

5. **HTTPS Only**
   - Always use HTTPS in production
   - Set `secure` flag on cookies
   - Update redirect URIs to use HTTPS

---

## 📚 Additional Resources

- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [@react-oauth/google Documentation](https://www.npmjs.com/package/@react-oauth/google)
- [Google Cloud Console](https://console.cloud.google.com)
- [JWT Decode Library](https://www.npmjs.com/package/jwt-decode)

---

## ✨ Features

✅ **Gmail Login** - Use Google account to sign in  
✅ **Email Verification** - Only verified Google accounts  
✅ **Domain Restriction** - Limit to authorized domains  
✅ **Auto-Role Assignment** - Assign roles based on email  
✅ **Session Persistence** - Remember login in localStorage  
✅ **Demo Login** - Development/testing mode  
✅ **Logout** - Clear session and tokens

---

## 🎯 Next Steps

1. Complete the setup steps above
2. Test Gmail login with your account
3. Customize authorized domains for your organization
4. Customize role assignment logic if needed
5. Deploy to production with proper security settings

---

**Happy authenticating!** 🚀

_Last Updated: March 9, 2026_
