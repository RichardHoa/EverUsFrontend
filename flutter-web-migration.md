# EverUs - Flutter Web Migration Plan

## Overview
Transforming the **EverUs** Flutter application into a multi-platform app supporting Flutter Web alongside iOS and Android.

## Success Criteria
1. Flutter Web builds cleanly with zero `dart:io` compilation errors.
2. Web app runs on desktop browsers (`flutter run -d chrome`).
3. Authentication (FastAPI + Google OAuth), Love Counter settings, and Real-time SSE Notifications function on Web.
4. Mobile portrait layout stays centered and responsive on wide desktop monitors.

## Tech Stack
- Flutter Web (Dart 3.x)
- `package:http/http.dart` for cross-platform HTTP requests
- `package:shared_preferences/shared_preferences.dart` for web storage
- `package:image_picker/image_picker.dart` for cross-platform image picking
- Google Sign-In for Web (`google_sign_in_web`)

## Task Breakdown
1. **P0: Web Scaffold Setup**
   - Create `web/index.html`, `web/manifest.json`, and favicon configuration.
2. **P0: Remove `dart:io` Dependencies**
   - Replace `HttpClient` in `auth_helper.dart` with `http.Client`.
   - Update `notification_manager.dart` to support web-compatible SSE and guard local notifications plugin initialization.
3. **P1: Web Storage for Images**
   - Refactor `love_counter_helper.dart` and `love_counter_screen.dart` to use Base64/MemoryImage on Web and FileImage on native platforms.
4. **P1: Web Layout Constraints**
   - Apply `ConstrainedBox` centered wrapper in `main.dart` for desktop browsers.
5. **P2: Verification & Testing**
   - Run `flutter build web` to ensure 0 build errors.
