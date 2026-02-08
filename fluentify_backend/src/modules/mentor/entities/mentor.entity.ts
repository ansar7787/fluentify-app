import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    OneToMany,
    JoinColumn,
} from 'typeorm';
import { User as UserEntity } from '../../user/entities/user.entity';

@Entity('mentors')
export class MentorEntity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    user_id: string;

    @Column()
    specialization: string;

    @Column('text', { array: true })
    languages: string[];

    @Column('text', { array: true })
    certifications: string[];

    @Column('text')
    bio: string;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    hourly_rate: number;

    @Column({ type: 'decimal', precision: 3, scale: 1, default: 0 })
    average_rating: number;

    @Column({ default: 0 })
    total_reviews: number;

    @Column({ default: 0 })
    total_sessions_completed: number;

    @Column({ default: 0 })
    total_earnings: number;

    @Column({ default: false })
    is_verified: boolean;

    @Column({ default: true })
    is_active: boolean;

    @Column('text', { array: true, default: [] })
    available_slots: string[];

    @ManyToOne(() => UserEntity)
    @JoinColumn({ name: 'user_id' })
    user: UserEntity;

    @OneToMany(() => BookingEntity, (booking) => booking.mentor)
    bookings: BookingEntity[];

    @CreateDateColumn()
    created_at: Date;

    @UpdateDateColumn()
    updated_at: Date;
}

@Entity('bookings')
export class BookingEntity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    user_id: string;

    @Column()
    mentor_id: string;

    @Column()
    scheduled_at: Date;

    @Column({ nullable: true })
    completed_at: Date;

    @Column()
    duration_minutes: number;

    @Column({
        type: 'enum',
        enum: ['pending', 'scheduled', 'completed', 'cancelled'],
        default: 'pending',
    })
    status: string;

    @Column({ nullable: true })
    notes: string;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    session_cost: number;

    @Column()
    coins_spent: number;

    @Column({ nullable: true })
    session_recording_url: string;

    @Column({ nullable: true })
    meeting_link: string;

    @ManyToOne(() => MentorEntity, (mentor) => mentor.bookings)
    @JoinColumn({ name: 'mentor_id' })
    mentor: MentorEntity;

    @CreateDateColumn()
    created_at: Date;

    @UpdateDateColumn()
    updated_at: Date;
}
