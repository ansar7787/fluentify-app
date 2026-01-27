import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserService } from './user.service';
import { User } from './entities/user.entity';
import { UserMission } from '../mission/entities/user-mission.entity';

import { UserController } from './user.controller';

@Module({
    imports: [TypeOrmModule.forFeature([User, UserMission])],
    controllers: [UserController],
    providers: [UserService],
    exports: [UserService],
})
export class UserModule { }
