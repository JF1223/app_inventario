import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../../database';
import { CreateClienteDto } from './dto/create-cliente.dto';
import { UpdateClienteDto } from './dto/update-cliente.dto';

export interface Cliente {
  id: number;
  nombre: string;
  documento: string;
  direccion: string | null;
  telefono: string | null;
  email: string | null;
  activo: boolean;
  created_at: Date;
  updated_at: Date;
}

@Injectable()
export class ClientesService {
  constructor(private readonly db: DatabaseService) {}

  async create(dto: CreateClienteDto): Promise<Cliente> {
    const result = await this.db.call<Cliente[]>(
      'sp_crear_cliente(?, ?, ?, ?, ?)',
      [dto.nombre, dto.documento, dto.direccion || null, dto.telefono || null, dto.email || null],
    );
    return result[0];
  }

  async findAll(): Promise<Cliente[]> {
    return this.db.call<Cliente[]>('sp_listar_clientes()');
  }

  async findOne(id: number): Promise<Cliente> {
    const result = await this.db.call<Cliente[]>('sp_obtener_cliente(?)', [id]);
    if (!result || result.length === 0) {
      throw new NotFoundException(`Cliente con ID ${id} no encontrado`);
    }
    return result[0];
  }

  async update(id: number, dto: UpdateClienteDto): Promise<Cliente> {
    const result = await this.db.call<Cliente[]>(
      'sp_actualizar_cliente(?, ?, ?, ?, ?, ?)',
      [id, dto.nombre || null, dto.documento || null, dto.direccion || null, dto.telefono || null, dto.email || null],
    );
    if (!result || result.length === 0) {
      throw new NotFoundException(`Cliente con ID ${id} no encontrado`);
    }
    return result[0];
  }

  async delete(id: number): Promise<void> {
    await this.db.call('sp_eliminar_cliente(?)', [id]);
  }
}
