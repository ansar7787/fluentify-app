# Fluentify: AI-Powered English Language Coach

Fluentify is a cutting-edge mobile application designed to bridge the gap between learning and speaking English. By leveraging the power of **Google Gemini 1.5 Flash**, Fluentify provides real-time, context-aware speaking practice and deep pronunciation analytics to help learners achieve fluency faster.

---

## 🌟 Key Features

### 🎙️ AI Speaking Partner
Engage in natural, turn-based conversations with an AI tutor tailored to real-world scenarios:
- **Coffee Shop**: Order your favorite drink.
- **Job Interview**: Practice technical and HR questions.
- **Airport Check-in**: Navigate travel logistics.
- **Doctor's Visit**: Describe symptoms and ask for advice.

### 📊 Pronunciation Analytics
Get instant, word-by-word feedback on your speech:
- **Fluency & Confidence**: Metrics on pacing and flow.
- **Grammar & Vocabulary**: AI-driven corrections and better-way-to-say suggestions.
- **Phonetic Accuracy**: (Coming Soon) Heatmaps highlighting areas for improvement.

### 🎮 Gamified Learning
- **Multiple Game Modes**: Grammar, Scramble, Word Match, Rapid Fire, and more.
- **Progression System**: Earn coins, track streaks, and climb the global leaderboard.
- **Daily Missions**: Personalized challenges based on your CEFR level.

---

## 🛠️ Technology Stack

### Frontend (Flutter)
- **Architecture**: Domain-Driven Design (DDD) / Clean Architecture.
- **State Management**: BLoC / Cubit.
- **Real-time Audio**: Integrated with `record` and `permission_handler`.
- **UI/UX**: Responsive design with `flutter_screenutil` and fluid animations with `flutter_animate`.

### Backend (NestJS)
- **Language**: TypeScript with Node.js.
- **AI Integration**: Multi-modal Gemini API (Audio + Text).
- **Persistence**: TypeORM with PostgreSQL.
- **Auth**: Firebase Google Auth + JWT.
- **Payments**: Razorpay Integration.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Node.js & npm
- PostgreSQL Database
- Gemini API Key

### Setup
1. **Clone the repo**: `git clone <repo-url>`
2. **Backend**:
   - `cd fluentify_backend`
   - `npm install`
   - Configure `.env` (use `.env.example` as a template).
   - `npm run start:dev`
3. **Frontend**:
   - `cd fluentify_frontend`
   - `flutter pub get`
   - `flutter run`

---

## 📄 License
© 2026 Fluentify Team. All rights reserved.
