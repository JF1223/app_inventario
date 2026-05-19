import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database';
import { CreateTecnicoDto } from './dto/create-tecnico.dto';
import { UpdateTecnicoDto } from './dto/update-tecnico.dto';

export interface Tecnico {
  id: number;
  nombre: string;
  especialidad: string;
  contacto: string;
  activo: boolean;
  created_at: Date;
  updated_at: Date;
}

@Injectable()
export class TecnicosService {
  constructor(private readonly db: DatabaseService) { }

  async create(dto: CreateTecnicoDto): Promise<Tecnico> {
    const result = await this.db.call<Tecnico[]>(
      'sp_crear_tecnico(?, ?, ?)',
      [dto.nombre, dto.especialidad, dto.contacto],
    );
    return result[0];
  }

  async findAll(): Promise<Tecnico[]> {
    return this.db.call<Tecnico[]>('sp_listar_tecnicos()');
  }

  async findOne(id: number): Promise<Tecnico> {
    const result = await this.db.call<Tecnico[]>('sp_obtener_tecnico(?)', [id]);
    if (!result || result.length === 0) {
      throw new NotFoundException(`Tecnico con ID ${id} no encontrado`);
    }
    return result[0];
  }

  async update(id: number, dto: UpdateTecnicoDto): Promise<Tecnico> {
    const result = await this.db.call<Tecnico[]>(
      'sp_actualizar_tecnico(?, ?, ?, ?)',
      [id, dto.nombre || null, dto.especialidad || null, dto.contacto || null],
    );
    if (!result || result.length === 0) {
      throw new NotFoundException(`Tecnico con ID ${id} no encontrado`);
    }
    return result[0];
  }

  async delete(id: number): Promise<void> {
    await this.db.call('sp_eliminar_tecnico(?)', [id]);
  }
}
