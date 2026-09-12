import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum AudioBriefingState { stopped, playing, paused }

/// Service responsible for synthesizing and speaking daily briefings using
/// the device's native speech synthesis engine.
class AudioBriefingService extends ChangeNotifier {
  final FlutterTts _flutterTts;
  AudioBriefingState _state = AudioBriefingState.stopped;
  String? _currentText;
  double _progress = 0.0;

  AudioBriefingService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts() {
    _initTts();
  }

  AudioBriefingState get state => _state;
  bool get isPlaying => _state == AudioBriefingState.playing;
  bool get isPaused => _state == AudioBriefingState.paused;
  bool get isStopped => _state == AudioBriefingState.stopped;
  double get progress => _progress;

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _state = AudioBriefingState.playing;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _state = AudioBriefingState.stopped;
      _progress = 1.0;
      notifyListeners();
    });

    _flutterTts.setPauseHandler(() {
      _state = AudioBriefingState.paused;
      notifyListeners();
    });

    _flutterTts.setContinueHandler(() {
      _state = AudioBriefingState.playing;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('AudioBriefingService TTS error: $msg');
      _state = AudioBriefingState.stopped;
      notifyListeners();
    });

    _flutterTts.setProgressHandler((text, start, end, word) {
      if (text.isNotEmpty) {
        _progress = (end / text.length).clamp(0.0, 1.0);
        notifyListeners();
      }
    });

    // Professional editorial speech configuration
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _currentText = cleanText;
    _progress = 0.0;
    _state = AudioBriefingState.playing;
    notifyListeners();

    await _flutterTts.stop();
    await _flutterTts.speak(cleanText);
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _state = AudioBriefingState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_state == AudioBriefingState.paused && _currentText != null) {
      _state = AudioBriefingState.playing;
      notifyListeners();
      await _flutterTts.speak(_currentText!);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _state = AudioBriefingState.stopped;
    _progress = 0.0;
    notifyListeners();
  }

  Future<void> togglePlay(String text) async {
    if (isPlaying) {
      await pause();
    } else if (isPaused) {
      await resume();
    } else {
      await speak(text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
