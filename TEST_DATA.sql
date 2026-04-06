-- ==========================================
-- QuarryForce Test Data Script
-- ==========================================
-- Use this to add sample data for testing all APIs locally
-- Copy & paste into phpMyAdmin SQL tab

-- Clear existing test data first (OPTIONAL - uncomment if needed)
-- DELETE FROM visit_logs;
-- DELETE FROM fuel_logs;
-- DELETE FROM customers WHERE id > 3;
-- DELETE FROM users WHERE id > 1;

-- ==========================================
-- 1. Add Test Users (Marketing Reps)
-- ==========================================
INSERT INTO users (name, email, role, is_active) VALUES
('John Doe', 'john@quarry.com', 'rep', 1),
('Jane Smith', 'jane@quarry.com', 'rep', 1),
('Mike Johnson', 'mike@quarry.com', 'rep', 1)
ON DUPLICATE KEY UPDATE is_active = 1;

-- ==========================================
-- 2. Add Test Customers (Site Locations)
-- ==========================================
-- NOTE: Update latitude/longitude with YOUR current coordinates
-- Get your coordinates from Google Maps (right-click on location)

INSERT INTO customers (name, lat, lng, assigned_rep_id, status, created_by) VALUES

-- Test sites at exact location (for successful check-in test)
('Office Location Test', 12.9716, 77.5946, 2, 'verified', 1),
('Construction Site A (John)', 12.9720, 77.5950, 2, 'verified', 1),

-- Test sites far away (for geofence block test)
('Distant Site (Blocked)', 12.98, 77.60, 3, 'prospect', 1),
('Remote Quarry', 13.0, 77.65, 3, 'prospect', 1),

-- Additional test sites
('Urban Office Complex', 12.9730, 77.5960, 2, 'verified', 1),
('Industrial Park', 12.9710, 77.5940, 2, 'verified', 1),
('Residential Project', 12.9760, 77.5970, 3, 'verified', 1)
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- ==========================================
-- 3. Add Sample Visit Data
-- ==========================================
INSERT INTO visit_logs (
  customer_id, rep_id, check_in_time, requirements_json, 
  lat_at_submission, lng_at_submission, distance_meters, gps_verified
) VALUES
(
  1, 2, NOW() - INTERVAL 2 DAY,
  '{
    "material_type": "M-Sand",
    "tonnage": 500,
    "frequency": "weekly",
    "project_deadline": "2026-03-31",
    "contact_person": "Raj Kumar"
  }',
  12.9716, 77.5946, 15, 1
),
(
  1, 2, NOW() - INTERVAL 1 DAY,
  '{
    "material_type": "P-Sand",
    "tonnage": 300,
    "frequency": "bi-weekly",
    "project_deadline": "2026-04-15",
    "contact_person": "Priya Singh"
  }',
  12.9716, 77.5946, 8, 1
),
(
  2, 2, NOW() - INTERVAL 6 HOUR,
  '{
    "material_type": "20mm Aggregate",
    "tonnage": 1000,
    "frequency": "daily",
    "project_deadline": "2026-03-20",
    "contact_person": "Amit Sharma"
  }',
  12.9720, 77.5950, 12, 1
);

-- ==========================================
-- 4. Add Sample Fuel Log Data
-- ==========================================
INSERT INTO fuel_logs (
  rep_id, odometer_reading, fuel_quantity_liters, 
  total_amount, lat, lng, logged_at
) VALUES
(
  2, 45250, 40, 2000,
  12.9716, 77.5946, NOW() - INTERVAL 2 DAY
),
(
  2, 45290, 35, 1750,
  12.9720, 77.5950, NOW() - INTERVAL 1 DAY
),
(
  2, 45325, 45, 2250,
  12.9730, 77.5960, NOW() - INTERVAL 6 HOUR
),
(
  3, 32100, 50, 2500,
  13.0, 77.65, NOW() - INTERVAL 3 DAY
);

-- ==========================================
-- 5. Verify Inserts
-- ==========================================
-- Run these to verify data was added:

-- Count users
-- SELECT COUNT(*) as total_users FROM users;

-- Show all customers with assignments
-- SELECT 
--   c.id, c.name, c.lat, c.lng, 
--   c.assigned_rep_id, u.name as rep_name, c.status
-- FROM customers c
-- LEFT JOIN users u ON c.assigned_rep_id = u.id
-- ORDER BY c.id;

-- Show recent visits
-- SELECT 
--   vl.id, vl.check_in_time, u.name as rep_name, 
--   c.name as customer_name, vl.distance_meters
-- FROM visit_logs vl
-- JOIN users u ON vl.rep_id = u.id
-- JOIN customers c ON vl.customer_id = c.id
-- ORDER BY vl.check_in_time DESC
-- LIMIT 10;

-- Show fuel logs
-- SELECT 
--   fl.id, fl.logged_at, u.name as rep_name, 
--   fl.odometer_reading, fl.fuel_quantity_liters, fl.total_amount
-- FROM fuel_logs fl
-- JOIN users u ON fl.rep_id = u.id
-- ORDER BY fl.logged_at DESC
-- LIMIT 10;

-- ==========================================
-- Notes for Testing
-- ==========================================
-- Rep IDs: 1 (Admin), 2 (John), 3 (Jane)
-- 
-- Test Scenarios:
-- 
-- 1. SUCCESS Check-in:
--    Customer: 1 (Office Location Test at 12.9716, 77.5946)
--    Rep: 2 (John)
--    POST /api/checkin with same GPS → Should PASS
-- 
-- 2. BLOCKED Check-in (Too Far):
--    Customer: 3 (Distant Site at 12.98, 77.60)
--    Rep: 2 (John)
--    POST /api/checkin with same GPS → Should BLOCK (difference > 50m)
-- 
-- 3. BLOCKED Check-in (Territory):
--    Customer: 1 (assigned to John/Rep 2)
--    Rep: 3 (Jane)
--    POST /api/checkin → Should BLOCK (not owner)
-- 
-- 4. Multiple Visits:
--    Rep 2 (John) has already visited Customer 1 three times
--    Check dashboard to see visit count and requirements
-- 
-- ==========================================

