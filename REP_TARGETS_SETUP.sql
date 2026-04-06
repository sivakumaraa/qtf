-- ==========================================
-- Rep Targets Setup Script
-- ==========================================
-- Add this to your database to enable target setting for reps

-- ==========================================
-- CREATE TABLE: rep_targets
-- PERSONALIZED SALES TARGETS & COMPENSATION (Per Rep, Editable)
-- ==========================================
CREATE TABLE IF NOT EXISTS `rep_targets` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `rep_id` INT NOT NULL UNIQUE,
  -- Sales Target (in cubic meters m³)
  `monthly_sales_target_m3` DECIMAL(10,2) DEFAULT 300,        -- e.g., 300 m³ minimum target
  -- Incentive Rate (bonus for exceeding target in ₹ per m³)
  `incentive_rate_per_m3` DECIMAL(10,2) DEFAULT 5,            -- e.g., ₹5 per m³ over target
  `incentive_rate_max_per_m3` DECIMAL(10,2) DEFAULT 9,        -- e.g., ₹9 per m³ max incentive
  -- Penalty Rate (fine for not meeting target in ₹ per m³)
  `penalty_rate_per_m3` DECIMAL(10,2) DEFAULT 50,             -- e.g., ₹50 per m³ shortfall
  -- Status
  `status` ENUM('active', 'inactive') DEFAULT 'active',
  -- Audit
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` INT,
  FOREIGN KEY (`rep_id`) REFERENCES users(`id`),
  FOREIGN KEY (`updated_by`) REFERENCES users(`id`)
) ENGINE=InnoDB;

-- ==========================================
-- INSERT DEFAULT TARGETS FOR EXISTING REPS
-- (Edit these per rep as needed)
-- ==========================================
INSERT INTO rep_targets (rep_id, monthly_sales_target_m3, incentive_rate_per_m3, incentive_rate_max_per_m3, penalty_rate_per_m3) VALUES
(2, 300, 5, 9, 50),    -- John Doe: 300 m³ target, ₹5-9 bonus, ₹50 penalty
(3, 300, 5, 9, 50),    -- Jane Smith: 300 m³ target, ₹5-9 bonus, ₹50 penalty
(4, 300, 5, 9, 50)     -- Mike Johnson: 300 m³ target, ₹5-9 bonus, ₹50 penalty
ON DUPLICATE KEY UPDATE monthly_sales_target_m3 = VALUES(monthly_sales_target_m3);

-- ==========================================
-- CREATE TABLE: rep_progress (Monthly Sales & Compensation Tracking)
-- ==========================================
CREATE TABLE IF NOT EXISTS `rep_progress` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `rep_id` INT NOT NULL,
  `month` DATE NOT NULL,                        -- First day of month (e.g., 2026-02-01)
  `sales_volume_m3` DECIMAL(10,2) DEFAULT 0,   -- Total sales in cubic meters
  `bonus_earned` DECIMAL(10,2) DEFAULT 0,       -- Auto-calculated: if sales > target, bonus = (sales-target) × incentive_rate
  `penalty_amount` DECIMAL(10,2) DEFAULT 0,     -- Auto-calculated: if sales < target, penalty = (target-sales) × penalty_rate
  `net_compensation` DECIMAL(10,2) DEFAULT 0,   -- Auto-calculated: bonus - penalty
  `status` ENUM('pending', 'finalized') DEFAULT 'pending',  -- pending = open to edit, finalized = locked
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_rep_month (rep_id, month),
  FOREIGN KEY (`rep_id`) REFERENCES users(`id`)
) ENGINE=InnoDB;

-- ==========================================
-- VERIFICATION
-- ==========================================
-- Run these to check:
-- SELECT * FROM rep_targets;
-- SELECT * FROM rep_progress;

