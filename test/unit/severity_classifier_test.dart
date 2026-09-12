import 'package:flutter_test/flutter_test.dart';
import 'package:byline/core/severity_classifier.dart';

void main() {
  group('SeverityClassifier tests', () {
    test('Classifies high severity keywords correctly', () {
      final level1 = SeverityClassifier.classifySeverity(
        'Bear attack kills hiker in national park',
        'Emergency services responded to a tragic incident.',
      );
      expect(level1, equals(SeverityLevel.high));

      final level2 = SeverityClassifier.classifySeverity(
        'Explosion reported at industrial plant',
        'Firefighters are battling the blaze.',
      );
      expect(level2, equals(SeverityLevel.high));
    });

    test('Classifies medium severity keywords correctly', () {
      final level = SeverityClassifier.classifySeverity(
        'Government issues warning over inflation risk',
        'Regulators launched an official investigation into trade practices.',
      );
      expect(level, equals(SeverityLevel.medium));
    });

    test('Classifies low severity for general technology news', () {
      final level = SeverityClassifier.classifySeverity(
        'Google Just Made This Premium Gemini Feature Free For Everyone',
        'Google announced that Daily Brief will be free for all users.',
      );
      expect(level, equals(SeverityLevel.low));
    });
  });
}
