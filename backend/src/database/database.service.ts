import { Injectable, Inject, OnModuleDestroy } from '@nestjs/common';
import { Pool } from 'pg';

const DATABASE_SYMBOL = 'DATABASE_POOL';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  constructor(@Inject(DATABASE_SYMBOL) private readonly pool: Pool) { }

  async query<T = any>(sql: string, params?: any[]): Promise<T> {
    const result = await this.pool.query(sql, params);
    return result.rows as unknown as T;
  }

  async call<T = any>(procedureName: string, params: any[] = []): Promise<T> {
    if (!procedureName || procedureName.trim() === '') {
      throw new Error("El nombre del procedimiento no puede estar vacío");
    }

    // Corregimos: eliminamos '()' del nombre si es que ya los traía, 
    // para evitar que se dupliquen en la consulta final.
    const cleanProcedureName = procedureName.replace('()', '');

    const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');
    const sql = `SELECT * FROM ${cleanProcedureName}(${placeholders})`;
    
    console.log('Ejecutando SQL:', sql, 'con params:', params);

    const result = await this.pool.query(sql, params);
    
    if (result.rows.length > 0) {
      return result.rows[0] as unknown as T;
    }
    return result.rows as unknown as T;
  }

  async getConnection() {
    return this.pool.connect();
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}
