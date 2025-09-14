import 'package:flutter/material.dart';

class FeedbackWidget extends StatelessWidget {
  final double scorePercent;
  final String feedback;

  const FeedbackWidget({required this.scorePercent, required this.feedback, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color scoreColor =
        scorePercent >= 80 ? Colors.green : scorePercent >= 50 ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Performance Score',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${scorePercent.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: scoreColor),
            ),
            const SizedBox(height: 16),
            Text(feedback, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
