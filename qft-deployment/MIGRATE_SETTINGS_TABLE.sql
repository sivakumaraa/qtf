-- Migration script to add new company settings fields to system_settings table
-- This script will add the new columns if they don't already exist

-- Check and add company_logo column
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS company_logo LONGTEXT NULL DEFAULT NULL;

-- Check and add company_address column
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS company_address TEXT NULL DEFAULT '';

-- Check and add company_email column
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS company_email VARCHAR(255) NULL DEFAULT '';

-- Check and add company_phone column
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS company_phone VARCHAR(20) NULL DEFAULT '';

-- Verify the schema
DESCRIBE system_settings;
