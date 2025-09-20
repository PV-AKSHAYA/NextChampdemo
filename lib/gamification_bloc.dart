// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'models/quest.dart';
// // import 'widgets/quest_widget.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // Future<void> updateGamification(String userId, Map<String, dynamic> updates) async {
// //   await FirebaseFirestore.instance.collection('users').doc(userId).update(updates);
// // }


// // // Events
// // abstract class GamificationEvent {}

// // class AddPoints extends GamificationEvent {
// //   final int points;
// //   AddPoints(this.points);
// // }

// // class AddBadge extends GamificationEvent {
// //   final String badge;
// //   AddBadge(this.badge);
// // }

// // class StartQuest extends GamificationEvent {
// //   final String questId;
// //   StartQuest(this.questId);
// // }

// // class CompleteQuest extends GamificationEvent {
// //   final String questId;
// //   CompleteQuest(this.questId);
// // }

// // // Assuming Quest class and QuestStatus enum are defined somewhere accessible
// // // Example:
// // // enum QuestStatus { locked, inProgress, completed }
// // // class Quest { ... }

// // class GamificationState {
// //   final int points;
// //   final int xp;
// //   final List<String> badges;
// //   final int level;
// //   final List<Quest> quests;

// //   GamificationState({
// //     required this.points,
// //     required this.xp,
// //     required this.badges,
// //     required this.level,
// //     this.quests = const [],
// //   });

// //   GamificationState copyWith({
// //     int? points,
// //     int? xp,
// //     List<String>? badges,
// //     int? level,
// //     List<Quest>? quests,
// //   }) {
// //     return GamificationState(
// //       points: points ?? this.points,
// //       xp: xp ?? this.xp,
// //       badges: badges ?? this.badges,
// //       level: level ?? this.level,
// //       quests: quests ?? this.quests,
// //     );
// //   }
// // }

// // // Bloc
// // class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
// //   GamificationBloc()
// //       : super(GamificationState(points: 0, xp: 0, badges: [], level: 1)) {
// //     // on<AddPoints>((event, emit) {
// //     //   final newPoints = state.points + event.points;
// //     //   final newXp = state.xp + event.points;
// //     //   final newLevel = (newXp ~/ 100) + 1;
// //     //   emit(state.copyWith(points: newPoints, xp: newXp, level: newLevel));
// //     // });

// //     // on<AddBadge>((event, emit) {
// //     //   final newBadges = List<String>.from(state.badges)..add(event.badge);
// //     //   emit(state.copyWith(badges: newBadges));
// //     // });
// //   on<AddPoints>((event, emit) async {
// //   final newPoints = state.points + event.points;
// //   await updateGamification(userId, {'points': newPoints});
// //   emit(state.copyWith(points: newPoints));
// // });

// // on<AddBadge>((event, emit) async {
// //   final updatedBadges = List<String>.from(state.badges)..add(event.badge);
// //   await updateGamification(userId, {'badges': updatedBadges});
// //   emit(state.copyWith(badges: updatedBadges));
// // });

// // // Repeat this pattern for other events (quests, xp, level, etc)

// //     on<StartQuest>((event, emit) {
// //       var updatedQuests = state.quests.map((q) {
// //         if (q.id == event.questId) {
// //           return Quest(
// //             id: q.id,
// //             title: q.title,
// //             description: q.description,
// //             rewardPoints: q.rewardPoints,
// //             status: QuestStatus.inProgress,
// //           );
// //         }
// //         return q;
// //       }).toList();
// //       emit(state.copyWith(quests: updatedQuests));
// //     });

// //     on<CompleteQuest>((event, emit) {
// //       var updatedQuests = state.quests.map((q) {
// //         if (q.id == event.questId) {
// //           return Quest(
// //             id: q.id,
// //             title: q.title,
// //             description: q.description,
// //             rewardPoints: q.rewardPoints,
// //             status: QuestStatus.completed,
// //           );
// //         }
// //         return q;
// //       }).toList();

// //       int questPoints = updatedQuests.firstWhere((q) => q.id == event.questId).rewardPoints;
// //       final newPoints = state.points + questPoints;
// //       final newXp = state.xp + questPoints;
// //       final newLevel = (newXp ~/ 100) + 1;

// //       emit(state.copyWith(points: newPoints, xp: newXp, level: newLevel, quests: updatedQuests));
// //     });
// //   }
// //   static GamificationState _initialState() {
// //     final initialQuests = [
// //       Quest(
// //           id: 'q1',
// //           title: 'Complete first test',
// //           description: 'Record and upload your first test video',
// //           rewardPoints: 20),
// //       Quest(
// //           id: 'q2',
// //           title: 'Reach 100 points',
// //           description: 'Earn 100 points by completing tests',
// //           rewardPoints: 50),
// //     ];

// //     return GamificationState(
// //       points: 0,
// //       xp: 0,
// //       badges: [],
// //       level: 1,
// //       quests: initialQuests,
// //     );
// //   } 
// // }

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'models/quest.dart'; // Adjust import as per your structure
// import 'widgets/quest_widget.dart'; // Use if widgets/quest_widget.dart exports QuestWidget

// // Utility: Update Firestore user gamification doc
// Future<void> updateGamification(String userId, Map<String, dynamic> updates) async {
//   await FirebaseFirestore.instance.collection('users').doc(userId).update(updates);
// }

// // --- EVENTS ---
// abstract class GamificationEvent {}

// class AddPoints extends GamificationEvent {
//   final int points;
//   final String userId;
//   AddPoints(this.points, this.userId);
// }

// class AddBadge extends GamificationEvent {
//   final String badge;
//   final String userId;
//   AddBadge(this.badge, this.userId);
// }

// class StartQuest extends GamificationEvent {
//   final String questId;
//   final String userId;
//   StartQuest(this.questId, this.userId);
// }

// class CompleteQuest extends GamificationEvent {
//   final String questId;
//   final String userId;
//   CompleteQuest(this.questId, this.userId);
// }

// // --- STATE ---
// class GamificationState {
//   final int points;
//   final int xp;
//   final List<String> badges;
//   final int level;
//   final List<Quest> quests;
//   GamificationState({
//     required this.points,
//     required this.xp,
//     required this.badges,
//     required this.level,
//     required this.quests,
//   });

//   GamificationState copyWith({
//     int? points,
//     int? xp,
//     List<String>? badges,
//     int? level,
//     List<Quest>? quests,
//   }) {
//     return GamificationState(
//       points: points ?? this.points,
//       xp: xp ?? this.xp,
//       badges: badges ?? this.badges,
//       level: level ?? this.level,
//       quests: quests ?? this.quests,
//     );
//   }

//   // Optional: initial state factory
//   static GamificationState initialState(List<Quest> starterQuests) => GamificationState(
//     points: 0,
//     xp: 0,
//     badges: [],
//     level: 1,
//     quests: starterQuests,
//   );
// }

// // --- BLOC ---
// class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
//   late final Stream<DocumentSnapshot> _firestoreStream;
//   late final StreamSubscription _firestoreSub;

//   GamificationBloc(String userId, {List<Quest>? starterQuests})
//       : super(GamificationState.initialState(starterQuests ?? [
//           // Example starter quests:
//           Quest(
//             id: 'q1',
//             title: 'Complete first test',
//             description: 'Record and upload your first test video',
//             rewardPoints: 20,
//             status: QuestStatus.locked,
//           ),
//           Quest(
//             id: 'q2',
//             title: 'Reach 100 points',
//             description: 'Earn 100 points by completing tests',
//             rewardPoints: 50,
//             status: QuestStatus.locked,
//           ),
//         ])) {
//     // Firestore sync
//     _firestoreStream =
//         FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
//     _firestoreSub = _firestoreStream.listen((snapshot) {
//       final data = snapshot.data() as Map<String, dynamic>?;
//       if (data != null) {
//         emit(
//           state.copyWith(
//             points: data['points'] ?? state.points,
//             xp: data['xp'] ?? state.xp,
//             badges: (data['badges'] as List<dynamic>?)?.cast<String>() ?? state.badges,
//             level: data['level'] ?? state.level,
//             quests: (data['quests'] as List<dynamic>?)
//                 ?.map((q) => Quest.fromMap(q))
//                 .toList() ??
//                 state.quests,
//           ),
//         );
//       }
//     });

//     on<AddPoints>((event, emit) async {
//       final newPoints = state.points + event.points;
//       final newXp = state.xp + event.points;
//       final newLevel = (newXp ~/ 100) + 1;
//       await updateGamification(event.userId, {
//         'points': newPoints,
//         'xp': newXp,
//         'level': newLevel,
//       });
//       emit(state.copyWith(points: newPoints, xp: newXp, level: newLevel));
//     });

//     on<AddBadge>((event, emit) async {
//       final newBadges = List<String>.from(state.badges)..add(event.badge);
//       await updateGamification(event.userId, {'badges': newBadges});
//       emit(state.copyWith(badges: newBadges));
//     });

//     on<StartQuest>((event, emit) async {
//       final updatedQuests = state.quests.map((q) {
//         if (q.id == event.questId) {
//           return q.copyWith(status: QuestStatus.inProgress);
//         }
//         return q;
//       }).toList();
//       await updateGamification(event.userId, {
//         'quests': updatedQuests.map((q) => q.toMap()).toList(),
//       });
//       emit(state.copyWith(quests: updatedQuests));
//     });

//     on<CompleteQuest>((event, emit) async {
//       final updatedQuests = state.quests.map((q) {
//         if (q.id == event.questId) {
//           return q.copyWith(status: QuestStatus.completed);
//         }
//         return q;
//       }).toList();
//       // Add quest points to points and xp
//       final questPoints = updatedQuests.firstWhere((q) => q.id == event.questId).rewardPoints;
//       final newPoints = state.points + questPoints;
//       final newXp = state.xp + questPoints;
//       final newLevel = (newXp ~/ 100) + 1;
//       await updateGamification(event.userId, {
//         'quests': updatedQuests.map((q) => q.toMap()).toList(),
//         'points': newPoints,
//         'xp': newXp,
//         'level': newLevel,
//       });
//       emit(state.copyWith(
//           points: newPoints, xp: newXp, level: newLevel, quests: updatedQuests));
//     });
//   }

//   @override
//   Future<void> close() async {
//     await _firestoreSub.cancel();
//     return super.close();
//   }
// }




// gamification_bloc.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/quest.dart'; // ensure Quest has fromMap/toMap/copyWith implementation
// import 'widgets/quest_widget.dart'; // only needed where you use the widget (not required in the bloc file)

// Utility: Update Firestore user gamification doc
Future<void> updateGamification(String userId, Map<String, dynamic> updates) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update(updates);
}

// --- EVENTS ---
abstract class GamificationEvent {}

class AddPoints extends GamificationEvent {
  final int points;
  final String userId;
  AddPoints(this.points, this.userId);
}

class AddBadge extends GamificationEvent {
  final String badge;
  final String userId;
  AddBadge(this.badge, this.userId);
}

class StartQuest extends GamificationEvent {
  final String questId;
  final String userId;
  StartQuest(this.questId, this.userId);
}

class CompleteQuest extends GamificationEvent {
  final String questId;
  final String userId;
  CompleteQuest(this.questId, this.userId);
}

// Private event used to update state from Firestore snapshot safely
class _FirestoreUpdated extends GamificationEvent {
  final Map<String, dynamic> data;
  _FirestoreUpdated(this.data);
}

// --- STATE ---
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
    required this.quests,
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

  // Optional: initial state factory
  static GamificationState initialState(List<Quest> starterQuests) => GamificationState(
    points: 0,
    xp: 0,
    badges: [],
    level: 1,
    quests: starterQuests,
  );
}

// --- BLOC ---
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final String userId;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _firestoreStream;
  late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _firestoreSub;

  GamificationBloc(this.userId, {List<Quest>? starterQuests})
      : super(GamificationState.initialState(starterQuests ?? [
          // Example starter quests:
          Quest(
            id: 'q1',
            title: 'Complete first test',
            description: 'Record and upload your first test video',
            rewardPoints: 20,
            status: QuestStatus.locked,
          ),
          Quest(
            id: 'q2',
            title: 'Reach 100 points',
            description: 'Earn 100 points by completing tests',
            rewardPoints: 50,
            status: QuestStatus.locked,
          ),
        ])) {
    // Listen to Firestore and convert updates into an internal event
    _firestoreStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    _firestoreSub = _firestoreStream.listen((snapshot) {
      final data = snapshot.data();
      if (data != null) {
        add(_FirestoreUpdated(data));
      }
    });

    // Handle firestore updates (safe place to call emit)
    on<_FirestoreUpdated>((event, emit) {
      final data = event.data;
      // safe parsing with defaults
      final points = (data['points'] is int) ? data['points'] as int : (data['points'] is num ? (data['points'] as num).toInt() : state.points);
      final xp = (data['xp'] is int) ? data['xp'] as int : (data['xp'] is num ? (data['xp'] as num).toInt() : state.xp);
      final level = (data['level'] is int) ? data['level'] as int : state.level;

      final badges = (data['badges'] as List<dynamic>?)?.cast<String>() ?? state.badges;

      final questsList = (data['quests'] as List<dynamic>?)
          ?.map((q) {
            if (q is Map<String, dynamic>) {
              return Quest.fromMap(q);
            } else {
              return null;
            }
          })
          .whereType<Quest>()
          .toList() ?? state.quests;

      emit(state.copyWith(points: points, xp: xp, level: level, badges: badges, quests: questsList));
    });

    // AddPoints
    on<AddPoints>((event, emit) async {
      final newPoints = state.points + event.points;
      final newXp = state.xp + event.points;
      final newLevel = (newXp ~/ 100) + 1;
      await updateGamification(event.userId, {
        'points': newPoints,
        'xp': newXp,
        'level': newLevel,
      });
      emit(state.copyWith(points: newPoints, xp: newXp, level: newLevel));
    });

    // AddBadge
    on<AddBadge>((event, emit) async {
      final newBadges = List<String>.from(state.badges)..add(event.badge);
      await updateGamification(event.userId, {'badges': newBadges});
      emit(state.copyWith(badges: newBadges));
    });

    // StartQuest
    on<StartQuest>((event, emit) async {
      final updatedQuests = state.quests.map((q) {
        if (q.id == event.questId) {
          return q.copyWith(status: QuestStatus.inProgress);
        }
        return q;
      }).toList();
      await updateGamification(event.userId, {
        'quests': updatedQuests.map((q) => q.toMap()).toList(),
      });
      emit(state.copyWith(quests: updatedQuests));
    });

    // CompleteQuest
    on<CompleteQuest>((event, emit) async {
      final updatedQuests = state.quests.map((q) {
        if (q.id == event.questId) {
          return q.copyWith(status: QuestStatus.completed);
        }
        return q;
      }).toList();
      final finishedQuest = updatedQuests.firstWhere((q) => q.id == event.questId);
      final questPoints = finishedQuest.rewardPoints;
      final newPoints = state.points + questPoints;
      final newXp = state.xp + questPoints;
      final newLevel = (newXp ~/ 100) + 1;
      await updateGamification(event.userId, {
        'quests': updatedQuests.map((q) => q.toMap()).toList(),
        'points': newPoints,
        'xp': newXp,
        'level': newLevel,
      });
      emit(state.copyWith(points: newPoints, xp: newXp, level: newLevel, quests: updatedQuests));
    });
  }

  @override
  Future<void> close() async {
    await _firestoreSub.cancel();
    return super.close();
  }
}
