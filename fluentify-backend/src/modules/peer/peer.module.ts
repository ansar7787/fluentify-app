import { Module } from '@nestjs/common';
import { PeerGateway } from './peer.gateway';
import { PeerService } from './peer.service';
import { AgoraService } from './agora.service';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
    imports: [
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: async (configService: ConfigService) => ({
                secret: configService.get<string>('JWT_SECRET'),
            }),
            inject: [ConfigService],
        }),
    ],
    providers: [PeerGateway, PeerService, AgoraService],
})
export class PeerModule { }
