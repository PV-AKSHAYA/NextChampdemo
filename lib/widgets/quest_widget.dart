import 'package:flutter/material.dart';
import '../models/quest.dart';

class QuestWidget extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  const QuestWidget({required this.quest, this.onStart, this.onComplete, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocked = quest.status == QuestStatus.locked;
    final isInProgress = quest.status == QuestStatus.inProgress;
    final isCompleted = quest.status == QuestStatus.completed;

    return Card(
      child: ListTile(
        title: Text(quest.title),
        subtitle: Text(quest.description),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green, key: ValueKey('completed'))
              : isInProgress
                  ? ElevatedButton(onPressed: onComplete, child: const Text('Complete'), key: ValueKey('completeBtn'))
                  : ElevatedButton(onPressed: onStart, child: const Text('Start'), key: ValueKey('startBtn')),
        ),
      ),
    );
  }
}
