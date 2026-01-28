import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('game_levels')
export class GameLevel {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    gameType: string; // 'grammar', 'speaking', 'scramble', etc.

    @Column()
    levelNumber: number;

    @Column()
    title: string;

    @Column({ nullable: true })
    description: string;

    @Column({ type: 'jsonb', default: [] })
    content: any; // Holds challenges/questions

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
