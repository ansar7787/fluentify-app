import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GameController } from './game.controller';
import { GameService } from './game.service';
import { GameLevel } from './entities/game-level.entity';

@Module({
    imports: [TypeOrmModule.forFeature([GameLevel])],
    controllers: [GameController],
    providers: [GameService],
    exports: [GameService],
})
export class GameModule { }
