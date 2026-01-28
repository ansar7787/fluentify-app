import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MissionService } from './mission.service';
import { MissionController } from './mission.controller';
import { Mission } from './entities/mission.entity';
import { UserMission } from './entities/user-mission.entity';
import { AIService } from '../../shared/services/ai.service';
import { UserModule } from '../user/user.module';

@Module({
    imports: [TypeOrmModule.forFeature([Mission, UserMission]), UserModule],
    controllers: [MissionController],
    providers: [MissionService, AIService],
    exports: [MissionService],
})
export class MissionModule { }
