import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byline/views/shared/empty_state_widget.dart';

void main() {
  testWidgets('EmptyStateWidget renders title and message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            title: 'No Matches',
            message: 'No articles match your query.',
          ),
        ),
      ),
    );

    expect(find.text('No Matches'), findsOneWidget);
    expect(find.text('No articles match your query.'), findsOneWidget);
  });
}
