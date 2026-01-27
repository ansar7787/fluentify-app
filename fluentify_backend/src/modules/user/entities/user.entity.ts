import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum UserRole {
    USER = 'user',
    MENTOR = 'mentor',
    ADMIN = 'admin',
}

export enum SubscriptionPlan {
    FREE = 'free',
    STARTER = 'starter',
    STANDARD = 'standard',
    PRO = 'pro',
    ELITE = 'elite',
    PREMIUM = 'premium', // Legacy support
    BASIC = 'basic', // Legacy support
}

@Entity('users')
export class User {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    email: string;

    @Column({ nullable: true })
    password?: string;

    @Column()
    fullName: string;

    @Column({ nullable: true })
    avatarUrl?: string;

    @Column({
        type: 'enum',
        enum: UserRole,
        default: UserRole.USER,
    })
    role: UserRole;

    @Column({
        type: 'enum',
        enum: SubscriptionPlan,
        default: SubscriptionPlan.FREE,
    })
    subscriptionPlan: SubscriptionPlan;

    @Column({ type: 'timestamp', nullable: true })
    subscriptionExpiry?: Date;

    @Column({ default: 'A1' })
    cefrLevel: string; // A1, A2, B1, B2, C1, C2

    @Column({ default: 0 })
    coins: number;

    @Column({ default: 0 })
    streakCount: number;

    @Column({ default: 1 })
    gameLevel: number;

    @Column({ default: 1 })
    grammarLevel: number;

    @Column({ default: 1 })
    speakingLevel: number;

    @Column({ type: 'timestamp', nullable: true })
    lastPracticeDate?: Date;

    @Column({ default: true })
    isActive: boolean;

    @Column({ nullable: true })
    firebaseUid?: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
