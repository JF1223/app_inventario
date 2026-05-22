import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { DatabaseService } from '../../database';
import {
  CreateEquipoDto,
  UpdateEquipoDto,
  EnviarReparacionDto,
  ReasignarEquipoDto,
} from './dto';

export interface Equipo {
  id: number;
  placa: string;
  estado: string;
  limpieza: string | null;
  uso: string | null;
  novedad: string;
  asignadas: string | null;
  observaciones: string | null;
  id_cliente: number | null;
  cliente_nombre?: string;
  cliente_documento?: string;
  created_at: Date;
  updated_at: Date;
}

@Injectable()
export class EquiposService {
  constructor(private readonly db: DatabaseService) {}

  // ============================================
  // CREAR EQUIPO
  // ============================================

  async create(dto: CreateEquipoDto): Promise<Equipo> {
    try {
      const result = await this.db.query<Equipo>(
        `
        SELECT * FROM sp_equipo_create(
          $1, $2, $3, $4, $5, $6, $7, $8
        )
        `,
        [
          dto.placa,
          dto.estado || 'operativo',
          dto.limpieza || null,
          dto.uso || null,
          dto.novedad || 'disponible',
          dto.asignadas || null,
          dto.observaciones || null,
          dto.id_cliente || null,
        ],
      );

      return result.rows[0];
    } catch (error: any) {
      console.log(error);

      throw new BadRequestException(
        error.message || 'Error al crear el equipo',
      );
    }
  }

  // ============================================
  // LISTAR EQUIPOS
  // ============================================

  async findAll(): Promise<Equipo[]> {
    const result = await this.db.query<Equipo>(
      `SELECT * FROM sp_equipo_find_all()`,
    );

    return result.rows;
  }

  // ============================================
  // OBTENER UN EQUIPO
  // ============================================

  async findOne(id: number): Promise<Equipo> {
    const result = await this.db.query<Equipo>(
      `SELECT * FROM sp_equipo_find_one($1)`,
      [id],
    );

    if (!result.rows || result.rows.length === 0) {
      throw new NotFoundException(
        `Equipo con ID ${id} no encontrado`,
      );
    }

    return result.rows[0];
  }

  // ============================================
  // ACTUALIZAR EQUIPO
  // ============================================

  async update(
    id: number,
    dto: UpdateEquipoDto,
  ): Promise<Equipo> {
    const result = await this.db.query<Equipo>(
      `
      SELECT * FROM sp_equipo_update(
        $1, $2, $3, $4, $5, $6, $7, $8, $9
      )
      `,
      [
        id,
        dto.placa || null,
        dto.estado || null,
        dto.limpieza || null,
        dto.uso || null,
        dto.novedad || null,
        dto.asignadas || null,
        dto.observaciones || null,
        dto.id_cliente || null,
      ],
    );

    if (!result.rows || result.rows.length === 0) {
      throw new NotFoundException(
        `Equipo con ID ${id} no encontrado`,
      );
    }

    return result.rows[0];
  }

  // ============================================
  // ELIMINAR EQUIPO
  // ============================================

  async delete(id: number): Promise<void> {
    await this.db.query(
      `SELECT * FROM sp_equipo_delete($1)`,
      [id],
    );
  }

  // ============================================
  // BUSCAR POR ESTADO
  // ============================================

  async findByEstado(estado: string): Promise<Equipo[]> {
    const result = await this.db.query<Equipo>(
      `SELECT * FROM sp_equipo_find_by_estado($1)`,
      [estado],
    );

    return result.rows;
  }

  // ============================================
  // EQUIPOS OPERATIVOS DISPONIBLES
  // ============================================

  async findOperativosDisponibles(): Promise<Equipo[]> {
    const result = await this.db.query<Equipo>(
      `SELECT * FROM sp_equipo_find_operativos_disponibles()`,
    );

    return result.rows;
  }

  // ============================================
  // ENVIAR A REPARACION
  // ============================================

  async enviarReparacion(
    id: number,
    dto: EnviarReparacionDto,
  ): Promise<Equipo> {
    const result = await this.db.query<Equipo>(
      `
      SELECT * FROM sp_equipo_enviar_reparacion(
        $1,
        $2
      )
      `,
      [id, dto.observaciones],
    );

    return result.rows[0];
  }

  // ============================================
  // FINALIZAR REPARACION
  // ============================================

  async finalizarReparacion(id: number): Promise<Equipo> {
    const result = await this.db.query<Equipo>(
      `
      SELECT * FROM sp_equipo_finalizar_reparacion($1)
      `,
      [id],
    );

    if (!result.rows || result.rows.length === 0) {
      throw new NotFoundException(
        `Equipo con ID ${id} no encontrado o no está en reparación`,
      );
    }

    return result.rows[0];
  }

  // ============================================
  // REASIGNAR EQUIPO
  // ============================================

  async reasignar(
    id: number,
    dto: ReasignarEquipoDto,
  ): Promise<Equipo> {
    const result = await this.db.query<Equipo>(
      `
      SELECT * FROM sp_equipo_reasignar($1, $2)
      `,
      [id, dto.id_cliente],
    );

    return result.rows[0];
  }
}
