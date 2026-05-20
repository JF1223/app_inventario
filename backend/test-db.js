require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USERNAME || process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  ssl: { rejectUnauthorized: false }
});

async function testConnection() {
  try {
    console.log('Intentando conectar con:', process.env.DB_HOST);
    const res = await pool.query('SELECT NOW()');
    console.log('Conexión Exitosa. Hora en la BD:', res.rows[0].now);
  } catch (err) {
    console.error('Error de conexión:', err.message);
  } finally {
    await pool.end();
  }
}

testConnection();
