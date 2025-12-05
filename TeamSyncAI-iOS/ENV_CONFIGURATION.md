# TeamSync AI - Environment Configuration

This file explains how to configure your development environment.

## 🔐 Environment Variables (.env file)

Create a `.env` file in your project root (DO NOT commit to git):

```
# Backend Configuration
API_BASE_URL=https://teamsyncai.abacusai.app/api/v1
API_TIMEOUT=30

# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...your_key_here

# Apple Configuration
APPLE_TEAM_ID=XXXXXXXXXX
APPLE_BUNDLE_ID=com.teamsyncai.app

# App-Specific Password (for CI/CD)
APPLE_ID_EMAIL=your-email@example.com
APPLE_ID_PASSWORD=xxxx-xxxx-xxxx-xxxx

# Feature Flags
ENABLE_OFFLINE_MODE=false
ENABLE_DEBUG_LOGGING=true
```

## 📝 .gitignore Entry

Add to your `.gitignore`:

```
# Environment files
.env
.env.local
.env.*.local
*.xcconfig

# Xcode
xcuserdata/
*.xcworkspace/xcuserdata/
DerivedData/

# Build files
Build/
build/
```

## 🛠️ Development Environment Setup

### 1. Xcode Configuration

**File**: `TeamSyncAI.xcodeproj/project.pbxproj`

After creating your Xcode project:

1. Select project → Build Settings
2. Add User-Defined Settings:

```
API_BASE_URL = https://dev-backend.teamsyncai.app/api/v1
SUPABASE_URL = https://[YOUR_PROJECT_ID].supabase.co
SUPABASE_ANON_KEY = [YOUR_ANON_KEY]
```

### 2. Build Configuration Files

Create `Debug.xcconfig` and `Release.xcconfig`:

**Debug.xcconfig:**
```
API_BASE_URL = http://localhost:3000/api/v1
ENABLE_LOGGING = 1
ENABLE_OFFLINE = 0
```

**Release.xcconfig:**
```
API_BASE_URL = https://teamsyncai.abacusai.app/api/v1
ENABLE_LOGGING = 0
ENABLE_OFFLINE = 1
```

### 3. Use in Code

In `Config.swift`:
```swift
static let apiBaseURL = URL(string: Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "https://teamsyncai.abacusai.app/api/v1")!
```

## 🔑 Getting Your Credentials

### Supabase Credentials

1. Go to: https://app.supabase.com/
2. Select your project
3. Settings → API
4. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **Anon Key** → `SUPABASE_ANON_KEY`

### Apple Team ID

1. Go to: https://developer.apple.com/account
2. Look for "Team ID" in top right
3. It's a 10-character code (e.g., `ABCDE12345`)

### Backend API URL

Development:
```
http://localhost:3000/api/v1
```

Production:
```
https://teamsyncai.abacusai.app/api/v1
```

## 🧪 Testing Different Environments

### Switch to Development

```swift
// In Config.swift
static let apiBaseURL = URL(string: "http://localhost:3000/api/v1")!
```

### Switch to Production

```swift
// In Config.swift
static let apiBaseURL = URL(string: "https://teamsyncai.abacusai.app/api/v1")!
```

### Scheme-Based Configuration

In Xcode:
1. Product → Scheme → Manage Schemes
2. Create new scheme for each environment
3. Set environment variables per scheme

## 📊 Configuration Priority

The app reads configuration in this order:

1. **Build Settings** (highest priority)
2. **xcconfig files**
3. **Config.swift hardcoded values**
4. **Defaults** (lowest priority)

## 🔐 Secure Credential Management

### For CI/CD (GitHub Actions)

Store secrets in GitHub:
1. Go to repo Settings → Secrets
2. Add secrets:
   - `APPLE_ID_EMAIL`
   - `APPLE_ID_PASSWORD`
   - `APPLE_TEAM_ID`
   - `SUPABASE_ANON_KEY`

### For Local Development

Create `.env.local`:
```
APPLE_ID=your-email@example.com
APPLE_PASSWORD=app-specific-password
TEAM_ID=XXXXXXXXXX
```

Load in your shell profile (`~/.zshrc` or `~/.bash_profile`):
```bash
if [ -f ~/.env.local ]; then
    export $(cat ~/.env.local | xargs)
fi
```

## 🚀 Launch Configuration

### Available Schemes

Create multiple schemes for different setups:

**Development**
- API: localhost:3000
- Logging: Enabled
- Offline: Disabled

**Staging**
- API: dev.teamsyncai.app
- Logging: Enabled
- Offline: Disabled

**Production**
- API: teamsyncai.abacusai.app
- Logging: Disabled
- Offline: Enabled

### Select Scheme in Xcode

```
Product → Scheme → [Select Scheme]
```

## ✅ Verify Configuration

Add this to `ContentView.swift` for debugging:

```swift
VStack {
    Text("API: \(Config.apiBaseURL.absoluteString)")
    Text("Debug: \(Config.isDebug ? "YES" : "NO")")
    Text("Version: \(Config.appVersion)")
}
.font(.caption)
.foregroundColor(.gray)
.padding()
```

## 🐛 Debug Configuration

To enable detailed logging:

```swift
// In Config.swift
static let enableNetworkLogging = true  // Enable to see all API calls

// Usage
if Config.enableNetworkLogging {
    print("Request: \(request.url?.absoluteString ?? "")")
    print("Response: \(String(data: data, encoding: .utf8) ?? "")")
}
```

## 📋 Checklist

Before development:

- [ ] Supabase credentials obtained
- [ ] Apple Team ID found
- [ ] Config.swift updated
- [ ] .env file created (not committed)
- [ ] Build runs successfully
- [ ] API calls hit correct endpoint
- [ ] Tokens stored securely
- [ ] No hardcoded secrets in code

## 🆘 Common Issues

### "Invalid Supabase URL"
- Check for trailing slashes
- Verify project ID is correct
- Test in browser first

### "401 Unauthorized on API calls"
- Verify auth token is saved
- Check KeychainManager is working
- Test with mock token

### "API calls going to wrong endpoint"
- Check Config.swift baseURL
- Verify xcconfig file
- Check Build Settings

### "Credentials not loading from .env"
- Verify .env file is in right location
- Check file name (exactly `.env`)
- Restart Xcode after creating file

---

**Ready to configure?** Start with XCODE_ACCOUNT_SETUP.md!
