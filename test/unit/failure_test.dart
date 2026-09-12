import 'package:flutter_test/flutter_test.dart';
import 'package:byline/core/error/failure.dart';

void main() {
  group('Failure hierarchy tests', () {
    test('NoInternetFailure default message', () {
      const failure = NoInternetFailure();
      expect(failure.message, contains('No internet connection'));
    });

    test('TimeoutFailure default message', () {
      const failure = TimeoutFailure();
      expect(failure.message, contains('timed out'));
    });

    test('InvalidDataFailure custom message', () {
      const failure = InvalidDataFailure('Custom server error 404');
      expect(failure.message, equals('Custom server error 404'));
    });

    test('UnknownFailure default message', () {
      const failure = UnknownFailure();
      expect(failure.message, contains('unexpected error'));
    });
  });
}
