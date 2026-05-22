import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Injectable()
export class DatabaseService {
  constructor(private readonly dataSource: DataSource) {}

  /**
   * Ejecuta una función PostgreSQL que retorna TABLE/SETOF
   * Traduce placeholders ? a $1, $2... y ajusta la sintaxis PostgreSQL
   */
  async call<T = any>(functionCall: string, params: any[] = []): Promise<T> {
    // Extraer nombre de función (quitar paréntesis y parámetros)
    // Ej: 'sp_listar_clientes()' → 'sp_listar_clientes'
    // Ej: 'sp_obtener_cliente(?)' → 'sp_obtener_cliente'
    const functionName = functionCall.split('(')[0].trim();

    // Construir placeholders PostgreSQL $1, $2...
    const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');

    // Construir query correcta para PostgreSQL:
    // SELECT * FROM funcion() para funciones TABLE/SETOF
    const query = params.length > 0
      ? `SELECT * FROM ${functionName}(${placeholders})`
      : `SELECT * FROM ${functionName}()`;

    return this.dataSource.query(query, params) as Promise<T>;
  }

  /**
   * Ejecuta una función PostgreSQL VOID (sin retorno de filas)
   */
  async exec(functionName: string, params: any[] = []): Promise<void> {
    const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');
    const query = params.length > 0
      ? `SELECT ${functionName}(${placeholders})`
      : `SELECT ${functionName}()`;

    await this.dataSource.query(query, params);
  }
}
