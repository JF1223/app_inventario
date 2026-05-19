import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database';

@Injectable()
export class ReportesService {
  constructor(private readonly db: DatabaseService) {}

  async getResumen(): Promise<any> {
    const equiposPorEstado = await this.db.query(
      'SELECT estado, COUNT(*) as cantidad FROM equipos GROUP BY estado',
    );

    const ordenesPorEstado = await this.db.query(
      'SELECT estado, COUNT(*) as cantidad FROM ordenes_servicio GROUP BY estado',
    );

    const ordenesPorTipo = await this.db.query(
      'SELECT tipo, COUNT(*) as cantidad FROM ordenes_servicio GROUP BY tipo',
    );

    const reemplazos = await this.db.query(
      'SELECT COUNT(*) as total_reemplazos FROM ordenes_servicio WHERE es_reemplazo = TRUE',
    );

    const totalEquipos = await this.db.query('SELECT COUNT(*) as total FROM equipos');
    const totalClientes = await this.db.query(
      'SELECT COUNT(*) as total FROM clientes WHERE activo = TRUE',
    );
    const totalTecnicos = await this.db.query(
      'SELECT COUNT(*) as total FROM tecnicos WHERE activo = TRUE',
    );

    return {
      equipos_por_estado: equiposPorEstado,
      ordenes_por_estado: ordenesPorEstado,
      ordenes_por_tipo: ordenesPorTipo,
      total_reemplazos: reemplazos[0].total_reemplazos,
      total_equipos: totalEquipos[0].total,
      total_clientes: totalClientes[0].total,
      total_tecnicos: totalTecnicos[0].total,
    };
  }

  async getReporteMensual(year: number, month: number): Promise<any> {
    const ordenesMes = await this.db.query(
      `SELECT o.*, e.placa, t.nombre as tecnico_nombre
       FROM ordenes_servicio o
       JOIN equipos e ON o.id_equipo = e.id
       LEFT JOIN tecnicos t ON o.id_tecnico = t.id
       WHERE YEAR(o.created_at) = ? AND MONTH(o.created_at) = ?
       ORDER BY o.created_at DESC`,
      [year, month],
    );

    const totalOrdenes = ordenesMes.length;
    const finalizadas = ordenesMes.filter((o: any) => o.estado === 'finalizada').length;
    const reemplazos = ordenesMes.filter((o: any) => o.es_reemplazo === 1).length;

    return {
      year,
      month,
      ordenes: ordenesMes,
      resumen: {
        total_ordenes: totalOrdenes,
        finalizadas,
        reemplazos,
        pendientes: totalOrdenes - finalizadas,
      },
    };
  }
}
