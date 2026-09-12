class UserInterestProfile {
  final String userId;
  final Map<String, double> topicWeights; // Explicit weights (0.0 to 1.0)
  final List<String> followedEntities; // Sub-topics or named entities
  final String depthPreference; // 'brief', 'standard', 'deepDive'
  final String tonePreference; // 'neutral', 'analytical', 'conversational'
  final int dailyTimeBudgetMinutes; // 5, 10, 20
  final Map<String, double> implicitWeights; // Updated by reading behavior
  final int totalArticlesRead;
  final Map<String, int> recentTopicReads; // Counts for fatigue calculation
  final List<String> fatigueExemptTopics; // Topics user pinned: "keep showing me this"
  final DateTime updatedAt;

  const UserInterestProfile({
    required this.userId,
    required this.topicWeights,
    required this.followedEntities,
    this.depthPreference = 'standard',
    this.tonePreference = 'analytical',
    this.dailyTimeBudgetMinutes = 10,
    this.implicitWeights = const {},
    this.totalArticlesRead = 0,
    this.recentTopicReads = const {},
    this.fatigueExemptTopics = const [],
    required this.updatedAt,
  });

  /// Calculates blended weight between explicit stated preference and implicit behavior.
  /// Starts at 60/40 (explicit/implicit), gradually shifting up to 30/70 as reads accrue.
  double getBlendedWeight(String topic) {
    final lowerTopic = topic.toLowerCase();
    final explicitWeight = topicWeights[lowerTopic] ?? 0.2;
    final implicitWeight = implicitWeights[lowerTopic] ?? explicitWeight;

    // Transition factor from 0.0 (new user) to 1.0 (seasoned user with >= 30 reads)
    final progress = (totalArticlesRead / 30.0).clamp(0.0, 1.0);
    final explicitRatio = 0.60 - (0.30 * progress); // 0.60 down to 0.30
    final implicitRatio = 1.0 - explicitRatio;      // 0.40 up to 0.70

    return (explicitWeight * explicitRatio) + (implicitWeight * implicitRatio);
  }

  /// Calculates fatigue penalty for a topic.
  /// If user has read >= 3 recent stories on this topic, weight is gently attenuated,
  /// unless user explicitly marked the topic as fatigue-exempt.
  double getFatigueAttenuation(String topic) {
    final lowerTopic = topic.toLowerCase();
    if (fatigueExemptTopics.contains(lowerTopic)) {
      return 1.0; // No penalty for exempt topics
    }

    final recentCount = recentTopicReads[lowerTopic] ?? 0;
    if (recentCount < 3) {
      return 1.0; // No penalty for first 2 reads
    }

    // Decay formula: 1 / (1 + 0.25 * (recentCount - 2))
    return 1.0 / (1.0 + (0.25 * (recentCount - 2)));
  }

  UserInterestProfile recordRead({
    required String topic,
    required int durationSeconds,
    bool? thumbsUp,
  }) {
    final lowerTopic = topic.toLowerCase();
    final currentImplicit = Map<String, double>.from(implicitWeights);
    final currentRecent = Map<String, int>.from(recentTopicReads);

    // Incremental reinforcement
    double delta = 0.05;
    if (thumbsUp == true) delta += 0.15;
    if (thumbsUp == false) delta -= 0.20;
    if (durationSeconds > 60) delta += 0.05;

    final prevWeight = currentImplicit[lowerTopic] ?? topicWeights[lowerTopic] ?? 0.5;
    currentImplicit[lowerTopic] = (prevWeight + delta).clamp(0.05, 1.0);

    currentRecent[lowerTopic] = (currentRecent[lowerTopic] ?? 0) + 1;

    return copyWith(
      implicitWeights: currentImplicit,
      recentTopicReads: currentRecent,
      totalArticlesRead: totalArticlesRead + 1,
      updatedAt: DateTime.now(),
    );
  }

  UserInterestProfile toggleFatigueExemption(String topic) {
    final lowerTopic = topic.toLowerCase();
    final currentExempt = List<String>.from(fatigueExemptTopics);
    if (currentExempt.contains(lowerTopic)) {
      currentExempt.remove(lowerTopic);
    } else {
      currentExempt.add(lowerTopic);
    }
    return copyWith(fatigueExemptTopics: currentExempt, updatedAt: DateTime.now());
  }

  UserInterestProfile copyWith({
    String? userId,
    Map<String, double>? topicWeights,
    List<String>? followedEntities,
    String? depthPreference,
    String? tonePreference,
    int? dailyTimeBudgetMinutes,
    Map<String, double>? implicitWeights,
    int? totalArticlesRead,
    Map<String, int>? recentTopicReads,
    List<String>? fatigueExemptTopics,
    DateTime? updatedAt,
  }) {
    return UserInterestProfile(
      userId: userId ?? this.userId,
      topicWeights: topicWeights ?? this.topicWeights,
      followedEntities: followedEntities ?? this.followedEntities,
      depthPreference: depthPreference ?? this.depthPreference,
      tonePreference: tonePreference ?? this.tonePreference,
      dailyTimeBudgetMinutes: dailyTimeBudgetMinutes ?? this.dailyTimeBudgetMinutes,
      implicitWeights: implicitWeights ?? this.implicitWeights,
      totalArticlesRead: totalArticlesRead ?? this.totalArticlesRead,
      recentTopicReads: recentTopicReads ?? this.recentTopicReads,
      fatigueExemptTopics: fatigueExemptTopics ?? this.fatigueExemptTopics,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'topicWeights': topicWeights,
      'followedEntities': followedEntities,
      'depthPreference': depthPreference,
      'tonePreference': tonePreference,
      'dailyTimeBudgetMinutes': dailyTimeBudgetMinutes,
      'implicitWeights': implicitWeights,
      'totalArticlesRead': totalArticlesRead,
      'recentTopicReads': recentTopicReads,
      'fatigueExemptTopics': fatigueExemptTopics,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserInterestProfile.fromJson(Map<dynamic, dynamic> json) {
    return UserInterestProfile(
      userId: json['userId'] as String? ?? '',
      topicWeights: (json['topicWeights'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ) ??
          {},
      followedEntities: (json['followedEntities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      depthPreference: json['depthPreference'] as String? ?? 'standard',
      tonePreference: json['tonePreference'] as String? ?? 'analytical',
      dailyTimeBudgetMinutes: json['dailyTimeBudgetMinutes'] as int? ?? 10,
      implicitWeights: (json['implicitWeights'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ) ??
          {},
      totalArticlesRead: json['totalArticlesRead'] as int? ?? 0,
      recentTopicReads: (json['recentTopicReads'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          {},
      fatigueExemptTopics: (json['fatigueExemptTopics'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
