import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gamification_bloc.dart';
import 'gamification_widgets.dart';
import 'widgets/quest_widget.dart'; // Import your QuestWidget
import 'models/quest.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GamificationBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Achievements')),
        body: BlocBuilder<GamificationBloc, GamificationState>(
          builder: (context, state) {
            double progress = (state.xp % 100) / 100.0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Level ${state.level}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  ProgressBarWidget(progressPercent: progress),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    children: state.badges
                        .map((badge) => BadgeWidget(label: badge, icon: Icons.star))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  // Added quests UI below badges and progress bar
                  Expanded(
                    child: ListView(
                      children: state.quests
                          .map((quest) => QuestWidget(
                                quest: quest,
                                onStart: () => context.read<GamificationBloc>().add(StartQuest(quest.id)),
                                onComplete: () => context.read<GamificationBloc>().add(CompleteQuest(quest.id)),
                              ))
                          .toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GamificationBloc>().add(AddPoints(10));
                      if ((state.points + 10) % 50 == 0) {
                        context.read<GamificationBloc>().add(
                              AddBadge('Milestone ${(state.points + 10)}'),
                            );
                      }
                    },
                    child: const Text('Complete Test (+10 pts)'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
