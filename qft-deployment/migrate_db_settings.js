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
        console.log('Adding production database settings to system_settings...');
        
        await connection.execute('ALTER TABLE system_settings ADD COLUMN prod_db_host VARCHAR(255) DEFAULT "localhost"');
        await connection.execute('ALTER TABLE system_settings ADD COLUMN prod_db_user VARCHAR(255) DEFAULT "root"');
        await connection.execute('ALTER TABLE system_settings ADD COLUMN prod_db_pass VARCHAR(255) DEFAULT ""');
        await connection.execute('ALTER TABLE system_settings ADD COLUMN prod_db_name VARCHAR(255) DEFAULT "quarryforce_db"');
        
        console.log('Migration successful!');
    } catch (err) {
        if (err.code === 'ER_DUP_COLUMN_NAME') {
            console.log('One or more columns already exist. Skipping duplicates.');
        } else {
            console.error('Migration failed:', err.message);
        }
    } finally {
        await connection.end();
    }
}

migrate();
