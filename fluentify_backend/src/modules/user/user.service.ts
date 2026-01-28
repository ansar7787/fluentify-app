import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { User } from './entities/user.entity';
import { UserMission } from '../mission/entities/user-mission.entity';

@Injectable()
export class UserService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
        @InjectRepository(UserMission)
        private userMissionRepository: Repository<UserMission>,
    ) { }

    // ... existing methods ...

    async getUserRank(userId: string): Promise<number> {
        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (!user) return 0;

        const higherRanked = await this.userRepository.count({
            where: { coins: MoreThan(user.coins) }
        });
        return higherRanked + 1;
    }


    async findByEmail(email: string): Promise<User | null> {
        return this.userRepository.findOne({ where: { email } });
    }

    async findById(id: string): Promise<any> {
        const user = await this.userRepository.findOne({ where: { id } });
        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }

        const missionsCompleted = await this.userMissionRepository.count({
            where: { user: { id }, isCompleted: true }
        });

        return {
            ...user,
            missionsCompleted
        };
    }

    async create(userData: Partial<User>): Promise<User> {
        const user = this.userRepository.create(userData);
        return this.userRepository.save(user);
    }

    async update(id: string, updateData: Partial<User>): Promise<User> {
        await this.userRepository.update(id, updateData);
        return this.findById(id);
    }

    async findByFirebaseUid(firebaseUid: string): Promise<User | null> {
        return this.userRepository.findOne({ where: { firebaseUid } });
    }

    async getLeaderboard(limit: number = 20): Promise<User[]> {
        return this.userRepository.find({
            order: { coins: 'DESC' },
            take: limit,
            select: ['id', 'fullName', 'avatarUrl', 'coins', 'streakCount', 'cefrLevel']
        });
    }

    async addCoins(userId: string, amount: number): Promise<User> {
        const user = await this.findById(userId);
        user.coins = (user.coins || 0) + amount;
        return this.userRepository.save(user);
    }
}
