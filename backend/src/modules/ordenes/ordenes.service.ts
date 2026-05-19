import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database';
import { CreateOrdenDto } from './dto/create-orden.dto';
import { AsignarTecnicoDto } from './dto/asignar-tecnico.dto';
import { UpdateEstadoOrdenDto } from './dto/update-estado-orden.dto';

export interface Orden {
  id: number;
  id_equipo: number;
  id_tecnico: number | null;
  estado: string;
  tipo: string;
  descripcion: string | null;
  observaciones: string | null;
  es_reemplazo: boolean;
  id_equipo_reemplazo: number | null;
  fecha_reemplazo: Date | null;
  fecha_limite: Date;
  fecha_inicio: Date | null;
  fecha_fin: Date | null;
  created_at: Date;
  updated_at: Date;
  equipo?: any;
  tecnico?: any;
}

@Injectable()
export class OrdenesService {
  private readonly logger = new Logger(OrdenesService.name);

  constructor(private readonly db: DatabaseService) {}

  async create(dto: CreateOrdenDto): Promise<any> {
    const result = await this.db.call(
      'sp_crear_orden(?, ?, ?, ?)',
      [dto.id_equipo, dto.tipo, dto.descripcion || null, dto.id_tecnico || null],
    );
    return result[0];
  }

  async findAll(): Promise<Orden[]> {
    return this.db.call<Orden[]>('sp_listar_ordenes()');
  }

  async findOne(id: number): Promise<Orden> {
    const result = await this.db.call<Orden[]>('sp_obtener_orden(?)', [id]);
    if (!result || result.length === 0) {
      throw new NotFoundException(`Orden con ID ${id} no encontrada`);
    }
    return result[0];
  }

  async asignarTecnico(dto: AsignarTecnicoDto): Promise<any> {
    const result = await this.db.call(
      'sp_orden_asignar_tecnico(?, ?)',
      [dto.id_orden, dto.id_tecnico],
    );
    return result[0];
  }

  async actualizarEstado(dto: UpdateEstadoOrdenDto): Promise<any> {
    const result = await this.db.call(
      'sp_orden_actualizar_estado(?, ?, ?)',
      [dto.id_orden, dto.nuevo_estado, dto.observaciones || null],
    );
    return result[0];
  }

  async cerrarOrden(id: number, observaciones?: string): Promise<any> {
    const result = await this.db.call('sp_orden_cerrar(?, ?)', [id, observaciones || null]);
    return result[0];
  }

  async verificarPlazos(): Promise<any> {
    this.logger.log('Ejecutando verificar_plazos...');
    const result = await this.db.call('sp_orden_verificar_plazos()');
    this.logger.log(`Plazos verificados: ${JSON.stringify(result[0])}`);
    return result[0];
  }

  async delete(id: number): Promise<void> {
    await this.db.call('sp_orden_delete(?)', [id]);
  }
}
