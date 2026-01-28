import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, GenerativeModel } from '@google/generative-ai';
import { GenerateContentDto } from './dto/generate-content.dto';

@Injectable()
export class AiService {
    private genAI: GoogleGenerativeAI;
    private model: GenerativeModel;

    constructor(private configService: ConfigService) {
        const apiKey = this.configService.get<string>('GEMINI_API_KEY');
        if (!apiKey) {
            console.warn('GEMINI_API_KEY is not defined in env variables.');
        }
        this.genAI = new GoogleGenerativeAI(apiKey || 'dummy_key');
        this.model = this.genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    }

    async generateContent(dto: GenerateContentDto): Promise<any> {
        const { gameType, level, topic, count = 5 } = dto;

        const schema = this.getSchemaForType(gameType);
        if (!schema) {
            throw new Error(`Unsupported game type: ${gameType}`);
        }

        const prompt = `
      You are an expert language learning content generator.
      Generate ${count} ${gameType} questions/challenges for ${level} level learners.
      Topic: ${topic}.
      
      Output ONLY a valid JSON array. Do not include markdown code blocks (like \`\`\`json).
      Ensure the output rigorously follows this structure for each item:
      ${JSON.stringify(schema, null, 2)}
      
      For 'grammar', provide a 'question' with a blanket blank (____), 'options', 'correctAnswer', and 'explanation'.
      For 'speaking', provide a 'phrase' to speak and 'phonetic' (optional).
      For 'scramble', provide a 'scrambled' sentence and 'correct' sentence.
    `;

        try {
            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            let text = response.text();

            // Sanitization: Remove potential markdown code blocks
            text = text.replace(/```json/g, '').replace(/```/g, '').trim();

            return JSON.parse(text);
        } catch (error) {
            console.error('AI Generation Error:', error);
            throw new InternalServerErrorException('Failed to generate content via AI');
        }
    }

    private getSchemaForType(type: string): any {
        switch (type) {
            case 'grammar':
                return {
                    question: "string (e.g., 'I ____ to the store yesterday.')",
                    options: "string[] (4 options)",
                    correctAnswer: "string (must be one of the options)",
                    explanation: "string (why it is correct)"
                };
            case 'speaking':
                return {
                    phrase: "string (the sentence to speak)",
                    translation: "string (optional)",
                    phonetic: "string (optional)"
                };
            case 'scramble':
                return {
                    original: "string (the correct sentence)",
                    scramble: "string[] (words in random order) OR string (scrambled text)",
                    hint: "string (optional)"
                };
            case 'word_match':
                return {
                    word: "string",
                    match: "string (synonym/antonym/translation)",
                    pairType: "string (synonym, antonym, etc)"
                };
            case 'rapid_fire':
                return {
                    question: "string",
                    answer: "string (correct answer)", // Simple for rapid fire
                    options: "string[] (optional distractors)"
                };
            case 'reading':
                return {
                    passage: "string (short text)",
                    question: "string",
                    options: "string[]",
                    correctAnswer: "string"
                };
            case 'dictation':
                return {
                    sentence: "string (sentence to listen and type)",
                    hint: "string"
                };
            case 'typing':
                return {
                    text: "string (text to type accurately)"
                };
            default:
                return null;
        }
    }
}
