import { IsString, IsOptional, IsBoolean, MaxLength } from 'class-validator';

export class CreateTecnicoDto {
  @IsString()
  @MaxLength(150)
  nombre: string;

  @IsString()
  @MaxLength(100)
  especialidad: string;

  @IsString()
  @MaxLength(50)
  contacto: string;

  @IsOptional()
  @IsBoolean()
  activo?: boolean;
}