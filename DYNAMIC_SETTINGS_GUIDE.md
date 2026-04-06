# Dynamic Settings Configuration Guide

## Overview

The QuarryForce mobile app now supports dynamic configuration through the backend. Administrators can update app settings without requiring app redistribution.

## How It Works

1. **App Startup**: When the mobile app starts, it fetches the latest settings from the backend via `/api/settings`
2. **Settings Caching**: Settings are applied to the app for the current session
3. **Admin Updates**: Admins can update settings via the settings endpoint
4. **Automatic Sync**: The next time the app restarts, it will fetch the updated settings

## Configurable Settings

### API Configuration

- **api_endpoint** (string): The base URL for API calls
  - Default: `https://valviyal.com/qft/api`
  - Example: `https://api.yourdomain.com/qft/api`

- **api_timeout** (integer): API request timeout in milliseconds
  - Min: 5000ms (5 seconds)
  - Max: 120000ms (120 seconds)
  - Default: 60000ms (60 seconds)

### GPS Settings

- **gps_update_interval** (integer): How often to update GPS location in milliseconds
  - Min: 1000ms (1 second)
  - Max: 60000ms (60 seconds)
  - Default: 5000ms (5 seconds)

- **gps_min_distance** (integer): Minimum distance in meters before GPS updates
  - Min: 0 meters
  - Max: 1000 meters
  - Default: 10 meters

- **gps_radius_limit** (integer): GPS accuracy radius in meters
  - Min: 10 meters
  - Max: 500 meters
  - Default: 50 meters

### Visit Configuration

- **min_visit_duration** (integer): Minimum visit duration in seconds
  - Min: 15 seconds (for testing)
  - Max: 3600 seconds (1 hour)
  - Default: 15 seconds
  - **Note**: In production, this should be at least 900 seconds (15 minutes)

### Company Settings

- **company_name** (string): Company name
- **company_address** (string): Company address
- **company_email** (string): Company email
- **company_phone** (string): Company phone
- **company_logo** (string): Company logo URL
- **currency_symbol** (string): Currency symbol (max 3 characters)
  - Default: `₹`

## API Endpoints

### Get Current Settings

```
GET /api/settings
```

**Response:**

```json
{
  "success": true,
  "data": {
    "api_endpoint": "https://valviyal.com/qft/api",
    "api_timeout": 60000,
    "gps_update_interval": 5000,
    "gps_min_distance": 10,
    "min_visit_duration": 15,
    "currency_symbol": "₹",
    ...
  }
}
```

### Update Settings

```
PUT /api/settings
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "api_endpoint": "https://api.yourdomain.com/qft/api",
  "gps_update_interval": 10000,
  "min_visit_duration": 900
}
```

**Response:**

```json
{
  "success": true,
  "data": { ... updated settings ... }
}
```

## Admin Dashboard UI

To add this to your admin dashboard:

1. Create a Settings page with form fields for each setting
2. Add input validation based on the constraints listed above
3. Call the `PUT /api/settings` endpoint to save changes
4. Display success/error messages to the user

### Example Admin Form

- API Endpoint (URL input)
- API Timeout (number slider 5000-120000ms)
- GPS Update Interval (number slider 1000-60000ms)
- Minimum Visit Duration (number slider 15-3600s)
- Company Name (text input)
- Currency Symbol (text input, max 3 chars)

## Database Migration

Run the migration to add new columns (if upgrading from an older version):

```bash
mysql -u username -p database_name < migrations/migration_20260325_add_api_config.sql
```

Or copy-paste the SQL commands from that file into your database client.

## Testing

1. **Test with Emulator**:
   - Firebase Emulator connects to `10.0.2.2:8000`
   - Update `api_endpoint` to test different backends

2. **Test with Production**:
   - Deploy backend with settings configured
   - App will fetch settings on next restart
   - Verify GeolocationService uses updated `gps_update_interval`

3. **Test API Timeout**:
   - Set high timeout and verify slow requests complete
   - Set low timeout and verify fast requests don't timeout prematurely

## Troubleshooting

### Settings Not Updating

- **Check**: Is the app restarting? (Settings are only fetched once on startup)
- **Check**: Is the backend settings endpoint responding?
- **Check**: Is the admin token valid for the PUT endpoint?

### Invalid Field Values

- **Error**: "Invalid GPS radius"
  - Solution: Ensure value is between 10-500
- **Error**: "Invalid API endpoint URL"
  - Solution: Ensure URL starts with http:// or https://

### Database Migration Issues

- **Error**: "Column already exists"
  - Solution: This is fine, the migration is idempotent
- **Error**: Permission denied
  - Solution: Ensure user has ALTER TABLE permissions

## Security Notes

⚠️ **Important**: The settings endpoint should be protected:

- Only admins should be able to access `PUT /api/settings`
- Implement proper authorization checks in your backend
- Validate all input values before storing
- Log all settings changes for audit purposes
- Never expose sensitive URLs in public settings

## Example: Updating Settings via cURL

```bash
# Get current settings
curl -X GET https://api.yourdomain.com/qft/api/settings

# Update settings (requires admin token)
curl -X PUT https://api.yourdomain.com/qft/api/settings \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "api_endpoint": "https://newapi.yourdomain.com/qft/api",
    "gps_update_interval": 8000
  }'
```
