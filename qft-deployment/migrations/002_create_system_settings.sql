-- QuarryForce Database Migration: Create system_settings table
-- This table stores application-wide configuration

CREATE TABLE IF NOT EXISTS system_settings (
    id INT PRIMARY KEY DEFAULT 1,
    gps_radius_limit INT DEFAULT 50 COMMENT 'GPS radius limit in meters (10-500)',
    company_name VARCHAR(255) DEFAULT 'QuarryForce' COMMENT 'Company name displayed in the app',
    currency_symbol VARCHAR(3) DEFAULT '₹' COMMENT 'Currency symbol for payments',
    site_types JSON DEFAULT '["Quarry", "Site", "Dump"]' COMMENT 'List of available site types',
    logging_enabled TINYINT DEFAULT 0 COMMENT 'Enable detailed logging (0 or 1)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System settings and configurations';

-- Insert default settings if table is empty
INSERT INTO system_settings (id, gps_radius_limit, company_name, currency_symbol, site_types, logging_enabled)
SELECT 1, 50, 'QuarryForce', '₹', '["Quarry", "Site", "Dump"]', 0
WHERE NOT EXISTS (SELECT 1 FROM system_settings WHERE id = 1);

-- Verify the table was created
SELECT 'system_settings table is ready' as status;
