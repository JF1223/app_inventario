const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: 'postgres' // Conectamos a postgres default primero
};

async function resetDatabase() {
  let client;
  let targetClient;

  try {
    console.log('Connecting to PostgreSQL server...');
    client = new Client(dbConfig);
    await client.connect();

    const databaseName = process.env.DB_DATABASE || 'neveras_db';
    console.log(`Dropping database ${databaseName} if exists...`);
    await client.query(`DROP DATABASE IF EXISTS "${databaseName}"`);

    console.log(`Creating database ${databaseName}...`);
    await client.query(`CREATE DATABASE "${databaseName}"`);
    await client.end();

    console.log(`Connecting to new database ${databaseName}...`);
    const targetConfig = { ...dbConfig, database: databaseName };
    targetClient = new Client(targetConfig);
    await targetClient.connect();

    console.log('Loading schema.sql...');
    const schemaPath = path.join(__dirname, 'database', 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    await targetClient.query(schemaSql);
    console.log('Schema created successfully.');

    console.log('Loading seed.sql...');
    const seedPath = path.join(__dirname, 'database', 'seed.sql');
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    await targetClient.query(seedSql);
    console.log('Seed data inserted successfully.');

    console.log('Loading procedures.sql...');
    const proceduresPath = path.join(__dirname, 'database', 'procedures.sql');
    const proceduresSql = fs.readFileSync(proceduresPath, 'utf8');
    await targetClient.query(proceduresSql);
    console.log('Procedures loaded successfully.');

    console.log('Database reset completed successfully!');

  } catch (error) {
    console.error('Error resetting database:', error);
    throw error;
  } finally {
    if (targetClient) await targetClient.end();
  }
}

resetDatabase().then(() => process.exit(0)).catch(() => process.exit(1));