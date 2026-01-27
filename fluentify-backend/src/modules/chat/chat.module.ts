import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ChatGateway } from './chat.gateway';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { MessageEntity, ConversationEntity } from './entities/chat.entity';

@Module({
    imports: [TypeOrmModule.forFeature([MessageEntity, ConversationEntity])],
    controllers: [ChatController],
    providers: [ChatGateway, ChatService],
})
export class ChatModule { }
