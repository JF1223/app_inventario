import { IsInt, IsEnum, IsOptional, IsString } from 'class-validator';

export class CreateOrdenDto {
  @IsInt()
  id_equipo: number;

  @IsEnum(['mantenimiento', 'reparacion', 'reemplazo'])
  tipo: string;

  @IsOptional()
  @IsString()
  descripcion?: string;

  @IsOptional()
  @IsInt()
  id_tecnico?: number;
}