const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

// Database connection configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root'
};

async function resetDatabase() {
  let connection;

  try {
    console.log('Connecting to MySQL server...');
    connection = await mysql.createConnection(dbConfig);

    const databaseName = process.env.DB_DATABASE || 'neveras_db';
    console.log(` Dropping database ${databaseName} if exists...`);
    await connection.query(`DROP DATABASE IF EXISTS \`${databaseName}\``);

    console.log(` Creating database ${databaseName}...`);
    await connection.query(`CREATE DATABASE \`${databaseName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);

    console.log(` Using database ${databaseName}...`);
    await connection.query(`USE \`${databaseName}\``);

    // Read and execute schema.sql
    console.log(' Loading schema.sql...');
    const schemaPath = path.join(__dirname, 'database', 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    // Split by semicolon and execute each statement
    const schemaStatements = schemaSql.split(';').filter(stmt => stmt.trim() !== '');
    for (const statement of schemaStatements) {
      if (statement.trim()) {
        await connection.query(statement);
      }
    }
    console.log(' Schema created successfully.');

    // Read and execute seed.sql
    console.log(' Loading seed.sql...');
    const seedPath = path.join(__dirname, 'database', 'seed.sql');
    const seedSql = fs.readFileSync(seedPath, 'utf8');

    // Split by semicolon and execute each statement
    const seedStatements = seedSql.split(';').filter(stmt => stmt.trim() !== '');
    for (const statement of seedStatements) {
      if (statement.trim()) {
        await connection.query(statement);
      }
    }
    console.log(' Seed data inserted successfully.');

    // Read and execute procedures.sql
    console.log(' Loading procedures.sql...');
    const proceduresPath = path.join(__dirname, 'database', 'procedures.sql');
    const proceduresSql = fs.readFileSync(proceduresPath, 'utf8');

    const drops = [...proceduresSql.matchAll(/DROP PROCEDURE IF EXISTS [a-zA-Z0-9_]+;/g)].map(m => m[0]);
    const creates = [...proceduresSql.matchAll(/CREATE PROCEDURE[\s\S]*?END(?=\s*\/\/)/g)].map(m => m[0]);

    for (const drop of drops) {
      await connection.query(drop);
    }
    for (const create of creates) {
      await connection.query(create);
    }
    console.log(` Procedures loaded successfully (${creates.length} procedures).`);

    console.log(' Database reset completed successfully!');

  } catch (error) {
    console.error(' Error resetting database:', error);
    throw error;
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Execute the function
resetDatabase()
  .then(() => {
    console.log(' Process completed.');
    process.exit(0);
  })
  .catch((error) => {
    console.error(' Process failed:', error);
    process.exit(1);
  });