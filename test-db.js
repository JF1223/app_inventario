const mysql = require('mysql2/promise');

async function testConnection() {
  let connection;
  try {
    console.log('Testing MySQL connection...');
    connection = await mysql.createConnection({
      host: 'localhost',
      port: 3307,  // Changed from 3306 to 3307 as per docker-compose
      user: 'root',
      password: 'neveras123'
    });

    console.log('Connection successful!');
    const [rows] = await connection.query('SELECT 1 as test');
    console.log('Query result:', rows);

  } catch (error) {
    console.error('Connection error:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

testConnection();