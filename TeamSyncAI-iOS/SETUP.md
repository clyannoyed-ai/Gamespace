# TeamSync AI iOS Setup Guide

## Complete Setup Instructions

### Step 1: Import Project into Xcode

Since we've created a Swift source structure, you'll need to create an Xcode project:

#### Option A: Create New Project via Xcode
1. Open Xcode
2. File → New → Project
3. Choose "App" template
4. Configure:
   - **Product Name**: TeamSyncAI
   - **Team**: Your Apple Developer Team
   - **Organization Identifier**: com.teamsync.ai
   - **Interface**: SwiftUI
   - **Lifecycle**: SwiftUI App
5. Choose location: `/workspaces/Gamespace/TeamSyncAI-iOS`
6. Replace generated files with our source code

#### Option B: Recommended - Convert to Xcode Workspace
```bash
# Create Xcode project
cd /workspaces/Gamespace/TeamSyncAI-iOS
xcodebuild -createWorkspace TeamSyncAI.xcworkspace

# Or use: 
# In Xcode: File → New → Workspace
```

### Step 2: Configure Info.plist

Add required keys for iOS 15+:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Name and Version -->
    <key>CFBundleName</key>
    <string>TeamSync AI</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    
    <!-- Microphone Access -->
    <key>NSMicrophoneUsageDescription</key>
    <string>We need access to your microphone for voice coaching and team chat features.</string>
    
    <!-- Camera Access (future) -->
    <key>NSCameraUsageDescription</key>
    <string>We need access to your camera to take team photos and record drills.</string>
    
    <!-- Photo Library Access -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need access to your photo library to upload player photos.</string>
    
    <!-- Location Access -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to show event venues on the map.</string>
    
    <!-- Health Kit (future) -->
    <key>NSHealthShareUsageDescription</key>
    <string>TeamSync AI would like to access your workout data.</string>
    
    <!-- Background Modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
        <string>fetch</string>
    </array>
    
    <!-- Minimum iOS Version -->
    <key>MinimumOSVersion</key>
    <string>15.0</string>
    
    <!-- Supported Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- App Requires Network -->
    <key>NSLocalNetworkUsageDescription</key>
    <string>Connect to team devices on your network.</string>
    <key>NSBonjourServices</key>
    <array>
        <string>_teamsync._tcp</string>
    </array>
</dict>
</plist>
```

### Step 3: Set Up App Icons and Assets

Create Assets.xcassets with required images:

```
Assets.xcassets/
├── AppIcon.appiconset/
│   ├── Icon_1024x1024.png
│   ├── Icon_512x512.png
│   ├── Icon_180x180.png (iPhone)
│   ├── Icon_167x167.png (iPad)
│   └── Contents.json
├── LaunchScreen.imageset/
├── TeamLogo.imageset/
└── Colors/
    ├── Brand.colorset/
    └── Accent.colorset/
```

Required icon sizes (in pixels):
- 1024x1024 (App Store)
- 512x512 (App Store small)
- 180x180 (iPhone)
- 167x167 (iPad Pro)
- 152x152 (iPad)
- 120x120 (iPhone Retina)

### Step 4: Configure Backend Connection

Edit `Services/APIService.swift`:

```swift
// Update base URL
private let baseURL: URL

private init() {
    // Development
    if CommandLine.arguments.contains("TESTING") {
        self.baseURL = URL(string: "http://localhost:3000/api/v1")!
    } else {
        // Production
        self.baseURL = URL(string: "https://teamsyncai.abacusai.app/api/v1")!
    }
}
```

### Step 5: Enable Push Notifications

**In Xcode:**
1. Select target → Signing & Capabilities
2. Click "+ Capability"
3. Add "Push Notifications"
4. Add "Background Modes"
   - Select "Remote notifications"
   - Select "Background fetch"

**Register device token:**
```swift
// In AppDelegate or SceneDelegate
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let center = UNUserNotificationCenter.current()
    center.delegate = NotificationService.shared
    
    DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    return true
}
```

### Step 6: Configure Authentication

1. **Set up Supabase auth:**
   ```swift
   // In AuthManager
   let supabaseURL = URL(string: "https://[YOUR-PROJECT].supabase.co")!
   let supabaseKey = "YOUR_ANON_KEY"
   ```

2. **Store tokens securely:**
   ```swift
   // Use Keychain for production
   import Security
   
   // For now, UserDefaults (use Keychain in production)
   UserDefaults.standard.set(token, forKey: "authToken")
   ```

### Step 7: Test on Device vs Simulator

#### Simulator Testing
- ✅ All views and navigation
- ✅ Local notifications
- ✅ API calls (if backend accessible)
- ❌ Push notifications (simulator limitation)
- ❌ Actual microphone (use simulated input)

#### Physical Device Testing
- ✅ Everything including microphone
- ✅ Real push notifications
- ✅ Actual app permissions
- Required: Code signing certificate

### Step 8: Build Configuration

**Debug Configuration:**
```
Build Settings:
- Other Swift Flags: -D DEBUG
- Optimization Level: None [-Onone]
- Deployment: Local development URL
```

**Release Configuration:**
```
Build Settings:
- Optimization Level: Optimize for Speed [-O]
- Deployment: Production API URL
```

### Step 9: Testing Checklist

Before submitting to App Store:

```
✓ Authentication
  [ ] Login works
  [ ] Signup works
  [ ] Logout works
  [ ] Token refresh works
  [ ] Session persistence works

✓ Team Roster
  [ ] Load players
  [ ] Add player
  [ ] Edit player
  [ ] Delete player
  [ ] Search works
  [ ] Photos load

✓ Event Scheduling
  [ ] Create event
  [ ] Edit event
  [ ] Delete event
  [ ] Calendar picker works
  [ ] Attendance tracking

✓ Drills
  [ ] Load drills by age group
  [ ] View drill details
  [ ] Save favorites
  [ ] Load strategies

✓ Messaging
  [ ] Send message
  [ ] Receive message
  [ ] Load announcements
  [ ] Mark as read

✓ Notifications
  [ ] Event reminders trigger
  [ ] Message notifications work
  [ ] Announcement alerts sound
  [ ] Notification badges update
  [ ] Tap navigation works

✓ Settings
  [ ] Edit profile
  [ ] Change notification preferences
  [ ] Logout works
```

### Step 10: Prepare for App Store

**App Store Connect Setup:**
1. Create App ID in Apple Developer
2. Set up bundle identifier: `com.teamsync.ai`
3. Create Test Flight group
4. Generate screenshots (6.5" iPhone)

**Privacy Policy & EULA:**
1. Add Privacy Policy URL
2. Add Terms & Conditions URL
3. Mark sensitive categories:
   - Health & Fitness (voice coaching)
   - User ID (for authentication)
   - Location (for events)

### Step 11: Build and Archive

```bash
# Build for testing
xcodebuild -scheme TeamSyncAI -configuration Debug \
  -destination 'generic/platform=iOS' build

# Build for archive (submission)
xcodebuild -scheme TeamSyncAI -configuration Release \
  -destination 'generic/platform=iOS' archive \
  -archivePath ./TeamSyncAI.xcarchive
```

Or in Xcode:
- Product → Build for → Running
- Product → Archive

### Step 12: Submit to App Store

1. In Xcode → Window → Organizer
2. Select TeamSyncAI archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Follow submission flow

## Environment Configuration

Create `Config.swift` for environment settings:

```swift
struct Config {
    static let apiBaseURL = URL(string: Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? "https://teamsyncai.abacusai.app/api/v1")!
    
    static let isProduction = Bundle.main.infoDictionary?["PRODUCTION"] as? Bool ?? true
    
    static let supabaseURL = URL(string: "https://[PROJECT_ID].supabase.co")!
    static let supabaseKey = "[ANON_KEY]"
}
```

## Troubleshooting Setup

### Build Errors
```
error: Cannot find 'ContentView' in scope
→ Ensure all Views are in the correct module
→ Check Xcode target membership

error: Compiler is unable to type-check this expression in reasonable time
→ Break into smaller computed properties
→ Use @ViewBuilder instead of VStack chains
```

### Runtime Errors
```
Thread 1: Fatal error: No ObservedObject of type AuthManager
→ Add .environmentObject() to root view
→ Check environment is passed through NavigationStack

NSURLConnection finished with error - code -1022
→ App Transport Security - allow localhost in development
→ Add to Info.plist under NSAppTransportSecurity
```

### Notification Issues
```
Permission: User denied
→ App will never ask again
→ User must enable in Settings → TeamSync AI

Notifications don't trigger
→ Check trigger date is in future
→ Check calendar components match
→ Verify app has notification capability
```

## Performance Optimization

### Network
- Implement request caching
- Use URLSession configuration:
  ```swift
  let config = URLSessionConfiguration.default
  config.waitsForConnectivity = true
  config.timeoutIntervalForRequest = 30
  ```

### Memory
- Use `@StateObject` not `@ObservedObject`
- Unsubscribe from notifications
- Cancel URLSession tasks

### Battery
- Use efficient date handling
- Minimize location updates
- Batch notification triggers

## Security Best Practices

```swift
// Use Keychain for sensitive data
// Implement certificate pinning
// Validate all API responses
// Clear sensitive data on logout
// Use HTTPS only
// Implement request signing
```

## Next Steps

1. ✅ Set up Xcode project
2. ✅ Configure Info.plist
3. ✅ Set up capabilities
4. ✅ Configure backend connection
5. ✅ Test on device/simulator
6. ✅ Prepare for App Store
7. 📝 Submit for review

---

**Status**: Ready for Development  
**Last Updated**: December 5, 2025
