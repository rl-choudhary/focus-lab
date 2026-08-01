import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/date_selector.dart';
import '../widgets/daily_tasks.dart';
import '../widgets/habit_grid.dart';
import '../widgets/overall_progress.dart';
import '../widgets/success_line_chart.dart';
import '../widgets/success_score_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Focus Lab",
            style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          _buildThemeToggle(appState, isDark),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Summary Cards
                  _buildSummarySection(isMobile),
                  const SizedBox(height: 32),

                  // Navigation Section (Date Selector & Tab Switcher)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.02),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey(appState.selectedTab),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: appState.selectedTab == DashboardTab.tasks
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: DayTaskPanel(),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: HabitGrid(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(bool isMobile) {
    if (isMobile) {
      return Column(
        children: const [
          SuccessScoreCard(),
          SizedBox(height: 16),
          OverallProgress(),
          SizedBox(height: 16),
          SuccessLineChart(),
        ],
      );
    }
    return SizedBox(
      height: 280,
      child: Row(
        children: const [
          Expanded(child: SuccessScoreCard()),
          SizedBox(width: 20),
          Expanded(child: OverallProgress()),
          SizedBox(width: 20),
          Expanded(child: SuccessLineChart()),
        ],
      ),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                    color: Colors.black.withOpacity(0.2),
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

  Widget _buildThemeToggle(AppState appState, bool isDark) {
    return GestureDetector(
      onTap: () => appState.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? Colors.grey.shade800 : Colors.blue.shade100,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDark ? 30 : 2,
              top: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  color: isDark ? Colors.blueGrey : Colors.orange,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
