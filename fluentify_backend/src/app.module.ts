import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';

// Modules
import { AuthModule } from './modules/auth/auth.module';
import { UserModule } from './modules/user/user.module';
import { MissionModule } from './modules/mission/mission.module';
import { PaymentModule } from './modules/payment/payment.module';
import { PeerModule } from './modules/peer/peer.module';
import { MentorModule } from './modules/mentor/mentor.module';
import { SessionModule } from './modules/session/session.module';
import { AdminModule } from './modules/admin/admin.module';
import { ChatModule } from './chat/chat.module';
import { GameModule } from './modules/game/game.module';
import { AiModule } from './modules/ai/ai.module';
import { SpeakingPartnerModule } from './modules/speaking-partner/speaking-partner.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get('DB_PORT', 5432),
        username: configService.get('DB_USERNAME', 'postgres'),
        password: configService.get('DB_PASSWORD', ''),
        database: configService.get('DB_NAME', 'fluentify_db'),
        entities: ['dist/**/*.entity{.ts,.js}'],
        synchronize: true, // Enable for now to ensure tables exist in prod
        ssl: configService.get('NODE_ENV') === 'production',
        extra: configService.get('NODE_ENV') === 'production'
          ? { ssl: { rejectUnauthorized: false } }
          : undefined,
      }),
    }),
    ScheduleModule.forRoot(),
    AuthModule,
    UserModule,
    MissionModule,
    PaymentModule,
    PeerModule,
    MentorModule,
    SessionModule,
    AdminModule,
    ChatModule,
    GameModule,
    AiModule,
    SpeakingPartnerModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule { }