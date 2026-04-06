const express = require('express');
const app = express();
const db = require('./db');
const geolib = require('geolib');

// Middleware
app.use(express.json());
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// ==========================================
// 0. ROOT ROUTE (Welcome)
// ==========================================
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'QuarryForce Backend API',
    version: '1.0.0',
    status: 'Online',
    apis: {
      settings: 'GET /api/settings',
      login: 'POST /api/login',
      checkin: 'POST /api/checkin',
      visit: 'POST /api/visit/submit',
      fuel: 'POST /api/fuel/submit',
      admin_reps: 'GET /api/admin/reps',
      admin_customers: 'GET /api/admin/customers',
      admin_orders_all: 'GET /api/admin/orders',
      admin_orders_by_customer: 'GET /api/admin/orders/customer/:customerId',
      admin_orders_create: 'POST /api/admin/orders',
      admin_orders_update: 'PUT /api/admin/orders/:id',
      admin_orders_delete: 'DELETE /api/admin/orders/:id',
      admin_reset: 'POST /api/admin/reset-device',
      admin_rep_targets_all: 'GET /api/admin/rep-targets',
      admin_rep_targets_get: 'GET /api/admin/rep-targets/:rep_id',
      admin_rep_targets_create: 'POST /api/admin/rep-targets',
      admin_rep_targets_update: 'PUT /api/admin/rep-targets/:id',
      admin_rep_progress: 'GET /api/admin/rep-progress/:rep_id',
      admin_rep_sales_update: 'POST /api/admin/rep-progress/update',
      health: 'GET /test'
    }
  });
});

// ==========================================
// LOGGING UTILITY
// ==========================================
let loggingEnabled = process.env.LOGGING_ENABLED !== 'false';

const logger = {
  log: (level, message, data = null) => {
    if (!loggingEnabled) return;
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level,
      message,
      data: data ? JSON.stringify(data) : null
    };
    console.log(`[${timestamp}] [${level}] ${message}`, data || '');
  },
  info: (message, data) => logger.log('INFO', message, data),
  error: (message, data) => logger.log('ERROR', message, data),
  debug: (message, data) => logger.log('DEBUG', message, data)
};

// ==========================================
// 1. SETTINGS API
// ==========================================
app.get('/api/settings', async (req, res) => {
  try {
    logger.debug('Fetching system settings');
    const [settings] = await db.execute('SELECT * FROM system_settings LIMIT 1');
    res.json({ success: true, data: settings });
  } catch (err) {
    logger.error('Failed to fetch settings', err.message);
    res.json({ success: false, error: err.message });
  }
});

app.put('/api/settings', async (req, res) => {
  try {
    const { gps_radius_limit, company_name, currency_symbol, site_types, logging_enabled } = req.body;
    logger.info('Updating system settings', { gps_radius_limit, company_name, currency_symbol, logging_enabled });
    
    // Validate GPS radius
    if (gps_radius_limit && (isNaN(gps_radius_limit) || gps_radius_limit < 10 || gps_radius_limit > 500)) {
      return res.status(400).json({ success: false, error: 'GPS radius must be between 10 and 500 meters' });
    }
    
    // Validate currency symbol
    if (currency_symbol && currency_symbol.length > 3) {
      return res.status(400).json({ success: false, error: 'Currency symbol must be 3 characters or less' });
    }
    
    // Update settings (assuming system_settings table has a single row)
    const updates = [];
    const values = [];
    
    if (gps_radius_limit !== undefined) {
      updates.push('gps_radius_limit = ?');
      values.push(gps_radius_limit);
    }
    
    if (company_name !== undefined) {
      updates.push('company_name = ?');
      values.push(company_name);
    }
    
    if (currency_symbol !== undefined) {
      updates.push('currency_symbol = ?');
      values.push(currency_symbol);
    }
    
    if (site_types !== undefined) {
      updates.push('site_types = ?');
      values.push(JSON.stringify(site_types));
    }

    if (logging_enabled !== undefined) {
      updates.push('logging_enabled = ?');
      values.push(logging_enabled ? 1 : 0);
      loggingEnabled = logging_enabled;
      logger.info('Logging status changed', { logging_enabled });
    }

    if (req.body.production_url !== undefined) {
      updates.push('production_url = ?');
      values.push(req.body.production_url);
    }

    if (req.body.backend_port !== undefined) {
      updates.push('backend_port = ?');
      values.push(req.body.backend_port);
    }
    
    if (req.body.mobile_api_url !== undefined) {
      updates.push('mobile_api_url = ?');
      values.push(req.body.mobile_api_url);
    }

    if (req.body.prod_db_host !== undefined) {
      updates.push('prod_db_host = ?');
      values.push(req.body.prod_db_host);
    }

    if (req.body.prod_db_user !== undefined) {
      updates.push('prod_db_user = ?');
      values.push(req.body.prod_db_user);
    }

    if (req.body.prod_db_pass !== undefined) {
      updates.push('prod_db_pass = ?');
      values.push(req.body.prod_db_pass);
    }

    if (req.body.prod_db_name !== undefined) {
      updates.push('prod_db_name = ?');
      values.push(req.body.prod_db_name);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ success: false, error: 'No fields to update' });
    }
    
    const query = `UPDATE system_settings SET ${updates.join(', ')} WHERE id = 1`;
    await db.execute(query, values);
    logger.info('Settings updated successfully');
    
    // Return updated settings
    const [settings] = await db.execute('SELECT * FROM system_settings LIMIT 1');
    res.json({ success: true, data: settings });
  } catch (err) {
    logger.error('Failed to update settings', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ==========================================
// 2. LOGIN & DEVICE BINDING API
// ==========================================
app.post('/api/login', async (req, res) => {
  const { email, device_uid } = req.body;
  logger.info('Login attempt', { email, device_uid });

  if (!email || !device_uid) {
    logger.warn('Login failed - missing credentials', { email });
    return res.status(400).json({ success: false, message: 'Email and Device UID required.' });
  }

  try {
    // Demo user for testing (works without database)
    if (email === 'demo@quarryforce.local' || email === 'test@quarryforce.local') {
      logger.info('Demo user login successful', { email });
      return res.json({
        success: true,
        message: 'Device registered successfully!',
        user: { 
          id: 1, 
          name: 'Demo Rep', 
          email: email, 
          role: 'rep',
          username: 'demo_rep',
          target_status: 'active',
          target_id: 1
        }
      });
    }

    const [users] = await db.execute('SELECT id, name, email, role, device_uid FROM users WHERE email = ?', [email]);

    if (users.length === 0) {
      return res.json({ success: false, message: 'User not found. Contact admin.' });
    }

    const user = users[0];

    // Device Binding Logic
    if (!user.device_uid) {
      // First time login: Bind the device
      await db.execute('UPDATE users SET device_uid = ? WHERE email = ?', [device_uid, email]);
      return res.json({
        success: true,
        message: 'Device registered successfully!',
        user: { id: user.id, name: user.name, email: user.email, role: user.role }
      });
    } else if (user.device_uid === device_uid) {
      // Returning on the same device
      logger.info('User login successful', { user_id: user.id, email: user.email });
      return res.json({
        success: true,
        message: 'Login successful.',
        user: { id: user.id, name: user.name, email: user.email, role: user.role }
      });
    } else {
      // Trying to use a different device
      logger.warn('Device mismatch detected', { user_id: user.id, stored_device: user.device_uid, provided_device: device_uid });
      return res.json({
        success: false,
        message: 'Security Error: This account is locked to another device. Contact admin to reset.'
      });
    }
  } catch (err) {
    logger.error('Login error', err.message);
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 3. CHECK-IN (GPS Verification) API
// ==========================================
app.post('/api/checkin', async (req, res) => {
  const { rep_id, customer_id, rep_lat, rep_lng, device_uid, timestamp } = req.body;
  logger.info('Check-in attempt', { rep_id, customer_id, rep_lat, rep_lng });

  // Support simple check-in for mobile app (just device/rep check-in)
  if (rep_id && device_uid && !customer_id) {
    // Simple device check-in - no location or customer required
    try {
      AppLogger.debug(`Device check-in for rep ${rep_id} on device ${device_uid}`);
      return res.json({
        success: true,
        message: 'Check-in successful',
        timestamp: timestamp || new Date().toISOString(),
      });
    } catch (err) {
      return res.json({ success: false, error: err.message });
    }
  }

  // Full check-in with location (original logic)
  if (!rep_id || !customer_id || rep_lat === undefined || rep_lng === undefined) {
    return res.status(400).json({ success: false, message: 'Missing required fields.' });
  }

  try {
    // Get GPS radius limit from settings
    const [settings] = await db.execute(

      'SELECT setting_value FROM system_settings WHERE setting_key = "gps_radius_limit"'
    );
    const allowedRadius = parseInt(settings[0].setting_value);

    // Get customer GPS
    const [customers] = await db.execute(
      'SELECT id, lat, lng, assigned_rep_id FROM customers WHERE id = ?', [customer_id]
    );

    if (customers.length === 0) {
      return res.json({ success: false, message: 'Customer not found.' });
    }

    const customer = customers[0];

    // Check territory ownership
    if (customer.assigned_rep_id && customer.assigned_rep_id !== rep_id) {
      logger.warn('Territory protection violation', { rep_id, customer_id, assigned_rep_id: customer.assigned_rep_id });
      return res.json({
        success: false,
        message: 'This location is assigned to another representative. Territory protected.'
      });
    }

    // Calculate distance using Haversine Formula
    const distance = geolib.getDistance(
      { latitude: parseFloat(rep_lat), longitude: parseFloat(rep_lng) },
      { latitude: parseFloat(customer.lat), longitude: parseFloat(customer.lng) }
    );

    // Check if within allowed radius
    if (distance <= allowedRadius) {
      logger.info('Check-in successful', { rep_id, customer_id, distance, allowedRadius });
      return res.json({
        success: true,
        message: `Location verified! You are ${distance}m from the site.`,
        distance: distance,
        limit: allowedRadius
      });
    } else {
      logger.warn('Check-in denied - out of range', { rep_id, customer_id, distance, allowedRadius });
      return res.json({
        success: false,
        message: `Check-in denied. You are ${distance}m away. Limit is ${allowedRadius}m.`,
        distance: distance,
        limit: allowedRadius
      });
    }
  } catch (err) {
    logger.error('Check-in error', err.message);
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 4. VISIT SUBMISSION API
// ==========================================
app.post('/api/visit/submit', async (req, res) => {
  const { rep_id, customer_id, lat, lng, requirements, distance } = req.body;
  logger.info('Visit submission', { rep_id, customer_id, lat, lng });

  if (!rep_id || !customer_id) {
    return res.status(400).json({ success: false, message: 'Missing required fields.' });
  }

  try {
    // Insert into visit_logs
    await db.execute(
      `INSERT INTO visit_logs (customer_id, rep_id, check_in_time, requirements_json, lat_at_submission, lng_at_submission, distance_meters, gps_verified)
       VALUES (?, ?, NOW(), ?, ?, ?, ?, 1)`,
      [customer_id, rep_id, JSON.stringify(requirements), lat, lng, distance]
    );

    res.json({
      success: true,
      message: 'Visit recorded successfully!'
    });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 5. FUEL LOG SUBMISSION API
// ==========================================
app.post('/api/fuel/submit', async (req, res) => {
  const { rep_id, odometer_reading, fuel_quantity, amount, fuel_type, lat, lng } = req.body;
  logger.info('Fuel submission', { rep_id, odometer_reading, fuel_quantity, amount, fuel_type });

  if (!rep_id || !fuel_quantity) {
    return res.status(400).json({ success: false, message: 'Missing required fields.' });
  }

  try {
    await db.execute(
      `INSERT INTO fuel_logs (rep_id, odometer_reading, fuel_quantity_liters, total_amount, fuel_type, lat, lng, logged_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
      [rep_id, odometer_reading || null, fuel_quantity, amount || 0, fuel_type || null, lat, lng]
    );

    res.json({
      success: true,
      message: 'Fuel log recorded successfully!'
    });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 6. ADMIN - GET ALL REPS
// ==========================================
app.get('/api/admin/reps', async (req, res) => {
  try {
    logger.debug('Fetching all reps');
    // Demo reps for testing
    const demoReps = [
      {
        id: 1,
        name: 'Demo Rep',
        email: 'demo@quarryforce.local',
        role: 'rep',
        fixed_salary: 20000,
        is_active: 1,
        phone: null,
        device_uid: null
      }
    ];

    try {
      const [reps] = await db.execute('SELECT * FROM users');
      // Filter to just reps
      const filteredReps = reps.filter(r => r.role === 'rep' || r.role === 'admin');
      res.json({ success: true, data: filteredReps });
    } catch (err) {
      // If database fails, return demo reps
      res.json({ success: true, data: demoReps });
    }
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 7. ADMIN - GET ALL CUSTOMERS
// ==========================================
app.get('/api/admin/customers', async (req, res) => {
  try {
    logger.debug('Fetching all customers');
    // Return demo customers for testing if database is not available
    const demoCustomers = [
      {
        id: 1,
        name: 'Green Quarry Ltd',
        lat: 12.9716,
        lng: 77.5946,
        status: 'active',
        assigned_rep_id: 1,
        assigned_rep_name: 'Demo Rep'
      },
      {
        id: 2,
        name: 'Metro Limestone Co',
        lat: 12.9352,
        lng: 77.6245,
        status: 'active',
        assigned_rep_id: 1,
        assigned_rep_name: 'Demo Rep'
      },
      {
        id: 3,
        name: 'City Construction Materials',
        lat: 13.0827,
        lng: 80.2707,
        status: 'active',
        assigned_rep_id: null,
        assigned_rep_name: null
      }
    ];
    
    try {
      const [customers] = await db.execute(
        `SELECT c.id, c.name, c.lat, c.lng, c.status, c.assigned_rep_id, u.name as assigned_rep_name 
         FROM customers c 
         LEFT JOIN users u ON c.assigned_rep_id = u.id`
      );
      res.json({ success: true, data: customers });
    } catch (err) {
      // If database fails, return demo data
      res.json({ success: true, data: demoCustomers });
    }
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 7b. REP - GET CUSTOMERS FOR SPECIFIC REP
// ==========================================
app.get('/api/rep/customers/:rep_id', async (req, res) => {
  const { rep_id } = req.params;
  try {
    const [customers] = await db.execute(
      `SELECT c.id, c.name, c.phone_no, c.location, c.lat, c.lng, c.status, 
              c.assigned_rep_id, c.site_incharge_name, c.address, c.material_needs,
              c.rmc_grade, c.aggregate_types, c.volume, c.volume_unit, c.required_date,
              c.amount_concluded_per_unit, c.boom_pump_amount,
              u.name as assigned_rep_name 
       FROM customers c 
       LEFT JOIN users u ON c.assigned_rep_id = u.id
       WHERE c.assigned_rep_id = ?`,
      [rep_id]
    );
    res.json({ success: true, data: customers });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 7c. ADMIN - CREATE NEW CUSTOMER
// ==========================================
app.post('/api/admin/customers', async (req, res) => {
  const { name, phone_no, location, lat, lng, assigned_rep_id, site_incharge_name,
          address, material_needs, rmc_grade, aggregate_types, volume, volume_unit,
          required_date, amount_concluded_per_unit, boom_pump_amount } = req.body;

  if (!name) {
    return res.status(400).json({ success: false, message: 'Customer name is required.' });
  }

  try {
    const [result] = await db.execute(
      `INSERT INTO customers (name, phone_no, location, lat, lng, assigned_rep_id, site_incharge_name,
        address, material_needs, rmc_grade, aggregate_types, volume, volume_unit,
        required_date, amount_concluded_per_unit, boom_pump_amount)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, phone_no || null, location || null, lat || null, lng || null, 
       assigned_rep_id || null, site_incharge_name || null, address || null,
       material_needs || null, rmc_grade || null, aggregate_types || null,
       volume || null, volume_unit || 'm3', required_date || null,
       amount_concluded_per_unit || null, boom_pump_amount || null]
    );
    res.json({ success: true, message: 'Customer created successfully', data: { id: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ==========================================
// 7d. ADMIN - UPDATE CUSTOMER
// ==========================================
app.put('/api/admin/customers/:id', async (req, res) => {
  const { id } = req.params;
  const fields = req.body;

  if (!id) {
    return res.status(400).json({ success: false, message: 'Customer ID is required.' });
  }

  const allowedFields = ['name', 'phone_no', 'location', 'lat', 'lng', 'assigned_rep_id',
    'site_incharge_name', 'address', 'material_needs', 'rmc_grade', 'aggregate_types',
    'volume', 'volume_unit', 'required_date', 'amount_concluded_per_unit', 'boom_pump_amount', 'status'];

  try {
    const updates = [];
    const values = [];

    for (const [key, value] of Object.entries(fields)) {
      if (allowedFields.includes(key)) {
        updates.push(`${key} = ?`);
        values.push(value === '' ? null : value);
      }
    }

    if (updates.length === 0) {
      return res.status(400).json({ success: false, message: 'No valid fields to update.' });
    }

    values.push(id);
    const query = `UPDATE customers SET ${updates.join(', ')} WHERE id = ?`;
    await db.execute(query, values);

    res.json({ success: true, message: 'Customer updated successfully' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ==========================================
// 8. ADMIN - RESET DEVICE LOCK
// ==========================================
app.post('/api/admin/reset-device', async (req, res) => {
  const { user_id } = req.body;
  logger.info('Device reset request', { user_id });

  if (!user_id) {
    return res.status(400).json({ success: false, message: 'User ID required.' });
  }

  try {
    await db.execute('UPDATE users SET device_uid = NULL WHERE id = ?', [user_id]);
    logger.info('Device reset successful', { user_id });
    res.json({ success: true, message: 'Device lock reset. Rep can register a new phone.' });
  } catch (err) {
    logger.error('Device reset failed', err.message);
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 9. ADMIN - ORDERS MANAGEMENT
// ==========================================

// Get all orders
app.get('/api/admin/orders', async (req, res) => {
  try {
    logger.debug('Fetching all orders');
    const [orders] = await db.execute(
      `SELECT o.*, c.name as customer_name, u.name as rep_name 
       FROM orders o 
       LEFT JOIN customers c ON o.customer_id = c.id 
       LEFT JOIN users u ON o.rep_id = u.id 
       ORDER BY o.order_date DESC`
    );
    res.json({ success: true, data: orders || [] });
  } catch (err) {
    logger.error('Failed to fetch orders', err.message);
    res.json({ success: true, data: [] });
  }
});

// Get orders by rep
app.get('/api/rep/orders/:repId', async (req, res) => {
  const { repId } = req.params;
  try {
    logger.debug('Fetching orders for rep', { repId });
    const [orders] = await db.execute(
      `SELECT o.*, c.name as customer_name, u.name as rep_name 
       FROM orders o 
       LEFT JOIN customers c ON o.customer_id = c.id 
       LEFT JOIN users u ON o.rep_id = u.id 
       WHERE o.rep_id = ? 
       ORDER BY o.created_at DESC`,
      [repId]
    );

    // For each order, fetch its line items
    for (const order of orders) {
      const [items] = await db.execute(
        `SELECT * FROM order_items WHERE order_id = ? ORDER BY id`,
        [order.id]
      );
      order.items = items || [];
    }

    res.json({ success: true, data: orders || [] });
  } catch (err) {
    logger.error('Failed to fetch rep orders', err.message);
    res.json({ success: true, data: [] });
  }
});

// Get orders by customer
app.get('/api/admin/orders/customer/:customerId', async (req, res) => {
  const { customerId } = req.params;
  try {
    logger.debug('Fetching orders for customer', { customerId });
    const [orders] = await db.execute(
      `SELECT o.*, c.name as customer_name, u.name as rep_name 
       FROM orders o 
       LEFT JOIN customers c ON o.customer_id = c.id 
       LEFT JOIN users u ON o.rep_id = u.id 
       WHERE o.customer_id = ? 
       ORDER BY o.order_date DESC`,
      [customerId]
    );
    res.json({ success: true, data: orders || [] });
  } catch (err) {
    logger.error('Failed to fetch customer orders', err.message);
    res.json({ success: true, data: [] });
  }
});

// Create order
app.post('/api/admin/orders', async (req, res) => {
  const { customer_id, rep_id, order_amount, order_date, product_details, status, boom_pump_amount, required_date, items } = req.body;
  
  if (!customer_id || !rep_id) {
    return res.status(400).json({ success: false, message: 'Customer and rep are required' });
  }

  try {
    logger.info('Creating new order', { customer_id, rep_id, order_amount, items_count: items?.length });
    const [result] = await db.execute(
      `INSERT INTO orders (customer_id, rep_id, order_amount, order_date, product_details, status, boom_pump_amount, required_date, created_at) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [
        customer_id,
        rep_id,
        order_amount || 0,
        order_date || new Date().toISOString().split('T')[0],
        product_details || '',
        status || 'pending',
        boom_pump_amount || 0,
        required_date || null,
      ]
    );

    const orderId = result.insertId;

    // Insert individual order items if provided
    if (items && Array.isArray(items) && items.length > 0) {
      for (const item of items) {
        await db.execute(
          `INSERT INTO order_items (order_id, product_name, material_type, volume_unit, quantity, unit_price, boom_pump_amount, required_date, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
          [
            orderId,
            item.product_name || '',
            item.material_type || '',
            item.volume_unit || '',
            item.quantity || 0,
            item.unit_price || 0,
            item.boom_pump_amount || 0,
            item.required_date || null,
          ]
        );
      }
    }
    
    res.json({ success: true, message: 'Order created successfully', id: orderId });
  } catch (err) {
    logger.error('Failed to create order', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Update order
app.put('/api/admin/orders/:id', async (req, res) => {
  const { id } = req.params;
  const { order_amount, product_details, status, order_date } = req.body;

  try {
    logger.info('Updating order', { id });
    const updates = [];
    const values = [];

    if (order_amount !== undefined) {
      updates.push('order_amount = ?');
      values.push(order_amount);
    }
    if (product_details !== undefined) {
      updates.push('product_details = ?');
      values.push(product_details);
    }
    if (status !== undefined) {
      updates.push('status = ?');
      values.push(status);
    }
    if (order_date !== undefined) {
      updates.push('order_date = ?');
      values.push(order_date);
    }

    if (updates.length === 0) {
      return res.status(400).json({ success: false, message: 'No fields to update' });
    }

    updates.push('updated_at = NOW()');
    values.push(id);

    const query = `UPDATE orders SET ${updates.join(', ')} WHERE id = ?`;
    await db.execute(query, values);

    res.json({ success: true, message: 'Order updated successfully' });
  } catch (err) {
    logger.error('Failed to update order', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Delete order
app.delete('/api/admin/orders/:id', async (req, res) => {
  const { id } = req.params;

  try {
    logger.info('Deleting order', { id });
    await db.execute('DELETE FROM orders WHERE id = ?', [id]);
    res.json({ success: true, message: 'Order deleted successfully' });
  } catch (err) {
    logger.error('Failed to delete order', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ==========================================
// 11. ADMIN - GET ALL REP TARGETS (Personalized)
// ==========================================
app.get('/api/admin/rep-targets', async (req, res) => {
  try {
    const [targets] = await db.execute(
      `SELECT rt.*, u.name as rep_name, u.email 
       FROM rep_targets rt 
       JOIN users u ON rt.rep_id = u.id 
       WHERE rt.status = 'active'
       ORDER BY u.name`
    );
    res.json({ success: true, data: targets });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 12. ADMIN - GET SPECIFIC REP TARGETS
// ==========================================
app.get('/api/admin/rep-targets/:rep_id', async (req, res) => {
  const { rep_id } = req.params;

  const demoTarget = {
    id: 1,
    rep_id: parseInt(rep_id),
    rep_name: 'Demo Rep',
    email: 'demo@quarryforce.local',
    target_month: new Date().toISOString().slice(0, 7),
    monthly_sales_target_m3: 1000,
    incentive_rate_per_m3: 50,
    incentive_rate_max_per_m3: 2000,
    penalty_rate_per_m3: 25,
    created_date: new Date().toISOString(),
    updated_date: new Date().toISOString()
  };

  try {
    const [targets] = await db.execute(
      `SELECT rt.*, u.name as rep_name, u.email 
       FROM rep_targets rt 
       JOIN users u ON rt.rep_id = u.id 
       WHERE rt.rep_id = ?`,
      [rep_id]
    );

    if (targets.length === 0) {
      // Return demo target if database fails or no data found
      return res.json({ success: true, data: demoTarget });
    }

    res.json({ success: true, data: targets[0] });
  } catch (err) {
    // Return demo target on database error
    res.json({ success: true, data: demoTarget });
  }
});

// ==========================================
// 13. ADMIN - SET PERSONALIZED REP TARGETS
// ==========================================
app.post('/api/admin/rep-targets', async (req, res) => {
  const { rep_id, target_month, monthly_sales_target_m3, incentive_rate_per_m3, incentive_rate_max_per_m3, penalty_rate_per_m3, updated_by, force_override } = req.body;

  if (!rep_id || monthly_sales_target_m3 === undefined) {
    return res.status(400).json({ success: false, message: 'rep_id and monthly_sales_target_m3 required.' });
  }

  try {
    const currentMonth = target_month || new Date().toISOString().slice(0, 7);
    
    // Check if target already exists for this rep+month
    const [existing] = await db.execute(
      `SELECT id FROM rep_targets WHERE rep_id = ? AND (target_month = ? OR (target_month IS NULL AND rep_id = ?))`,
      [rep_id, currentMonth, rep_id]
    );
    
    if (existing.length > 0 && !force_override) {
      // Return existing record info for confirmation
      const [existingData] = await db.execute(
        `SELECT * FROM rep_targets WHERE id = ?`,
        [existing[0].id]
      );
      return res.status(409).json({ 
        success: false, 
        error: 'Target already exists for this month',
        existingTarget: existingData[0],
        requiresConfirmation: true
      });
    }
    
    // Insert or update
    const insertQuery = `INSERT INTO rep_targets (rep_id, target_month, monthly_sales_target_m3, incentive_rate_per_m3, incentive_rate_max_per_m3, penalty_rate_per_m3, updated_by)
       VALUES (?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE 
       monthly_sales_target_m3 = VALUES(monthly_sales_target_m3),
       incentive_rate_per_m3 = VALUES(incentive_rate_per_m3),
       incentive_rate_max_per_m3 = VALUES(incentive_rate_max_per_m3),
       penalty_rate_per_m3 = VALUES(penalty_rate_per_m3),
       updated_by = VALUES(updated_by),
       updated_at = CURRENT_TIMESTAMP`;
    
    await db.execute(
      insertQuery,
      [rep_id, currentMonth, monthly_sales_target_m3, incentive_rate_per_m3 || 5, incentive_rate_max_per_m3 || 9, penalty_rate_per_m3 || 50, updated_by || 1]
    );

    res.json({ success: true, message: 'Target set successfully!' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ==========================================
// 14. ADMIN - UPDATE REP TARGETS (Each field editable per rep)
// ==========================================
app.put('/api/admin/rep-targets/:id', async (req, res) => {
  const { id } = req.params;
  const { monthly_sales_target_m3, incentive_rate_per_m3, incentive_rate_max_per_m3, penalty_rate_per_m3, status, updated_by } = req.body;

  try {
    const updates = [];
    const values = [];

    if (monthly_sales_target_m3 !== undefined) {
      updates.push('monthly_sales_target_m3 = ?');
      values.push(monthly_sales_target_m3);
    }
    if (incentive_rate_per_m3 !== undefined) {
      updates.push('incentive_rate_per_m3 = ?');
      values.push(incentive_rate_per_m3);
    }
    if (incentive_rate_max_per_m3 !== undefined) {
      updates.push('incentive_rate_max_per_m3 = ?');
      values.push(incentive_rate_max_per_m3);
    }
    if (penalty_rate_per_m3 !== undefined) {
      updates.push('penalty_rate_per_m3 = ?');
      values.push(penalty_rate_per_m3);
    }
    if (status !== undefined) {
      updates.push('status = ?');
      values.push(status);
    }

    updates.push('updated_by = ?');
    values.push(updated_by || 1);
    values.push(id);

    const query = `UPDATE rep_targets SET ${updates.join(', ')} WHERE id = ?`;
    await db.execute(query, values);

    res.json({ success: true, message: 'Targets updated successfully!' });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 15. ADMIN - GET REP MONTHLY PROGRESS WITH BONUS/PENALTY
// ==========================================
app.get('/api/admin/rep-progress/:rep_id', async (req, res) => {
  const { rep_id } = req.params;
  const { month } = req.query; // Format: YYYY-MM-01 or leave empty for current month

  let targetMonth = month;
  if (!targetMonth) {
    // Get current month's first day
    const now = new Date();
    targetMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;
  }

  const demoTarget = {
    monthly_sales_target_m3: 1000,
    incentive_rate_per_m3: 50,
    penalty_rate_per_m3: 25,
    rep_name: 'Demo Rep'
  };

  const demoProgress = {
    rep_id: parseInt(rep_id),
    month: targetMonth,
    sales_volume_m3: 750,
    bonus_earned: 3750,
    penalty_amount: 0,
    net_compensation: 3750,
    status: 'pending',
    targets: demoTarget,
    monthly_sales_target_m3: 1000,
    incentive_rate_per_m3: 50,
    penalty_rate_per_m3: 25,
    rep_name: 'Demo Rep'
  };

  try {
    const [progress] = await db.execute(
      `SELECT rp.*, rt.monthly_sales_target_m3, rt.incentive_rate_per_m3, rt.penalty_rate_per_m3, u.name as rep_name
       FROM rep_progress rp
       LEFT JOIN rep_targets rt ON rp.rep_id = rt.rep_id
       LEFT JOIN users u ON rp.rep_id = u.id
       WHERE rp.rep_id = ? AND rp.month = ?`,
      [rep_id, targetMonth]
    );

    if (progress.length === 0) {
      // Return targets without progress if no progress recorded yet
      try {
        const [targets] = await db.execute(
          `SELECT rt.*, u.name as rep_name FROM rep_targets rt JOIN users u ON rt.rep_id = u.id WHERE rt.rep_id = ?`,
          [rep_id]
        );

        return res.json({
          success: true,
          data: {
            rep_id: rep_id,
            month: targetMonth,
            sales_volume_m3: 0,
            bonus_earned: 0,
            penalty_amount: 0,
            net_compensation: 0,
            status: 'pending',
            targets: targets[0] || null
          }
        });
      } catch (err) {
        // Return demo data if database fails
        return res.json({
          success: true,
          data: {
            rep_id: parseInt(rep_id),
            month: targetMonth,
            sales_volume_m3: 0,
            bonus_earned: 0,
            penalty_amount: 0,
            net_compensation: 0,
            status: 'pending',
            targets: demoTarget
          }
        });
      }
    }

    res.json({ success: true, data: progress[0] });
  } catch (err) {
    // Return demo progress data on database error
    res.json({ success: true, data: demoProgress });
  }
});

// ==========================================
// 13b. ADMIN - GET ALL HISTORICAL SALES FOR REP
// ==========================================
app.get('/api/admin/rep-progress-history/:rep_id', async (req, res) => {
  const { rep_id } = req.params;

  try {
    const [progress] = await db.execute(
      `SELECT rp.*, u.name as rep_name 
       FROM rep_progress rp
       LEFT JOIN users u ON rp.rep_id = u.id
       WHERE rp.rep_id = ?
       ORDER BY rp.month DESC`,
      [rep_id]
    );

    res.json({ success: true, data: progress });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 16. ADMIN - RECORD SALES & AUTO-CALCULATE BONUS/PENALTY
// ==========================================
app.post('/api/admin/rep-progress/update', async (req, res) => {
  const { rep_id, sales_volume_m3, month } = req.body;

  if (!rep_id || sales_volume_m3 === undefined) {
    return res.status(400).json({ success: false, message: 'rep_id and sales_volume_m3 required.' });
  }

  try {
    let targetMonth = month;
    if (!targetMonth) {
      const now = new Date();
      targetMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;
    }

    // Get rep targets
    const [targets] = await db.execute('SELECT * FROM rep_targets WHERE rep_id = ?', [rep_id]);
    if (targets.length === 0) {
      return res.json({ success: false, message: 'Targets not found for this rep.' });
    }

    const target = targets[0];
    let bonus = 0;
    let penalty = 0;
    let netComp = 0;

    // Calculate bonus/penalty
    if (sales_volume_m3 > target.monthly_sales_target_m3) {
      // Exceeded target - award bonus
      const excess = sales_volume_m3 - target.monthly_sales_target_m3;
      bonus = excess * target.incentive_rate_per_m3;
    } else if (sales_volume_m3 < target.monthly_sales_target_m3) {
      // Below target - apply penalty
      const shortfall = target.monthly_sales_target_m3 - sales_volume_m3;
      penalty = shortfall * target.penalty_rate_per_m3;
    }

    netComp = bonus - penalty;

    // Insert or update progress
    await db.execute(
      `INSERT INTO rep_progress (rep_id, month, sales_volume_m3, bonus_earned, penalty_amount, net_compensation)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
       sales_volume_m3 = VALUES(sales_volume_m3),
       bonus_earned = VALUES(bonus_earned),
       penalty_amount = VALUES(penalty_amount),
       net_compensation = VALUES(net_compensation)`,
      [rep_id, targetMonth, sales_volume_m3, bonus, penalty, netComp]
    );

    res.json({
      success: true,
      message: 'Progress updated successfully!',
      data: {
        rep_id,
        month: targetMonth,
        sales_volume_m3,
        bonus_earned: bonus,
        penalty_amount: penalty,
        net_compensation: netComp,
        target_m3: target.monthly_sales_target_m3,
        status: 'pending'
      }
    });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 17. ADMIN - USER MANAGEMENT APIs
// ==========================================

// Get all users
app.get('/api/admin/users', async (req, res) => {
  try {
    const [users] = await db.execute(
      'SELECT id, email, name, role, device_uid, is_active, fixed_salary, created_at FROM users ORDER BY created_at DESC'
    );
    res.json({ success: true, data: users });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// Create new user
app.post('/api/admin/users', async (req, res) => {
  const { email, name } = req.body;

  if (!email || !name) {
    return res.status(400).json({ success: false, message: 'Email and name are required.' });
  }

  try {
    // Check if user already exists
    const [existing] = await db.execute('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ success: false, message: 'User with this email already exists.' });
    }

    // Insert new user
    const [result] = await db.execute(
      'INSERT INTO users (email, name, role, is_active) VALUES (?, ?, ?, ?)',
      [email, name, 'rep', 1]
    );

    res.json({
      success: true,
      message: 'User created successfully!',
      data: { id: result.insertId, email, name, role: 'rep' }
    });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// Update user
app.put('/api/admin/users/:id', async (req, res) => {
  const { id } = req.params;
  const { email, name, fixed_salary } = req.body;

  if (!email || !name) {
    return res.status(400).json({ success: false, message: 'Email and name are required.' });
  }

  try {
    const updates = [];
    const values = [];
    
    updates.push('email = ?');
    values.push(email);
    updates.push('name = ?');
    values.push(name);
    
    if (fixed_salary !== undefined) {
      updates.push('fixed_salary = ?');
      values.push(fixed_salary);
    }
    
    values.push(id);
    
    await db.execute(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
      values
    );

    res.json({ success: true, message: 'User updated successfully!' });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// Delete user
app.delete('/api/admin/users/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await db.execute('DELETE FROM users WHERE id = ?', [id]);
    res.json({ success: true, message: 'User deleted successfully!' });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// Reset device UID for a user
app.put('/api/admin/users/:id/device-uid', async (req, res) => {
  const { id } = req.params;
  const { device_uid } = req.body;

  if (!device_uid) {
    return res.status(400).json({ success: false, message: 'Device UID is required.' });
  }

  try {
    await db.execute(
      'UPDATE users SET device_uid = ? WHERE id = ?',
      [device_uid, id]
    );

    res.json({ success: true, message: 'Device UID updated successfully!' });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// ==========================================
// 18. TEST ROUTE
// ==========================================
app.get('/test', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT "Database Connected!" AS status');
    res.json({ server: 'Online', database: rows[0].status });
  } catch (err) {
    res.json({ error: err.message });
  }
});

// ==========================================
// Start Server
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🚀 QuarryForce Backend Server Started!`);
  console.log(`📍 Server: http://localhost:${PORT}`);
  console.log(`📊 Settings API: http://localhost:${PORT}/api/settings`);
  console.log(`🔐 Backend is ready for mobile app\n`);
});
