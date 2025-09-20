// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'gamification_bloc.dart';
// import 'gamification_widgets.dart';
// import 'widgets/quest_widget.dart'; // Import your QuestWidget
// import 'models/quest.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class GamificationScreen extends StatelessWidget {
//   final String userId;

//   const GamificationScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => GamificationBloc(),
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Achievements')),
//         body: BlocBuilder<GamificationBloc, GamificationState>(
//           builder: (context, state) {
//             double progress = (state.xp % 100) / 100.0;

//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Text('Level ${state.level}',
//                       style: Theme.of(context).textTheme.headlineSmall),
//                   const SizedBox(height: 20),
//                   ProgressBarWidget(progressPercent: progress),
//                   const SizedBox(height: 20),
//                   Wrap(
//                     spacing: 12,
//                     children: state.badges
//                         .map((badge) => BadgeWidget(label: badge, icon: Icons.star))
//                         .toList(),
//                   ),
//                   const SizedBox(height: 20),
//                   // Added quests UI below badges and progress bar
//                   Expanded(
//                     child: ListView(
//                       children: state.quests
//                           .map((quest) => QuestWidget(
//                                 quest: quest,
//                                 onStart: () => context.read<GamificationBloc>().add(StartQuest(quest.id)),
//                                 onComplete: () => context.read<GamificationBloc>().add(CompleteQuest(quest.id)),
//                               ))
//                           .toList(),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<GamificationBloc>().add(AddPoints(10));
//                       if ((state.points + 10) % 50 == 0) {
//                         context.read<GamificationBloc>().add(
//                               AddBadge('Milestone ${(state.points + 10)}'),
//                             );
//                       }
//                     },
//                     child: const Text('Complete Test (+10 pts)'),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationScreen extends StatelessWidget {
  final String userId;

  const GamificationScreen({Key? key, required this.userId}) : super(key: key);

  // Method to update gamification data in Firestore
  Future<void> updateGamification(String userId, Map<String, dynamic> updates) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update(updates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gamification"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text('No gamification data available.'));
          }

          int points = data['points'] ?? 0;
          int xp = data['xp'] ?? 0;
          List<dynamic> badges = data['badges'] ?? [];
          int level = data['level'] ?? 1;
          List<dynamic> quests = data['quests'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Points: $points', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('XP: $xp', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Level: $level', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Badges:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: badges.map<Widget>((badge) {
                    return Chip(label: Text(badge.toString()));
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Quests:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...quests.map<Widget>((quest) {
                  final questMap = quest as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Quest ID: ${questMap['questId'] ?? 'Unknown'}'),
                      subtitle: Text('Status: ${questMap['status'] ?? 'Unknown'}'),
                      trailing: questMap.containsKey('rewardPoints')
                          ? Text('+${questMap['rewardPoints']} pts')
                          : null,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Example: Update gamification - add points
                    int newPoints = points + 100;
                    updateGamification(userId, {'points': newPoints});
                  },
                  child: const Text('Add 100 Points'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
