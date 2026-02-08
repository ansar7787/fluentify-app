import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Mission } from './entities/mission.entity';
import { UserMission } from './entities/user-mission.entity';
import { User } from '../user/entities/user.entity';
import { AiService } from '../ai/ai.service';
import { UserService } from '../user/user.service';

@Injectable()
export class MissionService {
    constructor(
        @InjectRepository(Mission)
        private missionRepository: Repository<Mission>,
        @InjectRepository(UserMission)
        private userMissionRepository: Repository<UserMission>,
        private aiService: AiService,
        private userService: UserService,
    ) { }

    async submitAttempt(user: User, missionId: string, audioBuffer: Buffer): Promise<any> {
        const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
        let mission: Mission | null = null;
        let isProcedural = false;

        if (uuidRegex.test(missionId)) {
            mission = await this.findById(missionId);
            if (!mission) throw new NotFoundException('Mission not found');
        } else {
            // Handle Procedural IDs (e.g. s_1_0) from local games
            isProcedural = true;
            mission = new Mission();
            mission.id = missionId;
            mission.title = 'Free Practice';
            mission.content = 'Speak freely about the topic.';
            mission.rewardCoins = 10;
        }



        // --- Usage Limit Check ---
        // Basic MVP logic: 20 free tries per day for 'free' users
        if (user.subscriptionPlan === 'free') {
            const today = new Date();
            const lastUsage = user.lastAiUsageDate ? new Date(user.lastAiUsageDate) : null;

            // Check if we need to reset count (new day)
            if (!lastUsage || lastUsage.getDate() !== today.getDate() || lastUsage.getMonth() !== today.getMonth()) {
                user.aiUsageCount = 0;
            }

            if (user.aiUsageCount >= 20) {
                throw new ForbiddenException('Daily AI limit reached. Please upgrade to Premium for unlimited feedback.');
            }
        }

        // 1. Get AI Analysis (Gemini)
        const analysis = await this.aiService.analyzeSpeech(audioBuffer, mission.content);

        // Increment usage
        await this.userService.update(user.id, {
            aiUsageCount: (user.aiUsageCount || 0) + 1,
            lastAiUsageDate: new Date()
        });


        // 2. Calculate overall score
        const overallScore = (analysis.fluencyScore + analysis.grammarScore + analysis.vocabularyScore + analysis.pronunciationScore) / 4;

        if (isProcedural) {
            // Return virtual result without saving to DB
            // We reward the user anyway? Let's give them coins!
            await this.userService.update(user.id, {
                coins: user.coins + mission.rewardCoins,
                streakCount: user.streakCount + 1, // Simple streak logic
                lastPracticeDate: new Date(),
            });

            return {
                id: 'temp_' + Date.now(),
                user: user,
                mission: mission,
                score: overallScore,
                feedback: analysis,
                isCompleted: true,
                completedAt: new Date(),
            };
        }

        // 3. Save Attempt
        const userMission = this.userMissionRepository.create({
            user,
            mission,
            score: overallScore,
            feedback: analysis,
            isCompleted: true,
            completedAt: new Date(),
        });

        await this.userMissionRepository.save(userMission);

        // 4. Reward User
        await this.userService.update(user.id, {
            coins: user.coins + mission.rewardCoins,
            streakCount: user.streakCount + 1, // Simple streak logic for MVP
            lastPracticeDate: new Date(),
        });

        return userMission;
    }

    async findAll(user?: User): Promise<any[]> {
        const missions = await this.missionRepository.find({ order: { title: 'ASC' } });
        if (!user) return missions;

        const userMissions = await this.userMissionRepository.find({
            where: { user: { id: user.id }, isCompleted: true },
            relations: ['mission']
        });

        const completedMissionIds = new Set(userMissions.map(um => um.mission.id));

        return missions.map(mission => ({
            ...mission,
            isCompleted: completedMissionIds.has(mission.id)
        }));
    }

    async findByLevel(level: any, user?: User): Promise<any[]> {
        const missions = await this.missionRepository.find({
            where: { level },
            order: { title: 'ASC' }
        });
        if (!user) return missions;

        const userMissions = await this.userMissionRepository.find({
            where: { user: { id: user.id }, isCompleted: true },
            relations: ['mission']
        });

        const completedMissionIds = new Set(userMissions.map(um => um.mission.id));

        return missions.map(mission => ({
            ...mission,
            isCompleted: completedMissionIds.has(mission.id)
        }));
    }

    async findById(id: string): Promise<Mission | null> {
        return this.missionRepository.findOne({ where: { id } });
    }

    async startMission(user: User, missionId: string): Promise<UserMission> {
        const mission = await this.findById(missionId);
        if (!mission) throw new Error('Mission not found');

        const userMission = this.userMissionRepository.create({
            user,
            mission,
        });
        return this.userMissionRepository.save(userMission);
    }

    async completeMission(userMissionId: string, score: number, feedback: any): Promise<UserMission | null> {
        await this.userMissionRepository.update(userMissionId, {
            score,
            feedback,
            isCompleted: true,
            completedAt: new Date(),
        });
        return this.userMissionRepository.findOne({ where: { id: userMissionId }, relations: ['user', 'mission'] });
    }

    async getUserHistory(userId: string): Promise<UserMission[]> {
        return this.userMissionRepository.find({
            where: { user: { id: userId } },
            relations: ['mission'],
            order: { completedAt: 'DESC' },
        });
    }
}
