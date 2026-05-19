import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database';

@Injectable()
export class HistorialService {
  constructor(private readonly db: DatabaseService) {}

  async getHistorialEquipo(idEquipo: number): Promise<any[]> {
    return this.db.query(
      'SELECT * FROM historial_equipos WHERE id_equipo = ? ORDER BY created_at DESC',
      [idEquipo],
    );
  }

  async getHistorialOrden(idOrden: number): Promise<any[]> {
    return this.db.query(
      'SELECT * FROM historial_ordenes WHERE id_orden = ? ORDER BY created_at DESC',
      [idOrden],
    );
  }

  async getHistorialCompleto(): Promise<any[]> {
    return this.db.query(
      'SELECT ho.*, o.id_equipo FROM historial_ordenes ho JOIN ordenes_servicio o ON ho.id_orden = o.id ORDER BY ho.created_at DESC LIMIT 100',
    );
  }
}
