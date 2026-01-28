import { Controller, Get, Post, Body, Param, Put, Delete, Query, UseGuards } from '@nestjs/common';
import { GameService } from './game.service';
import { GameLevel } from './entities/game-level.entity';

@Controller('game')
export class GameController {
    constructor(private readonly gameService: GameService) { }

    @Get('levels')
    async getLevels(@Query('type') gameType: string): Promise<GameLevel[]> {
        return this.gameService.getLevels(gameType);
    }

    @Get('levels/:id')
    async getLevel(@Param('id') id: string): Promise<GameLevel> {
        return this.gameService.getLevelById(id);
    }

    @Post('levels')
    async createLevel(@Body() data: Partial<GameLevel>): Promise<GameLevel> {
        return this.gameService.createLevel(data);
    }

    @Put('levels/:id')
    async updateLevel(@Param('id') id: string, @Body() data: Partial<GameLevel>): Promise<GameLevel> {
        return this.gameService.updateLevel(id, data);
    }

    @Delete('levels/:id')
    async deleteLevel(@Param('id') id: string): Promise<void> {
        return this.gameService.deleteLevel(id);
    }
}
