import { Injectable, Inject, OnModuleDestroy } from '@nestjs/common';
import { Pool } from 'mysql2/promise';

const DATABASE_SYMBOL = 'DATABASE_POOL';

@Injectable()
export class DatabaseService {
  constructor(@Inject(DATABASE_SYMBOL) private readonly pool: Pool) { }

  async query<T = any>(sql: string, params?: any[]): Promise<T> {
    const [rows] = await this.pool.execute(sql, params);
    return rows as T;
  }

  async call<T = any>(procedureName: string, params: any[] = []): Promise<T> {
    const [rows] = await this.pool.query(`CALL ${procedureName}`, params);
    if (Array.isArray(rows) && rows.length > 0 && Array.isArray(rows[0])) {
      return rows[0] as unknown as T;
    }
    return rows as T;
  }

  async getConnection() {
    return this.pool.getConnection();
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}
