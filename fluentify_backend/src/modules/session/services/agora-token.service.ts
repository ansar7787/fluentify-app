import { Injectable, Logger } from '@nestjs/common';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AgoraTokenService {
    private readonly logger = new Logger(AgoraTokenService.name);

    constructor(private readonly configService: ConfigService) { }

    generateToken(
        channelName: string,
        uid: number | string,
        role: number = RtcRole.PUBLISHER,
        expireTime: number = 3600,
    ): string {
        try {
            const appId = this.configService.get<string>('AGORA_APP_ID');
            const appCertificate = this.configService.get<string>('AGORA_APP_CERTIFICATE');

            if (!appId || !appCertificate) {
                throw new Error('AGORA_APP_ID or AGORA_APP_CERTIFICATE not configured');
            }

            // Calculate privilege expire time
            const currentTimestamp = Math.floor(Date.now() / 1000);
            const privilegeExpiredTs = currentTimestamp + expireTime;

            // Ensure uid is number if your logic requires it, or 0. 
            // RtcTokenBuilder.buildTokenWithUid takes number, buildTokenWithAccount takes string.
            // We will assume string account for flexibility or convert to 0 if needed.
            // Using buildTokenWithAccount for string UIDs (UUIDs).

            const token = RtcTokenBuilder.buildTokenWithAccount(
                appId,
                appCertificate,
                channelName,
                String(uid),
                role,
                privilegeExpiredTs
            );

            this.logger.log(`Token generated for channel: ${channelName}`);
            return token;
        } catch (error) {
            this.logger.error(`Failed to generate token: ${error.message}`);
            throw error;
        }
    }
}
