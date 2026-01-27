# Fluentify 🎓 - Advanced Language Learning

![Status](https://img.shields.io/badge/status-active--development-orange)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![NestJS](https://img.shields.io/badge/Backend-NestJS-E0234E?logo=nestjs)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-blueviolet)

**Fluentify** is a professional-grade language learning platform. It is built using **Clean Architecture** principles and **BLoC State Management** to ensure high scalability, maintainability, and testability.

---

## 🏗 Detailed Project Structure

### 📱 Frontend (Flutter Clean Architecture)
The mobile application is divided into feature-based modules, each following a strict three-layer architectural pattern.

```bash
fluentify_frontend/
├── lib/
│   ├── core/               # Global utilities, services, and common widgets
│   │   ├── constants/      # App-wide constants (URLs, keys)
│   │   ├── di/             # Dependency Injection (Service Locator)
│   │   ├── error/          # Failure and Exception classes
│   │   ├── network/        # Network info & Dio client configuration
│   │   ├── services/       # Global services (Storage, Audio, etc.)
│   │   └── theme/          # App styles and theme data
│   ├── features/           # Independent business modules
│   │   └── auth/           # Example: Authentication Feature
│   │       ├── data/       # Data Implementation
│   │       │   ├── datasources/  # API & Local storage logic
│   │       │   ├── models/       # Data DTOs & JSON serialization
│   │       │   └── repositories/ # Implementation of domain repos
│   │       ├── domain/     # Business Logic Contract
│   │       │   ├── entities/     # Simple data blueprints
│   │       │   ├── repositories/ # Abstract repository contracts
│   │       │   └── usecases/     # Specific business actions
│   │       └── presentation/ # UI & State Management
│   │           ├── bloc/         # BLoC logic for the feature
│   │           ├── pages/        # Full-screen widgets
│   │           └── widgets/      # Small reusable components
│   └── main.dart           # Application entry point
```

### 🛠 Backend (NestJS Modular Architecture)
The server uses a modular architecture where each domain is encapsulated in its own module.

```bash
fluentify_backend/
├── src/
│   ├── modules/            # Domain modules
│   │   ├── auth/           # JWT, Google, and Email Auth logic
│   │   ├── user/           # Profile and user management
│   │   ├── mission/        # Learning mission tasks
│   │   ├── peer/           # Real-time peer matching logic
│   │   ├── chat/           # Messaging services
│   │   └── payment/        # Razorpay & Subscription integration
│   ├── database/           # TypeORM migrations and configuration
│   ├── common/             # Global decorators, filters, and guards
│   ├── shared/             # Shared services (Firebase, AWS, etc.)
│   ├── app.module.ts       # Root module
│   └── main.ts             # Server entry point
└── .env                    # Environment variables (Secrets)
```

---

## 🔐 Authentication & Security

Fluentify provides multiple secure authentication methods:
- **Email/Password**: Traditional authentication with data securely stored in **PostgreSQL**.
- **Google Sign-In**: Seamless OAuth2 integration using Firebase Authentication.
- **JWT Security**: All backend requests are protected by JSON Web Tokens.

---

## 🚀 Core Features

- **Adaptive Learning**: 100+ levels that scale with your progress.
- **Smart Peer Matching**: Instantly connect with users for real-time practice via Agora.
- **AI Feedback**: Detailed pronunciation and grammar analysis using AI models.
- **Responsive UI**: Built with `flutter_screenutil` for a perfect look on all screen sizes.

---

## 📸 Project Showcase

| Sentence Master | Profile Dashboard | Peer Matching |
| :---: | :---: | :---: |
| ![Levels](assets/screenshots/level_selection.jpg) | ![Profile](assets/screenshots/profile_dashboard.jpg) | ![Peer](assets/screenshots/finding_peer.jpg) |

---

## 🏁 Execution Guide

### 1. Backend Setup
```bash
cd fluentify_backend && npm install && npm run start:dev
```

### 2. Mobile App Setup
```bash
cd fluentify_frontend && flutter pub get && flutter run
```
*Note: Ensure your `apiBaseUrl` is updated with a valid tunnel for physical device testing.*

---

## 📄 License
Project is licensed under the MIT License.
