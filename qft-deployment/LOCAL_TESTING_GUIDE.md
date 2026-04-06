# 🧪 Local Testing Guide - QuarryForce Mobile App

Your local test server is now running! Test everything before deploying to production.

---

## 🚀 Access Your App

**Open your browser and go to:**

```
http://localhost:8080
```

---

## 📋 Test Credentials

```
Email:    demo@quarryforce.local
Password: demo123
```

**Note:** This connects to the PRODUCTION API at `https://valviyal.com/qft/api`

---

## 🧪 Complete Testing Checklist

### 1️⃣ **Login Test**

**Steps:**

1. Open: http://localhost:8080
2. Enter: `demo@quarryforce.local`
3. Tap: **LOGIN**

**Expected Result:**

- ✅ Login successful
- ✅ Dashboard loads with rep name and ID
- ✅ No errors in browser console (F12)

---

### 2️⃣ **Dashboard Test**

**What You Should See:**

```
Welcome back!
[Rep Name]
Rep ID: 1

Today's Activity
├─ Visits: 0
└─ Distance: 0.0 km

Location Status
[GPS Info]

Quick Actions (4 buttons)
├─ Start Visit (blue)
├─ Log Fuel (orange)
├─ View Earnings (green)
└─ More (blue)

Bottom Navigation
[Home] [Visits] [Fuel] [Earnings] [Profile]
```

**Expected Result:**

- ✅ All elements visible
- ✅ No layout issues
- ✅ Colors correct

---

### 3️⃣ **Fuel Logging Test** ⭐ (Most Important)

**Steps:**

1. On dashboard, tap: **"Log Fuel"** (orange button)
2. Fill in:
   - Fuel Type: Select **Diesel** or **Petrol**
   - Quantity: `50` (liters)
   - Cost: `2500` (rupees)
   - Notes: `Test fuel entry`
3. Tap: **SUBMIT**

**Expected Results:**

- ✅ Form validates without errors
- ✅ Cost field shows: **₹** (rupee symbol, NOT $)
- ✅ Cost label shows: **Cost (₹ INR)**
- ✅ Success message displays
- ✅ No console errors

**Verify in Admin Panel:**

1. Open: https://valviyal.com/qft (admin)
2. Go to: **Fuel Log**
3. You should see your fuel entry with ₹ 2500

---

### 4️⃣ **Visit Recording Test**

**Steps:**

1. On dashboard, tap: **"Start Visit"** (blue button)
2. Fill in:
   - Select Customer: Choose any customer from dropdown
   - Duration: `30` (minutes)
   - Notes: `Test visit from local`
3. Tap: **GET LOCATION** (it will skip on web/laptop)
4. Tap: **SUBMIT**

**Expected Results:**

- ✅ Customer dropdown populated
- ✅ Form validates
- ✅ Success message appears
- ✅ Can submit without location (safe on web)
- ✅ No console errors

**Verify in Admin Panel:**

1. Go to: https://valviyal.com/qft
2. Check: **Visit History**
3. You should see your visit entry

---

### 5️⃣ **Earnings/Compensation Test** ⭐ (Currency Check)

**Steps:**

1. On dashboard, tap: **"View Earnings"** (green button)
2. Navigate to: **Compensation** tab (if not auto-opened)

**Expected Results:**

- ✅ Page loads with earnings data
- ✅ All amounts show: **₹** symbol (NOT $)
- ✅ Amounts display correctly: **₹ 5000.00**
- ✅ Bonus shows: **₹ 500.00**
- ✅ Penalty shows: **₹ 200.00**
- ✅ Volume units show: **m³** (NOT mÂ³)
- ✅ Rates show: **₹ 50/m³**

**Error Indicators (if you see these, there's a problem):**

```
❌ Dollar sign: $
❌ Corrupted: â‚¹
❌ Bad unit: mÂ³
```

---

### 6️⃣ **Navigation Test**

Click each bottom tab and verify it loads:

```
[ ] Home      - Dashboard loads
[ ] Visits    - Visit list/form loads
[ ] Fuel      - Fuel form loads
[ ] Earnings  - Compensation loads (with ₹ symbols)
[ ] Profile   - User profile loads with logout button
```

---

### 7️⃣ **Logout Test**

**Steps:**

1. Tap: **Profile** tab
2. Scroll down, tap: **LOGOUT**
3. You should be redirected to login

**Expected Result:**

- ✅ Back at login screen
- ✅ Can login again with same credentials

---

### 8️⃣ **Browser Console Check** (F12)

**Steps:**

1. Press: **F12** (open Developer Tools)
2. Click: **Console** tab
3. Look for errors

**Expected Result:**

- ✅ No red error messages
- ✅ No 404s for assets
- ✅ SSL warning acceptable (dark red, about service worker)
- ✅ Some yellow warnings OK

---

### 9️⃣ **Responsive Design Test**

**Steps:**

1. Press: **F12** (Developer Tools)
2. Click: **Device Toggle** (phone icon)
3. Test on different phone sizes

**Expected Result:**

- ✅ Layout adapts correctly
- ✅ Buttons clickable on small screens
- ✅ Text readable
- ✅ No overlapping elements

---

### 🔟 **Offline Mode Test** (Optional)

**Steps:**

1. In DevTools, **Network** tab
2. Select: **Offline**
3. Try to submit fuel or visit
4. Go **Online**

**Expected Result:**

- ✅ Offline message appears
- ✅ Data queues locally
- ✅ Syncs when online

---

## ✅ Final Checklist

### Functionality

```
[✅] Login works
[✅] Dashboard loads
[✅] Fuel logging works
[✅] Visit recording works
[✅] Earnings shows correctly
[✅] Navigation works
[✅] Logout works
[✅] No console errors
```

### Currency Display (CRITICAL)

```
[✅] Cost field shows: ₹ (not $)
[✅] Earnings shows: ₹ (not $)
[✅] All amounts have rupee symbol
[✅] Volume units: m³ (not mÂ³)
[✅] Rates: ₹ 50/m³ (correct format)
```

### Data Sync

```
[✅] Fuel logged data appears in admin
[✅] Visit data appears in admin
[✅] Data syncs within 5 seconds
[✅] No data loss
```

---

## 🎯 Success Criteria

**Your app is ready for production if:**

1. ✅ All tests above pass
2. ✅ All currency symbols display as **₹** (not $ or corrupted)
3. ✅ All volume units display as **m³** (not mÂ³)
4. ✅ No red errors in console
5. ✅ Data syncs to admin dashboard
6. ✅ Responsive design works on all screen sizes
7. ✅ All navigation works

---

## 🚀 Ready for Production?

**If all tests pass:**

1. Kill the local server: `Ctrl+C` in the terminal
2. Deploy to Namecheap: Follow the deployment guide
3. Test on production: https://valviyal.com/qft/mobile

---

## 🆘 If Something Fails

### Issue: Login fails

**Solution:** Check internet connection, verify API is online

```
Test: curl https://valviyal.com/qft/api/test
```

### Issue: Data won't submit

**Solution:** Check network tab in DevTools, look for failed requests

### Issue: Symbols still wrong ($ instead of ₹)

**Solution:** Hard refresh browser: `Ctrl+Shift+R`

### Issue: 404 errors

**Solution:** Bad build - rebuild locally: `flutter build web --release`

---

## 📱 Phone Testing (Optional)

To test on your phone from laptop:

1. **Find your laptop's IP:**

   ```powershell
   ipconfig
   # Look for IPv4 Address (e.g., 192.168.x.x)
   ```

2. **Connect phone to same WiFi**

3. **On phone, open:**
   ```
   http://[your-laptop-ip]:8080
   ```

Example:

```
http://192.168.1.100:8080
```

---

## ✨ Testing Complete!

Once all tests pass, your app is **production-ready** and can be deployed to Namecheap! 🎉

---

## 📞 Quick Commands

Stop server:

```powershell
Ctrl+C
```

Restart server:

```powershell
cd d:\quarryforce
node local-test-server.js
```

Clear local storage (if stuck in bad state):

```javascript
// In DevTools Console:
localStorage.clear();
sessionStorage.clear();
```

Rebuild if needed:

```powershell
cd d:\quarryforce\quarryforce_mobile
flutter build web --release
```
