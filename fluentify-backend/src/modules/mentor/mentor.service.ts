import {
    Injectable,
    BadRequestException,
    NotFoundException,
    Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MentorEntity, BookingEntity } from './entities/mentor.entity';
import { User as UserEntity, UserRole } from '../user/entities/user.entity';

@Injectable()
export class MentorService {
    private readonly logger = new Logger(MentorService.name);

    constructor(
        @InjectRepository(MentorEntity)
        private readonly mentorRepository: Repository<MentorEntity>,
        @InjectRepository(BookingEntity)
        private readonly bookingRepository: Repository<BookingEntity>,
        @InjectRepository(UserEntity)
        private readonly userRepository: Repository<UserEntity>,
    ) { }

    async createMentorProfile(userId: string, mentorData: any): Promise<MentorEntity> {
        try {
            const user = await this.userRepository.findOne({
                where: { id: userId },
            });

            if (!user) {
                throw new NotFoundException('User not found');
            }

            const existingMentor = await this.mentorRepository.findOne({
                where: { user_id: userId },
            });

            if (existingMentor) {
                throw new BadRequestException('Mentor profile already exists');
            }

            const mentor = this.mentorRepository.create({
                user_id: userId,
                ...mentorData,
            });

            const savedMentor = await this.mentorRepository.save(mentor);

            user.role = UserRole.MENTOR;
            await this.userRepository.save(user);

            this.logger.log(`Mentor profile created: ${(savedMentor as any).id}`);

            return savedMentor as any;
        } catch (error) {
            this.logger.error(`Failed to create mentor profile: ${error.message}`);
            throw error;
        }
    }

    async getAllMentors(filters?: any): Promise<MentorEntity[]> {
        try {
            let query = this.mentorRepository
                .createQueryBuilder('mentor')
                .leftJoinAndSelect('mentor.user', 'user') // Include user details
                .where('mentor.is_active = :active', { active: true });
            //.andWhere('mentor.is_verified = :verified', { verified: true }); // Temporarily allow unverified for testing

            if (filters?.language) {
                query = query.andWhere(':language = ANY(mentor.languages)', {
                    language: filters.language,
                });
            }

            if (filters?.minRating) {
                query = query.andWhere('mentor.average_rating >= :minRating', {
                    minRating: filters.minRating,
                });
            }

            if (filters?.specialization) {
                query = query.andWhere('mentor.specialization ILIKE :spec', {
                    spec: `%${filters.specialization}%`,
                });
            }

            return await query.orderBy('mentor.average_rating', 'DESC').getMany();
        } catch (error) {
            this.logger.error(`Failed to fetch mentors: ${error.message}`);
            throw error;
        }
    }

    async getMentorById(mentorId: string): Promise<MentorEntity> {
        try {
            const mentor = await this.mentorRepository.findOne({
                where: { id: mentorId },
                relations: ['user', 'bookings'],
            });

            if (!mentor) {
                throw new NotFoundException('Mentor not found');
            }

            return mentor;
        } catch (error) {
            this.logger.error(`Failed to fetch mentor: ${error.message}`);
            throw error;
        }
    }

    async createBooking(
        userId: string,
        mentorId: string,
        bookingData: any,
    ): Promise<BookingEntity> {
        try {
            const mentor = await this.getMentorById(mentorId);

            if (!mentor) {
                throw new NotFoundException('Mentor not found');
            }

            const user = await this.userRepository.findOne({
                where: { id: userId },
            });

            if (!user) {
                throw new NotFoundException('User not found');
            }

            // Simple cost calc: hourly_rate * (minutes / 60). Assuming 1 coin = 1 currency unit for now or keep separate
            const coinsNeeded = Math.ceil((bookingData.durationMinutes / 60) * mentor.hourly_rate);

            // Verify wallet balance
            if (user.coins < coinsNeeded) {
                throw new BadRequestException('Insufficient coins for booking');
            }

            const booking = this.bookingRepository.create({
                user_id: userId,
                mentor_id: mentorId,
                scheduled_at: bookingData.scheduledAt,
                duration_minutes: bookingData.durationMinutes,
                session_cost: (bookingData.durationMinutes / 60) * mentor.hourly_rate,
                coins_spent: coinsNeeded,
                status: 'pending',
            });

            const savedBooking = await this.bookingRepository.save(booking);

            user.coins -= coinsNeeded;
            await this.userRepository.save(user as any);

            this.logger.log(`Booking created: ${savedBooking.id}`);

            return savedBooking;
        } catch (error) {
            this.logger.error(`Failed to create booking: ${error.message}`);
            throw error;
        }
    }

    async confirmBooking(bookingId: string, meetingLink: string): Promise<BookingEntity> {
        try {
            const booking = await this.bookingRepository.findOne({
                where: { id: bookingId },
            });

            if (!booking) {
                throw new NotFoundException('Booking not found');
            }

            booking.status = 'scheduled';
            booking.meeting_link = meetingLink;

            const updatedBooking = await this.bookingRepository.save(booking);

            this.logger.log(`Booking confirmed: ${bookingId}`);

            return updatedBooking;
        } catch (error) {
            this.logger.error(`Failed to confirm booking: ${error.message}`);
            throw error;
        }
    }

    async getUserBookings(userId: string): Promise<BookingEntity[]> {
        try {
            return await this.bookingRepository.find({
                where: { user_id: userId },
                relations: ['mentor', 'mentor.user'],
                order: { scheduled_at: 'DESC' },
            });
        } catch (error) {
            this.logger.error(`Failed to fetch user bookings: ${error.message}`);
            throw error;
        }
    }

    async setAvailability(userId: string, slots: string[]): Promise<MentorEntity> {
        try {
            const mentor = await this.mentorRepository.findOne({
                where: { user_id: userId }, // Mentors are found by user_id
            });

            if (!mentor) {
                throw new NotFoundException('Mentor not found');
            }

            mentor.available_slots = slots;
            const updatedMentor = await this.mentorRepository.save(mentor);

            this.logger.log(`Mentor availability updated: ${mentor.id}`);

            return updatedMentor;
        } catch (error) {
            this.logger.error(`Failed to update availability: ${error.message}`);
            throw error;
        }
    }

    // Helper methods
    async completeBooking(bookingId: string, recordingUrl?: string): Promise<BookingEntity | null> { return null; } // Placeholder
    async cancelBooking(bookingId: string): Promise<BookingEntity | null> { return null; } // Placeholder
}
