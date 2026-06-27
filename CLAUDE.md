# Self Service Portal Development Guide

## Project Overview

This is a Flutter web application for Ipsos interviewers to manage their devices and applications. The app supports two user types with different workflows:
- **New Interviewers**: Onboarding with device setup instructions
- **Existing Interviewers**: Self-service app updates and device management

## Key Architectural Decisions

### State Management
- Using **Provider** for authentication state across the app
- `AuthProvider` tracks login status, current user, device ID, and user type
- Simple and sufficient for current scope

### Routing
- Using **go_router** for type-safe navigation
- Routes: `/auth`, `/new-interviewer`, `/existing-interviewer`, `/existing-interviewer-dashboard`, `/device-setup`, `/update-ireach`
- Navigation passes device IDs as route parameters

### API Integration
- `AuthService` handles all backend communication
- Currently has mock implementations that should be replaced with real API calls:
  - `authenticateNewInterviewer()` - Email + phone verification
  - `authenticateExistingInterviewer()` - Username/password login
  - `validateDeviceId()` - Call RMM API to validate device exists
  - `executeIReachUpdate()` - Call RMM API to run update script

## Development Workflow

### Running the App
```bash
flutter run -d chrome
```

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
flutter build web --release
```

## Implementation Notes

### New Interviewer Flow
1. Email + last 4 digits of phone number for verification
2. Device ID entry triggers RMM API validation
3. Based on device type from API, show appropriate setup instructions
4. Instructions are interactive (expandable cards with steps)
5. Device types: Windows Laptop, Android Tablet, iOS Tablet

### Existing Interviewer Flow
1. Username/password authentication
2. Dashboard with action cards
3. Update iReach flow:
   - Enter device ID and validate
   - Confirm app is closed
   - Execute update via RMM API
   - Show success confirmation

### Device Setup Instructions
- Device type determines which instructions are shown
- Windows Laptop: WiFi, Teams, iReach, sync, helpdesk
- Android/iOS: WiFi, Teams app store, iReach app store, helpdesk
- Instructions are in `DeviceSetupScreen` - currently hardcoded, could be fetched from API

## Integration Points

### Backend API Required
1. **Authentication**
   - New interviewer: `/api/auth/new-interviewer` (POST: email, lastFourDigits)
   - Existing interviewer: `/api/auth/login` (POST: username, password)

2. **Device Validation**
   - `/api/devices/validate/{deviceId}` (GET) - Returns device type and info

3. **App Updates**
   - `/api/updates/ireach/execute/{deviceId}` (POST) - Triggers update script

### Optional Enhancements
- Chat widget for real-time support (noted in requirements but not implemented)
- Persistent device list/history
- Update notifications/status tracking
- Feedback form

## Testing Considerations

When adding tests:
- Mock `AuthService` for unit tests
- Mock `GoRouter` context for navigation tests
- Use `ChangeNotifierProvider` wrapper for provider tests
- Test both happy path and error scenarios

## Browser Compatibility

Target: Modern browsers (Chrome, Firefox, Safari, Edge)
- Minimum viewport width: 320px (mobile)
- Optimized for: 768px+ (tablets and desktops)

## Performance Notes

- Screens are stateful only when needed (device validation, form state)
- Loading dialogs for async operations
- Validated field input to reduce backend calls
- No persistence layer implemented (sessions end on page refresh)
