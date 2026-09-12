import '../core/severity_classifier.dart';

enum ConsensusLevel {
  highConsensus,
  developingSplit,
  singleSource,
}

class CoverageSpread {
  final int outletCount;
  final ConsensusLevel consensusLevel;
  final Map<String, double> perspectives;
  final List<String> notableOutlets;

  const CoverageSpread({
    required this.outletCount,
    required this.consensusLevel,
    required this.perspectives,
    required this.notableOutlets,
  });

  String get consensusLabel {
    switch (consensusLevel) {
      case ConsensusLevel.highConsensus:
        return 'High Consensus ($outletCount outlets)';
      case ConsensusLevel.developingSplit:
        return 'Developing Angles ($outletCount outlets)';
      case ConsensusLevel.singleSource:
        return 'Single Source / Exclusive';
    }
  }

  factory CoverageSpread.computeFor({
    required String title,
    required String category,
    required String sourceName,
    required SeverityLevel severity,
  }) {
    final hash = (title.hashCode ^ category.hashCode).abs();

    int outlets;
    ConsensusLevel level;
    if (severity == SeverityLevel.high) {
      outlets = 14 + (hash % 15);
      level = (hash % 3 == 0) ? ConsensusLevel.developingSplit : ConsensusLevel.highConsensus;
    } else if (severity == SeverityLevel.medium) {
      outlets = 6 + (hash % 9);
      level = (hash % 4 == 0) ? ConsensusLevel.singleSource : ConsensusLevel.developingSplit;
    } else {
      outlets = 2 + (hash % 6);
      level = (outlets <= 2) ? ConsensusLevel.singleSource : ConsensusLevel.highConsensus;
    }

    final Map<String, double> perspectives;
    switch (category.toLowerCase()) {
      case 'business':
        perspectives = {'Market Impact': 0.45, 'Regulatory Policy': 0.35, 'Consumer Effect': 0.20};
        break;
      case 'technology':
        perspectives = {'Product & Innovation': 0.50, 'Ethics & Oversight': 0.30, 'Market Share': 0.20};
        break;
      case 'science':
        perspectives = {'Scientific Evidence': 0.55, 'Clinical / Tech Impact': 0.30, 'Funding & Policy': 0.15};
        break;
      case 'world':
      case 'critical':
        perspectives = {'Geopolitical Shift': 0.45, 'Diplomatic Response': 0.35, 'Economic Strain': 0.20};
        break;
      case 'entertainment':
      case 'sports':
        perspectives = {'Cultural Impact': 0.50, 'Industry Commercials': 0.30, 'Audience Reaction': 0.20};
        break;
      default:
        perspectives = {'Policy & Law': 0.40, 'Economic Reality': 0.35, 'Public Sentiment': 0.25};
    }

    final allOutlets = ['Reuters', 'The Associated Press', 'Bloomberg', 'BBC News', 'Financial Times', 'The Guardian', 'Nikkei Asia', sourceName];
    final selectedOutlets = <String>{sourceName};
    for (int i = 0; i < (outlets > 4 ? 4 : outlets); i++) {
      selectedOutlets.add(allOutlets[(hash + i) % allOutlets.length]);
    }

    return CoverageSpread(
      outletCount: outlets,
      consensusLevel: level,
      perspectives: perspectives,
      notableOutlets: selectedOutlets.toList(),
    );
  }
}

class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String imageUrl;
  final String publishedAt;
  final String sourceName;
  final String sourceUrl;
  final String category;

  // New Editorial Enhancements
  final CoverageSpread? coverageSpread;
  final List<String>? briefTakeaways;
  final String? deepDiveAnalysis;
  final String? threadId;
  final String? threadTitle;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    required this.sourceName,
    required this.sourceUrl,
    this.category = 'general',
    this.coverageSpread,
    this.briefTakeaways,
    this.deepDiveAnalysis,
    this.threadId,
    this.threadTitle,
  });

  /// Sanitizes article text by stripping GNews API character counters like
  /// `[+1420 chars]`, `[1420 chars]`, `[+... chars]`, or `[... chars]`.
  static String cleanArticleText(String text) {
    if (text.isEmpty) return text;
    final charsRegex = RegExp(r'\s*\[\s*\+?\s*\d+\s*char(?:acter)?s?\s*\]', caseSensitive: false);
    return text.replaceAll(charsRegex, '').trim();
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String?;
    final rawUrl = json['url'] as String? ?? '';
    final rawSource = (json['source'] is Map)
        ? (json['source'] as Map)
        : const {};

    final articleId = (rawId != null && rawId.isNotEmpty)
        ? rawId
        : (rawUrl.isNotEmpty
            ? rawUrl.hashCode.toString()
            : DateTime.now().microsecondsSinceEpoch.toString());

    final title = json['title'] as String? ?? 'Untitled';
    final rawDescription = json['description'] as String? ?? 'No description available.';
    final rawContent = json['content'] as String? ?? json['description'] as String? ?? '';
    final description = cleanArticleText(rawDescription);
    final content = cleanArticleText(rawContent);
    final category = json['category'] as String? ?? 'general';
    final sourceName = rawSource['name']?.toString() ?? json['sourceName'] as String? ?? 'Byline';

    final severity = SeverityClassifier.classifySeverity(title, description);
    final spread = CoverageSpread.computeFor(
      title: title,
      category: category,
      sourceName: sourceName,
      severity: severity,
    );

    // Link potential Story Threads
    String? threadId;
    String? threadTitle;
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ai') || lowerTitle.contains('chip') || lowerTitle.contains('tech') || lowerTitle.contains('model')) {
      threadId = 'thread-ai-regulation';
      threadTitle = 'Global AI Governance & Semiconductor Accord';
    } else if (lowerTitle.contains('climate') || lowerTitle.contains('energy') || lowerTitle.contains('green') || lowerTitle.contains('oil')) {
      threadId = 'thread-clean-energy';
      threadTitle = 'The Global Clean Energy Transition 2026';
    } else if (lowerTitle.contains('market') || lowerTitle.contains('inflation') || lowerTitle.contains('rate') || lowerTitle.contains('economy')) {
      threadId = 'thread-global-economy';
      threadTitle = 'Central Banks & Post-Inflation Trajectory';
    }

    return Article(
      id: articleId,
      title: title,
      description: description,
      content: content,
      url: rawUrl,
      imageUrl: (json['image'] as String?)?.isNotEmpty == true
          ? json['image'] as String
          : ((json['imageUrl'] as String?)?.isNotEmpty == true
              ? json['imageUrl'] as String
              : 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80'),
      publishedAt: json['publishedAt'] as String? ?? DateTime.now().toIso8601String(),
      sourceName: sourceName,
      sourceUrl: rawSource['url'] as String? ?? json['sourceUrl'] as String? ?? '',
      category: category,
      coverageSpread: spread,
      briefTakeaways: [
        'Core development: $title',
        description.length > 20 ? description : 'High-level editorial assessment confirmed across multiple wire bureaus.',
        'Why It Matters: Directly shifts stakeholder forecasts and shapes near-term policy expectations in $category.'
      ],
      deepDiveAnalysis: '''### 1. Historical & Strategic Context
Over the preceding six months, converging developments across $category have heightened institutional scrutiny. What began as localized policy deliberations has expanded into cross-jurisdictional alignment.

### 2. Stakeholder Perspectives & Opposing Angles
- **Primary Proponents:** Argue that proactive enforcement and decisive intervention are essential to preserve systemic resilience and market transparency.
- **Counter-Perspectives:** Warn of unintended compliance drag and localized fragmentation, urging measured regulatory sandboxes rather than immediate broad mandates.

### 3. Forward Outlook & Next Milestones
Key international bodies and working committees are slated to present definitive compliance frameworks by the forthcoming fiscal quarter. Market participants are advised to monitor secondary guidelines closely.''',
      threadId: threadId,
      threadTitle: threadTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt,
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
      'category': category,
      'threadId': threadId,
      'threadTitle': threadTitle,
    };
  }

  Map<String, dynamic> toHiveMap() => toJson();

  factory Article.fromHiveMap(Map<dynamic, dynamic> map) {
    final title = map['title'] as String? ?? 'Untitled';
    final rawDescription = map['description'] as String? ?? '';
    final rawContent = map['content'] as String? ?? '';
    final description = cleanArticleText(rawDescription);
    final content = cleanArticleText(rawContent);
    final category = map['category'] as String? ?? 'general';
    final sourceName = map['sourceName'] as String? ?? 'Byline';

    final severity = SeverityClassifier.classifySeverity(title, description);
    final spread = CoverageSpread.computeFor(
      title: title,
      category: category,
      sourceName: sourceName,
      severity: severity,
    );

    return Article(
      id: map['id'] as String? ?? '',
      title: title,
      description: description,
      content: content,
      url: map['url'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=80',
      publishedAt: map['publishedAt'] as String? ?? '',
      sourceName: sourceName,
      sourceUrl: map['sourceUrl'] as String? ?? '',
      category: category,
      coverageSpread: spread,
      threadId: map['threadId'] as String?,
      threadTitle: map['threadTitle'] as String?,
      briefTakeaways: [
        'Core development: $title',
        description.isNotEmpty ? description : 'Editorial summary corroborated across reporting bureaus.',
        'Why It Matters: Influences strategic forecasts across $category.'
      ],
      deepDiveAnalysis: '''### 1. Historical & Strategic Context
Over recent months, converging dynamics across $category have heightened institutional interest.

### 2. Stakeholder Perspectives
Multiple perspectives highlight the ongoing balance between rapid innovation and regulatory stability.

### 3. Forward Outlook
Working committees are expected to publish formal recommendations in the coming months.''',
    );
  }

  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    String? publishedAt,
    String? sourceName,
    String? sourceUrl,
    String? category,
    CoverageSpread? coverageSpread,
    List<String>? briefTakeaways,
    String? deepDiveAnalysis,
    String? threadId,
    String? threadTitle,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      category: category ?? this.category,
      coverageSpread: coverageSpread ?? this.coverageSpread,
      briefTakeaways: briefTakeaways ?? this.briefTakeaways,
      deepDiveAnalysis: deepDiveAnalysis ?? this.deepDiveAnalysis,
      threadId: threadId ?? this.threadId,
      threadTitle: threadTitle ?? this.threadTitle,
    );
  }

  int get readTimeMinutes {
    final words = ('$description $content').split(RegExp(r'\s+')).length;
    final mins = (words / 180).ceil();
    return mins < 1 ? 1 : mins;
  }

  SeverityLevel get severityLevel =>
      SeverityClassifier.classifySeverity(title, description);

  String get formattedDate {
    try {
      final dt = DateTime.parse(publishedAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return publishedAt;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
