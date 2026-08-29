import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';
import '../models/habit.dart';

class HabitGrid extends StatefulWidget {
  const HabitGrid({super.key});

  @override
  State<HabitGrid> createState() => _HabitGridState();
}

class _HabitGridState extends State<HabitGrid> {
  final ScrollController _scrollController = ScrollController();
  double? _lastWidth;
  DateTime? _lastSelectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);

    // Ensure we have a selection (Auto-select today if needed, though AppState handles init)
    // If logic needed to "auto select current date if not selected", AppState already defaults to Now.
    // Use the same generation logic as build
    final today = DateTime.now();
    final days = List.generate(
        14, (index) => today.subtract(Duration(days: 13 - index)));

    final selectedIndex = days.indexWhere((d) =>
        d.year == appState.selectedDate.year &&
        d.month == appState.selectedDate.month &&
        d.day == appState.selectedDate.day);

    if (selectedIndex != -1 && _scrollController.hasClients) {
      final itemWidth = 50.0;
      final offset = selectedIndex * itemWidth;

      try {
        final viewport = _scrollController.position.viewportDimension;
        final maxScroll = _scrollController.position.maxScrollExtent;

        // Center the selected item
        // item center = offset + itemWidth/2
        // viewport center = viewport/2
        // scroll needed = item center - viewport center
        double target = (offset + itemWidth / 2) - (viewport / 2);

        // Clamp to valid range
        target = target.clamp(0.0, maxScroll);

        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        // Handle cases where layout might not be ready
        print("Scroll error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final habits = appState.habits;
    final screenWidth = MediaQuery.of(context).size.width;

    // Trigger scroll if width or selection changes
    if (_lastWidth != screenWidth ||
        _lastSelectedDate != appState.selectedDate) {
      _lastWidth = screenWidth;
      _lastSelectedDate = appState.selectedDate;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }

    // Generate last 14 days
    final today = DateTime.now();
    final days = List.generate(
        14, (index) => today.subtract(Duration(days: 13 - index)));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Habit Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: TextButton.icon(
                        onPressed: () => _showAddHabitBottomSheet(context, appState),
                        icon: const Icon(Icons.add, size: 18, color: AppColors.primaryGreen),
                        label: const Text(
                          "ADD",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  ...habits.map((habit) => Container(
                        height: 54, // Match row height
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _showEditHabitBottomSheet(context, appState, habit),
                          child: Text(
                            "${habit.iconEmoji} ${habit.title}",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )),
                ],
              ),
              // Scrollable Days
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: days.map((date) {
                      final isSelected =
                          date.day == appState.selectedDate.day &&
                              date.month == appState.selectedDate.month &&
                              date.year == appState.selectedDate.year;

                      final isToday = date.day == DateTime.now().day &&
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;

                      return GestureDetector(
                        onTap: () => appState.updateSelectedDate(date),
                        child: Container(
                          width: 50, // Widened column
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen.withValues(alpha: 0.05)
                                : isToday ? Colors.grey.withValues(alpha: 0.03) : Colors.transparent,
                            border: isToday ? Border(
                              left: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                              right: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                            ) : null,
                          ),
                          child: Column(
                            children: [
                              // Date Header
                              Container(
                                height: 60,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: isSelected ? BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ) : null,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('E').format(date).toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: isSelected
                                            ? AppColors.primaryGreen
                                            : Theme.of(context).textTheme.bodySmall?.color),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppColors.primaryGreen
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color),
                                    ),
                                  ],
                                ),
                              ),
                              // Checkboxes
                              ...habits.map((habit) {
                                final isCompleted = habit.isCompletedOn(date);
                                return Container(
                                  height: 54, // Match row height
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      appState.toggleHabit(habit.id, date);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: AnimatedScale(
                                      duration: const Duration(milliseconds: 200),
                                      scale: isCompleted ? 1.0 : 0.9,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOutBack,
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? AppColors.primaryGreen
                                              : Colors.grey.withValues(alpha: 0.08),
                                          border: Border.all(
                                            color: isCompleted
                                                ? AppColors.primaryGreen
                                                : Colors.grey.withValues(alpha: 0.15),
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: isCompleted
                                            ? const Icon(Icons.check,
                                                size: 24,
                                                color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddHabitBottomSheet(BuildContext context, AppState appState) {
    final titleController = TextEditingController();
    final emojiController = TextEditingController(text: "✨");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add New Habit",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: emojiController,
                      decoration: InputDecoration(
                        labelText: "Emoji",
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: "Habit Title",
                        hintText: "e.g. Drink Water",
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      appState.addHabit(titleController.text, emojiController.text);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Create Habit",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditHabitBottomSheet(BuildContext context, AppState appState, Habit habit) {
    final titleController = TextEditingController(text: habit.title);
    final emojiController = TextEditingController(text: habit.iconEmoji);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Edit Habit",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      )),
                  IconButton(
                    onPressed: () {
                      appState.deleteHabit(habit.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                    tooltip: "Delete Habit",
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: emojiController,
                      decoration: InputDecoration(
                        labelText: "Emoji",
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: "Habit Title",
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      appState.updateHabit(habit.id, titleController.text, emojiController.text);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Changes",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
