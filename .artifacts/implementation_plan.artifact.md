# Implementation Plan - App Improvement & Modernization

This plan outlines a series of enhancements to modernize the Focus Lab app, improve code quality, and provide a more premium user experience.

## Proposed Changes

### 1. Code Quality & Modernization
- **Fix Deprecations**: Replace all instances of `.withOpacity()` with `.withValues()` and update `ColorScheme` properties (e.g., `background` to `surface`).
- **Style Consolidation**: Centralize common UI properties like `borderRadius` and `boxShadow` in a new `lib/theme/styles.dart` file.

### 2. UI/UX Enhancements
- **Modern Input**: Replace standard `AlertDialog` with styled `ModalBottomSheet` for "Add Task" and "Add/Edit Habit" actions.
- **Unified Card Component**: Create a `FocusCard` widget to standardize the look and feel of all dashboard elements.
- **Enhanced Dashboard Navigation**: Refine the `DateSelector` and `TabSwitcher` container for better visual hierarchy.
- **Improved Empty States**: Add subtle illustrations or better icons for empty task/habit lists.

### 3. Feature Refinements
- **Success Score Card**: Improve layout stability to prevent overflows on edge cases.
- **Chart Polish**: Refine `fl_chart` configurations for better readability on both themes.

## User Review Required

> [!IMPORTANT]
> I will be changing the interaction model for adding tasks and habits from dialogs to bottom sheets. This is generally preferred in modern mobile apps but changes the "flow" slightly.

## Verification Plan

### Automated Tests
- Run `dart analyze` to ensure all deprecation warnings are resolved.

### Manual Verification
- Test "Add Task" and "Add Habit" flows to ensure the new bottom sheets work correctly.
- Verify that the app remains fully responsive on both mobile and desktop screen widths.
- Check Dark Mode consistency across all new/modified widgets.
