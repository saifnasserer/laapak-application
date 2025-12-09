# Production Readiness Guide for Google Play Store

This document outlines the steps needed to prepare the Laapak mobile app for production release on Google Play Store.

## ✅ Completed Configuration

### 1. **Package Name**
- ✅ Updated from `com.example.laapak` to `com.laapak.app`
- ⚠️ **ACTION REQUIRED**: Update MainActivity.kt package declaration
- ⚠️ **ACTION REQUIRED**: Move MainActivity.kt to new package structure

### 2. **App Description**
- ✅ Updated `pubspec.yaml` with proper description

### 3. **Build Configuration**
- ✅ Configured release build type with minification and code shrinking
- ✅ Added ProGuard rules file
- ✅ Configured multiDex support

### 4. **API Credentials**
- ✅ Moved WooCommerce credentials to AppConstants
- ⚠️ **RECOMMENDED**: Move credentials to secure storage or use environment variables

## 🔧 Required Actions Before Release

### 1. **Create and Configure Keystore**

1. Generate a keystore file:
```bash
cd android/app
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias laapak-key
```

2. Create `android/key.properties` file (copy from `key.properties.example`):
```properties
storeFile=../keystore.jks
storePassword=your_keystore_password
keyAlias=laapak-key
keyPassword=your_key_password
```

3. Add `key.properties` and `keystore.jks` to `.gitignore`:
```
android/key.properties
android/app/keystore.jks
*.jks
*.keystore
```

4. Update `build.gradle.kts` to load from key.properties:
```kotlin
// Load keystore properties from file
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    create("release") {
        storeFile = file(keystoreProperties["storeFile"] as String? ?: "../keystore.jks")
        storePassword = keystoreProperties["storePassword"] as String? ?: ""
        keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
        keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
    }
}
```

### 2. **Update Package Name Structure**

The package name has been changed to `com.laapak.app`. You need to:

1. Update MainActivity.kt package declaration:
   - Change `package com.example.laapak` to `package com.laapak.app`
   - Move file from `android/app/src/main/kotlin/com/example/laapak/` 
   - To: `android/app/src/main/kotlin/com/laapak/app/`

2. Update AndroidManifest.xml (if package references exist)

### 3. **Update Version Information**

Current version in `pubspec.yaml`: `1.0.0+1`

- Version name (1.0.0): User-visible version
- Version code (+1): Internal version number for Google Play

For each release, increment:
- Version name: `1.0.1`, `1.1.0`, `2.0.0`, etc.
- Version code: `2`, `3`, `4`, etc. (must always increase)

### 4. **Security Checklist**

- [ ] Move API credentials to secure configuration
- [ ] Remove any debug logging in release builds (ProGuard will handle this)
- [ ] Verify no sensitive data in logs
- [ ] Ensure HTTPS is used for all API calls
- [ ] Review all permissions in AndroidManifest.xml

### 5. **Google Play Store Requirements**

#### Required Assets:
- [ ] App icon (1024x1024 PNG, 32-bit PNG with alpha)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (at least 2, up to 8 per device type)
  - Phone: 16:9 or 9:16, min 320px, max 3840px
  - Tablet: 16:9 or 9:16, min 320px, max 3840px
- [ ] App description (80-4000 characters)
- [ ] Short description (80 characters max)
- [ ] Privacy Policy URL (required if app handles user data)

#### Content Rating:
- [ ] Complete content rating questionnaire
- [ ] Get rating certificate

#### Store Listing:
- [ ] App name (max 50 characters)
- [ ] Category selection
- [ ] Contact details (email, phone, website)
- [ ] Pricing and distribution countries

### 6. **Build Release APK/AAB**

#### Build App Bundle (Recommended for Play Store):
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

#### Or Build APK:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### 7. **Testing Before Release**

- [ ] Test on multiple Android versions (API 21+)
- [ ] Test on different screen sizes
- [ ] Test all app features
- [ ] Test offline functionality
- [ ] Test push notifications
- [ ] Test deep linking
- [ ] Test on physical devices
- [ ] Performance testing
- [ ] Security testing

### 8. **Permissions Review**

Current permissions in AndroidManifest.xml:
- ✅ `INTERNET` - Required for network requests
- ✅ `ACCESS_NETWORK_STATE` - For connectivity checks
- ✅ `SCHEDULE_EXACT_ALARM` - For precise notification scheduling (Android 12+)
- ✅ `USE_EXACT_ALARM` - Fallback for devices that don't support exact alarms

All permissions appear necessary and properly declared.

### 9. **ProGuard/R8 Configuration**

✅ ProGuard rules file created at `android/app/proguard-rules.pro`

The rules include:
- Flutter engine protection
- Keep necessary classes for plugins
- Remove logging in release builds
- Optimization settings

### 10. **Pre-Launch Checklist**

- [ ] All TODO comments resolved or documented
- [ ] All hardcoded values moved to configuration
- [ ] Error handling tested
- [ ] Analytics integrated (if needed)
- [ ] Crash reporting configured (recommended: Firebase Crashlytics)
- [ ] Update mechanism tested
- [ ] Legal pages (Privacy Policy, Terms of Service) available
- [ ] Support email configured

## 📱 Google Play Console Setup

1. **Create Developer Account**
   - One-time fee: $25 USD
   - Complete developer profile

2. **Create App**
   - Fill in app details
   - Upload app bundle (AAB)
   - Complete store listing
   - Set up pricing and distribution

3. **Content Rating**
   - Complete questionnaire
   - Get rating certificate

4. **Release Management**
   - Internal testing (up to 100 testers)
   - Closed testing (up to 1,000 testers)
   - Open testing (unlimited)
   - Production release

## 🔐 Security Best Practices

1. **Keystore Security**
   - Store keystore file securely (use password manager)
   - Back up keystore file (losing it means you can't update the app)
   - Never commit keystore to version control
   - Use strong passwords

2. **API Keys**
   - Move credentials to secure storage
   - Use environment variables or secure configuration
   - Consider using Google Play App Signing

3. **Code Obfuscation**
   - Already configured in release build
   - ProGuard rules ensure necessary classes are kept

## 📝 Notes

- The app uses Kotlin with Java 11
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest (set by Flutter)
- MultiDex enabled for large apps

## 🚀 Quick Start Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release app bundle
flutter build appbundle --release

# Build release APK
flutter build apk --release

# Build release APK (split by ABI for smaller size)
flutter build apk --split-per-abi --release
```

## 📞 Support

For issues or questions about the production setup, refer to:
- [Flutter Deployment Documentation](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)

