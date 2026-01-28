import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MentorEntity, BookingEntity } from './entities/mentor.entity';
import { MentorService } from './mentor.service';
import { MentorController } from './mentor.controller';
import { User as UserEntity } from '../user/entities/user.entity';

@Module({
    imports: [
        TypeOrmModule.forFeature([MentorEntity, BookingEntity, UserEntity]),
    ],
    controllers: [MentorController],
    providers: [MentorService],
    exports: [MentorService],
})
export class MentorModule { }
