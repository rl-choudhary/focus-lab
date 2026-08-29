# Habit Tracker UI & Feature Enhancement Plan

We will enhance and complete the Habit Tracker web application to match all requested specifications and screenshot annotations. The solution will incorporate Apple-inspired micro-interactions, cross-platform haptics with Web Audio API sound synthesis, dynamic habit CRUD modal dialogs, and a full-featured analytics sidebar to utilize the empty space.

## Key Changes & New Features

### 1. Header & Navigation (`[ADD HABIT]` Button)
- **Top Header Action**: Add an prominent `[+ Add Habit]` button on the top-left header area above habits/dates.
- **Header Controls**: View controls (Rolling 14-Day Grid, Month View), Category Filter pills (All, Health, Mindset, Fitness, Productivity), and Theme toggle (Dark / Light Glassmorphism).

### 2. Apple-Inspired Interactive Checkboxes & Cross-Platform Haptic Feedback
- **Apple Haptic Feedback Engine**:
  - Combined `navigator.vibrate([10, 30, 15])` (for mobile devices) + Web Audio API synthesizer generating a crisp, realistic iOS/Apple Watch tactile tap click sound on toggle (desktop & mobile).
- **Micro-Animations**:
  - Spring-scale bounce effect (`scale(0.85)` → `scale(1.18)` → `scale(1.0)`).
  - SVG checkmark path draw animation with custom stroke offsets.
  - Confetti/sparkle particle burst effect on checking off a habit.

### 3. Edit & Add Habit Modal Dialogs (`[EMOJI]` & `[DELETE BUTTON]`)
- **Interactive Emoji Selector**:
  - Display the current habit emoji as a clickable badge next to the Habit Title field in the Edit/Add dialog.
  - Clicking the emoji opens an interactive Emoji Picker Palette with categorized icons (Fitness 🏃, Health 🥗, Mind 🧘, Productivity ⚡, etc.).
- **Red-Themed Delete Icon Button**:
  - Add a styled red trash-can icon button on the bottom-left of the Edit Habit dialog (`trash-2` / `delete`).
  - Includes smooth deletion animation, modal closing, and an animated undo Toast notification.

### 4. Filling the `[EMPTY]` Space (Right Analytics & Dashboard Panel)
- **Today's Completion Progress Ring**: Apple Activity-style dynamic SVG progress ring displaying completion % and ratio (e.g. `6 / 8 Habits Done`).
- **Streak & Consistency Metrics**:
  - 🔥 Current Streak & Best Streak tracking.
  - 🏆 Total Completed Check-ins counter.
- **Weekly Habit Heatmap & Trend Chart**: Interactive mini visual chart showing daily consistency over the last 7 days.
- **Category Summary & Motivational Insight Card**: Daily habit tip or streak milestone card.

### 5. Layout & Spacing Adjustments
- Expanded grid padding, date column headers (highlighting TODAY with a glowing pill), smooth horizontal scrolling for date columns, and responsive glassmorphism background cards.

---

## Proposed File Changes

### [NEW] [index.html](file:///c:/Projects/GSPN_DATA_SCRAPPER_CROME_EXT/index.html)
- Main entry point for the Habit Tracker application.
- Modern HTML5 structure with semantic components, header, 14-day date grid, analytics sidebar, and Edit/Add Habit modal.

### [NEW] [habit_tracker.css](file:///c:/Projects/GSPN_DATA_SCRAPPER_CROME_EXT/habit_tracker.css)
- Design tokens, Apple dark/light glassmorphic color palette, custom CSS spring keyframes, checkmark stroke animations, particle burst styles, modal overlays, and responsive flex/grid layouts.

### [NEW] [habit_tracker.js](file:///c:/Projects/GSPN_DATA_SCRAPPER_CROME_EXT/habit_tracker.js)
- Application logic: state management, local storage persistence, date calculation engine, haptic vibrate & Web Audio API synthesizer, habit CRUD actions, emoji picker modal handling, progress ring & streak calculations.

---

## Verification Plan

### Automated / Browser Verification
- Open `index.html` in browser and test:
  1. Adding a new habit via `[+ Add Habit]` button.
  2. Editing habit title & selecting a new emoji from the Emoji picker.
  3. Deleting a habit via the red Delete button in the Edit modal.
  4. Clicking checkboxes: verifying spring scale animation, checkmark draw effect, and Web Audio haptic click sound.
  5. Verifying the right panel dynamic progress ring, streaks, and heatmap update live when habits are toggled.
