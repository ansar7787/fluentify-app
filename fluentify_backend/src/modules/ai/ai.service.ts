import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, GenerativeModel } from '@google/generative-ai';
import { GenerateContentDto } from './dto/generate-content.dto';
import { AnalyzeSpeakingDto } from './dto/analyze-speaking.dto';

@Injectable()
export class AiService {
    private readonly logger = new Logger(AiService.name);
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

    async processAudio(audioBuffer: Buffer, prompt: string): Promise<any> {
        try {
            const audioBase64 = audioBuffer.toString('base64');
            const result = await this.model.generateContent([
                {
                    inlineData: {
                        mimeType: "audio/mp3",
                        data: audioBase64
                    }
                },
                { text: prompt }
            ]);
            const responseText = result.response.text();
            return JSON.parse(responseText);
        } catch (error) {
            this.logger.error(`AI Audio Processing Error: ${error.message}`);
            throw new InternalServerErrorException('Failed to process AI audio request');
        }
    }

    async generateContent(dto: GenerateContentDto): Promise<any> {
        const { gameType, level, topic, count = 5 } = dto;
        const schema = this.getSchemaForType(gameType);

        if (!schema) {
            throw new Error(`Unsupported game type: ${gameType}`);
        }

        const promptText = `
            You are an expert language learning content generator for the app "Fluentify".
            Generate ${count} ${gameType} questions/challenges for ${level} level learners.
            Topic: ${topic}.
            
            Output ONLY a valid JSON array. Do not include markdown code blocks.
            Ensure the output rigorously follows this structure for each item:
            ${JSON.stringify(schema, null, 2)}
            
            Guidelines:
            - Grammar: Use (____) for blanks.
            - Vocabulary: Use engaging, high-frequency words.
            - Scramble: Ensure the words when unscrambled form a natural sentence.
            - Tone: Encouraging and educational.
        `;

        try {
            return await this.callGemini(promptText, true);
        } catch (error) {
            this.logger.error(`AI Generation Error: ${error.message}`);
            throw new InternalServerErrorException('Failed to generate content via AI');
        }
    }

    async analyzeSpeaking(dto: AnalyzeSpeakingDto): Promise<any> {
        const { transcript, prompt = '', learnerLevel = 'Intermediate' } = dto;

        const responseSchema = {
            overallBand: "number (0-10)",
            fluency: "number (0-10)",
            grammar: "number (0-10)",
            vocabulary: "number (0-10)",
            pronunciation: "number (0-10)",
            summary: "string (2-3 encouraging sentences)",
            strengths: "string[] (3 items max)",
            priorities: "string[] (3 items max)",
            corrections: [{ original: "string", corrected: "string", reason: "string" }],
            drills: [{ title: "string", instruction: "string", durationMinutes: "number" }],
            weeklyPlan: [{ day: "string", focus: "string", task: "string" }],
            nextPrompt: "string"
        };

        const promptText = `
            You are an elite English speaking coach.
            Analyze the learner transcript and return ONLY valid JSON.
            
            Learner level: ${learnerLevel}
            Practice prompt: ${prompt}
            Transcript: "${transcript}"
            
            Use this exact response structure:
            ${JSON.stringify(responseSchema, null, 2)}
            
            Evaluation Criteria:
            - Be specific, kind, and constructive.
            - Scores must be realistic based on the transcript.
            - Provide a balanced weekly plan for improvement.
        `;

        try {
            return await this.callGemini(promptText, false);
        } catch (error) {
            this.logger.error(`AI Speaking Analysis Error: ${error.message}`);
            return this.getSpeakingMock(dto);
        }
    }

    async processGenericPrompt(prompt: string): Promise<any> {
        try {
            return await this.callGemini(prompt, false);
        } catch (error) {
            this.logger.error(`AI Generic Prompt Error: ${error.message}`);
            throw new InternalServerErrorException('Failed to process AI request');
        }
    }

    private async callGemini(prompt: string, expectArray: boolean): Promise<any> {
        const result = await this.model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();
        return this.sanitizeAndParseJson(text, expectArray);
    }

    private sanitizeAndParseJson(text: string, expectArray: boolean): any {
        try {
            // Remove markdown code blocks if present
            let cleanText = text.replace(/```json/g, '').replace(/```/g, '').trim();

            // Find first [ or { and last ] or } to handle potential surrounding text
            const startChar = expectArray ? '[' : '{';
            const endChar = expectArray ? ']' : '}';

            const startIndex = cleanText.indexOf(startChar);
            const endIndex = cleanText.lastIndexOf(endChar);

            if (startIndex !== -1 && endIndex !== -1) {
                cleanText = cleanText.substring(startIndex, endIndex + 1);
            }

            return JSON.parse(cleanText);
        } catch (e) {
            this.logger.error(`JSON Parsing Error: ${e.message}. Raw text: ${text}`);
            throw new Error('Failed to parse AI response as JSON');
        }
    }

    private getSpeakingMock(dto: AnalyzeSpeakingDto): any {
        return {
            overallBand: 7.2,
            fluency: 7.0,
            grammar: 7.5,
            vocabulary: 7.0,
            pronunciation: 7.3,
            summary:
                'You communicate clearly and confidently. Your structure is mostly correct, and your next gains will come from tighter phrasing and stronger word variety.',
            strengths: [
                'Good sentence flow and confidence.',
                'Clear ideas with understandable pacing.',
                'Useful everyday vocabulary.'
            ],
            priorities: [
                'Use more connectors like "however", "meanwhile", "as a result".',
                'Reduce repeated words and try synonyms.',
                'Slow down slightly at sentence endings for clarity.'
            ],
            corrections: [
                {
                    original: 'I am agree with this idea.',
                    corrected: 'I agree with this idea.',
                    reason: 'Use "agree" as a verb, not "am agree".'
                },
                {
                    original: 'He go to school every day.',
                    corrected: 'He goes to school every day.',
                    reason: 'Third person singular needs "goes".'
                }
            ],
            drills: [
                {
                    title: 'Connector Sprint',
                    instruction:
                        'Speak for 60 seconds and include 3 connectors: however, therefore, meanwhile.',
                    durationMinutes: 5
                },
                {
                    title: 'Pronunciation Shadowing',
                    instruction:
                        'Read your transcript slowly and repeat each sentence twice with clearer endings.',
                    durationMinutes: 7
                },
                {
                    title: 'Vocabulary Upgrade',
                    instruction:
                        'Replace 5 common words in your transcript with stronger alternatives.',
                    durationMinutes: 6
                }
            ],
            weeklyPlan: [
                { day: 'Day 1', focus: 'Fluency', task: '90-second free talk on your day.' },
                { day: 'Day 2', focus: 'Grammar', task: 'Practice past tense storytelling.' },
                { day: 'Day 3', focus: 'Pronunciation', task: 'Shadow 10 short sentences.' },
                { day: 'Day 4', focus: 'Vocabulary', task: 'Use 10 new words in speech.' },
                { day: 'Day 5', focus: 'Fluency', task: 'Answer one interview-style prompt.' },
                { day: 'Day 6', focus: 'Grammar', task: 'Correct and re-speak yesterday transcript.' },
                { day: 'Day 7', focus: 'Review', task: 'Record and compare with Day 1.' }
            ],
            nextPrompt:
                dto.prompt || 'Describe a challenge you solved recently and what you learned.'
        };
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
