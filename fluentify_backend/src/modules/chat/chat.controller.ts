import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
    constructor(private readonly chatService: ChatService) { }

    @Get('conversations')
    async getConversations(@Request() req) {
        const data = await this.chatService.getUserConversations(req.user.id);
        return { success: true, data };
    }

    @Get('messages')
    async getMessages(@Query('conversationId') conversationId: string) {
        const data = await this.chatService.getMessages(conversationId);
        return { success: true, data };
    }
}
