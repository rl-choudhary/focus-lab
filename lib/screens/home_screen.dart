import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../widgets/date_selector.dart';
import '../widgets/daily_tasks.dart';
import '../widgets/habit_grid.dart';
import '../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGetInsightsPressed;

  const HomeScreen({super.key, required this.onGetInsightsPressed});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Two Cards Section + Get Insights Button
          _buildTwoCardsAndInsightsButton(context, onGetInsightsPressed, appState),
          const SizedBox(height: 32),

          // Navigation Section (Date Selector & Tab Switcher)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      const DateSelector(),
                      const SizedBox(height: 20),
                      _buildTabSwitcher(context, appState),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(child: DateSelector()),
                      const SizedBox(width: 24),
                      _buildTabSwitcher(context, appState),
                      const SizedBox(width: 12),
                    ],
                  ),
          ),
          const SizedBox(height: 32),

          // Content Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: IndexedStack(
              index: appState.selectedTab == DashboardTab.tasks ? 0 : 1,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: DayTaskPanel(),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: HabitGrid(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTwoCardsAndInsightsButton(BuildContext context, VoidCallback onGetInsights, AppState appState) {
    final theme = Theme.of(context);
    final selectedDate = appState.selectedDate;

    // Card 1 Data: Daily Habits & Tasks
    final habits = appState.habits;
    final completedHabits = habits.where((h) => h.isCompletedOn(selectedDate)).length;
    final tasks = appState.tasksForSelectedDate;
    final completedTasks = tasks.where((t) => t.isCompleted).length;

    final totalHabits = habits.length;
    final totalTasks = tasks.length;
    final totalItems = totalHabits + totalTasks;
    final completedItems = completedHabits + completedTasks;
    final dailyProgress = totalItems == 0 ? 0.0 : completedItems / totalItems;

    // Card 2 Data: Weekly Dot Matrix Graph (Last 7 days)
    final history = appState.getSuccessFailureHistory();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Daily Habits & Tasks
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.primaryGreen.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.today_rounded, color: Colors.white, size: 22),
                        Text("Daily Basis", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Habits & Tasks",
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Habits: $completedHabits/$totalHabits",
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text("Tasks: $completedTasks/$totalTasks",
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                value: dailyProgress,
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 4,
                              ),
                            ),
                            Text("${(dailyProgress * 100).toInt()}%",
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Weekly Dot Matrix Graph
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.grid_view_rounded, color: theme.colorScheme.primary, size: 22),
                        const Text("Weekly Dots", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("Completion",
                        style: TextStyle(color: theme.textTheme.titleLarge?.color, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // Weekly dots representation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: history.map((h) {
                        final success = h['success'] as int;
                        final failure = h['failure'] as int;
                        final dayName = DateFormat('E').format(h['day'] as DateTime)[0];
                        return Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: success > 0 ? AppColors.primaryGreen : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: failure > 0 ? Colors.red : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(dayName, style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color)),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryGreen)),
                        const SizedBox(width: 3),
                        const Text("Done", style: TextStyle(fontSize: 8, color: Colors.grey)),
                        const SizedBox(width: 6),
                        Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                        const SizedBox(width: 3),
                        const Text("Missed", style: TextStyle(fontSize: 8, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onGetInsights,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 4,
            ),
            icon: const Icon(Icons.insights_rounded, color: Colors.white),
            label: const Text("Get Insights",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher(BuildContext context, AppState appState) {
    final isTasks = appState.selectedTab == DashboardTab.tasks;
    final theme = Theme.of(context);

    return Container(
      width: 300,
      height: 54,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            left: isTasks ? 4 : 152,
            top: 4,
            child: Container(
              width: 144,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => appState.setSelectedTab(DashboardTab.tasks),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "Tasks",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTasks ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => appState.setSelectedTab(DashboardTab.habits),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "Habits",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !isTasks ? Colors.white : Colors.grey,
                      ),
                    ),
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
