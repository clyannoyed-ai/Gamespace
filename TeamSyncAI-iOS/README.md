# TeamSync AI - Native iOS App

A native SwiftUI iOS application for TeamSync AI, built to mirror all functionality of the web platform while providing a native iOS experience with local notifications and offline capabilities.

## Project Structure

```
TeamSyncAI-iOS/
├── TeamSyncAI/
│   ├── Models/
│   │   ├── Team.swift              # Team, Player, Coach, Staff models
│   │   ├── Event.swift             # Event scheduling models
│   │   ├── Drill.swift             # Drill & strategy models
│   │   ├── Communication.swift     # Message & announcement models
│   │   └── User.swift              # User & auth models
│   ├── Views/
│   │   ├── App.swift               # Main app entry point
│   │   ├── LoginView.swift         # Authentication screens
│   │   ├── ContentView.swift       # Main dashboard & tab navigation
│   │   ├── RosterView.swift        # Team roster management
│   │   ├── ScheduleView.swift      # Event scheduling
│   │   ├── DrillsView.swift        # Drills & strategies
│   │   ├── MessagesView.swift      # Team chat & announcements
│   │   └── SettingsView.swift      # App settings
│   ├── Services/
│   │   ├── NotificationService.swift   # iOS push/local notifications
│   │   ├── APIService.swift            # Supabase/backend API client
│   │   └── VoiceService.swift          # AVFoundation for voice chat
│   ├── Utilities/
│   │   ├── Constants.swift             # App-wide constants
│   │   ├── Extensions.swift            # Swift extensions
│   │   └── Helpers.swift               # Utility functions
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── Localizable.strings
│       └── AppDelegate.swift
├── project.json                    # Project configuration
├── README.md                       # This file
└── SETUP.md                        # Setup instructions
```

## Features

### ✅ Core Functionality (iOS-Native Implementation)
- **Team Roster Management**: Full CRUD for players, coaches, and staff
- **Event Scheduling**: Create, update, and track practices, games, and meetings
- **Practice Drills**: Browse AI-generated drills by age group with detailed instructions
- **Team Communication**: Real-time messaging and announcements with priority levels
- **Voice Interface**: AVFoundation-based voice recording/playback for AI coach

### 📱 iOS-Specific Features
- **Local Notifications**: 
  - Event reminders (customizable timing: 15m, 30m, 1h, 2h before)
  - Message alerts
  - Announcement notifications with priority-based sound
  - Attendance request notifications
- **Offline Support**: Core data caching for roster and drills
- **Background App Refresh**: Stay updated with notifications
- **Biometric Auth**: Face ID / Touch ID support (ready to implement)
- **Share Extensions**: Share drills and events via native share sheet

## Technology Stack

### Frontend
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive data binding
- **AVFoundation**: Audio recording and playback
- **UserNotifications**: Local and remote notifications
- **MapKit**: Event location mapping

### Backend Integration
- **Supabase**: PostgreSQL database and authentication
- **REST API**: URLSession-based networking
- **Real-time Updates**: WebSocket support ready

### iOS Deployment
- **Minimum iOS Version**: 15.0
- **Swift Version**: 5.9
- **Architecture**: MVVM with environment objects
- **State Management**: @StateObject, @State, @EnvironmentObject

## Getting Started

### Prerequisites
- Mac with Xcode 15+
- iOS 15.0+ device or simulator
- Apple Developer Account (for App Store deployment)

### Installation

1. **Clone the repository**
   ```bash
   cd /workspaces/Gamespace/TeamSyncAI-iOS
   ```

2. **Open in Xcode**
   ```bash
   open TeamSyncAI.xcodeproj
   ```
   (Note: Create Xcode project from this structure)

3. **Configure Backend URL**
   - Edit `APIService.swift`
   - Update `baseURL` with your backend URL
   ```swift
   self.baseURL = URL(string: "https://your-backend-url.com/api/v1")!
   ```

4. **Request Notification Permissions**
   - App requests permissions on first launch
   - User must grant access for notifications to work

5. **Build and Run**
   ```bash
   ⌘ + B  (Build)
   ⌘ + R  (Run)
   ```

## API Integration

### Connecting to Your Supabase Backend

Update `APIService.swift` with your credentials:

```swift
// In APIService.init()
self.baseURL = URL(string: "https://[YOUR-PROJECT].supabase.co/rest/v1")!

// Authentication
let token = UserDefaults.standard.string(forKey: "authToken")
APIService.shared.setAuthToken(token)
```

### Expected API Endpoints

```
GET    /teams
GET    /teams/{id}/players
POST   /teams/{id}/players
PUT    /teams/{id}/players/{playerId}
DELETE /teams/{id}/players/{playerId}

GET    /teams/{id}/events
POST   /teams/{id}/events
PUT    /teams/{id}/events/{eventId}
DELETE /teams/{id}/events/{eventId}

GET    /teams/{id}/messages
POST   /teams/{id}/messages

GET    /teams/{id}/announcements
PUT    /teams/{id}/announcements/{id}/read

GET    /drills?ageGroup={ageGroup}
GET    /strategies?ageGroup={ageGroup}

POST   /chat  (AI chat with context)
```

## Notification System

### Local Notifications Implementation

The app uses `UserNotifications` framework for native iOS notifications:

```swift
// Request permission
await NotificationService.shared.requestAuthorizationIfNeeded()

// Schedule event reminder
NotificationService.shared.scheduleEventReminder(event: event, minutesBefore: 60)

// Send message notification
NotificationService.shared.notifyNewMessage(message: message, senderName: senderName)

// Send announcement
NotificationService.shared.notifyNewAnnouncement(announcement: announcement)
```

### Notification Handling

All notifications are handled through `UNUserNotificationCenterDelegate`:

- **Event Reminder**: Taps navigate to event details
- **Message**: Navigates to team chat
- **Announcement**: Shows announcement details with read status
- **Attendance Request**: Prompts for RSVP

## Voice Chat Implementation

The `VoiceService` provides voice recording/playback:

```swift
// Request microphone permission
let granted = await VoiceService.shared.requestMicrophonePermission()

// Start recording
try VoiceService.shared.startRecording()

// Stop and get audio URL
if let audioURL = VoiceService.shared.stopRecording() {
    // Send to AI API for processing
}

// Playback AI response
try VoiceService.shared.playAudio(from: responseAudioURL)
```

## Development Workflow

### State Management Pattern
```swift
// EnvironmentObject for app-wide state
@EnvironmentObject var authManager: AuthManager

// StateObject for view-specific state
@StateObject private var viewModel = ViewModel()

// Published properties trigger UI updates
@Published var items: [Item] = []
```

### Adding New Features

1. **Create Model** in `Models/`
   - Conform to `Codable` and `Identifiable`
   - Use CodingKeys for API mapping

2. **Add API Methods** in `APIService.swift`
   - Generic `request()` method handles JSON encoding/decoding
   - Async/await for clean async code

3. **Create Views** in `Views/`
   - Use `@StateObject` for view models
   - List with `.listStyle(.plain)` for custom styling

4. **Add Notifications** in `NotificationService.swift`
   - Schedule local notifications for key events
   - Handle taps with navigation

### Testing Notifications
```swift
// Simulate notification (in debug)
let notification = UNNotification(...)
NotificationService.shared.userNotificationCenter(
    center,
    didReceive: response
)
```

## Building for App Store

### Signing & Capabilities
1. Open project in Xcode
2. Select target → Signing & Capabilities
3. Add capabilities:
   - Push Notifications
   - Background Modes (Remote Notifications)
   - Face ID (if implementing)

### Building Archive
```bash
⌘ + Shift + B  (Build for Archive)
```

### TestFlight Distribution
1. Upload archive to App Store Connect
2. Submit for review
3. Distribute via TestFlight

## Troubleshooting

### Notifications Not Working
- Check `requestAuthorizationIfNeeded()` is called on app launch
- Verify Settings → Notifications have access enabled
- Ensure notification identifiers are unique

### Microphone Permission Issues
- First-time permission prompt must be triggered by user gesture
- Check `Info.plist` has `NSMicrophoneUsageDescription`

### API Connection Errors
- Verify backend URL is correct in `APIService.swift`
- Check CORS headers if connecting to web backend
- Ensure auth token is valid and not expired

## Next Steps

### Phase 2 Features
- [ ] Offline mode with Core Data persistence
- [ ] Push notifications via APNs
- [ ] Biometric authentication (Face ID/Touch ID)
- [ ] Photo/video upload from camera
- [ ] Workouts integration (HealthKit)
- [ ] Siri shortcuts

### Phase 3 Features
- [ ] Home screen widgets
- [ ] Live activity for game broadcasts
- [ ] Deep linking
- [ ] Share extensions
- [ ] Watch app companion

## Support

For issues or feature requests:
1. Check existing GitHub issues
2. Review API documentation
3. Check notification permissions on device
4. Test in simulator vs. physical device

## License

This project is part of TeamSync AI. All rights reserved.

## Contributors

- TeamSync AI Development Team
- iOS Development Lead: [Your Name]

---

**Version**: 1.0.0  
**Last Updated**: December 5, 2025  
**Status**: Ready for Development
