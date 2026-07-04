# Self Service Portal - Flutter Web App

A Flutter web application for Ipsos interviewers to self-manage their devices and applications.

## Features

- **New Interviewer Onboarding**: Email and mobile number verification, device setup, and interactive instructions for:
  - WiFi connection
  - Microsoft Teams setup
  - Ipsos app installation (iReach, etc.)
  - Android showcard synchronization
  - Helpdesk contact information

- **Existing Interviewer Dashboard**: 
  - Self-service iReach app updates
  - Device management
  - Support access

## Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher

## Getting Started

### 1. Install Flutter dependencies

```bash
flutter pub get
```

### 2. Run the web app in development mode

```bash
flutter run -d chrome
```

The app will open in your default Chrome browser at `http://localhost:port`

### 3. Build for production

```bash
flutter build web --release
```

The production build will be available in the `build/web` directory.

## Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── models/
│   └── device_type.dart     # Device type enum and utilities
├── screens/
│   ├── auth_screen.dart                      # Initial auth selection
│   ├── new_interviewer_screen.dart           # New interviewer login
│   ├── existing_interviewer_screen.dart      # Existing interviewer login
│   ├── existing_interviewer_dashboard.dart   # Existing interviewer dashboard
│   ├── device_setup_screen.dart              # Device setup and instructions
│   └── update_ireach_screen.dart             # iReach update workflow
├── services/
│   └── auth_service.dart    # API communication and authentication
├── providers/
│   └── auth_provider.dart   # Authentication state management
└── widgets/
    ├── auth_button.dart         # Reusable button for auth options
    ├── loading_dialog.dart      # Loading indicator dialog
    └── setup_instruction.dart   # Expandable instruction widget
```

## Configuration

### API Endpoints

Update the `baseUrl` in `lib/services/auth_service.dart` with your backend API:

```dart
static const String baseUrl = 'https://your-api.example.com';
```

### Device Validation

Replace the mock device validation in `validateDeviceId()` with calls to your RMM (Remote Management Manager) API.

### iReach Update Script

Replace the mock update execution in `executeIReachUpdate()` with calls to your RMM API to trigger the update script.

## Dependencies

- **flutter**: Flutter framework
- **provider**: State management
- **go_router**: Navigation and routing
- **http**: HTTP client for API calls
- **google_fonts**: Google fonts integration

## Authentication Flow

### New Interviewer
1. Select "New Interviewer" on auth screen
2. Enter email and last 4 digits of phone number
3. Enter device ID
4. Receive device-specific setup instructions
5. Follow interactive steps to complete setup

### Existing Interviewer
1. Select "Existing Interviewer" on auth screen
2. Enter username and password
3. Access dashboard with options including:
   - Update iReach application
   - View device information
   - Contact support

## Update Workflow (Existing Interviewer)

1. Go to dashboard and select "Update iReach"
2. Enter device ID
3. Confirm device is valid
4. Close iReach application
5. Confirm closure and start update
6. Update runs automatically via RMM API
7. Device restarts and iReach reopens with new version

## Contributing

When adding new features:

1. Keep screens focused on their primary task
2. Use the provider pattern for state management
3. Add helpful error messages and loading states
4. Test on both desktop and mobile viewports
5. Follow Flutter style guide conventions

## Support

For issues or questions:
- Email: helpdesk@ipsos.com
- Phone: 0800 478 783
- Hours: 7 days, 9AM-8PM (Local Time)

## License

Internal use only - Ipsos Limited
# interviewer-self-service-portal-
