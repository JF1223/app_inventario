import { Controller, Get, Post, Put, Delete, Body, Param, ParseIntPipe } from '@nestjs/common';
import { OrdenesService } from './ordenes.service';
import { CreateOrdenDto } from './dto/create-orden.dto';
import { AsignarTecnicoDto } from './dto/asignar-tecnico.dto';
import { UpdateEstadoOrdenDto } from './dto/update-estado-orden.dto';

@Controller('ordenes')
export class OrdenesController {
  constructor(private readonly service: OrdenesService) {}

  @Post()
  create(@Body() dto: CreateOrdenDto) {
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

  @Put('asignar')
  asignarTecnico(@Body() dto: AsignarTecnicoDto) {
    return this.service.asignarTecnico(dto);
  }

  @Put('estado')
  actualizarEstado(@Body() dto: UpdateEstadoOrdenDto) {
    return this.service.actualizarEstado(dto);
  }

  @Put(':id/cerrar')
  cerrarOrden(@Param('id', ParseIntPipe) id: number, @Body('observaciones') observaciones?: string) {
    return this.service.cerrarOrden(id, observaciones);
  }

  @Delete(':id')
  delete(@Param('id', ParseIntPipe) id: number) {
    return this.service.delete(id);
  }
}