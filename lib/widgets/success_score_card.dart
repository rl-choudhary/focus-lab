import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';
import 'focus_card.dart';

class SuccessScoreCard extends StatelessWidget {
  const SuccessScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final score = appState.dailySuccessScore;
    final percentage = (score * 100).toInt();

    return FocusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Success Score",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  Text(
                    "Keep up the momentum!",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              Icon(Icons.trending_up, color: AppColors.primaryGreen.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: CircularPercentIndicator(
              radius: 54.0,
              lineWidth: 14.0,
              animation: true,
              percent: score.clamp(0.0, 1.0),
              center: Text(
                "$percentage%",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22.0,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: AppColors.primaryGreen,
              backgroundColor: AppColors.lightGreen.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
