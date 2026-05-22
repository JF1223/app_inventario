import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database';
import { CreateEquipoDto, UpdateEquipoDto, EnviarReparacionDto, ReasignarEquipoDto } from './dto';

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
  cliente?: { id: number; nombre: string };
  created_at: Date;
  updated_at: Date;
}

@Injectable()
  export class EquiposService {
    constructor(private readonly db: DatabaseService) {}

    async create(dto: CreateEquipoDto): Promise<Equipo> {
      const result = await this.db.call<Equipo[]>(
        'sp_crear_equipo(?, ?, ?, ?, ?, ?, ?, ?)',
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
      return result[0];
    }

    catch (error: any) {

  console.log(error);

  throw error;

}

  async findAll(): Promise<Equipo[]> {
  try {
    const result = await this.db.call<Equipo[]>('sp_listar_equipos()');
    
    // Si result es nulo, indefinido o no es un array, devolvemos un array vacío []
    return Array.isArray(result) ? result : [];
  } catch (error) {
    console.error("Error al listar equipos:", error);
    // Si la BD falla, devolvemos un array vacío en lugar de romper la comunicación
    return [];
  }
}
  async findOne(id: number): Promise<Equipo> {
    const result = await this.db.call<Equipo[]>('sp_obtener_equipo(?)', [id]);
    if (!result || result.length === 0) {
      throw new NotFoundException(`Equipo con ID ${id} no encontrado`);
    }
    return result[0];
  }

  async update(id: number, dto: UpdateEquipoDto): Promise<Equipo> {
    const result = await this.db.call<Equipo[]>(
      'sp_actualizar_equipo(?, ?, ?, ?, ?, ?, ?, ?, ?)',
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
    if (!result || result.length === 0) {
      throw new NotFoundException(`Equipo con ID ${id} no encontrado`);
    }
    return result[0];
  }

  async delete(id: number): Promise<void> {
    await this.db.call('sp_eliminar_equipo(?)', [id]);
  }

  async findByEstado(estado: string): Promise<Equipo[]> {
    const result = await this.db.call<Equipo[]>('sp_listar_equipos_por_estado(?)', [estado]);
    return result;
  }

  async findOperativosDisponibles(): Promise<Equipo[]> {
    const result = await this.db.call<Equipo[]>('sp_listar_operativos_disponibles()');
    return result;
  }

  async enviarReparacion(id: number, dto: EnviarReparacionDto): Promise<any> {
    const result = await this.db.call('sp_equipo_enviar_reparacion(?, ?)', [id, dto.observaciones]);
    return result[0];
  }



  async finalizarReparacion(id: number): Promise<Equipo> {
    const result = await this.db.call<Equipo[]>('sp_finalizar_reparacion(?)', [id]);
    if (!result || result.length === 0) {
      throw new NotFoundException(`Equipo con ID ${id} no encontrado o no está en reparación`);
    }
    return result[0];
  }

  async reasignar(id: number, dto: ReasignarEquipoDto): Promise<any> {
    const result = await this.db.call('sp_reasignar_equipo(?, ?)', [id, dto.id_cliente]);
    return result[0];
  }
}
