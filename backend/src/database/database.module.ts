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
        const pool = new Pool({
          host: config.get('DB_HOST'),
          port: config.get<number>('DB_PORT'),
          user: config.get('DB_USERNAME'),
          password: config.get('DB_PASSWORD'),
          max: 10,
          ssl: (config.get('DB_HOST') || '').includes('render.com') || config.get('NODE_ENV') === 'production' 
               ? { rejectUnauthorized: false } : false
        });

        return pool;
      },
      inject: [ConfigService],
    },
    DatabaseService,
  ],
  exports: [DATABASE_SYMBOL, DatabaseService],
})
export class DatabaseModule { }
