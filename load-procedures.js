require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_DATABASE || 'neveras_db',
  ssl: { rejectUnauthorized: false }
};

async function loadProcedures() {
  let client;
  try {
    console.log('Connecting to PostgreSQL server...');
    client = new Client(dbConfig);
    await client.connect();

    const sqlPath = path.join(__dirname, 'database', 'procedures.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');

    // En PostgreSQL podemos enviar todo el archivo de funciones como un solo script
    await client.query(sqlContent);
    
    console.log('Procedures loaded successfully!');
  } catch (error) {
    console.error('Error:', error);
  } finally {
    if (client) {
      await client.end();
    }
  }
}

loadProcedures();
