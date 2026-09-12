import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byline/services/audio_briefing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_tts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'speak':
        case 'stop':
        case 'pause':
        case 'setSpeechRate':
        case 'setVolume':
        case 'setPitch':
          return 1;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('AudioBriefingService unit tests', () {
    test('Initial state is stopped with 0 progress', () {
      final service = AudioBriefingService();
      expect(service.state, equals(AudioBriefingState.stopped));
      expect(service.isPlaying, isFalse);
      expect(service.isPaused, isFalse);
      expect(service.isStopped, isTrue);
      expect(service.progress, equals(0.0));
      service.dispose();
    });

    test('Ignores empty or whitespace-only speak requests', () async {
      final service = AudioBriefingService();
      await service.speak('   ');
      expect(service.state, equals(AudioBriefingState.stopped));
      expect(service.isPlaying, isFalse);
      service.dispose();
    });

    test('Speaks non-empty text and transitions to playing', () async {
      final service = AudioBriefingService();
      await service.speak('Welcome to Byline Morning Dispatch.');
      expect(service.state, equals(AudioBriefingState.playing));
      expect(service.isPlaying, isTrue);
      service.dispose();
    });

    test('Pause and resume toggle state', () async {
      final service = AudioBriefingService();
      await service.speak('Welcome to Byline.');
      expect(service.isPlaying, isTrue);

      await service.pause();
      expect(service.isPaused, isTrue);

      await service.resume();
      expect(service.isPlaying, isTrue);

      await service.stop();
      expect(service.isStopped, isTrue);
      service.dispose();
    });
  });
}
