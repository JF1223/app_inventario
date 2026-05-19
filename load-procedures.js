const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root',
  database: process.env.DB_DATABASE || 'neveras_db'
};

async function loadProcedures() {
  let connection;
  try {
    console.log('Connecting to MySQL server...');
    connection = await mysql.createConnection(dbConfig);

    const sqlPath = path.join(__dirname, 'database', 'procedures.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');

    const drops = [...sqlContent.matchAll(/DROP PROCEDURE IF EXISTS [a-zA-Z0-9_]+;/g)].map(m => m[0]);
    const creates = [...sqlContent.matchAll(/CREATE PROCEDURE[\s\S]*?END(?=\s*\/\/)/g)].map(m => m[0]);

    console.log(`Found ${drops.length} DROP statements and ${creates.length} CREATE statements.`);

    for (const drop of drops) {
      await connection.query(drop);
    }
    console.log('Executed all DROP statements.');

    for (const create of creates) {
      await connection.query(create);
    }
    console.log('Executed all CREATE statements.');

    console.log('Procedures loaded successfully!');
  } catch (error) {
    console.error('Error:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

loadProcedures();
