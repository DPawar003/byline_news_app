import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byline/views/main_shell.dart';

void main() {
  Widget buildTestApp() {
    return const MaterialApp(
      home: MainShell(
        screens: [
          Center(child: Text('HOME_TAB_CONTENT')),
          Center(child: Text('SHORTS_TAB_CONTENT')),
          Center(child: Text('PORTFOLIO_TAB_CONTENT')),
          Center(child: Text('PREMIUM_TAB_CONTENT')),
        ],
      ),
    );
  }

  group('MainShell bottom bar & back navigation tests', () {
    testWidgets('Starts on Home tab by default', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('HOME_TAB_CONTENT'), findsOneWidget);
    });

    testWidgets('Tapping Shorts tab and pressing back returns to Home tab instead of exiting', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Tap on Byline Shorts (second item)
      await tester.tap(find.text('Byline Shorts'));
      await tester.pump();

      // Verify we are on Shorts tab
      final bottomNav = tester.widget<BottomNavigationBar>(find.byKey(const Key('byline_bottom_nav')));
      expect(bottomNav.currentIndex, equals(1));

      // Simulate system back button press
      final popResult = await tester.binding.handlePopRoute();
      await tester.pump();

      // Verify back event was consumed (did not exit app)
      expect(popResult, isTrue);

      // Verify we returned to Home tab
      final updatedNav = tester.widget<BottomNavigationBar>(find.byKey(const Key('byline_bottom_nav')));
      expect(updatedNav.currentIndex, equals(0));
    });

    testWidgets('Navigating Home -> Portfolio -> Premium and pressing back navigates history back to Home', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Tap Portfolio (index 2)
      await tester.tap(find.text('Portfolio'));
      await tester.pump();
      expect(tester.widget<BottomNavigationBar>(find.byKey(const Key('byline_bottom_nav'))).currentIndex, equals(2));

      // Tap Premium (index 3)
      await tester.tap(find.text('Premium'));
      await tester.pump();
      expect(tester.widget<BottomNavigationBar>(find.byKey(const Key('byline_bottom_nav'))).currentIndex, equals(3));

      // First back press: should return to Portfolio (index 2)
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(tester.widget<BottomNavigationBar>(find.byKey(const Key('byline_bottom_nav'))).currentIndex, equals(2));

      // Second back press: should return to Home (index 0)
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(tester.widget<BottomNavigationBar>(find.byKey(const Key('byline_bottom_nav'))).currentIndex, equals(0));
    });

    testWidgets('Pressing back on Home tab shows confirmation snackbar and does not immediately escape', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Press back once while on Home tab
      final popResult = await tester.binding.handlePopRoute();
      await tester.pump();

      // Back is consumed by PopScope
      expect(popResult, isTrue);

      // SnackBar with warning appears
      expect(find.text('Press back again to exit'), findsOneWidget);
    });
  });
}
