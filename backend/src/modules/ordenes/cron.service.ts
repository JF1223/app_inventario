import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { OrdenesService } from './ordenes.service';

@Injectable()
export class CronService {
  private readonly logger = new Logger(CronService.name);

  constructor(private readonly ordenesService: OrdenesService) {}

  @Cron(CronExpression.EVERY_DAY_AT_8AM)
  async verificarPlazosDiario() {
    this.logger.log('Iniciando verificación diaria de plazos...');
    try {
      const result = await this.ordenesService.verificarPlazos();
      this.logger.log(`Verificación completada: ${JSON.stringify(result)}`);
    } catch (error) {
      this.logger.error('Error al verificar plazos', error.stack);
    }
  }
}