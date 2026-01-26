import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SessionEntity, UserAnalyticsEntity } from './entities/session.entity';
import { SessionService } from './session.service';
import { SessionController } from './session.controller';
import { AgoraTokenService } from './services/agora-token.service';

@Module({
    imports: [
        TypeOrmModule.forFeature([SessionEntity, UserAnalyticsEntity]),
    ],
    controllers: [SessionController],
    providers: [SessionService, AgoraTokenService],
    exports: [SessionService],
})
export class SessionModule { }
