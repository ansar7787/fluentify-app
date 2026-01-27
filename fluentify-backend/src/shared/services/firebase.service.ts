import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import axios from 'axios';

@Injectable()
export class FirebaseService implements OnModuleInit {
    private firebaseApp: admin.app.App;

    constructor(private configService: ConfigService) { }

    onModuleInit() {
        const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
        const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
        const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n');

        if (projectId && clientEmail && privateKey) {
            this.firebaseApp = admin.initializeApp({
                credential: admin.credential.cert({
                    projectId,
                    clientEmail,
                    privateKey,
                }),
            });
        } else {
            console.warn('⚠️ Firebase Admin not initialized. Using public API for token verification.');
        }
    }

    async verifyIdToken(token: string): Promise<any> {
        if (this.firebaseApp) {
            return admin.auth().verifyIdToken(token);
        }

        // Fallback: Verify via Firebase Identity Toolkit API
        // Using the Android API Key found in client config
        const apiKey = this.configService.get<string>('FIREBASE_API_KEY');

        try {
            const response = await axios.post(
                `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${apiKey}`,
                { idToken: token }
            );

            const user = response.data.users[0];

            // Map Identity Toolkit response to DecodedIdToken structure
            return {
                uid: user.localId,
                email: user.email,
                name: user.displayName,
                picture: user.photoUrl,
                email_verified: user.emailVerified,
            };
        } catch (error) {
            console.error('Token verification failed:', error.response?.data || error.message);
            throw new Error('Invalid Firebase token (Public Verify)');
        }
    }
}
