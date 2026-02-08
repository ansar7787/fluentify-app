import {
    WebSocketGateway,
    SubscribeMessage,
    MessageBody,
    ConnectedSocket,
    OnGatewayInit,
    OnGatewayConnection,
    OnGatewayDisconnect,
    WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
    cors: {
        origin: '*', // Allow all origins for dev simplicity
    },
    namespace: 'chat',
})
export class ChatGateway
    implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer() server: Server;
    private logger: Logger = new Logger('ChatGateway');

    afterInit(server: Server) {
        this.logger.log('Chat Gateway Initialized');
    }

    handleConnection(client: Socket) {
        this.logger.log(`Client connected: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected: ${client.id}`);
    }

    @SubscribeMessage('joinRoom')
    handleJoinRoom(
        @MessageBody() room: string,
        @ConnectedSocket() client: Socket,
    ) {
        client.join(room);
        this.logger.log(`Client ${client.id} joined room ${room}`);
        client.emit('joinedRoom', room);
    }

    @SubscribeMessage('sendMessage')
    handleMessage(
        @MessageBody() payload: { room: string; sender: string; message: string; timestamp: string },
        @ConnectedSocket() client: Socket,
    ) {
        this.logger.log(`Message in ${payload.room}: ${payload.message}`);
        // Broadcast to everyone in the room EXCEPT the sender (optional, but usually frontend handles own echo)
        // Or just broadcast to room including sender:
        this.server.to(payload.room).emit('receiveMessage', payload);
    }
}
