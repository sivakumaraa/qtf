-- ================================================================
-- PHASE 4.1: Rep Login & Live Location Tracking
-- Date: March 14, 2026
-- ================================================================

-- ================================================================
-- STEP 1: Modify users table - Add device binding columns
-- ================================================================

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS device_uid VARCHAR(255) UNIQUE NULL COMMENT 'Unique device identifier for one-time binding',
ADD COLUMN IF NOT EXISTS device_bound BOOLEAN DEFAULT FALSE COMMENT 'Flag to indicate device is bound',
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP NULL COMMENT 'Last login timestamp';

-- Add index for faster lookups
ALTER TABLE users 
ADD INDEX IF NOT EXISTS idx_device_uid (device_uid),
ADD INDEX IF NOT EXISTS idx_email_active (email, is_active);
cd d:\quarryforce\quarryforce_mobile
  
  -- Constraints
  FOREIGN KEY (rep_id) REFERENCES users(id) ON DELETE CASCADE,
  
  -- Indexes for performance
  INDEX idx_rep_id (rep_id),
  INDEX idx_timestamp (timestamp DESC),
  INDEX idx_rep_timestamp (rep_id, timestamp DESC),
  UNIQUE KEY uk_rep_latest (rep_id) COMMENT 'Ensure only one latest location per rep'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Real-time rep locations updated every 30 seconds';

-- ================================================================
-- STEP 3: Create location_history table
-- Archives all location history for analytics & tracking
-- ================================================================

CREATE TABLE IF NOT EXISTS location_history (
  id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier',
  rep_id INT NOT NULL COMMENT 'Foreign key to users table',
  lat DECIMAL(10, 8) NOT NULL COMMENT 'Latitude coordinate',
  lng DECIMAL(11, 8) NOT NULL COMMENT 'Longitude coordinate',
  accuracy FLOAT DEFAULT 0 COMMENT 'GPS accuracy in meters',
  timestamp TIMESTAMP NOT NULL COMMENT 'When location was recorded',
  date_key DATE NOT NULL COMMENT 'Date partitioning key for easy queries',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation time',
  
  -- Constraints
  FOREIGN KEY (rep_id) REFERENCES users(id) ON DELETE CASCADE,
  
  -- Indexes for performance
  INDEX idx_rep_id (rep_id),
  INDEX idx_date_key (date_key),
  INDEX idx_rep_date (rep_id, date_key),
  INDEX idx_timestamp (timestamp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Historical location data for analytics and path tracking';

-- ================================================================
-- STEP 4: Create location_access_log table
-- Tracks who accessed what location data (for security audit)
-- ================================================================

CREATE TABLE IF NOT EXISTS location_access_log (
  id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier',
  admin_id INT NOT NULL COMMENT 'Admin who accessed the data',
  rep_id INT NOT NULL COMMENT 'Which rep data was accessed',
  access_type VARCHAR(50) COMMENT 'live, history, map, report',
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When accessed',
  ip_address VARCHAR(45) COMMENT 'IP address of the accessor',
  
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (rep_id) REFERENCES users(id) ON DELETE CASCADE,
  
  INDEX idx_admin_id (admin_id),
  INDEX idx_rep_id (rep_id),
  INDEX idx_timestamp (timestamp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Audit log for location data access';

-- ================================================================
-- STEP 5: Create device_bind_log table
-- Tracks device binding events for security audit
-- ================================================================

CREATE TABLE IF NOT EXISTS device_bind_log (
  id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier',
  user_id INT NOT NULL COMMENT 'Foreign key to users table',
  device_uid VARCHAR(255) COMMENT 'Device identifier',
  device_model VARCHAR(255) COMMENT 'Device model info',
  device_manufacturer VARCHAR(255) COMMENT 'Device manufacturer',
  bind_status VARCHAR(50) COMMENT 'success, failed, mismatch',
  ip_address VARCHAR(45) COMMENT 'IP address of the device',
  user_agent TEXT COMMENT 'Device user agent',
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When binding occurred',
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  
  INDEX idx_user_id (user_id),
  INDEX idx_device_uid (device_uid),
  INDEX idx_timestamp (timestamp DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='Audit log for device binding events';

-- ================================================================
-- STEP 6: Verify data integrity
-- ================================================================

-- Show status of all new tables
SHOW CREATE TABLE live_locations\G
SHOW CREATE TABLE location_history\G
SHOW CREATE TABLE location_access_log\G
SHOW CREATE TABLE device_bind_log\G

-- Check users table structure
DESCRIBE users;

-- ================================================================
-- STEP 7: Insert test data (optional - for development only)
-- ================================================================

-- Uncomment below if you want to test with sample data
/*
-- Insert a test rep (password: password123)
INSERT INTO users (name, email, password, role, mobile_no, is_active, fixed_salary, created_at)
VALUES (
  'Test Rep',
  'test.rep@quarryforce.com',
  '$2y$10$YG2St0yT3H3K9O3.XZZZmuSLKv0G0R8OE8VVJw9vVkUqfLqpL1sDK',
  'Rep',
  '+919876543210',
  1,
  15000,
  NOW()
) ON DUPLICATE KEY UPDATE updated_at = NOW();

-- Get the rep ID
SET @rep_id = (SELECT id FROM users WHERE email = 'test.rep@quarryforce.com');

-- Insert sample location
INSERT INTO live_locations (rep_id, lat, lng, accuracy, timestamp, synced)
VALUES (
  @rep_id,
  28.6139,
  77.2090,
  15.5,
  NOW(),
  1
);

-- Insert sample location history
INSERT INTO location_history (rep_id, lat, lng, accuracy, timestamp, date_key)
SELECT @rep_id, 28.6139, 77.2090, 15.5, NOW(), CURDATE()
WHERE NOT EXISTS (SELECT 1 FROM location_history WHERE rep_id = @rep_id AND date_key = CURDATE());
*/

-- ================================================================
-- COMPLETION MESSAGE
-- ================================================================
-- Run this command to verify the migration:
-- SELECT 'Migration completed successfully!' as status;
-- SELECT COUNT(*) as users_count FROM users;
-- SELECT COUNT(*) as live_locations_count FROM live_locations;
-- SELECT COUNT(*) as location_history_count FROM location_history;
