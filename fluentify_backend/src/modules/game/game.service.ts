import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GameLevel } from './entities/game-level.entity';

@Injectable()
export class GameService {
    constructor(
        @InjectRepository(GameLevel)
        private gameLevelRepository: Repository<GameLevel>,
    ) { }

    async createLevel(data: Partial<GameLevel>): Promise<GameLevel> {
        const level = this.gameLevelRepository.create(data);
        return this.gameLevelRepository.save(level);
    }

    async getLevels(gameType: string): Promise<GameLevel[]> {
        return this.gameLevelRepository.find({
            where: { gameType },
            order: { levelNumber: 'ASC' },
        });
    }

    async getLevelById(id: string): Promise<GameLevel> {
        const level = await this.gameLevelRepository.findOne({ where: { id } });
        if (!level) throw new NotFoundException('Level not found');
        return level;
    }

    async updateLevel(id: string, data: Partial<GameLevel>): Promise<GameLevel> {
        await this.gameLevelRepository.update(id, data);
        return this.getLevelById(id);
    }

    async deleteLevel(id: string): Promise<void> {
        await this.gameLevelRepository.delete(id);
    }
}
