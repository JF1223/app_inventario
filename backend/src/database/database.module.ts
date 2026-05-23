import { Module, Global } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pool } from 'pg';
import { DatabaseService } from './database.service';

const DATABASE_SYMBOL = 'DATABASE_POOL';

@Global()
@Module({
  providers: [
    {
      provide: DATABASE_SYMBOL,
      useFactory: (config: ConfigService) => {
        const dbUrl = config.get<string>('DATABASE_URL');
        const dbHost = config.get<string>('DB_HOST') || '';
        const isProduction = config.get('NODE_ENV') === 'production';
        
        const poolOptions: any = {
          max: 10,
        };

        if (dbUrl) {
          poolOptions.connectionString = dbUrl;
          poolOptions.ssl = { rejectUnauthorized: false };
        } else {
          poolOptions.host = dbHost;
          poolOptions.port = config.get<number>('DB_PORT');
          poolOptions.user = config.get('DB_USERNAME');
          poolOptions.password = config.get('DB_PASSWORD');
          poolOptions.database = config.get('DB_DATABASE');
          poolOptions.ssl = dbHost.includes('render.com') || isProduction ? { rejectUnauthorized: false } : false;
        }

        const pool = new Pool(poolOptions);
        return pool;
      },
      inject: [ConfigService],
    },
    DatabaseService,
  ],
  exports: [DATABASE_SYMBOL, DatabaseService],
})
export class DatabaseModule { }
