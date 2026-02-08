import { Module } from '@nestjs/common';
import { SpeakingPartnerController } from './speaking-partner.controller';
import { SpeakingPartnerService } from './speaking-partner.service';
import { AiModule } from '../ai/ai.module';

@Module({
    imports: [AiModule],
    controllers: [SpeakingPartnerController],
    providers: [SpeakingPartnerService],
    exports: [SpeakingPartnerService],
})
export class SpeakingPartnerModule { }
