import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../user/entities/user.entity';
import { Mission } from './mission.entity';

@Entity('user_missions')
export class UserMission {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => User)
    user: User;

    @ManyToOne(() => Mission)
    mission: Mission;

    @Column({ default: false })
    isCompleted: boolean;

    @Column({ type: 'float', nullable: true })
    score?: number;

    @Column('json', { nullable: true })
    feedback?: any; // Detailed AI feedback

    @Column({ nullable: true })
    audioUrl?: string; // Recording link

    @CreateDateColumn()
    completedAt: Date;
}
