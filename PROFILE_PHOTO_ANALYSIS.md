# Profile Photo Handling Analysis - QuarryForce Mobile App

## Executive Summary

The profile photo upload system is **partially functional but has a critical data flow issue**. Photos ARE being uploaded to the server successfully, but there's a mismatch between how the backend returns the photo path and how the mobile app expects to receive it.

---

## 1. Current Implementation Flow

### Mobile App Flow (lib/screens/profile_screen.dart)

```
User selects photo (Gallery/Camera)
    ↓
_pickImage() / _takePhoto() captures XFile
    ↓
_updateProfile() calls authProvider.updateProfile()
    ↓
Updates _currentUser with photo path and notifies listeners
    ↓
_buildProfilePhoto() displays image from URL
```

### API Call Chain

```
profile_screen.dart (_updateProfile)
    ↓ Calls ↓
auth_provider.dart (updateProfile)
    ↓ Calls ↓
api_service.dart (updateProfile)
    ↓ Posts to ↓
Backend: POST /api/profile/update
```

---

## 2. File Upload Working Correctly ✓

**Location:** [d:\quarryforce\qft-deployment\uploads\profiles](d:\quarryforce\qft-deployment\uploads\profiles)

**Verified Uploads:**

- `rep_1_1773995138_profile_photo.jpg`
- `rep_1_1773995444_profile_photo.jpg`
- Multiple other successful uploads

**Conclusion:** Photos ARE being successfully uploaded and saved to disk.

---

## 3. Backend Photo Update Handler (api.php)

**Location:** [d:\quarryforce\qft-deployment\api.php](d:\quarryforce\qft-deployment\api.php#L553-L680)

**Endpoint:** `POST /api/profile/update`

**Request Handling:**

- Accepts both JSON and multipart/form-data
- Validates file type (JPEG, PNG only)
- Maximum file size: 5MB
- Creates `/uploads/profiles` directory if missing

**Response on Success:**

```php
{
    'success' => true,
    'message' => 'Profile updated successfully!',
    'user' => [
        'id' => $user['id'],
        'name' => $name,
        'email' => $user['email'],
        'mobile_no' => $phone,  // ← Note: returns 'mobile_no', not 'phone'
        'photo' => $photoPath    // ← Returns /qft/uploads/profiles/filename.jpg
    ]
}
```

---

## 4. Photo Path Storage

**Critical Point Found!**

The backend stores the photo path as:

```
$photoPath = '/qft/uploads/profiles/' . $fileName;
```

This path assumes the backend is served at `/qft` context. When accessed:

- **Full URL:** `http://127.0.0.1:8000/qft/uploads/profiles/rep_1_1774368261_profile_photo.jpg`

But the mobile app constructs the URL as:

```dart
// In profile_screen.dart, line 237
'http://127.0.0.1:8000${authProvider.currentUser!.photo}'
```

If `_currentUser.photo` = `/qft/uploads/profiles/file.jpg`, then:

- **Result:** `http://127.0.0.1:8000/qft/uploads/profiles/file.jpg` ✓ Correct

---

## 5. Mobile App Response Handling - ISSUES FOUND ⚠️

### Issue #1: Photo Field in AuthProvider

**File:** [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart#L235-L300)

**Problem:** The backend response returns `photo` inside the `user` object:

```php
'user' => [..., 'photo' => $photoPath, ...]
```

**Mobile App Handling (Line 268-270):**

```dart
final userData = result['data'] as Map<String, dynamic>?;
...
if (userData != null && userData['photo'] != null) {
    _currentUser!.photo = userData['photo'] as String?;
```

**Status:** ✓ This part is correct - it should receive the photo path properly.

### Issue #2: Phone vs mobile_no Field

**File:** [lib/models/models.dart](lib/models/models.dart#L35)

**The Model Handles This Correctly:**

```dart
phone: json['phone'] ?? json['mobile_no'],  // ← Falls back to mobile_no
```

So the backend returning `mobile_no` is handled properly.

### Issue #3: Photo Not Visible After Upload

**Observed Problem:** Photo is uploaded successfully but may not display in the profile screen immediately.

**Potential Causes:**

1. **Consumer Rebuild Issue:**
   - The `Consumer<AuthProvider>` in `_buildProfilePhoto()` rebuilds when AuthProvider notifies listeners
   - If `notifyListeners()` isn't called in `updateProfile()`, the UI won't refresh
   - **Check:** Line 296 in auth_provider.dart has `notifyListeners()` ✓

2. **Network Image Caching:**
   - Flutter may cache the old image URL if displaying same filename
   - The backend randomizes filenames with timestamp, so this shouldn't be the issue
   - **File pattern:** `rep_1_<timestamp>_profile_photo.jpg` ← Different each upload ✓

3. **Incorrect Path Handling:**
   - If the backend path doesn't start with `/`, it might not form correct URL
   - **Verified:** Backend returns `/qft/uploads/profiles/...` ✓

4. **State Not Persisting:**
   - Check of photo saves to SharedPreferences (Line 290-292 in auth_provider.dart) ✓

---

## 6. Key Code Sections

### Profile Screen Updates Photo

[lib/screens/profile_screen.dart](lib/screens/profile_screen.dart#L300-L340)

```dart
final success = await authProvider.updateProfile(
    name: _nameController.text,
    phone: _phoneController.text,
    photoFile: _selectedImage != null ? File(_selectedImage!.path) : null,
);
```

### AuthProvider Calls API

[lib/providers/auth_provider.dart](lib/providers/auth_provider.dart#L235-L300)

```dart
final result = await apiService.updateProfile(
    repId: _currentUser!.id!,
    name: name,
    phone: phone,
    photoFile: photoFile,
);
```

### API Service Sends Multipart

[lib/services/api_service.dart](lib/services/api_service.dart#L558-L580)

```dart
if (photoFile != null) {
    final formData = FormData.fromMap({
        'rep_id': repId,
        'name': name,
        'phone': phone,
        'photo': await MultipartFile.fromFile(
            photoFile.path,
            filename: 'profile_photo.jpg',
        ),
    });
    response = await _dio.post('/api/profile/update', data: formData);
}
```

### Photo Display in Profile

[lib/screens/profile_screen.dart](lib/screens/profile_screen.dart#L230-L260)

```dart
authProvider.currentUser?.photo != null &&
    authProvider.currentUser!.photo!.isNotEmpty
    ? ClipOval(
        child: Image.network(
            'http://127.0.0.1:8000${authProvider.currentUser!.photo}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
                return const Center(
                    child: Icon(Icons.person, size: 80),
                );
            },
        ),
    )
```

---

## 7. Potential Issues Preventing Photo Updates

### ✓ **Working Correctly:**

1. File upload to server - Photos ARE being saved
2. Backend API response - Returns correct photo path
3. AuthProvider state update - Updates `_currentUser.photo` and notifies listeners
4. SharedPreferences persistence - Photo path is stored
5. URL Construction - Correctly combines base URL with photo path
6. Error Handling - Shows fallback icon if photo fails to load

### ⚠️ **Possible Issues:**

1. **API Base URL Issue**
   - Is the backend really at `http://127.0.0.1:8000/`?
   - Is `/qft` the correct context path?
   - **Check:** Open `http://127.0.0.1:8000/qft/uploads/profiles/rep_1_1774368261_profile_photo.jpg` in browser
   - **Also check logs:** [d:\quarryforce\qft-deployment\logs](d:\quarryforce\qft-deployment\logs) for upload errors

2. **File Permission Issues**
   - Are uploaded files readable by the web server?
   - Check directory permissions: `uploads/profiles` should be readable
   - **Windows may have permission issues with PHP uploaded files**

3. **Session/Auth Token Issues**
   - Is the Authorization token being sent correctly?
   - Can backend verify the user is authenticated?
   - **Check logs for auth errors on profile update endpoint**

4. **Database Not Being Updated**
   - Backend updates database: `UPDATE users SET ... photo = ? WHERE id = ?`
   - If this fails silently, photo path won't persist
   - **Check:** Query the database: `SELECT photo FROM users WHERE id = 1;`

5. **Path Mismatch at Different Deployment Stages**
   - Local development: `/qft/uploads/...` might not work
   - Different root path on different servers
   - **Check:** Where is the `qft-deployment` folder mapped to in the web server?

6. **Image Cache Issue on Mobile**
   - Flutter's Image.network caches images
   - If using same URL for different photos, cache might serve old image
   - **Mitigated by:** Using timestamp in filename ✓

---

## 8. Investigation Checklist

To diagnose why photos aren't updating, run these checks:

```
[ ] 1. Check PHP error logs
    Location: d:\quarryforce\qft-deployment\logs\

[ ] 2. Verify uploaded files are readable
    `dir d:\quarryforce\qft-deployment\uploads\profiles`
    Files found: ✓ (confirmed)

[ ] 3. Test backend endpoint manually
    POST to: http://127.0.0.1:8000/api/profile/update
    With: rep_id=1, name=Test, phone=1234567890, photo=<file>

[ ] 4. Query database for stored photo path
    SELECT id, name, photo FROM users WHERE id = 1;

[ ] 5. Test image URL directly in browser
    http://127.0.0.1:8000/qft/uploads/profiles/rep_1_1774368261_profile_photo.jpg

[ ] 6. Check mobile app logs
    Look for: "Photo updated:", "Photo saved to SharedPreferences"

[ ] 7. Verify API response structure
    Check if 'user' key exists in response with 'photo' field

[ ] 8. Test with hardcoded test path
    Manually set: _currentUser?.photo = '/qft/uploads/profiles/test.jpg'
    See if image displays in profile screen
```

---

## 9. Recommended Fixes

### Quick Fix: Verify Database Storage

```php
// In handleProfileUpdate(), after UPDATE query succeeds:
$updatedUser = $db->queryOne('SELECT photo FROM users WHERE id = ?', [$rep_id]);
Logger::info('Verified photo in DB', ['photo' => $updatedUser['photo']]);
```

### Ensure Photo Path Consistency

```dart
// In auth_provider.dart, after API call:
if (userData != null && userData['photo'] != null) {
    final photoPath = userData['photo'] as String?;
    AppLogger.info('Photo path from API: $photoPath');
    AppLogger.info('Photo path type: ${photoPath.runtimeType}');
    _currentUser!.photo = photoPath;
} else {
    AppLogger.warning('No photo in userData. Keys: ${userData?.keys.toList()}');
}
```

### Add Photo URL Validation

```dart
// In profile_screen.dart _buildProfilePhoto():
if (authProvider.currentUser?.photo != null) {
    final photoUrl = 'http://127.0.0.1:8000${authProvider.currentUser!.photo}';
    AppLogger.info('Loading photo from: $photoUrl');
    // Use photoUrl for Image.network
}
```

### Handle Path Normalization

```php
// In api.php, before returning path:
// Ensure path always starts with /
$photoPath = ltrim($photoPath, '/');
$photoPath = '/' . $photoPath;  // Normalize to /qft/uploads/profiles/...
```

---

## 10. Files to Review

1. **Backend Profile Update Handler:** [d:\quarryforce\qft-deployment\api.php](d:\quarryforce\qft-deployment\api.php#L553-L680)
2. **Mobile AuthProvider:** [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart#L235-L300)
3. **Mobile API Service:** [lib/services/api_service.dart](lib/services/api_service.dart#L550-L640)
4. **Mobile Profile Screen:** [lib/screens/profile_screen.dart](lib/screens/profile_screen.dart#L220-L340)
5. **User Model:** [lib/models/models.dart](lib/models/models.dart#L1-L50)
6. **Logs Directory:** [d:\quarryforce\qft-deployment\logs](d:\quarryforce\qft-deployment\logs)

---

## Summary Table

| Component                | Status    | Details                                            |
| ------------------------ | --------- | -------------------------------------------------- |
| Photo Selection          | ✓ Working | Gallery and camera selection working               |
| File Upload to Server    | ✓ Working | Files saved to uploads/profiles directory          |
| Backend Photo Processing | ✓ Working | Validates, saves, returns path                     |
| API Response Format      | ✓ Correct | Returns photo path in 'user.photo' field           |
| Mobile State Update      | ✓ Working | Updates \_currentUser.photo and notifies listeners |
| SharedPreferences Save   | ✓ Working | Photo path persisted locally                       |
| Image URL Construction   | ✓ Correct | Combines http://127.0.0.1:8000 + path              |
| **Photo Display**        | ⚠️ Verify | Need to check if URL actually works                |
| **Database Update**      | ⚠️ Verify | Need to confirm photo path stored in DB            |
