import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum MissionType {
    AI = 'ai',
    PEER = 'peer',
    MENTOR = 'mentor',
}

export enum MissionLevel {
    BEGINNER = 'beginner',
    INTERMEDIATE = 'intermediate',
    ADVANCED = 'advanced',
}

@Entity('missions')
export class Mission {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    title: string;

    @Column('text')
    description: string;

    @Column('text', { nullable: true })
    content: string; // The text or prompt for the mission

    @Column({
        type: 'enum',
        enum: MissionType,
        default: MissionType.AI,
    })
    type: MissionType;

    @Column({
        type: 'enum',
        enum: MissionLevel,
        default: MissionLevel.BEGINNER,
    })
    level: MissionLevel;

    @Column({ default: 10 })
    rewardCoins: number;

    @Column({ default: false })
    isPremium: boolean;

    @Column({ nullable: true })
    imageUrl?: string;

    @Column({ nullable: true })
    category?: string; // Interview, Office, Travel, etc.

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
