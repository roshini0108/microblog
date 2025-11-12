import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microblog/main.dart';

void main() {
  testWidgets('App shows title and FAB', (WidgetTester tester) async {
    // Launch app
    await tester.pumpWidget(const MicroblogApp());
    await tester.pumpAndSettle();

    // Check for app title in AppBar
    expect(find.text('Microblog'), findsOneWidget);

    // Check for floating action button
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Check for compose icon inside FAB
    expect(find.byIcon(Icons.create), findsOneWidget);
  });

  testWidgets('Posting from top composer adds a tweet to the feed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MicroblogApp());
    await tester.pumpAndSettle();

    // Find the top text field where user types tweet
    final composer = find.byWidgetPredicate((widget) {
      return widget is TextField &&
          widget.decoration?.hintText == "What's happening?";
    });

    expect(composer, findsOneWidget);

    // Type a tweet
    const tweetText = 'Hello from widget test!';
    await tester.enterText(composer, tweetText);
    await tester.pumpAndSettle();

    // Tap the 'Tweet' button
    final tweetButton = find.widgetWithText(TextButton, 'Tweet');
    expect(tweetButton, findsOneWidget);

    await tester.tap(tweetButton);
    await tester.pumpAndSettle();

    // Verify tweet appears in feed
    expect(find.text(tweetText), findsOneWidget);

    // Verify snack bar confirmation
    expect(find.text('Posted'), findsOneWidget);
  });

  testWidgets('Quick compose (FAB) posts a tweet via bottom sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MicroblogApp());
    await tester.pumpAndSettle();

    // Tap floating action button
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Find the bottom sheet text field
    final allTextFields = find.byType(TextField);
    expect(allTextFields, findsWidgets);

    // Select the last TextField (in bottom sheet)
    final bottomSheetField = allTextFields.evaluate().last;
    final bottomSheetFinder = find.byWidget(bottomSheetField.widget);

    // Enter tweet text
    const quickTweet = 'Quick compose tweet';
    await tester.enterText(bottomSheetFinder, quickTweet);
    await tester.pumpAndSettle();

    // Tap 'Tweet' button in bottom sheet
    final bottomTweetButton = find.widgetWithText(ElevatedButton, 'Tweet');
    expect(bottomTweetButton, findsOneWidget);
    await tester.tap(bottomTweetButton);
    await tester.pumpAndSettle();

    // Verify new tweet appears in feed
    expect(find.text(quickTweet), findsOneWidget);
  });
}
