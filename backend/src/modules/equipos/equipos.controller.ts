import { Controller, Get, Post, Put, Body, Param, ParseIntPipe } from '@nestjs/common';
import { EquiposService } from './equipos.service';
import { CreateEquipoDto, UpdateEquipoDto, EnviarReparacionDto, ReasignarEquipoDto } from './dto';

@Controller('equipos')
export class EquiposController {
  constructor(private readonly service: EquiposService) {}

  @Post()
  create(@Body() dto: CreateEquipoDto) {
    return this.service.create(dto);
  }

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.service.findOne(id);
  }

  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateEquipoDto) {
    return this.service.update(id, dto);
  }

  @Post(':id/enviar-reparacion')
  enviarReparacion(@Param('id', ParseIntPipe) id: number, @Body() dto: EnviarReparacionDto) {
    return this.service.enviarReparacion(id, dto);
  }

  @Put(':id/finalizar-reparacion')
  finalizarReparacion(@Param('id', ParseIntPipe) id: number) {
    return this.service.finalizarReparacion(id);
  }

  @Put(':id/reasignar')
  reasignar(@Param('id', ParseIntPipe) id: number, @Body() dto: ReasignarEquipoDto) {
    return this.service.reasignar(id, dto);
  }
}