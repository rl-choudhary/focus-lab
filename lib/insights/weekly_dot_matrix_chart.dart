import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../widgets/focus_card.dart';
import '../theme/colors.dart';

class WeeklyDotMatrixChart extends StatelessWidget {
  const WeeklyDotMatrixChart({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Generate last 30 days (1 month)
    final today = DateTime.now();
    final days = List.generate(
        30, (index) => today.subtract(Duration(days: 29 - index)));

    return FocusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "30-Day Contribution Matrix",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "30 Days",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Double-shade activity boxes: Blue (Tasks) & Red (Habits)",
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          // Streak Grid Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: SizedBox(
              height: 160,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: days.map((date) {
                    final normalizedDate = DateTime(date.year, date.month, date.day);

                    // Completed tasks for this day
                    final completedTasks = appState.tasksForSelectedDate.where((t) {
                      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
                      return tDate.isAtSameMomentAs(normalizedDate) && t.isCompleted;
                    }).length;

                    // Completed habits for this day
                    final completedHabits = appState.habits.where((h) {
                      return h.isCompletedOn(normalizedDate);
                    }).length;

                    // Double shade intensities
                    final taskColor = completedTasks > 0
                        ? Colors.blueAccent.withValues(alpha: (completedTasks * 0.3).clamp(0.4, 1.0))
                        : Colors.grey.withValues(alpha: 0.12);

                    final habitColor = completedHabits > 0
                        ? Colors.redAccent.withValues(alpha: (completedHabits * 0.25).clamp(0.4, 1.0))
                        : Colors.grey.withValues(alpha: 0.12);

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: Text(DateFormat('EEE, MMM d yyyy').format(date)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Completed Tasks: $completedTasks", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                const SizedBox(height: 8),
                                Text("Completed Habits: $completedHabits", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 42,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Task Box (Blue double-shade)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: taskColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: completedTasks > 0 ? [
                                  BoxShadow(
                                    color: Colors.blueAccent.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ] : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                completedTasks > 0 ? "$completedTasks" : "",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Habit Box (Red double-shade)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: habitColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: completedHabits > 0 ? [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ] : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                completedHabits > 0 ? "$completedHabits" : "",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Day Label
                            Text(
                              DateFormat('E').format(date)[0],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: date.day == DateTime.now().day && date.month == DateTime.now().month
                                    ? AppColors.primaryGreen
                                    : theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendBox(color: Colors.blueAccent, label: "Tasks (Blue)"),
              const SizedBox(width: 32),
              _LegendBox(color: Colors.redAccent, label: "Habits (Red)"),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
