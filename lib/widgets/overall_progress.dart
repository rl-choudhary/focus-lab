import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';
import 'focus_card.dart';

class OverallProgress extends StatelessWidget {
  const OverallProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final stats = appState.getWeeklyProgressStats();

    final List<double> dailyData = stats['dailyData'];

    // Use total habit count as maxY for the chart (or at least a reasonable number)
    final double maxPossible =
        appState.habits.isNotEmpty ? appState.habits.length.toDouble() : 10.0;
    // Ensure maxY is at least 1 to avoid division by zero errors in chart
    final double maxY = maxPossible > 0 ? maxPossible : 1.0;

    return FocusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overall progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          // Use a bounded chart height so the card layout stays stable on web
          // and desktop preview, avoiding RenderFlex overflow.
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY == 0 ? 1 : maxY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final label = index >= 0 && index < days.length
                            ? days[index]
                            : '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY / 3,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.22),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List.generate(7, (index) {
                  final double val =
                      index < dailyData.length ? dailyData[index] : 0.0;
                  return makeGroupData(index, val, maxY);
                }),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ProgressBadge(
                label: 'Completed',
                value: dailyData.fold(0.0, (sum, item) => sum + item).toInt(),
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 12),
              _ProgressBadge(
                label: 'Max',
                value: (maxY * 7).toInt(),
                color: AppColors.lightGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, double max) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primaryGreen,
          width: 22, // Increased width
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), // Increased rounded corners
            topRight: Radius.circular(8),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: max,
            color: AppColors.lightGreen.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ProgressBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
          ],
        ),
      ],
    );
  }
}
