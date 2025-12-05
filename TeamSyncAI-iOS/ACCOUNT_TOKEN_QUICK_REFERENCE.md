# 🔐 Account & Token Quick Reference

**For**: TeamSync AI iOS App  
**Last Updated**: December 5, 2025

---

## 🚀 Quick Setup (15 minutes)

### Step 1: Apple Developer Account
```bash
Visit: https://developer.apple.com/account
Sign In with Apple ID
Pay $99/year (or use free tier)
Get: 10-character Team ID (e.g., ABCDE12345)
```

### Step 2: Add to Xcode
```
Xcode → Settings → Accounts → [+] → Apple ID
Sign in with your Apple ID
Select Team when prompted
```

### Step 3: Configure Project
```
Xcode Project Settings:
├─ Team: [Your Team Name]
├─ Bundle ID: com.teamsyncai.app
├─ Signing Certificate: Automatic
└─ Capabilities: Push Notifications, Keychain Sharing
```

### Step 4: Update Config.swift
```swift
// Location: TeamSyncAI/Utilities/Config.swift

static let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
static let supabaseAnonKey = "YOUR_ANON_KEY_HERE"

// In AppIdentifiers:
static let teamIdentifier = "XXXXXXXXXX"  // Your Team ID
```

### Step 5: Test
```bash
⌘ + B  (Build)
⌘ + R  (Run)
```

---

## 📋 Credentials You'll Need

| Credential | Where to Get | Used For |
|-----------|---|---|
| **Apple ID** | appleid.apple.com | Xcode login |
| **Team ID** | developer.apple.com/account | Bundle identifier, signing |
| **Supabase URL** | app.supabase.com → Settings | Backend connection |
| **Supabase Anon Key** | app.supabase.com → Settings | API authentication |
| **App-Specific Password** | appleid.apple.com → Security | CI/CD automation |

---

## 🔑 Token Management

### Where Tokens Are Stored

```
User's Login Credentials
        ↓
  Sent to Backend API
        ↓
  Backend validates & returns JWT Token
        ↓
  App saves securely in Keychain
        ↓
  Token used for all API requests
```

### How Tokens Work in the App

```swift
// 1. User logs in
await authManager.login(email: "user@example.com", password: "pass")

// 2. App gets JWT token from backend
// (You implement this in backend)

// 3. App saves token securely
KeychainManager.shared.saveToken(token, forKey: SecureStorageKey.authToken)

// 4. Token automatically used in API calls
// (APIService.swift handles this)

// 5. On logout, token is deleted
authManager.logout()
```

---

## 🔒 Security Checklist

- ✅ Tokens saved in **Keychain** (not UserDefaults)
- ✅ API calls use **HTTPS only**
- ✅ Tokens **not logged** to console
- ✅ Tokens **cleared on logout**
- ✅ **No hardcoded** credentials
- ✅ **No credentials** in git commits
- ✅ Use **.env files** locally (not committed)

---

## 📁 Files You Need to Update

### 1. Config.swift
```
Location: TeamSyncAI/Utilities/Config.swift
Update: Supabase credentials
        Team identifier
```

### 2. Info.plist
```
Location: Project Settings
Add: NSMicrophoneUsageDescription
     NSLocalNetworkUsageDescription
     Background Modes (Push Notifications)
```

### 3. Project Settings
```
General Tab:
├─ Team: Select your team
├─ Bundle Identifier: com.teamsyncai.app
└─ Minimum Deployment: iOS 15.0

Signing & Capabilities Tab:
├─ Signing Certificate: Automatic
├─ Provisioning Profile: Automatic
└─ Capabilities: Push Notifications, Keychain Sharing
```

---

## 🧪 Testing Your Setup

### Test 1: Build Succeeds
```bash
⌘ + B
Expected: Build successful
```

### Test 2: App Runs
```bash
⌘ + R
Expected: App launches in simulator
```

### Test 3: Config Loaded
Add to ContentView.swift:
```swift
VStack {
    Text("API: \(Config.apiBaseURL)")
    Text("Team: \(AppIdentifiers.teamIdentifier)")
}
```
Expected: URLs show correctly

### Test 4: Token Storage
```swift
KeychainManager.shared.saveToken("test123", forKey: SecureStorageKey.authToken)
let retrieved = KeychainManager.shared.getToken(forKey: SecureStorageKey.authToken)
print(retrieved)  // Should print: Optional("test123")
```

---

## ⚠️ Common Mistakes

❌ **Don't:**
- Store tokens in UserDefaults
- Commit .env file to git
- Hardcode credentials in code
- Log tokens to console
- Use plain HTTP
- Share Team ID publicly

✅ **Do:**
- Use Keychain for tokens
- Add .env to .gitignore
- Keep credentials in secure files
- Use environment variables
- Always use HTTPS
- Keep Team ID private

---

## 🆘 Troubleshooting

### "No team provisioning profile"
```
Fix: Xcode → Project Settings → Signing & Capabilities
     Select your Team from dropdown
```

### "Invalid Bundle Identifier"
```
Fix: Check format is com.teamsyncai.app
     No spaces or special characters
```

### "Certificate not found"
```
Fix: Xcode → Settings → Accounts
     Scroll down to "Download Manual Profiles"
     Click and wait for download
```

### "Token is nil after login"
```
Fix: Check KeychainManager.saveToken() returned true
     Verify SecureStorageKey matches
     Check app has Keychain Sharing capability
```

### "API calls returning 401 Unauthorized"
```
Fix: Verify token is being saved
     Check token is in API request headers
     Verify backend accepts your token format
     Test with curl first: curl -H "Authorization: Bearer TOKEN" API_URL
```

---

## 📊 Environment Quick Switch

### Development (Local Backend)
Edit `Config.swift`:
```swift
static let apiBaseURL = URL(string: "http://localhost:3000/api/v1")!
```

### Staging (Dev Server)
```swift
static let apiBaseURL = URL(string: "https://dev.teamsyncai.app/api/v1")!
```

### Production (Live)
```swift
static let apiBaseURL = URL(string: "https://teamsyncai.abacusai.app/api/v1")!
```

---

## 🎯 Before You Start Coding

- [ ] Apple Developer Account created
- [ ] Apple ID added to Xcode
- [ ] Team ID obtained and copied
- [ ] Config.swift updated with credentials
- [ ] Build Settings configured
- [ ] Signing certificate set
- [ ] Provisioning profile active
- [ ] Project builds without errors
- [ ] App runs in simulator
- [ ] Token storage tested

---

## 📞 Key Contacts

- **Apple Developer Support**: https://developer.apple.com/contact/
- **Supabase Support**: https://supabase.com/docs
- **GitHub Copilot**: Ask for help in your development

---

## 🚀 Next Steps

1. Follow **XCODE_ACCOUNT_SETUP.md** (detailed guide)
2. Update **Config.swift** with your credentials
3. Build and run in Xcode
4. Test token storage
5. Connect backend API
6. Start developing!

---

**Everything Configured?** You're ready to build! 🎉

*Built for TeamSync AI iOS*  
*December 5, 2025 | v1.0*
