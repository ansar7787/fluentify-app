import { IsString, IsNumber, IsOptional, Max, Min } from 'class-validator';

export class GenerateContentDto {
    @IsString()
    gameType: string;

    @IsString()
    level: string;

    @IsString()
    topic: string;

    @IsNumber()
    @Min(1)
    @Max(20)
    @IsOptional()
    count?: number;
}
