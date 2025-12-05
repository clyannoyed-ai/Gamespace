# Xcode Account & Token Setup Guide

**Last Updated**: December 5, 2025  
**For**: TeamSync AI iOS App Development

---

## 🔐 Overview

This guide walks you through:
1. Setting up Apple Developer Account
2. Configuring Xcode with your account
3. Obtaining and managing authentication tokens
4. Secure token storage for your app

---

## 📋 What You Need

- Apple ID (free or paid developer account)
- Mac with Xcode installed
- Internet connection
- 15 minutes of setup time

---

## 🚀 Step 1: Apple Developer Account Setup

### Option A: Individual Developer ($99/year)

1. Go to: https://developer.apple.com/account
2. Click "Sign Up"
3. Sign in with Apple ID (create one if needed)
4. Follow enrollment process
5. Agree to terms
6. Provide payment information
7. **Wait 24-48 hours** for approval

**What you get:**
- App Store distribution
- Push notifications
- In-app purchases
- Developer certificate

### Option B: Free Developer Account (Limited)

1. Launch Xcode
2. Xcode → Settings → Accounts
3. Click "+"
4. Select "Apple ID"
5. Sign in with Apple ID
6. Agree to license
7. **Restrictions:** Free provisioning only (7-day app validity)

**Recommended**: Go with paid account for real deployment.

---

## 💻 Step 2: Configure Xcode with Your Account

### Add Your Apple ID to Xcode

1. **Launch Xcode**
2. Go to **Xcode → Settings** (or Preferences on older macOS)
3. Click **Accounts** tab
4. Click **+** button (bottom left)
5. Select **Apple ID**
6. **Sign in** with your Apple ID
7. Click **Choose** when prompted for team

### Verify It's Working

- You should see your name in the Accounts list
- Team should be visible
- No error messages

---

## 🔑 Step 3: Generate Authentication Tokens

### Apple ID App-Specific Password (for CI/CD)

If you plan to automate builds:

1. Go to: https://appleid.apple.com/account/manage
2. Click **App-Specific Passwords**
3. Click **Generate**
4. Give it a name: `TeamSync AI iOS CI`
5. **Save the 16-character password** securely
6. Store in password manager or `.env` file (NOT in git)

### Example `.env` file (DON'T commit this!):
```
APPLE_ID=your-email@example.com
APP_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx
TEAM_ID=XXXXXXXXXX
```

---

## 📱 Step 4: Configure in Xcode Project

### Set Team ID and Bundle Identifier

1. Open your Xcode project
2. Select project in left sidebar
3. Select **TeamSyncAI** target
4. Go to **Signing & Capabilities** tab

**Configure:**
```
Team:                 [Your Team Name]
Bundle Identifier:    com.teamsyncai.app
Signing Certificate:  Automatic (Recommended)
Provisioning Profile: Automatic
```

### Add Capabilities

1. Click **+ Capability**
2. Add these capabilities:
   - **Push Notifications** (for notifications)
   - **Background Modes** (for background tasks)
   - **Keychain Sharing** (for secure token storage)
   - **HomeKit** (if needed - optional)

---

## 🔒 Step 5: Secure Token Storage in Your App

### Using Keychain (Already Implemented!)

The app includes `KeychainManager.swift` which securely stores tokens:

```swift
// Save token securely
let keychain = KeychainManager.shared
keychain.saveToken(authToken, forKey: SecureStorageKey.authToken)

// Retrieve token
if let token = keychain.getToken(forKey: SecureStorageKey.authToken) {
    APIService.shared.setAuthToken(token)
}

// Delete on logout
keychain.clearAllTokens()
```

**Advantages:**
- ✅ Encrypted storage
- ✅ Not accessible to other apps
- ✅ Survives app updates
- ✅ Cleared on app uninstall

### Don't Use UserDefaults for Tokens!
```swift
// ❌ INSECURE - Don't do this
UserDefaults.standard.set(token, forKey: "authToken")

// ✅ SECURE - Use Keychain
KeychainManager.shared.saveToken(token, forKey: SecureStorageKey.authToken)
```

---

## 📝 Step 6: Update Config File

Edit `/TeamSyncAI/Utilities/Config.swift`:

```swift
// Update Supabase credentials
static let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
static let supabaseAnonKey = "YOUR_ANON_KEY"

// Update Team ID
struct AppIdentifiers {
    static let teamIdentifier = "XXXXXXXXXX"  // Your 10-char Team ID
}
```

**Where to find your Team ID:**
1. Go to: https://developer.apple.com/account
2. Look for "Team ID" (10 alphanumeric characters)
3. Copy and paste into Config.swift

---

## 🧪 Step 7: Test Your Setup

### Build & Run

1. Select simulator or device: iPhone 15 Pro
2. Press **⌘ + B** to build
3. Press **⌘ + R** to run

### Check Console for Errors

```swift
// Add to AppDelegate or App.swift
print("API Base URL: \(Config.apiBaseURL)")
print("Team ID: \(AppIdentifiers.teamIdentifier)")
print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "N/A")")
```

### Common Issues

| Error | Solution |
|-------|----------|
| "No team provisioning profile" | Set team in Signing & Capabilities |
| "Invalid Bundle ID" | Update in Xcode settings |
| "Certificate not found" | Re-add Apple ID in Xcode Accounts |
| "Provisioning profile expired" | Regenerate in Apple Developer Console |

---

## 📲 Step 8: Testing on Real Device

### Prepare Device

1. Connect iPhone/iPad via USB
2. Trust the computer on device
3. Unlock device

### Build for Device

1. In Xcode: Select your device (not simulator)
2. Press **⌘ + R** to build and run
3. App should launch on device
4. Grant permissions when prompted

### Test Notifications

1. Create event in app
2. Check Settings for notification permissions
3. Grant if prompted
4. Verify notifications appear

---

## 🔄 Step 9: Handle Token Refresh

### When Tokens Expire

```swift
// In APIService.swift - Already implemented
private func handleUnauthorized() {
    // Token expired, need to refresh
    Task {
        do {
            let newToken = try await refreshToken()
            KeychainManager.shared.saveToken(newToken, forKey: SecureStorageKey.authToken)
            APIService.shared.setAuthToken(newToken)
        } catch {
            // Refresh failed - logout user
            authManager.logout()
        }
    }
}
```

### Implement Token Refresh Endpoint

In your backend, create a refresh endpoint:

```
POST /auth/refresh
Headers: Authorization: Bearer {refreshToken}
Response: { token: "new_token", refreshToken: "new_refresh_token" }
```

---

## 🔐 Security Best Practices

### ✅ DO

- ✅ Store tokens in Keychain
- ✅ Use HTTPS only
- ✅ Validate SSL certificates
- ✅ Implement token expiration
- ✅ Clear tokens on logout
- ✅ Use Bearer tokens
- ✅ Hash sensitive data

### ❌ DON'T

- ❌ Store tokens in UserDefaults
- ❌ Log tokens to console
- ❌ Commit tokens to git
- ❌ Use plain HTTP
- ❌ Store in files
- ❌ Hard-code credentials
- ❌ Share tokens between devices

---

## 📊 Token Structure

### JWT Token Example

```
Header.Payload.Signature

{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": "user_123",
    "email": "coach@example.com",
    "role": "coach",
    "exp": 1704067200,
    "iat": 1704063600
  },
  "signature": "..."
}
```

### Token Lifetime

```
Access Token:   15 minutes
Refresh Token:  7 days
App Session:    Until logout
```

---

## 🚀 Testing Credentials

For development, you can use test accounts:

```swift
// In UITests
let testEmail = "test@teamsyncai.app"
let testPassword = "Test1234!"
let testToken = "test_token_" + UUID().uuidString
```

---

## 📞 Troubleshooting

### "Provisioning profile is invalid"

**Solution:**
1. Xcode → Settings → Accounts
2. Click your team
3. Click "Download Manual Profiles"
4. Close and reopen Xcode

### "Certificate not available"

**Solution:**
1. Go to https://developer.apple.com/account/resources/certificates
2. Revoke old certificates if needed
3. Create new certificate
4. Download and double-click to install

### "Team ID not recognized"

**Solution:**
1. Verify Team ID is correct (10 characters)
2. Check for spaces or special characters
3. Confirm account has developer membership
4. Wait 24 hours if account is new

### Token always null after login

**Solution:**
1. Check `KeychainManager.saveToken()` returns true
2. Verify `SecureStorageKey` is consistent
3. Check Keychain Access permissions
4. Add debug prints:
```swift
let saved = KeychainManager.shared.saveToken(token, forKey: key)
print("Token saved: \(saved)")
```

---

## 🔄 Renewal Process

### Annual Account Renewal

1. Apple Developer Program costs $99/year
2. Renews automatically from stored card
3. No action needed unless canceling

### Certificate Renewal

Certificates expire every 2-3 years:
1. Go to Developer Console
2. Create new certificate
3. Download and install
4. Xcode will use automatically

---

## 📚 Reference Links

- **Apple Developer Account**: https://developer.apple.com/account
- **Certificates, IDs & Profiles**: https://developer.apple.com/account/resources/certificates
- **iOS Security Guide**: https://developer.apple.com/security/
- **Keychain Services**: https://developer.apple.com/documentation/security/keychain_services

---

## ✅ Checklist

Before submitting to App Store:

- [ ] Apple ID added to Xcode
- [ ] Team selected in Xcode
- [ ] Bundle identifier set correctly
- [ ] Signing certificate valid
- [ ] Provisioning profile active
- [ ] Push notifications capability added
- [ ] Keychain sharing enabled
- [ ] Token storage tested
- [ ] Build succeeds
- [ ] App runs on device

---

## 🎯 Next Steps

1. ✅ Set up Apple Developer Account
2. ✅ Configure Xcode with account
3. ✅ Update Config.swift with credentials
4. ✅ Test build and run
5. ✅ Connect backend API
6. ✅ Test token storage
7. ✅ Build for TestFlight
8. ✅ Submit to App Store

---

## 🆘 Getting Help

If you get stuck:

1. **Check Apple Developer Docs**: https://developer.apple.com/documentation/
2. **Search Stack Overflow**: Tag: `ios` + `xcode` + error message
3. **Check Xcode Error**: Often very specific - read it completely
4. **Enable Debug Logging**: Print config values at startup
5. **Test Incrementally**: Build, run, check each step

---

**You're Ready!** Follow these steps and you'll have secure token management in your iOS app. 🚀

---

*Version 1.0*  
*December 5, 2025*
