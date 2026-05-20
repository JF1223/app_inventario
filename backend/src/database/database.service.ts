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
    const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');
    const result = await this.pool.query(`SELECT * FROM ${procedureName}(${placeholders})`, params);
    if (result.rows.length > 0) {
      // In PostgreSQL, row results might come nested depending on how the function is defined,
      // but assuming we return SETOF record or TABLE, we get flat rows.
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
