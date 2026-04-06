-- QuarryForce Database Migration: Add mobile_no and photo fields to users table
-- This migration adds support for rep mobile numbers and profile photos

-- Check if columns exist and add them if they don't
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS mobile_no VARCHAR(20) NULL COMMENT 'Mobile phone number of the rep',
ADD COLUMN IF NOT EXISTS photo LONGTEXT NULL COMMENT 'Base64 encoded profile photo';

-- Verify the columns were added
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME='users' AND TABLE_SCHEMA=DATABASE() 
AND COLUMN_NAME IN ('mobile_no', 'photo');
