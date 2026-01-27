import { Controller, Get, UseGuards, Request, Query, Patch, Body, Post } from '@nestjs/common';
import { UserService } from './user.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody } from '@nestjs/swagger';

@ApiTags('users')
@Controller('users')
export class UserController {
    constructor(private readonly userService: UserService) { }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Get('me')
    @ApiOperation({ summary: 'Get current user profile' })
    async getProfile(@Request() req) {
        return this.userService.findById(req.user.id);
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Patch('me')
    @ApiOperation({ summary: 'Update current user profile' })
    @ApiBody({ schema: { type: 'object', properties: { fullName: { type: 'string' }, avatarUrl: { type: 'string' }, gameLevel: { type: 'number' }, grammarLevel: { type: 'number' }, speakingLevel: { type: 'number' } } } })
    async updateProfile(@Request() req, @Body() updateData: { fullName?: string; avatarUrl?: string; gameLevel?: number; grammarLevel?: number; speakingLevel?: number }) {
        return this.userService.update(req.user.id, updateData);
    }

    @Get('leaderboard')
    @ApiOperation({ summary: 'Get global leaderboard' })
    async getLeaderboard(@Query('limit') limit?: number) {
        return this.userService.getLeaderboard(limit);
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Post('me/coins')
    @ApiOperation({ summary: 'Add coins to current user' })
    @ApiBody({ schema: { type: 'object', properties: { amount: { type: 'number' } } } })
    async addCoins(@Request() req, @Body() body: { amount: number }) {
        return this.userService.addCoins(req.user.id, body.amount);
    }
}
