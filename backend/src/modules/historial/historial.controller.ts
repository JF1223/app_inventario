import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { HistorialService } from './historial.service';

@Controller('historial')
export class HistorialController {
  constructor(private readonly service: HistorialService) {}

  @Get('equipo/:id')
  getHistorialEquipo(@Param('id', ParseIntPipe) id: number) {
    return this.service.getHistorialEquipo(id);
  }

  @Get('orden/:id')
  getHistorialOrden(@Param('id', ParseIntPipe) id: number) {
    return this.service.getHistorialOrden(id);
  }

  @Get()
  getHistorialCompleto() {
    return this.service.getHistorialCompleto();
  }
}