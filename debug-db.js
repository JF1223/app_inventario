const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

// Database connection configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'neveras123'
};

console.log('Database config:', dbConfig);

async function testConnection() {
  let connection;

  try {
    console.log('Connecting to MySQL server...');
    connection = await mysql.createConnection(dbConfig);

    console.log('Connected successfully!');

    // Test a simple query
    const [rows] = await connection.query('SELECT 1 as test');
    console.log('Test query result:', rows);

  } catch (error) {
    console.error('Error connecting to MySQL:', error);
    console.error('Error code:', error.code);
    console.error('Error errno:', error.errno);
    console.error('Error sqlState:', error.sqlState);
    console.error('Error sqlMessage:', error.sqlMessage);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

testConnection();