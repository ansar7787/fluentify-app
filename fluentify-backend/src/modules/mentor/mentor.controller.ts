import {
    Controller,
    Post,
    Get,
    Put,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
    Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MentorService } from './mentor.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('Mentor')
@Controller('mentor')
export class MentorController {
    constructor(private readonly mentorService: MentorService) { }

    @Post('profile')
    @UseGuards(JwtAuthGuard)
    @HttpCode(201)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Create mentor profile' })
    async createMentorProfile(
        @Request() req,
        @Body() body: any,
    ) {
        const mentor = await this.mentorService.createMentorProfile(req.user.id, body);
        return {
            success: true,
            message: 'Mentor profile created',
            data: mentor,
        };
    }

    @Get('all')
    @HttpCode(200)
    @ApiOperation({ summary: 'Get all mentors' })
    async getAllMentors(@Query() filters: any) {
        const mentors = await this.mentorService.getAllMentors(filters);
        return {
            success: true,
            data: mentors,
        };
    }

    @Get(':id')
    @HttpCode(200)
    @ApiOperation({ summary: 'Get mentor by ID' })
    async getMentorById(@Param('id') mentorId: string) {
        const mentor = await this.mentorService.getMentorById(mentorId);
        return {
            success: true,
            data: mentor,
        };
    }

    @Post('booking')
    @UseGuards(JwtAuthGuard)
    @HttpCode(201)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Create booking' })
    async createBooking(
        @Request() req,
        @Body() body: { mentorId: string; scheduledAt: string; durationMinutes: number },
    ) {
        const booking = await this.mentorService.createBooking(req.user.id, body.mentorId, {
            scheduledAt: new Date(body.scheduledAt),
            durationMinutes: body.durationMinutes,
        });
        return {
            success: true,
            message: 'Booking created',
            data: booking,
        };
    }

    @Get('bookings/user')
    @UseGuards(JwtAuthGuard)
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get user bookings' })
    async getUserBookings(@Request() req) {
        const bookings = await this.mentorService.getUserBookings(req.user.id);
        return {
            success: true,
            data: bookings,
        };
    }

    @Put('availability')
    @UseGuards(JwtAuthGuard)
    @HttpCode(200)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Set mentor availability' })
    async setAvailability(
        @Request() req,
        @Body() body: { slots: string[] },
    ) {
        const mentor = await this.mentorService.setAvailability(req.user.id, body.slots);
        return {
            success: true,
            message: 'Availability updated',
            data: mentor,
        };
    }
}
