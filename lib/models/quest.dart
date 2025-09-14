enum QuestStatus { locked, inProgress, completed }

class Quest {
  final String id;
  final String title;
  final String description;
  final int rewardPoints;
  QuestStatus status;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoints,
    this.status = QuestStatus.locked,
  });
}
