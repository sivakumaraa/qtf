-- Insert test rep users
INSERT INTO users (name, email, password, role, is_active, fixed_salary) VALUES
('John Doe', 'john@quarry.com', 'password123', 'rep', 1, 25000),
('Jane Smith', 'jane@quarry.com', 'password123', 'rep', 1, 25000),
('Mike Johnson', 'mike@quarry.com', 'password123', 'rep', 1, 25000);

-- Insert test customers
INSERT INTO customers (name, phone_no, location, assigned_rep_id, status) VALUES
('Green Quarry Ltd', '+91 9876543210', 'North Delhi', 1, 'active'),
('Metro Limestone Co', '+91 9876543211', 'South Delhi', 1, 'active'),
('City Construction Materials', '+91 9876543212', 'East Delhi', 2, 'active');
