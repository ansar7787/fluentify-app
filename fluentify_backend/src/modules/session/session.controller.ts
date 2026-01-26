import {
    Controller,
    Post,
    Get,
    Body,
    Param,
    UseGuards,
    Request,
    HttpCode,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SessionService } from './session.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Session')
@Controller('session')
export class SessionController {
    constructor(private readonly sessionService: SessionService) { }

    @Post('initiate')
    @UseGuards(JwtAuthGuard)
    @HttpCode(201)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Initiate session and get Agora token' })
    async initiateSession(
        @Request() req,
        @Body() body: { bookingId: string },
    ) {
        const result = await this.sessionService.initiateSession(body.bookingId, req.user.id);
        return {
            success: true,
            message: 'Session initiated',
            data: result,
        };
    }

    @Post(':id/end')
    @UseGuards(JwtAuthGuard)
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'End session' })
    async endSession(
        @Param('id') sessionId: string,
        @Body() body: { recordingUrl?: string; feedback?: string },
    ) {
        const session = await this.sessionService.endSession(
            sessionId,
            body.recordingUrl,
            body.feedback,
        );
        return {
            success: true,
            message: 'Session ended',
            data: session,
        };
    }

    @Get('analytics')
    @UseGuards(JwtAuthGuard)
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get user analytics' })
    async getUserAnalytics(@Request() req) {
        const analytics = await this.sessionService.getUserAnalytics(req.user.id);
        return {
            success: true,
            data: analytics,
        };
    }
}
