# Keystore Setup for Production Release

This guide explains how to set up the keystore for signing release builds.

## Quick Setup

1. **Generate a keystore** (one-time, keep it safe!):
```bash
cd android/app
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias laapak-key
```

2. **Create key.properties** in the `android/` directory:
```properties
storeFile=../keystore.jks
storePassword=your_keystore_password
keyAlias=laapak-key
keyPassword=your_key_password
```

3. **Verify .gitignore** includes:
   - `key.properties`
   - `*.keystore`
   - `*.jks`

## Important Notes

- ⚠️ **BACKUP YOUR KEYSTORE**: If you lose the keystore file or forget the password, you will NOT be able to update your app on Google Play Store. You'll have to publish a new app with a different package name.
- Store the keystore file securely (password manager, encrypted backup, etc.)
- Never commit keystore files or key.properties to version control
- Consider using Google Play App Signing to let Google manage your signing key

## Alternative: Environment Variables

Instead of `key.properties`, you can use environment variables:
```bash
export KEYSTORE_FILE=/path/to/keystore.jks
export KEYSTORE_PASSWORD=your_password
export KEY_ALIAS=laapak-key
export KEY_PASSWORD=your_key_password
```

## Google Play App Signing

Google Play App Signing is recommended for better security:
- Google manages your app signing key
- You upload your app with an upload key (different from signing key)
- If you lose your upload key, Google can reset it

Enable this in Google Play Console → App Signing section.

