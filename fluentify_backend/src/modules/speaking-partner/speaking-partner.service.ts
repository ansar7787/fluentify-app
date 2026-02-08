import { Injectable, Logger } from '@nestjs/common';
import { AiService } from '../ai/ai.service';

@Injectable()
export class SpeakingPartnerService {
    private readonly logger = new Logger(SpeakingPartnerService.name);

    constructor(private readonly aiService: AiService) { }

    async getScenarios() {
        return [
            {
                id: 'coffee-shop',
                title: 'Ordering Coffee',
                description: 'Practice ordering your favorite drink at a busy cafe.',
                aiRole: 'Barista',
                userRole: 'Customer',
                difficulty: 'Beginner',
                image: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500&q=80',
            },
            {
                id: 'job-interview',
                title: 'Job Interview',
                description: 'Prepare for a software engineer role interview.',
                aiRole: 'Interviewer',
                userRole: 'Candidate',
                difficulty: 'Advanced',
                image: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500&q=80',
            },
            {
                id: 'airport-checkin',
                title: 'Airport Check-in',
                description: 'Handle your luggage and boarding pass at the counter.',
                aiRole: 'Check-in Agent',
                userRole: 'Traveler',
                difficulty: 'Intermediate',
                image: 'https://images.unsplash.com/photo-1436491865332-7a61a109c0f?w=500&q=80',
            },
            {
                id: 'doctor-visit',
                title: 'Visiting the Doctor',
                description: 'Explain your symptoms and ask for professional advice.',
                aiRole: 'Doctor',
                userRole: 'Patient',
                difficulty: 'Intermediate',
                image: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=500&q=80',
            },
        ];
    }

    async processTurn(scenarioId: string, audioBuffer: Buffer, historyJson: string) {
        const scenario = (await this.getScenarios()).find(s => s.id === scenarioId);
        if (!scenario) throw new Error('Scenario not found');

        const history = JSON.parse(historyJson);

        const promptText = `
      You are an AI Speaking Partner in a language learning app "Fluentify".
      Current Scenario: ${scenario.title}
      AI Role: ${scenario.aiRole}
      User Role: ${scenario.userRole}
      Difficulty: ${scenario.difficulty}

      Conversation History:
      ${history.map((h: any) => `${h.role === 'user' ? 'User' : 'AI'}: ${h.content}`).join('\n')}

      Task:
      1. Transcribe the user's audio accurately into "user_transcript".
      2. Respond as the ${scenario.aiRole} naturally and briefly (max 2 sentences).
      3. Provide a "correction" if the user made any grammatical or pronunciation mistakes in their statement (be kind).
      4. Suggest a "better_way" to say it.

      Return ONLY a JSON object with this structure:
      {
        "user_transcript": "What the user said",
        "response": "AI's spoken response",
        "correction": "Feedback on user's statement or null",
        "better_way": "A more natural version of the user's statement or null",
        "score": 0.0 to 10.0 (fluency score for this turn)
      }
    `;

        try {
            return await this.aiService.processAudio(audioBuffer, promptText);
        } catch (error) {
            this.logger.error(`Speaking Partner Turn Error: ${error.message}`);
            return {
                user_transcript: "[Inaudible]",
                response: "I'm sorry, I'm having a bit of trouble connecting to my brain. Can you say that again?",
                correction: null,
                better_way: null,
                score: 5.0
            };
        }
    }
}
