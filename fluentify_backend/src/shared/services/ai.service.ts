import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI, { toFile } from 'openai';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

@Injectable()
export class AIService {
    private openai: OpenAI;

    constructor(private configService: ConfigService) {
        this.openai = new OpenAI({
            apiKey: this.configService.get<string>('OPENAI_API_KEY'),
        });
    }

    async analyzeSpeech(audioBuffer: Buffer, missionContext: string = ''): Promise<{
        transcript: string;
        fluencyScore: number;
        vocabularyScore: number;
        grammarScore: number;
        pronunciationScore: number;
        feedback: string;
    }> {
        const apiKey = this.configService.get<string>('OPENAI_API_KEY');

        // If no API key, fallback to mock but log warning
        if (!apiKey || apiKey === 'YOUR_OPENAI_KEY') {
            console.warn('AIService: No OPENAI_API_KEY found. Using mock analysis.');
            return this.getMockAnalysis();
        }

        try {
            // 1. Transcription using Whisper
            const tempDir = os.tmpdir();
            const tempFilePath = path.join(tempDir, `upload-${Date.now()}.m4a`);
            fs.writeFileSync(tempFilePath, audioBuffer);

            const transcription = await this.openai.audio.transcriptions.create({
                file: fs.createReadStream(tempFilePath),
                model: 'whisper-1',
            });

            // Cleanup temp file
            fs.unlinkSync(tempFilePath);

            const transcript = transcription.text;

            // 2. Linguistic Analysis using GPT-4o
            const response = await this.openai.chat.completions.create({
                model: 'gpt-4o',
                messages: [
                    {
                        role: 'system',
                        content: `You are an expert English Language Coach. 
Analyze the student's speech based on the provided transcription and mission context.
Return a JSON object with the following fields:
- fluencyScore (0.0 to 10.0)
- vocabularyScore (0.0 to 10.0)
- grammarScore (0.0 to 10.0)
- pronunciationScore (0.0 to 10.0)
- feedback (String, encouraging and specific, use markdown for highlighting)

Mission Context: ${missionContext}`
                    },
                    {
                        role: 'user',
                        content: `Transcription: "${transcript}"`
                    }
                ],
                response_format: { type: 'json_object' }
            });

            const content = response.choices[0].message.content;
            if (!content) {
                throw new InternalServerErrorException('AI analysis returned empty content');
            }
            const analysis = JSON.parse(content);

            return {
                transcript,
                fluencyScore: analysis.fluencyScore,
                vocabularyScore: analysis.vocabularyScore,
                grammarScore: analysis.grammarScore,
                pronunciationScore: analysis.pronunciationScore,
                feedback: analysis.feedback,
            };

        } catch (error) {
            console.error('AIService Error:', error);
            throw new InternalServerErrorException('Failed to analyze speech with AI');
        }
    }

    private getMockAnalysis() {
        return {
            transcript: "Hello, my name is Rahul and I am a software engineer interested in AI.",
            fluencyScore: 8.5,
            vocabularyScore: 7.2,
            grammarScore: 8.0,
            pronunciationScore: 7.8,
            feedback: "Great job! (Mock Mode) Your pronunciation is clear. Try to use more complex transitions like 'furthermore' to sound more natural.",
        };
    }
}
