import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { AiService } from './ai.service';
import { GenerateContentDto } from './dto/generate-content.dto';
// import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
// import { RolesGuard } from '../auth/guards/roles.guard';
// import { Roles } from '../auth/decorators/roles.decorator';

@Controller('ai')
export class AiController {
    constructor(private readonly aiService: AiService) { }

    @Post('generate')
    // @UseGuards(JwtAuthGuard, RolesGuard)
    // @Roles('admin') // Uncomment to enforce admin only
    async generateContent(@Body() dto: GenerateContentDto) {
        return this.aiService.generateContent(dto);
    }
}
