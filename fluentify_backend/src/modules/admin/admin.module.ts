import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { User as UserEntity } from '../user/entities/user.entity';
import { MentorEntity } from '../mentor/entities/mentor.entity';
import { SessionEntity } from '../session/entities/session.entity';

@Module({
    imports: [
        TypeOrmModule.forFeature([UserEntity, MentorEntity, SessionEntity]),
    ],
    controllers: [AdminController],
    providers: [AdminService],
    exports: [AdminService],
})
export class AdminModule { }
