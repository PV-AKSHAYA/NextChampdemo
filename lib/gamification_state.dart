import 'models/quest.dart'; 
import 'package:equatable/equatable.dart';
// Change "your_project_name" appropriately

class GamificationState extends Equatable {
  final int points;
  final int xp;
  final List<String> badges;
  final int level;
  final List<Quest> quests;

  const GamificationState({
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

  @override
  List<Object> get props => [points, xp, badges, level, quests];
}
