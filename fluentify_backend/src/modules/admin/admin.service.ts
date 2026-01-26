import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User as UserEntity } from '../user/entities/user.entity';
import { MentorEntity } from '../mentor/entities/mentor.entity';
import { SessionEntity } from '../session/entities/session.entity';

@Injectable()
export class AdminService {
    private readonly logger = new Logger(AdminService.name);

    constructor(
        @InjectRepository(UserEntity)
        private readonly userRepository: Repository<UserEntity>,
        @InjectRepository(MentorEntity)
        private readonly mentorRepository: Repository<MentorEntity>,
        @InjectRepository(SessionEntity)
        private readonly sessionRepository: Repository<SessionEntity>,
    ) { }

    async getDashboardStats(): Promise<any> {
        try {
            const totalUsers = await this.userRepository.count();
            const activeMentors = await this.mentorRepository.count({ where: { is_active: true } });
            const pendingMentors = await this.mentorRepository.count({ where: { is_verified: false } });
            const totalSessions = await this.sessionRepository.count();
            const completedSessions = await this.sessionRepository.count({ where: { status: 'completed' } });

            return {
                users: { total: totalUsers },
                mentors: { active: activeMentors, pending: pendingMentors },
                sessions: { total: totalSessions, completed: completedSessions },
            };
        } catch (error) {
            this.logger.error(`Failed to fetch admin stats: ${error.message}`);
            throw error;
        }
    }

    async getAllUsers(page: number = 1, limit: number = 10): Promise<any> {
        const [users, total] = await this.userRepository.findAndCount({
            take: limit,
            skip: (page - 1) * limit,
            order: { createdAt: 'DESC' },
        });

        return {
            data: users,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getPendingMentors(): Promise<MentorEntity[]> {
        return await this.mentorRepository.find({
            where: { is_verified: false },
            relations: ['user'],
        });
    }

    async verifyMentor(mentorId: string, verify: boolean): Promise<void> {
        const mentor = await this.mentorRepository.findOne({ where: { id: mentorId } });
        if (mentor) {
            mentor.is_verified = verify;
            // If rejected, maybe set is_active = false or delete? For now just verify boolean.
            await this.mentorRepository.save(mentor);
        }
    }
}
