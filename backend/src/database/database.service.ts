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
  // 1. Verificación de seguridad
  if (!procedureName) {
    throw new Error("El nombre del procedimiento no puede estar vacío");
  }

  const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');
  const sql = `SELECT * FROM ${procedureName}(${placeholders})`;
  
  // 2. LOG para ver exactamente qué se está enviando a Postgres
  console.log('Ejecutando SQL:', sql, 'con params:', params);

  const result = await this.pool.query(sql, params);
  
  if (result.rows.length > 0) {
    // Si el procedimiento devuelve una sola fila con una columna que es un objeto (común en funciones de Postgres)
    // a veces el resultado viene en el primer nombre de columna.
    return result.rows[0] as unknown as T;
  }
  return result.rows as unknown as T;
}
