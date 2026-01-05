# APK Installation Guide

## Common Issue: "You can't install it on your device"

This error typically occurs due to one of these reasons:

### 1. **Existing App with Different Signature**
If you previously installed the app (even from a different build), Android won't allow installing a new APK with a different signature.

**Solution:**
- Uninstall any existing version of the app first
- Go to Settings > Apps > Pashu Swasthya > Uninstall
- Then try installing the new APK

### 2. **Installation from Unknown Sources Disabled**
Your device might block installation from unknown sources.

**Solution:**
- Go to Settings > Security > Enable "Install from Unknown Sources" or "Install Unknown Apps"
- For Android 8.0+: Settings > Apps > Special Access > Install Unknown Apps > Enable for your file manager/browser

### 3. **APK Corruption**
The APK file might be corrupted during transfer.

**Solution:**
- Re-download/transfer the APK file
- Use ADB to install directly (see below)

### 4. **Device Architecture Mismatch or Unsigned Package**
The APK on GitHub might be unsigned or not compatible with your device's CPU.

**Solution:**
- **Recommended:** Download `app-debug.apk` from the GitHub Release. It is automatically signed and includes all architectures, making it the most reliable for testing.
- If you use `app-release.apk`, ensure you have uninstalled any previous versions of the app first.
- If your device is older, try the specific architecture versions (e.g., `v7a` or `v8a`).

## Installation Methods

### Method 1: Install via ADB (Recommended)
```bash
# Connect your device via USB and enable USB debugging
adb install build\app\outputs\flutter-apk\app-release.apk

# If app is already installed, use:
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

### Method 2: Install Debug APK (Easier for Testing)
```bash
# Build debug APK
flutter build apk --debug

# Install via ADB
adb install build\app\outputs\flutter-apk\app-debug.apk
```

### Method 3: Manual Installation
1. Transfer the APK to your device
2. Open the APK file on your device
3. Allow installation from unknown sources when prompted
4. Install the app

## Troubleshooting Steps

1. **Uninstall Existing App:**
   ```bash
   adb uninstall com.pashu_swasthya
   ```

2. **Check Device Connection:**
   ```bash
   adb devices
   ```

3. **Check APK Information:**
   ```bash
   aapt dump badging build\app\outputs\flutter-apk\app-release.apk
   ```

4. **Install with Options:**
   ```bash
   # Replace existing app
   adb install -r build\app\outputs\flutter-apk\app-release.apk
   
   # Install and grant permissions
   adb install -r -g build\app\outputs\flutter-apk\app-release.apk
   ```

## File Locations

- **Release APK:** `build\app\outputs\flutter-apk\app-release.apk`
- **Debug APK:** `build\app\outputs\flutter-apk\app-debug.apk`

## Notes

- Debug APK is larger but includes all architectures and is easier to install
- Release APK is optimized but might have signing issues if not properly configured
- For production, create a proper signing key (key.properties file)

