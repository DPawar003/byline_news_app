enum SeverityLevel {
  high,
  medium,
  low,
}

class SeverityClassifier {
  static const List<String> highSeverityKeywords = [
    'attack',
    'killed',
    'disaster',
    'war',
    'outbreak',
    'explosion',
    'crisis',
    'dead',
    'emergency',
    'fire',
    'crash',
    'shooting',
    'bomb',
    'fatal',
    'casualty',
    'tragedy',
    'victim',
    'flood',
    'earthquake',
    'hurricane',
  ];

  static const List<String> mediumSeverityKeywords = [
    'warning',
    'concern',
    'risk',
    'investigation',
    'controversy',
    'protest',
    'strike',
    'threat',
    'court',
    'legal',
    'sanction',
    'tension',
    'dispute',
    'claim',
    'lawsuit',
    'probe',
  ];

  static SeverityLevel classifySeverity(String title, String description) {
    final text = '$title $description';

    for (final word in highSeverityKeywords) {
      final regex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
      if (regex.hasMatch(text)) {
        return SeverityLevel.high;
      }
    }

    for (final word in mediumSeverityKeywords) {
      final regex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
      if (regex.hasMatch(text)) {
        return SeverityLevel.medium;
      }
    }

    return SeverityLevel.low;
  }
}
