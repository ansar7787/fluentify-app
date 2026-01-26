# SpeakPay Folder Structure

## 📱 Flutter (lib/) - Clean Architecture
- **config/**: Remote config, routes, and theme.
- **core/**: App-wide constants, dependency injection, global errors, network interceptors, and reusable utils.
- **data/**:
    - **datasources/**: Remote (API) and Local (Cache) data providers.
    - **models/**: Data Transfer Objects (DTOs) for JSON parsing.
    - **repositories/**: Implementations of repository interfaces.
- **domain/**:
    - **entities/**: Plain Dart classes for business logic.
    - **repositories/**: Abstract interfaces for repositories.
    - **usecases/**: Single responsibility business logic classes.
- **presentation/**:
    - **bloc/**: State management logic.
    - **pages/**: Full screen UIs.
    - **widgets/**: Reusable UI components.
- **services/**: Infrastructure-level services (Firebase, Razorpay).

## 🚀 Backend (src/) - Modular NestJS
- **common/**: Global guards, filters, interceptors, and decoractors.
- **config/**: Configuration mapping for `.env`.
- **database/**: TypeORM migrations and seeders.
- **modules/**: Feature-based modules (Auth, User, Mission, Payment).
- **shared/**: Shared logic and utility services across modules.
