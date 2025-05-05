# AI Chat Bot

A Flutter application that provides an AI-powered chat interface using OpenAI's API. This project supports multiple languages (English and Vietnamese) and offers various AI capabilities through a clean, modern UI.

## Features

- **AI Chat Interface**: Conversational UI for interacting with OpenAI's models
- **Multilingual Support**: Full localization for English and Vietnamese
- **Tool Integration**: Support for various AI tools including:
  - Image generation
  - Weather information
  - Stock price lookup
  - Web page reading
  - Research and analysis
- **Modern UI**: Material Design 3 with responsive layout
- **Cross-Platform**: Works on Android, iOS, web, and desktop platforms

## Tech Stack

- **Flutter**: UI framework (SDK ^3.6.0)
- **dart_openai**: OpenAI API integration
- **flutter_bloc**: State management
- **equatable**: Value equality
- **get_it**: Dependency injection
- **flutter_screenutil**: Responsive UI
- **easy_localization**: Internationalization

## Project Structure

The project follows a clean architecture approach with the following structure:

- **lib/**
  - **constants/**: Application constants and enums
  - **data/**: Data providers and repositories
  - **domain/**: Business logic and repository interfaces
  - **gen/**: Generated localization files
  - **presentation/**: UI components and screens
    - **base/**: Base UI components
    - **chat/**: Chat interface components
  - **utils/**: Utility classes including OpenAI client setup and service locator

## Getting Started

### Prerequisites

- Flutter SDK (^3.6.0)
- Dart SDK
- OpenAI API key

### Installation

1. Clone the repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Configure your OpenAI API key in `lib/utils/open_ai_client.dart`
4. Run the application:
   ```
   flutter run
   ```

### Development Commands

The project includes several useful commands in the Makefile:

- `make analyze`: Run Flutter analyzer
- `make format`: Format Dart code
- `make format-analyze`: Format and analyze code
- `make b`: Run build_runner to generate code
- `make w`: Watch for changes and run build_runner
- `make c`: Clean the project and reinstall dependencies
- `make g`: Generate localization files

## Localization

The application supports English and Vietnamese languages. Localization files are stored in:

- `assets/translations/en-US.json`
- `assets/translations/vi-VN.json`

To add or modify translations, edit these files and run `make g` to regenerate the localization code.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.