import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';

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

    // Generate last 30 days for example
    final today = DateTime.now();
    final days = List.generate(
        14, (index) => today.subtract(Duration(days: 13 - index)));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Fixed Habit Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 60), // Header spacer
                  ...habits.map((habit) => Container(
                        height: 54, // Match row height
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final controller =
                                    TextEditingController(text: habit.title);
                                return AlertDialog(
                                  title: const Text("Edit Habit"),
                                  content: TextField(
                                    controller: controller,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                        labelText: "Habit Title"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (controller.text.isNotEmpty) {
                                          appState.updateHabitTitle(
                                              habit.id, controller.text);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Save"),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "${habit.iconEmoji} ${habit.title}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    14, // Maintained/slightly tweaked text size
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

                      return GestureDetector(
                        onTap: () => appState.updateSelectedDate(date),
                        child: Container(
                          width: 50, // Widened column
                          color: isSelected
                              ? AppColors.lightGreen.withAlpha(100)
                              : Colors.transparent,
                          child: Column(
                            children: [
                              // Date Header
                              Container(
                                height: 60,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: isSelected ? BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
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
                                    onTap: () =>
                                        appState.toggleHabit(habit.id, date),
                                    borderRadius: BorderRadius.circular(10),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.primaryGreen
                                            : Colors.grey.withOpacity(0.05),
                                        border: Border.all(
                                          color: isCompleted
                                              ? AppColors.primaryGreen
                                              : Colors.grey.withOpacity(0.1),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: isCompleted
                                          ? const Icon(Icons.check,
                                              size: 22,
                                              color: Colors.white)
                                          : null,
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
}
