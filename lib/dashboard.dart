import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String username;
  final int totalPoints;
  const DashboardScreen({required this.username, required this.totalPoints, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NextChamp Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome $username!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Total Points: $totalPoints', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _Badge(label: 'Rising Star', icon: Icons.star, color: Colors.amber),
                _Badge(label: 'Marathoner', icon: Icons.directions_run, color: Colors.green),
                _Badge(label: 'Achiever', icon: Icons.emoji_events, color: Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Leaderboard screen
                  Navigator.pushNamed(context, '/leaderboard');
                },
                child: const Text('View Leaderboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Badge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 32)),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}



