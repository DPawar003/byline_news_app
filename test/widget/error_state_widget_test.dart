import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byline/views/shared/error_state_widget.dart';
import 'package:byline/core/error/failure.dart';

void main() {
  testWidgets('ErrorStateWidget renders message and triggers onRetry when button is tapped', (WidgetTester tester) async {
    bool retryTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorStateWidget(
            failure: const NoInternetFailure("No internet connection. Please check your network."),
            onRetry: () {
              retryTriggered = true;
            },
          ),
        ),
      ),
    );

    // Verify error text is displayed
    expect(find.text("Connection Interrupted"), findsOneWidget);
    expect(find.text("No internet connection. Please check your network."), findsOneWidget);
    expect(find.text("Try Again"), findsOneWidget);

    // Tap retry button
    await tester.tap(find.text("Try Again"));
    await tester.pump();

    // Verify callback was invoked
    expect(retryTriggered, isTrue);
  });
}
