import { Injectable } from '@nestjs/common';

@Injectable()
export class PeerService {
    private queue: { socketId: string; userId: string; name: string; level: string }[] = [];

    addUserToQueue(socketId: string, userId: string, name: string, level: string) {
        // Avoid duplicates
        if (!this.queue.find((u) => u.userId === userId)) {
            this.queue.push({ socketId, userId, name, level });
        }
    }

    removeUserFromQueue(socketId: string) {
        this.queue = this.queue.filter((u) => u.socketId !== socketId);
    }

    findMatch(socketId: string): { peerSocketId: string; peerId: string; peerName: string } | null {
        const currentUser = this.queue.find((u) => u.socketId === socketId);
        if (!currentUser) return null;

        // FDA: Simple FCFS matching for now.
        // Ideally, we match by level (same level or +/- 1).
        const peer = this.queue.find((u) => u.userId !== currentUser.userId);

        if (peer) {
            // Remove both from queue
            this.removeUserFromQueue(currentUser.socketId);
            this.removeUserFromQueue(peer.socketId);
            return { peerSocketId: peer.socketId, peerId: peer.userId, peerName: peer.name };
        }

        return null;
    }
}
