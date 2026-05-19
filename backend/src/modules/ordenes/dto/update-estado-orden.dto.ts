import { IsInt, IsEnum, IsOptional, IsString } from 'class-validator';

export class UpdateEstadoOrdenDto {
  @IsInt()
  id_orden: number;

  @IsEnum(['pendiente', 'en_proceso', 'finalizada'])
  nuevo_estado: string;

  @IsOptional()
  @IsString()
  observaciones?: string;
}