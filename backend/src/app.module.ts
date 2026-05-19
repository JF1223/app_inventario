import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { DatabaseModule } from './database';
import { ClientesModule } from './modules/clientes/clientes.module';
import { EquiposModule } from './modules/equipos/equipos.module';
import { TecnicosModule } from './modules/tecnicos/tecnicos.module';
import { OrdenesModule } from './modules/ordenes/ordenes.module';
import { HistorialModule } from './modules/historial/historial.module';
import { ReportesModule } from './modules/reportes/reportes.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(),
    DatabaseModule,
    ClientesModule,
    EquiposModule,
    TecnicosModule,
    OrdenesModule,
    
    HistorialModule,
    ReportesModule,
  ],
})
export class AppModule {}
