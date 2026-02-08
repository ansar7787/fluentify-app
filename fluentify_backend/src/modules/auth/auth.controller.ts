import { Controller, Post, Body, UseGuards, Get, Request, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    @Post('login')
    @ApiOperation({ summary: 'Login with email and password' })
    async login(@Body() loginDto: any) {
        const user = await this.authService.validateUser(loginDto.email, loginDto.password);
        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }
        return this.authService.login(user);
    }

    @Post('register')
    @ApiOperation({ summary: 'Register a new user' })
    async register(@Body() registerDto: any) {
        return this.authService.register(registerDto);
    }

    @Post('firebase')
    @ApiOperation({ summary: 'Login with Firebase (Google) token' })
    async firebaseLogin(@Body('token') token: string) {
        return this.authService.firebaseLogin(token);
    }

    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @Get('profile')
    @ApiOperation({ summary: 'Get current user profile' })
    getProfile(@Request() req) {
        return req.user;
    }
}
