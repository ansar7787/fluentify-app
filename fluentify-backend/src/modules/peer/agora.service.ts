import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';

@Injectable()
export class AgoraService {
    constructor(private configService: ConfigService) { }

    generateToken(channelName: string, uid: number): string {
        const appId = this.configService.get<string>('AGORA_APP_ID');
        const appCertificate = this.configService.get<string>('AGORA_APP_CERTIFICATE');
        const role = RtcRole.PUBLISHER;

        if (!appId || !appCertificate) {
            throw new Error('AGORA_APP_ID or AGORA_APP_CERTIFICATE not configured');
        }

        const expirationTimeInSeconds = 3600;
        const currentTimestamp = Math.floor(Date.now() / 1000);
        const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

        return RtcTokenBuilder.buildTokenWithUid(
            appId,
            appCertificate,
            channelName,
            uid,
            role,
            privilegeExpiredTs,
        );
    }
}
