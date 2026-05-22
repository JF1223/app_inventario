// database/database.service.ts
import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Injectable()
export class DatabaseService {
  private readonly isPostgres: boolean;
  private readonly isMysql: boolean;

  constructor(private readonly dataSource: DataSource) {
    const driver = this.dataSource.driver.options.type;
    this.isPostgres = driver === 'postgres' || driver === 'postgresql';
    this.isMysql = driver === 'mysql' || driver === 'mariadb';
  }

  /**
   * Ejecuta un procedimiento/function y retorna filas.
   * Compatible con MySQL (CALL) y PostgreSQL (SELECT * FROM function()).
   * 
   * Tu service sigue usando: this.db.call('sp_name(?, ?)', [val1, val2])
   */
  async call<T = any>(procedureCall: string, params: any[] = []): Promise<T> {
    // Extraer nombre del SP: 'sp_listar_clientes()' → 'sp_listar_clientes'
    const functionName = procedureCall.split('(')[0].trim();

    if (this.isPostgres) {
      // PostgreSQL: SELECT * FROM function($1, $2)
      const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');
      const query = params.length > 0
        ? `SELECT * FROM ${functionName}(${placeholders})`
        : `SELECT * FROM ${functionName}()`;
      return this.dataSource.query(query, params) as Promise<T>;
    }

    if (this.isMysql) {
      // MySQL: CALL sp_name(?, ?)
      const placeholders = params.map(() => '?').join(', ');
      const query = params.length > 0
        ? `CALL ${functionName}(${placeholders})`
        : `CALL ${functionName}()`;
      return this.dataSource.query(query, params) as Promise<T>;
    }

    throw new Error(`Driver de base de datos no soportado: ${this.dataSource.driver.options.type}`);
  }

  /**
   * Ejecuta un procedimiento que no retorna filas (VOID).
   */
  async exec(procedureCall: string, params: any[] = []): Promise<void> {
    await this.call(procedureCall, params);
  }
}
