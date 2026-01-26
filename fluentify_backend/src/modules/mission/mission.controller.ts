import { Controller, Get, Post, Body, Param, UseGuards, Request, Query, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { MissionService } from './mission.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiConsumes, ApiBody } from '@nestjs/swagger';

@ApiTags('missions')
@Controller('missions')
export class MissionController {
    constructor(private readonly missionService: MissionService) { }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Get()
    @ApiOperation({ summary: 'Get all missions' })
    findAll(@Query('level') level: string) {
        if (level) {
            return this.missionService.findByLevel(level);
        }
        return this.missionService.findAll();
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Get(':id')
    @ApiOperation({ summary: 'Get mission by ID' })
    findOne(@Param('id') id: string) {
        return this.missionService.findById(id);
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Post(':id/start')
    @ApiOperation({ summary: 'Start a mission session' })
    startMission(@Request() req, @Param('id') id: string) {
        return this.missionService.startMission(req.user, id);
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Post(':id/submit')
    @UseInterceptors(FileInterceptor('audio'))
    @ApiConsumes('multipart/form-data')
    @ApiBody({
        schema: {
            type: 'object',
            properties: {
                audio: {
                    type: 'string',
                    format: 'binary',
                },
            },
        },
    })
    @ApiOperation({ summary: 'Submit mission audio for AI analysis' })
    submit(@Request() req, @Param('id') id: string, @UploadedFile() file: Express.Multer.File) {
        return this.missionService.submitAttempt(req.user, id, file.buffer);
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Get('history')
    @ApiOperation({ summary: 'Get user mission history' })
    getHistory(@Request() req) {
        return this.missionService.getUserHistory(req.user.id);
    }
}
