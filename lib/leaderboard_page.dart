import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  final List<UserScore> leaderboard;
  final String? currentUser;

  const LeaderboardPage({required this.leaderboard, this.currentUser, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NextChamp Leaderboard')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          final isCurrentUser = user.username == currentUser;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: isCurrentUser ? Colors.deepPurple.shade100 : Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCurrentUser ? Colors.deepPurple : Colors.grey.shade300,
                foregroundColor: isCurrentUser ? Colors.white : Colors.black87,
                child: Text('${user.rank}'),
              ),
              title: Text(user.username),
              trailing: Text('${user.score} pts'),
            ),
          );
        },
      ),
    );
  }
}

class UserScore {
  final int rank;
  final String username;
  final int score;
  UserScore({
    required this.rank,
    required this.username,
    required this.score,
  });
}
