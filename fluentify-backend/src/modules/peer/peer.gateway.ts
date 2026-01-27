import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    ConnectedSocket,
    MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { PeerService } from './peer.service';
import { AgoraService } from './agora.service';
import { JwtService } from '@nestjs/jwt';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
    namespace: 'peer',
})
export class PeerGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    constructor(
        private peerService: PeerService,
        private agoraService: AgoraService,
        private jwtService: JwtService,
    ) { }

    async handleConnection(client: Socket) {
        try {
            const token = client.handshake.query.token as string;
            if (!token) {
                client.disconnect();
                return;
            }
            // Verify token logic if needed, or rely on AuthGuard for specific events
            // For simplicity, we decode minimal info here if strictly needed
        } catch (e) {
            client.disconnect();
        }
    }

    handleDisconnect(client: Socket) {
        this.peerService.removeUserFromQueue(client.id);
    }

    @SubscribeMessage('join_queue')
    handleJoinQueue(
        @ConnectedSocket() client: Socket,
        @MessageBody() payload: { userId: string; name: string; level: string },
    ) {
        this.peerService.addUserToQueue(client.id, payload.userId, payload.name, payload.level);

        // Try to find a match immediately
        const match = this.peerService.findMatch(client.id);
        if (match) {
            // Generate Agora Token for a shared channel (e.g., sorted user IDs)
            const channelName = [payload.userId, match.peerId].sort().join('_');

            // We need numeric UIDs for Agora in some SDK versions, but string accounts are supported 
            // if using string user accounts. RtcTokenBuilder supports numeric uid. 
            // For simplicity, let's use 0 (auto-assign) or a hash of userId if needed. 
            // Actually, flutter_agora uses integer UID typically.
            // Let's rely on client passing 0 to join and getting assigned a UID, 
            // OR we hash the userId to an int32.
            // For MVP, we will send the Token generated for a wild-card/generic UID or specific if mapped.

            // Let's use a random numeric UID for the token generation for THIS user session
            const uid1 = Math.floor(Math.random() * 100000) + 1;
            const uid2 = Math.floor(Math.random() * 100000) + 1;

            const token1 = this.agoraService.generateToken(channelName, uid1);
            const token2 = this.agoraService.generateToken(channelName, uid2);

            // Notify Current User
            client.emit('match_found', {
                channelName,
                token: token1,
                uid: uid1,
                peerName: match.peerName,
            });

            // Notify Peer
            this.server.to(match.peerSocketId).emit('match_found', {
                channelName,
                token: token2,
                uid: uid2,
                peerName: payload.name,
            });
        } else {
            client.emit('queue_joined', { message: 'Waiting for a match...' });
        }
    }

    @SubscribeMessage('leave_queue')
    handleLeaveQueue(@ConnectedSocket() client: Socket) {
        this.peerService.removeUserFromQueue(client.id);
    }
}
