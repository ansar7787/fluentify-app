import { IsOptional, IsString, MaxLength } from 'class-validator';

export class AnalyzeSpeakingDto {
  @IsString()
  @MaxLength(5000)
  transcript: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  prompt?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  learnerLevel?: string;
}
