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
  // Validar que el nombre sea un identificador válido de PostgreSQL
  if (!/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(procedureName)) {
    throw new Error(`Nombre de procedimiento inválido: ${procedureName}`);
  }

  // Escapar el nombre con comillas dobles (requerido si es palabra reservada)
  const query = `SELECT * FROM "${procedureName}"(${params.map((_, i) => `$${i + 1}`).join(', ')})`;
  const result = await this.pool.query(query, params);
  return result.rows as T;
}

  async getConnection() {
    return await this.pool.connect();
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}
