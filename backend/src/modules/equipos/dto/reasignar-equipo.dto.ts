import { IsInt, IsString, IsOptional } from 'class-validator';

export class ReasignarEquipoDto {
  @IsInt()
  id_cliente: number;
}

export class EnviarReparacionDto {
  @IsOptional()
  @IsString()
  observaciones?: string;
}