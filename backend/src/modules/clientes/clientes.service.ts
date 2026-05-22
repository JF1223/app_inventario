import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Injectable()
export class DatabaseService {
  constructor(private readonly dataSource: DataSource) {}

  async call(functionName: string, params: any[] = []): Promise<any> {
    // Construir placeholders $1, $2, etc.
    const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');
    
    // Para funciones que retornan TABLE/SETOF
    const query = placeholders 
      ? `SELECT * FROM ${functionName}(${placeholders})`
      : `SELECT * FROM ${functionName}()`;
    
    return this.dataSource.query(query, params);
  }

  // Para funciones VOID (que no retornan filas)
  async exec(functionName: string, params: any[] = []): Promise<void> {
    const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');
    const query = placeholders 
      ? `SELECT ${functionName}(${placeholders})`
      : `SELECT ${functionName}()`;
    
    await this.dataSource.query(query, params);
  }
}
