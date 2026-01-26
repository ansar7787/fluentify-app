import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MessageEntity, ConversationEntity } from './entities/chat.entity';

@Injectable()
export class ChatService {
    private readonly logger = new Logger(ChatService.name);

    constructor(
        @InjectRepository(MessageEntity)
        private readonly messageRepository: Repository<MessageEntity>,
        @InjectRepository(ConversationEntity)
        private readonly conversationRepository: Repository<ConversationEntity>,
    ) { }

    async saveMessage(senderId: string, conversationId: string, content: string): Promise<MessageEntity> {
        try {
            const message = this.messageRepository.create({
                sender_id: senderId,
                conversation_id: conversationId,
                content: content,
            });

            await this.messageRepository.save(message);

            // Update conversation last message
            await this.conversationRepository.update(conversationId, {
                last_message_content: content,
                last_message_at: new Date(),
            });

            return message;
        } catch (error) {
            this.logger.error(`Failed to save message: ${error.message}`);
            throw error;
        }
    }

    async getMessages(conversationId: string, limit: number = 50): Promise<MessageEntity[]> {
        return await this.messageRepository.find({
            where: { conversation_id: conversationId },
            order: { created_at: 'ASC' }, // Oldest first for chat history usually, or DESC then reverse
            take: limit,
            relations: ['sender'],
        });
    }

    async createOrGetConversation(userId1: string, userId2: string): Promise<ConversationEntity> {
        // Check if conversation exists (naive implementation for array check)
        // In production, would use a better query or a junction table
        // For now, fetching all involving user1 and filtering in JS (bad for scale, good for MVP)
        const conversations = await this.conversationRepository
            .createQueryBuilder('conversation')
            .where(':id = ANY(participant_ids)', { id: userId1 })
            .getMany();

        const existing = conversations.find(c => c.participant_ids.includes(userId2));

        if (existing) {
            return existing;
        }

        const newConv = this.conversationRepository.create({
            participant_ids: [userId1, userId2],
            last_message_at: new Date(),
        });

        return await this.conversationRepository.save(newConv);
    }

    async getUserConversations(userId: string): Promise<ConversationEntity[]> {
        return await this.conversationRepository
            .createQueryBuilder('conversation')
            .where(':id = ANY(participant_ids)', { id: userId })
            .orderBy('last_message_at', 'DESC')
            .getMany();
    }
}
