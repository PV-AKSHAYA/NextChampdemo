abstract class GamificationEvent {}

class AddPoints extends GamificationEvent {
  final int points;
  AddPoints(this.points);
}

class AddBadge extends GamificationEvent {
  final String badge;
  AddBadge(this.badge);
}

class CompleteQuest extends GamificationEvent {
  final String questId;
  CompleteQuest(this.questId);
}

class StartQuest extends GamificationEvent {
  final String questId;
  StartQuest(this.questId);
}
