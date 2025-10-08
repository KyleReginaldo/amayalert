enum ActivityType { post, alert, evacuation, rescue }

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String? location;
  final DateTime createdAt;
  final String userId;
  final String? userName;
  final Map<String, dynamic>? metadata;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.location,
    required this.createdAt,
    required this.userId,
    this.userName,
    this.metadata,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.post,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'],
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      userId: map['user_id'] ?? '',
      userName: map['user_name'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'user_name': userName,
      'metadata': metadata,
    };
  }
}

class ActivityStats {
  final int totalPosts;
  final int totalAlerts;
  final int totalEvacuations;
  final int totalRescues;
  final int totalActivities;

  const ActivityStats({
    required this.totalPosts,
    required this.totalAlerts,
    required this.totalEvacuations,
    required this.totalRescues,
    required this.totalActivities,
  });

  factory ActivityStats.fromMap(Map<String, dynamic> map) {
    return ActivityStats(
      totalPosts: map['total_posts'] ?? 0,
      totalAlerts: map['total_alerts'] ?? 0,
      totalEvacuations: map['total_evacuations'] ?? 0,
      totalRescues: map['total_rescues'] ?? 0,
      totalActivities: map['total_activities'] ?? 0,
    );
  }
}
