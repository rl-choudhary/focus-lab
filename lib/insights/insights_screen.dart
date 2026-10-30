import 'package:flutter/material.dart';
import '../widgets/success_score_card.dart';
import '../widgets/overall_progress.dart';
import '../widgets/success_line_chart.dart';
import 'weekly_dot_matrix_chart.dart';
import 'monthly_leaf_graph.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Insights & Analytics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Track your performance, progress graphs, and consistency over time.",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          isMobile
              ? Column(
                  children: const [
                    SuccessScoreCard(),
                    SizedBox(height: 16),
                    OverallProgress(),
                    SizedBox(height: 16),
                    SuccessLineChart(),
                    SizedBox(height: 16),
                    WeeklyDotMatrixChart(),
                    SizedBox(height: 16),
                    MonthlyLeafGraph(),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
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
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(child: WeeklyDotMatrixChart()),
                        SizedBox(width: 20),
                        Expanded(child: MonthlyLeafGraph()),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
