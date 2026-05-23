require('dotenv').config({ path: require('path').join(__dirname, 'backend', '.env') });
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Usamos DATABASE_URL directamente (Supabase o cualquier PostgreSQL)
const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('ERROR: No se encontró DATABASE_URL en backend/.env');
  process.exit(1);
}

async function initDatabase() {
  let client;
  try {
    console.log('Conectando a PostgreSQL (Supabase)...');
    console.log('URL:', connectionString.replace(/:[^:@]+@/, ':****@')); // Ocultar password en log
    
    client = new Client({
      connectionString,
      ssl: { rejectUnauthorized: false }
    });
    await client.connect();
    console.log('¡Conexión exitosa!');

    // Limpiar esquema public
    console.log('Limpiando el esquema public...');
    await client.query('DROP SCHEMA public CASCADE');
    await client.query('CREATE SCHEMA public');
    await client.query('GRANT ALL ON SCHEMA public TO postgres');
    await client.query('GRANT ALL ON SCHEMA public TO public');
    console.log('Esquema public limpiado.');

    // 1. Cargar schema.sql
    console.log('Cargando database/schema.sql...');
    const schemaPath = path.join(__dirname, 'database', 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    await client.query(schemaSql);
    console.log('✅ Tablas creadas exitosamente.');

    // 2. Cargar seed.sql
    console.log('Cargando database/seed.sql...');
    const seedPath = path.join(__dirname, 'database', 'seed.sql');
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    await client.query(seedSql);
    console.log('✅ Datos iniciales insertados.');

    // 3. Cargar procedures.sql
    console.log('Cargando database/procedures.sql...');
    const proceduresPath = path.join(__dirname, 'database', 'procedures.sql');
    const proceduresSql = fs.readFileSync(proceduresPath, 'utf8');
    await client.query(proceduresSql);
    console.log('✅ Procedimientos almacenados cargados.');

    // Verificar tablas creadas
    const tables = await client.query(`
      SELECT table_name FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);
    console.log('\n📋 Tablas creadas:');
    tables.rows.forEach(r => console.log('  -', r.table_name));

    console.log('\n🎉 ¡Inicialización completada con éxito!');
  } catch (error) {
    console.error('❌ Error durante la inicialización:', error.message);
    if (error.message.includes('SASL') || error.message.includes('password')) {
      console.error('💡 Verifica que la contraseña en DATABASE_URL sea correcta.');
    }
  } finally {
    if (client) {
      await client.end();
    }
  }
}

initDatabase();
