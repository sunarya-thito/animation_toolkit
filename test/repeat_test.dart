import 'package:animation_toolkit/animation_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RepeatedAnimationBuilder animates correctly',
      (WidgetTester tester) async {
    const start = 0.0;
    const end = 1.0;
    const duration = Duration(seconds: 1);

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: RepeatedAnimationBuilder<double>(
          start: start,
          end: end,
          duration: duration,
          builder: (context, value, child) {
            return Text(value.toString());
          },
        ),
      ),
    );

    // Verify the start value is shown initially
    expect(find.text(start.toString()), findsOneWidget);

    // Advance time to simulate the animation progress
    await tester.pump(duration);
    expect(find.text(end.toString()), findsOneWidget);

    // The animation should loop, but for simplicity, we'll stop the test here.
  });

  testWidgets('RepeatedAnimationBuilder respects play parameter',
      (WidgetTester tester) async {
    const start = 0.0;
    const end = 1.0;
    const duration = Duration(seconds: 1);

    // Build the widget with play = false, so animation shouldn't start automatically
    await tester.pumpWidget(
      MaterialApp(
        home: RepeatedAnimationBuilder<double>(
          start: start,
          end: end,
          duration: duration,
          play: false,
          builder: (context, value, child) {
            return Text(value.toString());
          },
        ),
      ),
    );

    // Verify the widget shows the start value initially
    expect(find.text(start.toString()), findsOneWidget);

    // Trigger the animation by setting play to true
    await tester.pumpWidget(
      MaterialApp(
        home: RepeatedAnimationBuilder<double>(
          start: start,
          end: end,
          duration: duration,
          play: true, // Animation should now play
          builder: (context, value, child) {
            return Text(value.toString());
          },
        ),
      ),
    );

    // Advance time to allow the animation to complete its first cycle
    await tester.pump(duration);
    expect(find.text(end.toString()), findsOneWidget);
  });

  testWidgets('RepeatedAnimationBuilder handles reverse correctly',
      (WidgetTester tester) async {
    const start = 0.0;
    const end = 1.0;
    const duration = Duration(seconds: 1);

    // Build the widget with reverse mode
    await tester.pumpWidget(
      MaterialApp(
        home: RepeatedAnimationBuilder<double>(
          start: start,
          end: end,
          duration: duration,
          mode: RepeatMode.reverse,
          builder: (context, value, child) {
            return Text(value.toString());
          },
        ),
      ),
    );

    // Verify the start value before the animation begins
    expect(find.text(start.toString()), findsOneWidget);

    // Advance time to simulate forward animation
    await tester.pump(duration);
    expect(find.text(end.toString()), findsOneWidget);

    // The animation should reverse now, so advance time to simulate reverse animation
    await tester.pump(duration);
    expect(find.text(start.toString()), findsOneWidget);
  });

  testWidgets('RepeatedAnimationBuilder handles pingPong mode correctly',
      (WidgetTester tester) async {
    const start = 0.0;
    const end = 1.0;
    const duration = Duration(seconds: 1);

    // Build the widget with pingPong mode
    await tester.pumpWidget(
      MaterialApp(
        home: RepeatedAnimationBuilder<double>(
          start: start,
          end: end,
          duration: duration,
          mode: RepeatMode.pingPong,
          builder: (context, value, child) {
            print(value);
            return Text(value.toString());
          },
        ),
      ),
    );

    // Verify the start value before the animation begins
    expect(find.text(start.toString()), findsOneWidget);

    // Advance time to simulate the forward animation
    await tester.pump(duration);
    expect(find.text(end.toString()), findsOneWidget);

    // The animation should reverse now, so advance time to simulate the reverse animation
    await tester.pump(duration - const Duration(milliseconds: 1));
    expect(find.text(start.toString()), findsOneWidget);

    // The animation should go forward again, so advance time to simulate forward animation
    await tester.pump(duration);
    expect(find.text(end.toString()), findsOneWidget);
  });
}
