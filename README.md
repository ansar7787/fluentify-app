# Fluentify 🎓 - Advanced Language Learning

![Status](https://img.shields.io/badge/status-active--development-orange)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![NestJS](https://img.shields.io/badge/Backend-NestJS-E0234E?logo=nestjs)

**Fluentify** is an AI-powered language learning platform designed to make fluency accessible, interactive, and engaging. It features a gamified learning experience with real-time peer matching and AI-driven feedback.

---

## 📸 Project Showcase

### 🧩 Sentence Master Interface
Practice grammar and sentence building with an intuitive drag-and-drop interface.

| Level Selection | Challenge Interface | Dark Mode Challenge |
| :---: | :---: | :---: |
| ![Levels](assets/screenshots/level_selection.jpg) | ![Challenge](assets/screenshots/challenge_input.jpg) | ![Dark Mode](assets/screenshots/challenge_dark.jpg) |

### 👥 Peer Interaction & Social
Connect with fellow learners and track your progress on a comprehensive dashboard.

| Finding a Peer | Profile Dashboard | Settings & Dark Mode |
| :---: | :---: | :---: |
| ![Peer](assets/screenshots/finding_peer.jpg) | ![Profile](assets/screenshots/profile_dashboard.jpg) | ![Settings](assets/screenshots/profile_settings.jpg) |

### 💎 Gamification & Premium
Earn rewards and unlock advanced features with our premium membership.

| Level Complete | Free Membership | Premium Plans |
| :---: | :---: | :---: |
| ![Success](assets/screenshots/level_complete.jpg) | ![Free](assets/screenshots/subscription_free.jpg) | ![Premium](assets/screenshots/subscription_premium.jpg) |

---

## 🚀 Core Features

- **Adaptive Learning**: 100+ levels that scale with your progress.
- **Smart Peer Matching**: Instantly connect with users at your current level for real-time practice.
- **AI Feedback**: Get detailed pronunciation and grammar analysis.
- **Vibrant UI**: Beautifully crafted dark mode and responsive layouts for all devices.
- **Progress Tracking**: Daily streaks, coin rewards, and level-up milestones.

---

## 🛠 Technology Stack

- **Frontend**: Flutter (State Management: BLoC/Provider)
- **Backend API**: NestJS (Node.js)
- **Database**: PostgreSQL with TypeORM
- **Authentication**: Firebase Auth & Google Sign-In
- **Networking**: Dio (Client), Axios (Server)
- **Real-time**: Agora SDK for Peer-to-Peer communication
- **Development Tooling**: Tunnelmole for local testing on physical hardware

---

## 🏁 Execution Guide

### Backend (Local)
```bash
cd fluentify_backend
npm install
npm run start:dev
```

### Tunneling (For Mobile Testing)
```bash
npx tunnelmole 3000
```

### Mobile App
```bash
cd fluentify_frontend
flutter pub get
flutter run
```

---

## 📁 Repository Structure

```bash
fluentify/
├── fluentify_frontend/     # Flutter mobile codebase
├── fluentify_backend/      # NestJS backend codebase
└── assets/screenshots/     # Application visual assets
```

---

## 📄 License
Project is licensed under the MIT License.
