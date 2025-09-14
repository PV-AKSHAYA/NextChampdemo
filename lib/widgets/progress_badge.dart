import 'package:flutter/material.dart';

class ProgressBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const ProgressBadge({
    required this.label,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
