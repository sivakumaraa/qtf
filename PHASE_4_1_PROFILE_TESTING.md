# Profile Screen Testing Guide - Phase 4.1

## Quick Start Test (5 minutes)

### Prerequisites
- PHP server running: `http://127.0.0.1:8000`
- Flutter app compiled and running in Chrome
- Test user exists: `john@quarry.com`
- MySQL database accessible

### Step 1: Start PHP Server (if not running)
```powershell
cd D:\xampp\php
.\php.exe -S 127.0.0.1:8000 -t "D:\xampp\htdocs\qft" 2>&1
```

### Step 2: Verify Database Test User
```powershell
# Open MySQL command line
cd D:\xampp\mysql\bin
.\mysql.exe -u root -p quarryforce

# Check if john@quarry.com exists
SELECT id, name, email, mobile_no, photo FROM users WHERE email = 'john@quarry.com';

# If not exists, create test user
INSERT INTO users (name, email, password, role, mobile_no, is_active) 
VALUES ('John Doe', 'john@quarry.com', 'test123', 'rep', '9876543210', 1);
```

### Step 3: Run Flutter App
```powershell
cd D:\quarryforce\quarryforce_mobile
flutter run -d chrome --web-port=19006
```

### Step 4: Test Profile Screen

#### Scenario A: Successful Profile Update
1. **Login Screen**
   - Email: `john@quarry.com`
   - No password needed (email-only login with device binding)
   - Click "Login"

2. **Dashboard Screen**
   - Should see "Dashboard" with rep information
   - Bottom nav bar has 5 icons
   - Last icon (bottom right) is Profile (person icon)

3. **Profile Screen**
   - Click Profile button (bottom nav, 5th icon)
   - Should see:
     - Large circular avatar with person icon
     - Gallery/Camera buttons below
     - Name field showing "John Doe" (or empty)
     - Phone field showing "9876543210" (or empty)
     - Email field showing "john@quarry.com" (grayed out)
     - Blue "Update Profile" button

4. **Test Photo Upload**
   - Click "Gallery" button
   - Select any image from device
   - Should see preview in circular avatar
   - Check that image is selected

5. **Edit Name & Phone**
   - Clear Name field, enter: `John Smith`
   - Clear Phone field, enter: `9999999999`

6. **Save Changes**
   - Click "Update Profile" button
   - Should show loading spinner
   - Wait 2-3 seconds
   - Should see green success message: "Profile updated successfully!"
   - Screen returns to Dashboard automatically

7. **Verify in Database**
   ```sql
   SELECT id, name, email, mobile_no, photo, updated_at 
   FROM users WHERE email = 'john@quarry.com';
   ```
   - Should show: `name` = "John Smith", `mobile_no` = "9999999999"
   - `updated_at` should have current timestamp
   - `photo` should have path like "uploads/profiles/user_1_1234567890.jpg"

8. **Test Persistence**
   - Reload browser (F5)
   - App should re-login automatically
   - Navigate back to Profile
   - Should see "John Smith" and "9999999999"
   - Photo should still be visible

#### Scenario B: Error Handling Tests

**Test 1: Empty Name**
1. Go to Profile
2. Clear Name field (leave empty)
3. Click "Update Profile"
4. Should see red error: "Please enter your name"

**Test 2: Empty Phone**
1. Go to Profile
2. Clear Phone field (leave empty)
3. Click "Update Profile"
4. Should see red error: "Please enter your phone number"

**Test 3: Invalid File Type (if implementing)** 
1. Try uploading a .txt or .pdf file
2. Should see error: "Invalid file type. Only JPG and PNG allowed."

**Test 4: File Too Large (if implementing)**
1. Try uploading file > 5MB
2. Should see error: "File too large. Maximum 5MB allowed."

## Detailed API Testing

### Test Profile Update Endpoint Directly

#### Using PowerShell (Windows):
```powershell
# Create form data
$form = @{
    "rep_id" = "1"
    "name" = "Test Name"
    "phone" = "+91-9876543210"
}

# Send POST request
$response = Invoke-WebRequest `
    -Uri "http://127.0.0.1:8000/api/profile/update" `
    -Method POST `
    -Form $form

# View response
$response.Content
```

#### Expected Response (Success):
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "photo_path": null
}
```

#### With File Upload (PowerShell):
```powershell
# Create multipart form with file
$filePath = "C:\path\to\image.jpg"

$form = @{
    "rep_id" = "1"
    "name" = "John Updated"
    "phone" = "+91-1234567890"
    "photo" = Get-Item $filePath
}

$response = Invoke-WebRequest `
    -Uri "http://127.0.0.1:8000/api/profile/update" `
    -Method POST `
    -Form $form

$response.Content | ConvertFrom-Json
```

#### Expected Response (With Photo):
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "photo_path": "uploads/profiles/user_1_1611234567.jpg"
}
```

### Error Response Examples

**Missing rep_id:**
```json
{
  "success": false,
  "message": "rep_id is required"
}
```

**Invalid user:**
```json
{
  "success": false,
  "message": "User not found"
}
```

**Invalid file type:**
```json
{
  "success": false,
  "message": "Invalid file type. Only JPG and PNG allowed."
}
```

## Database Verification Steps

### 1. Check Table Structure
```sql
DESCRIBE users;
```

Should include these columns:
- `id` INT PRIMARY KEY
- `name` VARCHAR(255)
- `email` VARCHAR(255)
- `mobile_no` VARCHAR(20)
- `photo` LONGTEXT
- `updated_at` TIMESTAMP

### 2. View Test User Before Update
```sql
SELECT id, name, email, mobile_no, updated_at 
FROM users 
WHERE email = 'john@quarry.com';
```

### 3. View Test User After Update
```sql
SELECT id, name, email, mobile_no, photo, updated_at 
FROM users 
WHERE email = 'john@quarry.com';
```
- `name` should be changed
- `mobile_no` should be changed
- `updated_at` should be recent
- `photo` should contain file path (if uploaded)

### 4. Check Upload Directory
```powershell
# Check if uploads directory exists and has files
dir D:\xampp\htdocs\uploads\profiles\
```

Should see files like: `user_1_1234567890.jpg`

## Common Issues & Solutions

### Issue: "User not found"
**Cause:** rep_id doesn't exist in database
**Solution:** 
```sql
INSERT INTO users (name, email, password, role, mobile_no, is_active) 
VALUES ('John Doe', 'john@quarry.com', 'test', 'rep', '9876543210', 1);
```

### Issue: App shows "No changes made"
**Cause:** You didn't actually change any fields
**Solution:** Edit at least one of: name, phone, or upload a photo

### Issue: Photo upload fails silently
**Cause:** Uploads directory doesn't exist or no write permissions
**Solution:**
```powershell
# Create directory
mkdir D:\xampp\htdocs\uploads\profiles -Force

# Check PHP can write
icacls "D:\xampp\htdocs\uploads\profiles" /grant:r "SYSTEM:(OI)(CI)F"
```

### Issue: "Database update failed"
**Cause:** Column name mismatch
**Solution:** Verify column is `mobile_no` not `phone`
```sql
DESCRIBE users;  -- verify column names
```

### Issue: File too large error
**Cause:** File size > 5MB
**Solution:** Use smaller image file or increase limit in code
```php
// In api.php, change:
if ($photoFile['size'] > 10 * 1024 * 1024) { // 10MB instead
```

## Performance Testing

### Test 1: Multiple Updates
1. Update profile 5 times with different values
2. Each should complete in <2 seconds
3. All updates should persist

### Test 2: Large File Upload
1. Try uploading 4MB image
2. Should complete and save successfully

### Test 3: Rapid Updates
1. Update profile, quickly click Update again while loading
2. Should either cancel first request or queue second
3. Not throw error

## Checkpoint Summary

- ✅ App compilesith no errors
- ✅ Can login with john@quarry.com
- ✅ Profile screen accessible from Dashboard
- ✅ Can see existing profile info
- ✅ Can upload photo from gallery
- ✅ Can edit name and phone
- ✅ Can save changes (success message)
- ✅ Changes persist in database
- ✅ Changes persist after app reload
- ✅ Error validation works
- ✅ API endpoint responds correctly
- ✅ Files upload to correct directory

## Next Phase

After Profile Screen testing passes:

1. **Location Tracking** - Enable location service in dashboard
2. **Admin Dashboard** - Display live locations on map
3. **Location History** - View rep movement history
4. **Offline Queue** - Queue requests when offline

---

**Test Status:** Ready for execution
**Expected Duration:** 15-20 minutes (full test)
**Pass Criteria:** All checkpoints completed with success messages

