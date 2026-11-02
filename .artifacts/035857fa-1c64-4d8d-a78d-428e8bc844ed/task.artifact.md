# Task List - Fix Android Notifications & 16 KB Memory Page Size Support

- [x] Initialize Notification Service on app startup and request permissions automatically (`main.dart`, `notification_service.dart`)
- [x] Add notification permission request when scheduling tasks if needed (`app_state.dart`)
- [x] Configure `useLegacyPackaging = true` in `android/app/build.gradle` for 16 KB memory page size compliance
- [x] Update AGP version in `android/settings.gradle` to 8.5.1
- [x] Verify build, run `flutter analyze`, and test notification functionality
- [x] Create walkthrough artifact (`walkthrough.artifact.md`)
