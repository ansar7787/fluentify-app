import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Mission } from './entities/mission.entity';
import { UserMission } from './entities/user-mission.entity';
import { User } from '../user/entities/user.entity';
import { AIService } from '../../shared/services/ai.service';
import { UserService } from '../user/user.service';

@Injectable()
export class MissionService {
    constructor(
        @InjectRepository(Mission)
        private missionRepository: Repository<Mission>,
        @InjectRepository(UserMission)
        private userMissionRepository: Repository<UserMission>,
        private aiService: AIService,
        private userService: UserService,
    ) { }

    async submitAttempt(user: User, missionId: string, audioBuffer: Buffer): Promise<UserMission> {
        const mission = await this.findById(missionId);
        if (!mission) throw new NotFoundException('Mission not found');

        // 1. Get AI Analysis
        const analysis = await this.aiService.analyzeSpeech(audioBuffer, mission.content);

        // 2. Calculate overall score
        const overallScore = (analysis.fluencyScore + analysis.grammarScore + analysis.vocabularyScore + analysis.pronunciationScore) / 4;

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

    async findAll(): Promise<Mission[]> {
        return this.missionRepository.find();
    }

    async findByLevel(level: any): Promise<Mission[]> {
        return this.missionRepository.find({ where: { level } });
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
