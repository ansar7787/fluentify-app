import {
    Controller,
    Get,
    Post,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';

@ApiTags('Admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin') // Require admin role for all routes in this controller
export class AdminController {
    constructor(private readonly adminService: AdminService) { }

    @Get('stats')
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get dashboard stats' })
    async getStats() {
        const stats = await this.adminService.getDashboardStats();
        return { success: true, data: stats };
    }

    @Get('users')
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get all users' })
    async getAllUsers(@Query('page') page: number = 1, @Query('limit') limit: number = 10) {
        const users = await this.adminService.getAllUsers(page, limit);
        return { success: true, ...users };
    }

    @Get('mentors/pending')
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get pending mentor applications' })
    async getPendingMentors() {
        const mentors = await this.adminService.getPendingMentors();
        return { success: true, data: mentors };
    }

    @Post('mentors/:id/verify')
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Verify or reject mentor' })
    async verifyMentor(
        @Param('id') mentorId: string,
        @Body() body: { verify: boolean },
    ) {
        await this.adminService.verifyMentor(mentorId, body.verify);
        return { success: true, message: body.verify ? 'Mentor verified' : 'Mentor verification revoked' };
    }
}
