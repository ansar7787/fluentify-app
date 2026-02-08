import { Controller, Get, Post, Body, UseGuards, UseInterceptors, UploadedFile } from '@nestjs/common';
import { SpeakingPartnerService } from './speaking-partner.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { FileInterceptor } from '@nestjs/platform-express';

@Controller('speaking-partner')
@UseGuards(JwtAuthGuard)
export class SpeakingPartnerController {
    constructor(private readonly speakingPartnerService: SpeakingPartnerService) { }

    @Get('scenarios')
    async getScenarios() {
        return await this.speakingPartnerService.getScenarios();
    }

    @Post('turn')
    @UseInterceptors(FileInterceptor('audio'))
    async processTurn(
        @UploadedFile() file: Express.Multer.File,
        @Body('scenarioId') scenarioId: string,
        @Body('history') history: string,
    ) {
        return await this.speakingPartnerService.processTurn(scenarioId, file.buffer, history);
    }
}
