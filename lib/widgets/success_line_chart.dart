import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../theme/colors.dart';

class SuccessLineChart extends StatelessWidget {
  const SuccessLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final history = appState.getSuccessFailureHistory();
    // history is List<Map<String, dynamic>>: {day, success, failure}

    // Determine max Y for scaling
    double maxY = 0;
    for (var h in history) {
      if ((h['success'] as int) > maxY) maxY = (h['success'] as int).toDouble();
      if ((h['failure'] as int) > maxY) maxY = (h['failure'] as int).toDouble();
    }
    maxY = maxY == 0 ? 5 : maxY + 2; // Add some padding
    final dataLen = history.isNotEmpty ? history.length : 7;

    return Container(
      // Height handled by parent
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.28),
                    strokeWidth: 1.2,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final label = index >= 0 && index < dataLen && index < days.length
                            ? days[index]
                            : '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
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
                      interval: maxY / 4,
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
                      color: Theme.of(context).dividerColor.withOpacity(0.45),
                      width: 1.2,
                    ),
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.45),
                      width: 1.2,
                    ),
                  ),
                ),
                minX: 0,
                maxX: (dataLen - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) {
                      final lineLabel = spot.barIndex == 0
                          ? 'Success'
                          : 'Incomplete';
                      return LineTooltipItem(
                        '$lineLabel: ${spot.y.toInt()}',
                        TextStyle(
                          color: spot.barIndex == 0
                              ? AppColors.primaryGreen
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: history.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(),
                          (e.value['success'] as int).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primaryGreen,
                    barWidth: 3.8,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.primaryGreen,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryGreen.withOpacity(0.16),
                    ),
                  ),
                  LineChartBarData(
                    spots: history.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(),
                          (e.value['failure'] as int).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3.8,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 6,
                        color: Colors.redAccent,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.redAccent.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.primaryGreen, text: "Success"),
              const SizedBox(width: 20),
              _LegendItem(color: Colors.redAccent, text: "Incomplete"),
            ],
          )
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color)),
      ],
    );
  }
}
