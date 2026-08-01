# Implementation Plan - Modern Date Selector

The goal is to implement a new, modern date selector based on the provided image and integrate it into the dashboard, potentially placing it alongside the Tasks/Habits toggle.

## User Review Required

> [!IMPORTANT]
> - The new date selector will be a horizontal scrollable list of dates.
> - The "selected" state will feature a green pill for the day name and a white circle for the day number, matching the provided screenshot.
> - I will attempt to place the Date Selector and the Tab Switcher in a `Row` on wider screens, while stacking them on mobile for better accessibility.

## Proposed Changes

### [New Widget] [DateSelector](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/widgets/date_selector.dart)

- [NEW] Create a new file `lib/widgets/date_selector.dart`.
- Implement a `StatefulWidget` (or `Stateless` with `AppState`) that displays a horizontal list of dates.
- Styling:
    - Pill shape for the day name (e.g., "Tue").
    - Circular background for the day number.
    - Animation when switching dates.
    - Auto-scroll to the selected date on load.

### [DashboardScreen](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/screens/dashboard_screen.dart)

- Integrate the `DateSelector` widget.
- Update the layout to accommodate the new selector.
- Use a `Wrap` or `Column`/`Row` combination to place it "to the left" of the tab switcher if space permits.

### [HabitGrid](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/widgets/habit_grid.dart)

- Ensure the grid's internal date header remains functional or syncs perfectly with the new global selector.
- Consider refining the `HabitGrid` header to avoid redundancy if the global selector is nearby.

## Verification Plan

### Manual Verification
- Verify the "Selected" state matches the image (Green pill + White circle).
- Verify horizontal scrolling works smoothly.
- Verify clicking a date updates both Tasks and Habit views.
- Test responsiveness (Mobile vs Desktop).
