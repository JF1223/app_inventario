import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { Pool, QueryResult } from 'pg';

@Injectable()
export class DatabaseService
  implements OnModuleInit, OnModuleDestroy
{
  private pool: Pool;

  constructor() {
    this.pool = new Pool({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      user: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,

      // IMPORTANTE PARA SUPABASE
      ssl: {
        rejectUnauthorized: false,
      },
    });
  }

  // ============================================
  // CONEXION
  // ============================================

  async onModuleInit() {
    try {
      const client = await this.pool.connect();

      console.log('✅ PostgreSQL conectado correctamente');

      client.release();
    } catch (error) {
      console.error('❌ Error conectando PostgreSQL:', error);

      throw error;
    }
  }

  // ============================================
  // QUERY GENERAL
  // ============================================

  async query<T = any>(
    text: string,
    params?: any[],
  ): Promise<QueryResult<T>> {
    return this.pool.query(text, params);
  }

  // ============================================
  // CERRAR CONEXION
  // ============================================

  async onModuleDestroy() {
    await this.pool.end();

    console.log('🔌 PostgreSQL desconectado');
  }
}
