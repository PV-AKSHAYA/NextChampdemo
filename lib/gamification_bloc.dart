import 'package:flutter_bloc/flutter_bloc.dart';
import 'models/quest.dart';
import 'widgets/quest_widget.dart';

// Events
abstract class GamificationEvent {}

class AddPoints extends GamificationEvent {
  final int points;
  AddPoints(this.points);
}

class AddBadge extends GamificationEvent {
  final String badge;
  AddBadge(this.badge);
}

class StartQuest extends GamificationEvent {
  final String questId;
  StartQuest(this.questId);
}

class CompleteQuest extends GamificationEvent {
  final String questId;
  CompleteQuest(this.questId);
}

// Assuming Quest class and QuestStatus enum are defined somewhere accessible
// Example:
// enum QuestStatus { locked, inProgress, completed }
// class Quest { ... }

class GamificationState {
  final int points;
  final int xp;
  final List<String> badges;
  final int level;
  final List<Quest> quests;

  GamificationState({
    required this.points,
    required this.xp,
    required this.badges,
    required this.level,
    this.quests = const [],
  });

  GamificationState copyWith({
    int? points,
    int? xp,
    List<String>? badges,
    int? level,
    List<Quest>? quests,
  }) {
    return GamificationState(
      points: points ?? this.points,
      xp: xp ?? this.xp,
      badges: badges ?? this.badges,
      level: level ?? this.level,
      quests: quests ?? this.quests,
    );
  }
}

// Bloc
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  GamificationBloc()
      : super(GamificationState(points: 0, xp: 0, badges: [], level: 1)) {
    on<AddPoints>((event, emit) {
      final newPoints = state.points + event.points;
      final newXp = state.xp + event.points;
      final newLevel = (newXp ~/ 100) + 1;
      emit(state.copyWith(points: newPoints, xp: newXp, level: newLevel));
    });

    on<AddBadge>((event, emit) {
      final newBadges = List<String>.from(state.badges)..add(event.badge);
      emit(state.copyWith(badges: newBadges));
    });

    on<StartQuest>((event, emit) {
      var updatedQuests = state.quests.map((q) {
        if (q.id == event.questId) {
          return Quest(
            id: q.id,
            title: q.title,
            description: q.description,
            rewardPoints: q.rewardPoints,
            status: QuestStatus.inProgress,
          );
        }
        return q;
      }).toList();
      emit(state.copyWith(quests: updatedQuests));
    });

    on<CompleteQuest>((event, emit) {
      var updatedQuests = state.quests.map((q) {
        if (q.id == event.questId) {
          return Quest(
            id: q.id,
            title: q.title,
            description: q.description,
            rewardPoints: q.rewardPoints,
            status: QuestStatus.completed,
          );
        }
        return q;
      }).toList();

      int questPoints = updatedQuests.firstWhere((q) => q.id == event.questId).rewardPoints;
      final newPoints = state.points + questPoints;
      final newXp = state.xp + questPoints;
      final newLevel = (newXp ~/ 100) + 1;

      emit(state.copyWith(points: newPoints, xp: newXp, level: newLevel, quests: updatedQuests));
    });
  }
  static GamificationState _initialState() {
    final initialQuests = [
      Quest(
          id: 'q1',
          title: 'Complete first test',
          description: 'Record and upload your first test video',
          rewardPoints: 20),
      Quest(
          id: 'q2',
          title: 'Reach 100 points',
          description: 'Earn 100 points by completing tests',
          rewardPoints: 50),
    ];

    return GamificationState(
      points: 0,
      xp: 0,
      badges: [],
      level: 1,
      quests: initialQuests,
    );
  } 
}
