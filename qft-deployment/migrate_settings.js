const mysql = require('mysql2/promise');
require('dotenv').config({ path: '../.env' });

async function migrate() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'quarryforce_db'
    });

    console.log('Connected to database.');

    try {
        console.log('Adding production_url and backend_port to system_settings...');
        await connection.execute('ALTER TABLE system_settings ADD COLUMN production_url VARCHAR(255) DEFAULT "https://admin.quarryforce.pro"');
        await connection.execute('ALTER TABLE system_settings ADD COLUMN backend_port INT DEFAULT 8000');
        console.log('Migration successful!');
    } catch (err) {
        if (err.code === 'ER_DUP_COLUMN_NAME') {
            console.log('Columns already exist. Skipping.');
        } else {
            console.error('Migration failed:', err.message);
        }
    } finally {
        await connection.end();
    }
}

migrate();
