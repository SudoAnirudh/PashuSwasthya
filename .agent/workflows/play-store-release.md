---
description: Play Store Release Checklist
---

# 🚀 Pashu Swasthya Play Store Release Workflow

Follow these steps to prepare and release the application to the Google Play Store.

## 1. Prerequisites
- [ ] Google Play Developer Account ($25 one-time fee)
- [ ] App Privacy Policy URL (Required by Google)

## 2. Generate Signing Key (Run once)
Run this command in your terminal to generate your upload keystore:
// turbo
```powershell
keytool -genkey -v -keystore c:\Users\aniru\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Be sure to remember the password you set!*

## 3. Configure Signing
1. Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=c:\\Users\\aniru\\upload-keystore.jks
```
2. Verify `android/app/build.gradle.kts` is configured to read these properties.

## 4. Prepare Metadata
- [ ] **Title**: Pashu Swasthya (Max 50 chars)
- [ ] **Short Description**: Cattle breed and disease detection app.
- [ ] **Full Description**: (Include features like Offline ML, Voice Input, and Hindi support)
- [ ] **Graphics**: 
    - [ ] App Icon (512x512 PNG)
    - [ ] Feature Graphic (1024x500 PNG)
    - [ ] 2-8 Phone Screenshots

## 5. Build and Upload
1. Update version in `pubspec.yaml` (e.g., `1.0.0+2`).
2. Run clean and get dependencies:
// turbo
```powershell
flutter clean; flutter pub get
```
3. Build the App Bundle:
// turbo
```powershell
flutter build appbundle --release
```
4. Upload the generated file to Play Console:
   - `build\app\outputs\bundle\release\app-release.aab`

## 6. Play Store Status
- [ ] Review and rollout to Internal Testing
- [ ] Promote to Production 
