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

    private async validateStreak(user: User): Promise<User> {
        if (!user.lastPracticeDate) return user;

        const now = new Date();
        const lastPractice = new Date(user.lastPracticeDate);

        // Reset time components to compare only dates
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const last = new Date(lastPractice.getFullYear(), lastPractice.getMonth(), lastPractice.getDate());

        const diffTime = Math.abs(today.getTime() - last.getTime());
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        // If more than 1 day has passed (meaning they missed yesterday), reset streak
        if (diffDays > 1) {
            user.streakCount = 0;
            // distinct from lastPracticeDate, strictly speaking we might want to update this only on activity
            // but for reset purposes, we just update the count.
            await this.userRepository.save(user);
        }
        return user;
    }

    async findById(id: string): Promise<any> {
        let user = await this.userRepository.findOne({ where: { id } });
        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }

        // Validate streak on fetch
        user = await this.validateStreak(user);

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
        // If we represent activity, update lastPracticeDate
        if (updateData.coins || updateData.gameLevel || updateData.wordMatchLevel) {
            // Check if we need to increment streak
            const user = await this.userRepository.findOne({ where: { id } });
            if (user) {
                const now = new Date();
                const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

                let last: Date | null = null;
                if (user.lastPracticeDate) {
                    const ld = new Date(user.lastPracticeDate);
                    last = new Date(ld.getFullYear(), ld.getMonth(), ld.getDate());
                }

                // If never practiced, or practiced yesterday (diff 1), increment
                // If practiced today (diff 0), do nothing
                // If practiced long ago (diff > 1), reset to 1

                if (!last) {
                    updateData.streakCount = 1;
                    updateData.lastPracticeDate = now;
                } else {
                    const diffTime = Math.abs(today.getTime() - last.getTime());
                    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                    if (diffDays === 1) {
                        updateData.streakCount = (user.streakCount || 0) + 1;
                        updateData.lastPracticeDate = now;
                    } else if (diffDays > 1) {
                        updateData.streakCount = 1;
                        updateData.lastPracticeDate = now;
                    } else {
                        // Same day, update time but not streak
                        updateData.lastPracticeDate = now;
                    }
                }
            }
        }

        await this.userRepository.update(id, updateData);
        return this.findById(id);
    }

    async findByFirebaseUid(firebaseUid: string): Promise<User | null> {
        let user = await this.userRepository.findOne({ where: { firebaseUid } });
        if (user) {
            user = await this.validateStreak(user);
        }
        return user;
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
