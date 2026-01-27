import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, GenerativeModel } from '@google/generative-ai';

@Injectable()
export class AIService {
    private genAI: GoogleGenerativeAI;
    private model: GenerativeModel;

    constructor(private configService: ConfigService) {
        const apiKey = this.configService.get<string>('GEMINI_API_KEY');
        if (!apiKey) {
            console.warn('AIService: No GEMINI_API_KEY found. AI features will fail.');
        }
        this.genAI = new GoogleGenerativeAI(apiKey || 'dummy-key');
        this.model = this.genAI.getGenerativeModel({
            model: "gemini-1.5-flash",
            generationConfig: { responseMimeType: "application/json" }
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
        try {
            // Convert buffer to base64 for Gemini
            const audioBase64 = audioBuffer.toString('base64');

            const prompt = `
            You are an expert English Language Coach.
            Analyze the student's speech based on the provided audio and mission context.
            
            Mission Context: ${missionContext}

            Return a strict JSON object with the following fields:
            - transcript (The detailed transcription of what the student said)
            - fluencyScore (Number 0.0 to 10.0)
            - vocabularyScore (Number 0.0 to 10.0)
            - grammarScore (Number 0.0 to 10.0)
            - pronunciationScore (Number 0.0 to 10.0)
            - feedback (String, encouraging and specific, use markdown for highlighting)
            `;

            const result = await this.model.generateContent([
                {
                    inlineData: {
                        mimeType: "audio/mp3", // Assuming m4a/mp3 generic handling, Gemini is flexible
                        data: audioBase64
                    }
                },
                { text: prompt }
            ]);

            const responseText = result.response.text();
            console.log("Gemini Response:", responseText);

            const analysis = JSON.parse(responseText);

            return {
                transcript: analysis.transcript || "Transcript not available",
                fluencyScore: analysis.fluencyScore || 0,
                vocabularyScore: analysis.vocabularyScore || 0,
                grammarScore: analysis.grammarScore || 0,
                pronunciationScore: analysis.pronunciationScore || 0,
                feedback: analysis.feedback || "Good effort!",
            };

        } catch (error) {
            console.error('AIService (Gemini) Error:', error);
            console.warn('Falling back to mock analysis due to error.');
            return this.getMockAnalysis();
        }
    }

    private getMockAnalysis() {
        return {
            transcript: "Hello, I am practicing my English speaking skills.",
            fluencyScore: 8.0,
            vocabularyScore: 7.5,
            grammarScore: 8.5,
            pronunciationScore: 7.0,
            feedback: "Great effort! (Mock Mode) Your clarity is good. Try to vary your intonation more.",
        };
    }
}
