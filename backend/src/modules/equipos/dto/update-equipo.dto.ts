import { IsString, IsOptional, IsEnum, IsInt, MaxLength } from 'class-validator';

export class UpdateEquipoDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  placa?: string;

  @IsOptional()
  @IsEnum(['operativo', 'en_mantenimiento', 'reemplazado', 'en_reparacion'])
  estado?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  limpieza?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  uso?: string;

  @IsOptional()
  @IsEnum(['asignada', 'disponible', 'no_disponible'])
  novedad?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  asignadas?: string;

  @IsOptional()
  @IsString()
  observaciones?: string;

  @IsOptional()
  @IsInt()
  id_cliente?: number;
}