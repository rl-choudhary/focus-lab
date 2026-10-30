import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/focus_card.dart';

class MonthlyLeafGraph extends StatefulWidget {
  const MonthlyLeafGraph({super.key});

  @override
  State<MonthlyLeafGraph> createState() => _MonthlyLeafGraphState();
}

class _MonthlyLeafGraphState extends State<MonthlyLeafGraph> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Calculate monthly weekly breakdown (4 weeks of the current month)
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    List<Map<String, dynamic>> weeksData = [];
    for (int w = 0; w < 4; w++) {
      final weekStart = firstDayOfMonth.add(Duration(days: w * 7));

      int habitCompleted = 0;
      int habitTotal = 0;
      int taskCompleted = 0;
      int taskTotal = 0;

      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        if (day.month == now.month) {
          // Habits
          for (var h in appState.habits) {
            habitTotal++;
            if (h.isCompletedOn(day)) {
              habitCompleted++;
            }
          }
          // Tasks for this day
          final normalizedDay = DateTime(day.year, day.month, day.day);
          for (var t in appState.tasksForSelectedDate) {
            final tDate = DateTime(t.date.year, t.date.month, t.date.day);
            if (tDate.isAtSameMomentAs(normalizedDay)) {
              taskTotal++;
              if (t.isCompleted) taskCompleted++;
            }
          }
        }
      }

      final habitRate = habitTotal == 0 ? 0.0 : (habitCompleted / habitTotal);
      final taskRate = taskTotal == 0 ? 0.0 : (taskCompleted / taskTotal);

      weeksData.add({
        'title': 'Week ${w + 1}',
        'habitRate': habitRate,
        'habitCompleted': habitCompleted,
        'habitTotal': habitTotal,
        'taskRate': taskRate,
        'taskCompleted': taskCompleted,
        'taskTotal': taskTotal,
      });
    }

    return FocusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Leaf Analytics",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Interactive Petals",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Tap any week petal below to view detailed breakdown",
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 20),
          // Interactive Flower / Leaf Petal Layout
          Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing Central Core Hub
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade400, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.favorite_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  // 4 Petals arranged radially with tap actions
                  Positioned(
                    top: 10,
                    child: _buildInteractiveLeaf(context, weeksData[0]),
                  ),
                  Positioned(
                    bottom: 10,
                    child: _buildInteractiveLeaf(context, weeksData[2]),
                  ),
                  Positioned(
                    left: 10,
                    child: _buildInteractiveLeaf(context, weeksData[3]),
                  ),
                  Positioned(
                    right: 10,
                    child: _buildInteractiveLeaf(context, weeksData[1]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInteractiveLeaf(BuildContext context, Map<String, dynamic> week) {
    final theme = Theme.of(context);
    final String title = week['title'];
    final double habitRate = week['habitRate'];
    final double taskRate = week['taskRate'];
    final int habitCompleted = week['habitCompleted'];
    final int habitTotal = week['habitTotal'];
    final int taskCompleted = week['taskCompleted'];
    final int taskTotal = week['taskTotal'];

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$title Detailed Breakdown",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow(context, "Habits Completed", "$habitCompleted / $habitTotal", Colors.green, habitRate),
                const SizedBox(height: 16),
                _buildDetailRow(context, "Tasks Completed", "$taskCompleted / $taskTotal", Colors.redAccent, taskRate),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 135,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(36),
          gradient: LinearGradient(
            colors: [
              Colors.green.withValues(alpha: (habitRate == 0 ? 0.1 : habitRate) * 0.3),
              Colors.red.withValues(alpha: (taskRate == 0 ? 0.1 : taskRate) * 0.25),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "${(habitRate * 100).toInt()}%",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const Text("Habits", style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "${(taskRate * 100).toInt()}%",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Text("Tasks", style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, Color color, double rate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
