import { Module, Global } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createPool } from 'mysql2/promise';
import { DatabaseService } from './database.service';

const DATABASE_SYMBOL = 'DATABASE_POOL';

@Global()
@Module({
  providers: [
    {
      provide: DATABASE_SYMBOL,
      useFactory: (config: ConfigService) => {
        const pool = createPool({
          host: config.get('DB_HOST'),
          port: config.get<number>('DB_PORT'),
          user: config.get('DB_USERNAME'),
          password: config.get('DB_PASSWORD'),
          database: config.get('DB_DATABASE'),
          charset: 'utf8mb4',
          waitForConnections: true,
          connectionLimit: 10,
          queueLimit: 0,
          enableKeepAlive: true,
          keepAliveInitialDelay: 0,
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
