import { IsString, IsOptional, MaxLength } from 'class-validator';

export class UpdateTecnicoDto {
  @IsOptional()
  @IsString()
  @MaxLength(150)
  nombre?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  especialidad?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  contacto?: string;
}
