class ThreadEvent {
  final String id;
  final DateTime timestamp;
  final String headline;
  final String summary;
  final String source;
  final String impact; // e.g. 'Critical Milestone', 'Developing', 'Policy Shift', 'Context'
  final String? relatedArticleId;

  const ThreadEvent({
    required this.id,
    required this.timestamp,
    required this.headline,
    required this.summary,
    required this.source,
    this.impact = 'Critical Milestone',
    this.relatedArticleId,
  });

  factory ThreadEvent.fromJson(Map<dynamic, dynamic> json) {
    return ThreadEvent(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      headline: json['headline'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      source: json['source'] as String? ?? 'Byline Editorial',
      impact: json['impact'] as String? ?? 'Critical Milestone',
      relatedArticleId: json['relatedArticleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'headline': headline,
      'summary': summary,
      'source': source,
      'impact': impact,
      'relatedArticleId': relatedArticleId,
    };
  }

  String get formattedTimeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class StoryThread {
  final String id;
  final String title;
  final String topic;
  final String summary;
  final String category;
  final DateTime lastUpdated;
  final bool isFollowing;
  final int checkpointIndex; // Last event index user read up to
  final List<ThreadEvent> events;

  const StoryThread({
    required this.id,
    required this.title,
    required this.topic,
    required this.summary,
    required this.category,
    required this.lastUpdated,
    this.isFollowing = false,
    this.checkpointIndex = 0,
    required this.events,
  });

  int get unreadCount {
    if (events.isEmpty) return 0;
    final unread = events.length - (checkpointIndex + 1);
    return unread < 0 ? 0 : unread;
  }

  StoryThread copyWith({
    String? id,
    String? title,
    String? topic,
    String? summary,
    String? category,
    DateTime? lastUpdated,
    bool? isFollowing,
    int? checkpointIndex,
    List<ThreadEvent>? events,
  }) {
    return StoryThread(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isFollowing: isFollowing ?? this.isFollowing,
      checkpointIndex: checkpointIndex ?? this.checkpointIndex,
      events: events ?? this.events,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'summary': summary,
      'category': category,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isFollowing': isFollowing,
      'checkpointIndex': checkpointIndex,
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  factory StoryThread.fromJson(Map<dynamic, dynamic> json) {
    return StoryThread(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFollowing: json['isFollowing'] as bool? ?? false,
      checkpointIndex: json['checkpointIndex'] as int? ?? 0,
      events: (json['events'] as List?)
              ?.whereType<Map>()
              .map((e) => ThreadEvent.fromJson(e))
              .toList() ??
          [],
    );
  }
}
