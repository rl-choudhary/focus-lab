# Implementation Plan - Synchronize Date Selection and UI Polish

This plan focuses on aligning the `DateSelector` and `HabitGrid` date ranges and refining the typography and component sizing in the Habit Tracker.

## User Review Required

> [!IMPORTANT]
> - I will set both the `DateSelector` and `HabitGrid` to display exactly **30 days**, ending with Today.
> - This will ensure that T1 (Habit Grid dates) and S1 (Date Selector dates) are always perfectly synchronized.

## Proposed Changes

### [DateSelector](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/widgets/date_selector.dart)

- Update `_days` generation to **30 days** (from 14).
- Ensure the last day is always Today.

### [HabitGrid](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/widgets/habit_grid.dart)

- **Typography**: Increase habit title font size to **16** (from 14) and make it semi-bold to match other dashboard elements.
- **Checkbox Scaling**: Adjust the interactive checkbox size to be more prominent and ensure it scales smoothly.
- **Spacing**: Refine the padding around the "ADD" button and habit list to eliminate dead space.

### [AppState](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/models/app_state.dart)

- No changes required, as the core state already handles the selected date correctly.

## Verification Plan

### Manual Verification
- Verify that both the top date selector and the habit grid show the same range of dates.
- Check that "Today" is correctly identified and highlighted in both widgets.
- Confirm habit titles are more readable and match the app's overall text style.
- Test the habit checkbox interactivity and haptic feedback.
