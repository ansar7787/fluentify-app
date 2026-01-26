import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
} from 'typeorm';

@Entity('sessions')
export class SessionEntity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    booking_id: string;

    @Column()
    agora_channel_id: string;

    @Column({ nullable: true })
    session_recording_url: string;

    @Column()
    start_time: Date;

    @Column({ nullable: true })
    end_time: Date;

    @Column({ default: 'pending' })
    status: string; // pending, active, completed, cancelled

    @Column({ default: 0 })
    duration_seconds: number;

    @Column({ nullable: true })
    feedback: string;

    @CreateDateColumn()
    created_at: Date;

    @UpdateDateColumn()
    updated_at: Date;
}

@Entity('user_analytics')
export class UserAnalyticsEntity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    user_id: string;

    @Column({ default: 0 })
    total_sessions: number;

    @Column({ default: 0 })
    total_minutes: number;

    @Column({ default: 0 })
    total_coins_earned: number;

    @Column({ default: 0 })
    total_coins_spent: number;

    @Column({ default: 0 })
    average_session_rating: number;

    @Column('jsonb', { default: '{}' })
    language_progress: Record<string, any>;

    @Column('jsonb', { default: '{}' })
    category_stats: Record<string, any>;

    @CreateDateColumn()
    created_at: Date;

    @UpdateDateColumn()
    updated_at: Date;
}
