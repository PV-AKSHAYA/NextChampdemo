// models/quest.dart

enum QuestStatus { locked, inProgress, completed }

extension QuestStatusExtension on QuestStatus {
  String toShortString() {
    switch (this) {
      case QuestStatus.locked:
        return 'locked';
      case QuestStatus.inProgress:
        return 'inProgress';
      case QuestStatus.completed:
        return 'completed';
    }
  }

  static QuestStatus fromString(String? s) {
    switch (s) {
      case 'inProgress':
        return QuestStatus.inProgress;
      case 'completed':
        return QuestStatus.completed;
      case 'locked':
      default:
        return QuestStatus.locked;
    }
  }
}

class Quest {
  final String id;
  final String title;
  final String description;
  final int rewardPoints;
  final QuestStatus status;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoints,
    this.status = QuestStatus.locked,
  });

  /// Create a copy with optional changes (immutable pattern).
  Quest copyWith({
    String? id,
    String? title,
    String? description,
    int? rewardPoints,
    QuestStatus? status,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      status: status ?? this.status,
    );
  }

  /// Convert model -> map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rewardPoints': rewardPoints,
      'status': status.toShortString(),
    };
  }

  /// Create model from Firestore map
  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: (map['id'] as String?) ?? (map['ID'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      rewardPoints: (map['rewardPoints'] is num)
          ? (map['rewardPoints'] as num).toInt()
          : (int.tryParse((map['rewardPoints'] ?? '').toString()) ?? 0),
      status: QuestStatusExtension.fromString((map['status'] as String?)),
    );
  }

  @override
  String toString() {
    return 'Quest(id: $id, title: $title, rewardPoints: $rewardPoints, status: ${status.toShortString()})';
  }

  @override
  bool operator ==(Object other) {
    return other is Quest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
