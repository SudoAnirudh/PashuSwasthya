# Firebase Setup Instructions
To enable real OTP authentication via SMS, you must configure Firebase for your project.

## 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and follow the setup steps.

## 2. Add Android App
1. In your Firebase project settings, click the **Android** icon to add an app.
2. Enter your package name: `com.pashu_swasthya` (check `android/app/build.gradle` to confirm).
3. **Important**: You must add the **SHA-1** certificate fingerprint.
   - Run this command in your terminal to get the SHA-1 key:
     ```bash
     cd android
     ./gradlew signingReport
     ```
   - Copy the `SHA1` from the `debug` variant and paste it into the Firebase console.
4. Download the `google-services.json` file.
5. Place the file in: `android/app/google-services.json`.

## 3. Enable Phone Authentication
1. In Firebase Console, go to **Authentication** > **Sign-in method**.
2. Click **Phone** and enable it.
3. (Optional) Add test phone numbers for development.

## 4. Update Code
1. Open `lib/main.dart`.
2. Uncomment the line: `await Firebase.initializeApp();`.

## 5. Run the App
Run the app on an Android device or emulator.
```bash
flutter run
```
