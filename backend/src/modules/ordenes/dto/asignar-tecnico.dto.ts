import { IsInt } from 'class-validator';

export class AsignarTecnicoDto {
  @IsInt()
  id_orden: number;

  @IsInt()
  id_tecnico: number;
}