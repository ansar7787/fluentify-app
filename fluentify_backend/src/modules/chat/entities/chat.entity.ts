import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
} from 'typeorm';
import { User as UserEntity } from '../../user/entities/user.entity';

@Entity('conversations')
export class ConversationEntity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('text', { array: true })
    participant_ids: string[];

    @Column({ nullable: true })
    last_message_content: string;

    @Column({ nullable: true })
    last_message_at: Date;

    @CreateDateColumn()
    created_at: Date;

    @UpdateDateColumn()
    updated_at: Date;
}

@Entity('messages')
export class MessageEntity {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    conversation_id: string;

    @Column()
    sender_id: string;

    @Column()
    content: string;

    @Column({ default: false })
    is_read: boolean;

    @ManyToOne(() => ConversationEntity)
    @JoinColumn({ name: 'conversation_id' })
    conversation: ConversationEntity;

    @ManyToOne(() => UserEntity)
    @JoinColumn({ name: 'sender_id' })
    sender: UserEntity;

    @CreateDateColumn()
    created_at: Date;
}
