# AI Chat Bot

A Flutter application providing an AI-powered chat interface with AI assistance capabilities, file upload, and multi-language support (English, Vietnamese). Built with clean architecture, modern UI, and cross-platform support.

---

## Features

- **Conversational AI Chat**: Real-time chat interface with streaming responses.
- **File Upload & Processing**: Upload files (PDF, DOCX) for AI analysis and context-aware chat.
- **Multilingual Support**: Full localization for English and Vietnamese.
- **Modern UI**: Material Design 3, responsive layouts for mobile and desktop.
- **State Management**: Uses `flutter_bloc` for robust state handling.
- **Local Chat History**: Persists chat sessions and file context using Hive.
- **Extensible Tooling**: Designed for easy integration of additional AI tools (weather, stocks, web reading, etc.).
- **Cross-Platform**: Runs on Android, iOS, web, and desktop.

---

## Tech Stack

- **Flutter**: UI framework (SDK ^3.6.0)
- **Dart**
- **flutter_bloc**: State management
- **equatable**: Value equality
- **get_it**: Dependency injection
- **hive/hive_flutter**: Local storage
- **dio**: HTTP client
- **retrofit**: Type-safe API client
- **easy_localization**: Internationalization
- **flutter_screenutil**: Responsive UI
- **file_picker**: File selection
- **pretty_dio_logger**: API logging

---

## Project Structure

```
lib/
├── constants/         # Enums, app-wide constants
├── data/              # Data sources, models, repositories (API, local, file)
│   ├── data_sources/  # Retrofit API interfaces
│   ├── models/        # Data models (requests, responses, local)
│   └── repositories/  # Repository implementations
├── domain/            # Business logic, repository interfaces, entities
├── gen/               # Generated localization keys/loaders
├── presentation/      # UI: screens, widgets, cubits
│   ├── base/          # Base UI components (scaffold, drawer, etc.)
│   ├── chat/          # Chat UI, widgets, cubit/state
│   └── common/        # Common widgets (error, loading, file list)
├── utils/             # Utilities (Dio client, Hive helper, service locator)
└── main.dart          # App entry point
```

---

## Getting Started

### Prerequisites

- Flutter SDK (^3.6.0)
- Dart SDK
- Backend API (compatible with OpenAI-style endpoints)
- (Optional) OpenAI API key if using OpenAI directly

### Installation

1. **Clone the repository**
2. **Install dependencies**
   ```sh
   flutter pub get
   ```
3. **Configure API endpoint**
   - Edit `lib/utils/dio.dart` to set your backend base URL.
4. **Run the application**
   ```sh
   flutter run
   ```

### File Upload & AI Integration

- The app supports file uploads (PDF, DOCX) for context-aware chat.
- Backend must implement `/upload-and-process-file` and `/chat/stream` endpoints (see `lib/data/data_sources/`).

### Localization

- English and Vietnamese supported.
- Translation files: `assets/translations/en-US.json`, `assets/translations/vi-VN.json`
- To update translations, edit these files and run:
  ```sh
  make g
  ```

---

## Development Commands

- `make analyze` — Run Flutter analyzer
- `make format` — Format Dart code
- `make format-analyze` — Format and analyze code
- `make b` — Run build_runner to generate code
- `make w` — Watch for changes and run build_runner
- `make c` — Clean the project and reinstall dependencies
- `make g` — Generate localization files

---

## Extending Functionality

- **Add new AI tools**: Implement new data sources and repositories in `lib/data/`, update domain interfaces, and connect to UI via Cubit.
- **UI Components**: Add widgets in `lib/presentation/`.
- **State Management**: Use `flutter_bloc` for new features.

---

## Contributing

Contributions are welcome! Please submit a Pull Request.

---

## License

MIT License
