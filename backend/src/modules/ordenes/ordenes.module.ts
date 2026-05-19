import { Module } from '@nestjs/common';
import { OrdenesService } from './ordenes.service';
import { OrdenesController } from './ordenes.controller';
import { CronService } from './cron.service';

@Module({
  controllers: [OrdenesController],
  providers: [OrdenesService, CronService],
  exports: [OrdenesService],
})
export class OrdenesModule {}
