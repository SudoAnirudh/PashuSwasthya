# PashuSwasthya 🐄💚  
**An offline‑ready, multilingual cattle health assistant built with Flutter.**

![PashuSwasthya Logo](assets/images/logo.png)

---

## Why PashuSwasthya?
- Empowers field veterinarians and farmers with AI-assisted breed & disease insights.
- Works offline using on-device TensorFlow Lite models—perfect for low-connectivity regions.
- Speaks the farmer’s language with Malayalam, Hindi, Kannada, Tamil & English support.
- Bridges symptom descriptions, camera inputs, and treatment guides into one streamlined workflow.

---

## ✨ Core Features
- **Combined Breed & Disease Detection:** Capture or upload cattle photos, run sequential breed + disease models, and log the predictions locally.  
- **Voice Disease Prediction:** Speech-to-text with live analysis; non-English speech (Malayalam/Hindi/others) is auto-translated before running the symptom engine.  
- **Offline Treatment Library:** Rich Markdown-like guides bundled inside the app and accessible without network.  
- **Prediction History & Storage:** All camera and voice predictions are cached via Hive for quick recall.  
- **Localized UI & TTS:** Interfaces, snackbars, and text-to-speech prompts adapt to the chosen locale.  
- **Permissions & Safety:** Guided permission flows for microphone, storage, and camera keep the experience user-friendly.

---

## 🧱 Architecture & Tech Stack
| Layer | Highlights |
| --- | --- |
| **UI** | Flutter widgets, Google Fonts, responsive layouts, Provider for state |
| **Voice & TTS** | `speech_to_text`, `flutter_tts`, custom translation bridge to LibreTranslate |
| **ML Inference** | `tflite_flutter`, on-device models stored under `assets/` & `Model_New/` |
| **Data** | Hive + Hive Flutter for persistent prediction history (`StorageService`) |
| **Utilities** | Permission handling, UUID tagging, offline translation fallback |

---

## 🚀 Getting Started
1. **Prerequisites**
   - Flutter SDK 3.7.2+
   - Android Studio / Xcode with required tooling
   - A physical device or emulator (Android min SDK 21)

2. **Clone & Install**
   ```bash
   git clone https://github.com/<your-org>/PashuSwasthya_Flutter.git
   cd PashuSwasthya_Flutter
   flutter pub get
   ```

3. **Run on Device**
   ```bash
   flutter run -d <device_id>
   ```
   > Grant microphone, camera, and storage permissions when prompted to unlock all features.

---

## 📁 Key Directories
| Path | Purpose |
| --- | --- |
| `lib/screens/` | UI flows (home, combined detection, voice input, guides, settings) |
| `lib/services/` | Business logic: ML inference, localization, translation, storage |
| `assets/models/` | Default disease classifier + label metadata |
| `Model_New/` | Latest breed & disease TFLite models (dynamic/int8 variants) |
| `assets/images/` | Logos & UI illustrations |

---

## 🧠 Models & Data
- **Breed models:** `Model_New/Breed/*.tflite`
- **Disease models:** `Model_New/Diseases/*.tflite`
- **Default legacy model:** `assets/models/disease_classifier.tflite`

Models are loaded once at screen init (`CombinedDetectionScreen`) and disposed when the view exits. You can swap in updated `.tflite` files without code changes—just keep the filename & tensor specs consistent.

---

## 🌐 Localization & Speech
- App language is selected through `LanguageSelectionScreen` and persisted via `LocalizationService`.
- Speech locale auto-maps the UI language to matching STT locale IDs: `en_IN`, `hi_IN`, `ml_IN`, `kn_IN`, `ta_IN`.
- For languages without direct symptom keywords, transcripts are translated to English before analysis, ensuring parity across voice inputs.

---

## 🛠 Troubleshooting
- **Models won’t load:** Confirm `.tflite` paths exist and are listed under the `flutter.assets` section of `pubspec.yaml`.
- **Speech recognition unavailable:** Ensure Google voice services (Android) or Siri (iOS) are enabled; some emulators lack microphones.
- **LibreTranslate errors:** The fallback translation API requires internet—Malayalam speech still transcribes, but disease matching will rely on raw text if translation fails.



## 🤝 Contributing
1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-idea`
3. Commit your changes: `git commit -m 'Add amazing idea'`
4. Push to the branch: `git push origin feature/amazing-idea`
5. Open a pull request 🎉

---

## 📄 License


Built with ❤️ for farmers and field veterinarians. Empower rural communities with accessible animal healthcare! 🐮
