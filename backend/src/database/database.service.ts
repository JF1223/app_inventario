import { Injectable, Inject, OnModuleDestroy } from '@nestjs/common';
import { Pool } from 'pg'; // Usamos la librería 'pg'

const DATABASE_SYMBOL = 'DATABASE_POOL';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  constructor(@Inject(DATABASE_SYMBOL) private readonly pool: Pool) { }

  // En PostgreSQL, usamos .query() para ejecutar consultas
  async query<T = any>(sql: string, params?: any[]): Promise<T> {
    // Nota: PostgreSQL usa $1, $2 en lugar de ?
    const result = await this.pool.query(sql, params);
    return result.rows as T;
  }

  // Nota sobre 'call': PostgreSQL no usa 'CALL' de la misma forma que MySQL.
  // Si no usas procedimientos almacenados complejos, este método podría no ser necesario.
  async call<T = any>(procedureName: string, params: any[] = []): Promise<T> {
    // Si realmente usas funciones en Postgres, se llamarían con SELECT * FROM nombre_funcion(...)
    const result = await this.pool.query(`SELECT * FROM ${procedureName}($1)`, params);
    return result.rows as T;
  }

  async getConnection() {
    return await this.pool.connect();
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}
