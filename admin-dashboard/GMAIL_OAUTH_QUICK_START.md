# 🔐 Gmail OAuth - Quick Setup (5 Minutes)

## ⚡ TL;DR - Quick Steps

### 1. Get Google OAuth Client ID (2 min)

```
Go to: https://console.cloud.google.com
1. Create new project "QuarryForce"
2. Enable Google+ API
3. Create OAuth 2.0 Web credential
4. Add localhost:3001 as authorized URI
5. Copy Client ID
```

### 2. Update Environment File (30 sec)

```bash
# admin-dashboard directory
cp .env.example .env

# Edit .env and add your Client ID:
REACT_APP_GOOGLE_CLIENT_ID=your-client-id-here.apps.googleusercontent.com
```

### 3. Install & Run (2 min)

```bash
npm install
npm start
```

### 4. Test (30 sec)

```
Visit: http://localhost:3001
Click: "Sign in with Google"
Done! ✅
```

---

## 📝 Complete Checklist

- [ ] Google Cloud Project created
- [ ] Google+ API enabled
- [ ] OAuth 2.0 Client ID created
- [ ] Client ID copied
- [ ] `.env` file created and updated
- [ ] `npm install` completed
- [ ] `npm start` running
- [ ] Login page displays Google button
- [ ] Gmail login works

---

## 🔑 Client ID Format

Your Client ID should look like:

```
123456789012-abcdefghijklmnopqrstuvwxyz1234.apps.googleusercontent.com
```

❌ NOT your Project ID or other credentials

---

## 🚀 Alternative: Demo Login

To test without Gmail setup:

```
Click: "Demo Login (Development Only)"
- Email: demo@quarryforce.local
- Role: admin
- No Google account needed!
```

---

## 📱 Authorized Domains (Automatic)

These work out of the box:

- ✅ @quarryforce.local (testing)
- ✅ @quarryforce.com (production)
- ✅ @gmail.com (development)

---

## 🆘 Common Issues

| Issue                     | Solution                                 |
| ------------------------- | ---------------------------------------- |
| "Invalid Client ID"       | Check `.env` has correct Client ID       |
| "Domain not authorized"   | Add `localhost:3001` in Google Console   |
| npm install fails         | Run `npm cache clean --force` then retry |
| Login button doesn't work | Restart dev server after `.env` change   |

---

## 📚 Full Documentation

See [GMAIL_OAUTH_SETUP.md](./GMAIL_OAUTH_SETUP.md) for complete guide with:

- Detailed step-by-step instructions
- Screenshots & images
- Role assignment customization
- Production deployment guide
- Security best practices

---

**Ready?** Get your Client ID and update `.env` → Then run `npm start` 🎉
