# Implementation Plan - UI Improvements and Tabbed Navigation

The goal is to modernize the app's UI and introduce a toggle/tab system to separate "Tasks" and "Habit Tracker" for a cleaner, more focused experience.

## User Review Required

> [!IMPORTANT]
> - I will be adding a `DashboardTab` enum and a `selectedTab` property to `AppState`.
> - The bottom section of the dashboard will now toggle between the Task Panel and the Habit Grid.
> - I will introduce a custom-designed "Segmented Control" for tab switching to give it a premium feel.

## Proposed Changes

### [AppState](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/models/app_state.dart)

- [NEW] Add `DashboardTab` enum: `tasks`, `habits`.
- Add `_selectedTab` property with a getter and a `setSelectedTab` method.

### [DashboardScreen](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/screens/dashboard_screen.dart)

- Refactor `body` to include a tab switcher (toggle group).
- Use `AnimatedSwitcher` to transition between `DayTaskPanel` and `HabitGrid`.
- Improve the layout of top cards to ensure consistent height and alignment.
- Add better shadows and rounded corners for a modern "Glassmorphism" or "Clean Material 3" look.

### [DayTaskPanel](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/widgets/daily_tasks.dart)

- Refine the header (Day/Date) to be more compact when in the tab view.
- Improve the `TaskTile` design for better readability.

### [HabitGrid](file:///C:/Users/infod/AndroidStudioProjects/focus_lab_flutter-main/lib/widgets/habit_grid.dart)

- Ensure the grid fills the available space correctly when shown as a standalone tab.
- Refine the spacing and typography.

## UI Enhancement Details

1. **Custom Tab Switcher**: A sliding background toggle between "Tasks" and "Habits".
2. **Animation**: Smooth fade/slide transitions when switching views.
3. **Card Polish**: Add subtle borders and refined shadows to all cards.
4. **Spacing**: Uniform padding and margins across the entire app.

## Verification Plan

### Manual Verification
- Verify the toggle switch correctly swaps the view.
- Ensure state persists (if integrated with `AppState`).
- Check responsiveness on both Mobile and Desktop widths.
- Verify Dark Mode appearance for all new/modified components.
