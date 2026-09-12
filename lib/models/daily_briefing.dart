import 'article.dart';

class BriefingItem {
  final Article article;
  final String attributionTag; // "Why you're seeing this"
  final double matchScore;
  int? userFeedback; // 1 = thumbs up, -1 = thumbs down, null = none

  BriefingItem({
    required this.article,
    required this.attributionTag,
    required this.matchScore,
    this.userFeedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'article': article.toJson(),
      'attributionTag': attributionTag,
      'matchScore': matchScore,
      'userFeedback': userFeedback,
    };
  }

  factory BriefingItem.fromJson(Map<dynamic, dynamic> json) {
    final articleData = json['article'];
    final Article parsedArticle;
    if (articleData is Map) {
      parsedArticle = Article.fromJson(Map<String, dynamic>.from(articleData));
    } else {
      parsedArticle = const Article(
        id: '',
        title: 'Untitled',
        description: '',
        content: '',
        url: '',
        imageUrl: '',
        publishedAt: '',
        sourceName: '',
        sourceUrl: '',
      );
    }

    return BriefingItem(
      article: parsedArticle,
      attributionTag: json['attributionTag'] as String? ?? '',
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.0,
      userFeedback: json['userFeedback'] as int?,
    );
  }
}

class DailyBriefing {
  final String id;
  final DateTime date;
  final String title;
  final String executiveNarrative; // Cohesive synthesized briefing
  final int audioDurationSeconds;
  final List<BriefingItem> items;

  const DailyBriefing({
    required this.id,
    required this.date,
    required this.title,
    required this.executiveNarrative,
    required this.audioDurationSeconds,
    required this.items,
  });

  String get formattedAudioDuration {
    final mins = audioDurationSeconds ~/ 60;
    final secs = audioDurationSeconds % 60;
    return '${mins}m ${secs > 0 ? '${secs}s' : ''} listen';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'executiveNarrative': executiveNarrative,
      'audioDurationSeconds': audioDurationSeconds,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  factory DailyBriefing.fromJson(Map<dynamic, dynamic> json) {
    return DailyBriefing(
      id: json['id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      title: json['title'] as String? ?? 'Your Morning Briefing',
      executiveNarrative: json['executiveNarrative'] as String? ?? '',
      audioDurationSeconds: json['audioDurationSeconds'] as int? ?? 180,
      items: (json['items'] as List?)
              ?.whereType<Map>()
              .map((e) => BriefingItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}
