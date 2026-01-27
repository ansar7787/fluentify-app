import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SessionEntity, UserAnalyticsEntity } from './entities/session.entity';
import { AgoraTokenService } from './services/agora-token.service';

@Injectable()
export class SessionService {
    private readonly logger = new Logger(SessionService.name);

    constructor(
        @InjectRepository(SessionEntity)
        private readonly sessionRepository: Repository<SessionEntity>,
        @InjectRepository(UserAnalyticsEntity)
        private readonly analyticsRepository: Repository<UserAnalyticsEntity>,
        private readonly agoraTokenService: AgoraTokenService,
    ) { }

    async initiateSession(bookingId: string, userId: string): Promise<any> {
        try {
            // Logic to verify booking belongs to user/mentor would go here
            // For now, assuming valid request

            const channelId = `session_${bookingId}_${Date.now()}`;

            const session = this.sessionRepository.create({
                booking_id: bookingId,
                agora_channel_id: channelId,
                start_time: new Date(),
                status: 'active',
            });

            await this.sessionRepository.save(session);

            // Generate Agora tokens for the user
            // Role PUBLISHER for both for now
            const token = this.agoraTokenService.generateToken(channelId, userId);

            this.logger.log(`Session initiated: ${session.id} for user ${userId}`);

            return {
                sessionId: session.id,
                channelId,
                token,
                uid: userId, // Returning string ID as UID for Agora (using string account mode)
            };
        } catch (error) {
            this.logger.error(`Failed to initiate session: ${error.message}`);
            throw error;
        }
    }

    async endSession(
        sessionId: string,
        recordingUrl?: string,
        feedback?: string,
    ): Promise<SessionEntity> {
        try {
            const session = await this.sessionRepository.findOne({
                where: { id: sessionId },
            });

            if (!session) {
                throw new BadRequestException('Session not found');
            }

            const endTime = new Date();
            const durationSeconds = Math.floor(
                (endTime.getTime() - session.start_time.getTime()) / 1000,
            );

            session.end_time = endTime;
            session.duration_seconds = durationSeconds;
            session.status = 'completed';

            if (recordingUrl) {
                session.session_recording_url = recordingUrl;
            }

            if (feedback) {
                session.feedback = feedback;
            }

            const updatedSession = await this.sessionRepository.save(session);

            this.logger.log(`Session ended: ${sessionId}`);

            // Here we would update UserAnalytics (omitted for brevity but planned)

            return updatedSession;
        } catch (error) {
            this.logger.error(`Failed to end session: ${error.message}`);
            throw error;
        }
    }

    async getUserAnalytics(userId: string): Promise<UserAnalyticsEntity> {
        try {
            let analytics = await this.analyticsRepository.findOne({
                where: { user_id: userId },
            });

            if (!analytics) {
                analytics = this.analyticsRepository.create({
                    user_id: userId,
                });
                analytics = await this.analyticsRepository.save(analytics);
            }

            return analytics;
        } catch (error) {
            this.logger.error(`Failed to fetch analytics: ${error.message}`);
            throw error;
        }
    }

    async updateUserAnalytics(
        userId: string,
        updateData: Partial<UserAnalyticsEntity>,
    ): Promise<UserAnalyticsEntity> {
        try {
            let analytics = await this.analyticsRepository.findOne({
                where: { user_id: userId },
            });

            if (!analytics) {
                analytics = this.analyticsRepository.create({
                    user_id: userId,
                    ...updateData,
                });
            } else {
                Object.assign(analytics, updateData);
            }

            const updatedAnalytics = await this.analyticsRepository.save(analytics);
            return updatedAnalytics;
        } catch (error) {
            this.logger.error(`Failed to update analytics: ${error.message}`);
            throw error;
        }
    }
}
