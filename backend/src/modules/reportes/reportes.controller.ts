import { Controller, Get, Query } from '@nestjs/common';
import { ReportesService } from './reportes.service';

@Controller('reportes')
export class ReportesController {
  constructor(private readonly service: ReportesService) {}

  @Get('resumen')
  getResumen() {
    return this.service.getResumen();
  }

  @Get('mensual')
  getReporteMensual(
    @Query('year') year: number,
    @Query('month') month: number,
  ) {
    return this.service.getReporteMensual(+year, +month);
  }
}