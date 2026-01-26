import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import * as bcrypt from 'bcryptjs';
import { FirebaseService } from '../../shared/services/firebase.service';
import { User } from '../user/entities/user.entity';

@Injectable()
export class AuthService {
    constructor(
        private userService: UserService,
        private jwtService: JwtService,
        private firebaseService: FirebaseService,
    ) { }

    async validateUser(email: string, pass: string): Promise<any> {
        const user = await this.userService.findByEmail(email);
        if (user && user.password && (await bcrypt.compare(pass, user.password))) {
            const { password, ...result } = user;
            return result;
        }
        return null;
    }

    async login(user: any) {
        const payload = { email: user.email, sub: user.id, role: user.role };
        return {
            access_token: this.jwtService.sign(payload),
            user,
        };
    }

    async register(userData: any) {
        const existingUser = await this.userService.findByEmail(userData.email);
        if (existingUser) {
            throw new ConflictException('Email already exists');
        }

        const hashedPassword = await bcrypt.hash(userData.password, 10);
        const user = await this.userService.create({
            ...userData,
            password: hashedPassword,
        });

        const { password, ...result } = user;
        return this.login(result);
    }

    async firebaseLogin(token: string) {
        try {
            const decodedToken = await this.firebaseService.verifyIdToken(token);
            let user = await this.userService.findByFirebaseUid(decodedToken.uid);

            if (!user) {
                const email = decodedToken.email;
                if (!email) {
                    throw new UnauthorizedException('Firebase token does not contain an email');
                }
                user = await this.userService.findByEmail(email);
                if (user) {
                    // Link firebase account to existing email
                    user = await this.userService.update(user.id, { firebaseUid: decodedToken.uid });
                } else {
                    // Create new user
                    user = await this.userService.create({
                        email: email,
                        fullName: decodedToken.name || email.split('@')[0],
                        avatarUrl: decodedToken.picture,
                        firebaseUid: decodedToken.uid,
                    });
                }
            }

            return this.login(user);
        } catch (error) {
            throw new UnauthorizedException('Invalid Firebase token');
        }
    }
}
