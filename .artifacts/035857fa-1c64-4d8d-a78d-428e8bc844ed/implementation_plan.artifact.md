# Implementation Plan - Fix Android Notifications & 16 KB Memory Page Size Support

## Problem Statement
1. **Android Notifications**: Notifications are not working and permission is not being requested. `NotificationService.init()` is never called on app startup, permission request is only accessible via Settings, and runtime permissions (`POST_NOTIFICATIONS` / exact alarms) are not requested automatically.
2. **16 KB Memory Page Sizes (Google Play Console)**: Google Play requires apps to support 16 KB memory page sizes. Native libraries (`.so` files) bundled by plugins need proper packaging or AGP configuration (`useLegacyPackaging = true` or AGP 8.5.1+) to pass Google Play Console checks.

## Proposed Changes

### Notification Fixes
#### [MODIFY] [main.dart](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/main.dart)
- Initialize `NotificationService.init()` on app startup.
- Automatically request notification permissions on startup or when scheduling the first task.

#### [MODIFY] [notification_service.dart](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/services/notification_service.dart)
- Enhance `requestPermissions()` to explicitly request `POST_NOTIFICATIONS` and exact alarm permissions.
- Ensure `init()` is robustly called before any scheduling or permission check.

#### [MODIFY] [app_state.dart](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/models/app_state.dart)
- Request notification permissions when tasks with reminders are created/scheduled if not already granted.

### 16 KB Memory Page Size Fixes
#### [MODIFY] [build.gradle](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/android/app/build.gradle)
- Add `packaging { jniLibs { useLegacyPackaging = true } }` under `android` block to ensure compressed native libraries packaging compliant with Google Play Console 16 KB page size requirements.

#### [MODIFY] [settings.gradle](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/android/settings.gradle)
- Update Android Gradle Plugin version from `8.3.0` to `8.5.1` (or compatible version) to support modern Android build features.

## Verification Plan

### Automated Tests
- Run `flutter analyze` and `flutter test` to ensure zero compilation or linter errors.

### Manual Verification
- Deploy app to an Android 13+ device/emulator.
- Verify that notification permission prompt appears correctly.
- Test scheduling a task notification and verifying it fires successfully.
- Verify Gradle build succeeds with 16 KB memory page size configurations.
