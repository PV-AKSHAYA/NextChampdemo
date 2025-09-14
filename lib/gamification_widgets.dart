import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  const BadgeWidget({required this.label, required this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, size: 28, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ProgressBarWidget extends StatelessWidget {
  final double progressPercent; // from 0.0 to 1.0
  const ProgressBarWidget({required this.progressPercent, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progressPercent,
      minHeight: 12,
      backgroundColor: Colors.grey.shade300,
      color: Colors.deepPurple,
    );
  }
}
