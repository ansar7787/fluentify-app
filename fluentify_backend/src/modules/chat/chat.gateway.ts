import {
    WebSocketGateway,
    SubscribeMessage,
    MessageBody,
    ConnectedSocket,
    WebSocketServer,
    OnGatewayConnection,
    OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
    cors: {
        origin: '*', // Allow all origins for dev
    },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(ChatGateway.name);

    // Map to track active users: userId -> socketId
    private activeUsers = new Map<string, string>();

    constructor(private readonly chatService: ChatService) { }

    handleConnection(client: Socket) {
        this.logger.log(`Client connected: ${client.id}`);
        const userId = client.handshake.query.userId as string;
        if (userId) {
            this.activeUsers.set(userId, client.id);
            client.join(userId); // Join a room specific to this user
            this.logger.log(`User ${userId} joined room ${userId}`);
        }
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected: ${client.id}`);
        // Ideally remove from activeUsers
    }

    @SubscribeMessage('sendMessage')
    async handleMessage(
        @MessageBody() payload: { senderId: string; receiverId: string; content: string },
        @ConnectedSocket() client: Socket,
    ) {
        this.logger.log(`Message from ${payload.senderId} to ${payload.receiverId}: ${payload.content}`);

        // 1. Get or create conversation
        let conversation = await this.chatService.createOrGetConversation(payload.senderId, payload.receiverId);

        // 2. Save message
        const savedMessage = await this.chatService.saveMessage(payload.senderId, conversation.id, payload.content);

        // 3. Emit to receiver if online (via their room)
        this.server.to(payload.receiverId).emit('receiveMessage', savedMessage);

        // 4. Emit back to sender (confirm/update UI)
        client.emit('messageSent', savedMessage);
    }

    @SubscribeMessage('typing')
    handleTyping(@MessageBody() payload: { senderId: string; receiverId: string }) {
        this.server.to(payload.receiverId).emit('userTyping', { userId: payload.senderId });
    }
}
