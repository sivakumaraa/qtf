const mysql = require('mysql2/promise');
require('dotenv').config({ path: '../.env' });

async function fixTable() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'quarryforce_db'
    });

    console.log('Connected to database.');

    try {
        // 1. Create a backup table
        console.log('Backing up old settings...');
        await connection.execute('CREATE TABLE IF NOT EXISTS system_settings_old AS SELECT * FROM system_settings');

        // 2. Drop and recreate to match the required single-row schema
        console.log('Regenerating system_settings table...');
        await connection.execute('DROP TABLE IF EXISTS system_settings');
        
        await connection.execute(`
            CREATE TABLE system_settings (
                id INT PRIMARY KEY DEFAULT 1,
                gps_radius_limit INT DEFAULT 150,
                company_name VARCHAR(255) DEFAULT 'QFS',
                company_logo LONGTEXT,
                company_address TEXT,
                company_email VARCHAR(255),
                company_phone VARCHAR(20),
                currency_symbol VARCHAR(3) DEFAULT '₹',
                site_types JSON DEFAULT '["Private", "Public", "Home", "Apartment"]',
                logging_enabled TINYINT DEFAULT 1,
                production_url VARCHAR(255) DEFAULT 'https://admin.quarryforce.pro',
                backend_port INT DEFAULT 8000,
                mobile_api_url VARCHAR(255) DEFAULT 'http://10.0.2.2:8000/api',
                prod_db_host VARCHAR(255) DEFAULT 'localhost',
                prod_db_user VARCHAR(255) DEFAULT 'root',
                prod_db_pass VARCHAR(255) DEFAULT '',
                prod_db_name VARCHAR(255) DEFAULT 'quarryforce_db',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        `);

        // 3. Insert the single row
        await connection.execute('INSERT INTO system_settings (id) VALUES (1)');
        
        console.log('Table fixed successfully!');
    } catch (err) {
        console.error('Failed to fix table:', err.message);
    } finally {
        await connection.end();
    }
}

fixTable();
