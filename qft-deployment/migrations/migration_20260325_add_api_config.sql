/** 
 * Database Migration: Add API Configuration Fields to system_settings
 * Date: March 25, 2026
 * 
 * This migration adds new columns to the system_settings table to support
 * dynamic API configuration from the admin dashboard.
 * 
 * Run this SQL if the columns don't exist in your database.
 */

-- Add api_endpoint column if it doesn't exist
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS api_endpoint VARCHAR(500) DEFAULT 'https://valviyal.com/qft/api' COMMENT 'API base URL for mobile app connections';

-- Add api_timeout column if it doesn't exist  
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS api_timeout INT DEFAULT 60000 COMMENT 'API request timeout in milliseconds';

-- Add min_visit_duration column if it doesn't exist
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS min_visit_duration INT DEFAULT 15 COMMENT 'Minimum visit duration in seconds (for testing)';

-- Update existing records with default values if they are NULL
UPDATE system_settings 
SET api_endpoint = 'https://valviyal.com/qft/api' 
WHERE api_endpoint IS NULL AND id = 1;

UPDATE system_settings 
SET api_timeout = 60000 
WHERE api_timeout IS NULL AND id = 1;

UPDATE system_settings 
SET min_visit_duration = 15 
WHERE min_visit_duration IS NULL AND id = 1;
