-- QuarryForce Database Schema - Create All Tables
-- Run this script to create the complete database schema

-- ==========================================
-- 1. Users Table
-- ==========================================
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255),
  role ENUM('admin','rep','supervisor') DEFAULT 'rep',
  mobile_no VARCHAR(20),
  photo LONGTEXT,
  device_uid VARCHAR(500),
  is_active TINYINT DEFAULT 1,
  fixed_salary DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 2. System Settings Table
-- ==========================================
CREATE TABLE IF NOT EXISTS system_settings (
  id INT PRIMARY KEY DEFAULT 1,
  gps_radius_limit INT DEFAULT 50,
  company_name VARCHAR(255) DEFAULT 'QuarryForce',
  company_logo LONGTEXT,
  company_address TEXT,
  company_email VARCHAR(255),
  company_phone VARCHAR(20),
  currency_symbol VARCHAR(3) DEFAULT '₹',
  site_types JSON DEFAULT '["Quarry", "Site", "Dump"]',
  logging_enabled TINYINT DEFAULT 0,
  production_url VARCHAR(255) DEFAULT 'https://admin.quarryforce.pro',
  backend_port INT DEFAULT 8000,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 3. Customers Table
-- ==========================================
CREATE TABLE IF NOT EXISTS customers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  phone_no VARCHAR(20),
  location VARCHAR(255),
  assigned_rep_id INT,
  site_incharge_name VARCHAR(255),
  site_incharge_phone VARCHAR(20),
  address TEXT,
  material_needs JSON,
  rmc_grade VARCHAR(50),
  aggregate_types JSON,
  volume DECIMAL(10,2),
  volume_unit VARCHAR(20) DEFAULT 'm3',
  required_date DATE,
  amount_concluded_per_unit DECIMAL(10,2),
  boom_pump_amount DECIMAL(10,2),
  status ENUM('active','inactive','prospect') DEFAULT 'active',
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_rep_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 4. Visit Logs Table
-- ==========================================
CREATE TABLE IF NOT EXISTS visit_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  rep_id INT NOT NULL,
  check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  checkout_time TIMESTAMP NULL,
  requirements_json JSON,
  lat_at_submission DECIMAL(10,8),
  lng_at_submission DECIMAL(11,8),
  distance_meters INT,
  gps_verified TINYINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (rep_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 5. Fuel Logs Table
-- ==========================================
CREATE TABLE IF NOT EXISTS fuel_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  odometer_reading INT,
  fuel_quantity_liters DECIMAL(5,2),
  total_amount DECIMAL(10,2),
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 6. Rep Targets Table
-- ==========================================
CREATE TABLE IF NOT EXISTS rep_targets (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  month VARCHAR(7),
  sales_target DECIMAL(12,2),
  incentive_per_unit DECIMAL(8,2),
  penalty_per_miss DECIMAL(8,2),
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 7. Rep Progress Table
-- ==========================================
CREATE TABLE IF NOT EXISTS rep_progress (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  month VARCHAR(7),
  sales_achieved DECIMAL(12,2),
  target_amount DECIMAL(12,2),
  incentive_earned DECIMAL(10,2),
  penalty_deducted DECIMAL(10,2),
  final_bonus DECIMAL(10,2),
  status ENUM('pending','approved','paid') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 8. Orders Table
-- ==========================================
CREATE TABLE IF NOT EXISTS orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rep_id INT NOT NULL,
  customer_id INT NOT NULL,
  order_amount DECIMAL(12,2),
  order_date DATE,
  product_details TEXT,
  status ENUM('pending','confirmed','delivered','cancelled') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (rep_id) REFERENCES users(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Order Items Table (for multiple items per order)
-- ==========================================
CREATE TABLE IF NOT EXISTS order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- Insert Default Data
-- ==========================================

-- Insert admin user if not exists
INSERT INTO users (name, email, password, role, is_active) 
VALUES ('Admin', 'admin@quarryforce.local', 'admin123', 'admin', 1)
ON DUPLICATE KEY UPDATE is_active = 1;

-- Insert default settings
INSERT INTO system_settings (id, gps_radius_limit, company_name, currency_symbol, site_types, logging_enabled, production_url, backend_port)
VALUES (1, 50, 'QuarryForce', '₹', '["Quarry", "Site", "Dump"]', 0, 'https://admin.quarryforce.pro', 8000)
ON DUPLICATE KEY UPDATE currency_symbol = '₹';
