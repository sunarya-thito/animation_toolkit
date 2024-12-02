import 'package:animation_toolkit/animation_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedValueBuilder Tests', () {
    testWidgets('Animates from initialValue to target value', (tester) async {
      double lerp(double a, double b, double t) => a + (b - a) * t;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedValueBuilder<double>(
            initialValue: 0.0,
            value: 100.0,
            duration: const Duration(seconds: 2),
            lerp: lerp,
            builder: (context, value, child) {
              return Text(value.toString());
            },
          ),
        ),
      );

      // Initial value
      expect(find.text('0.0'), findsOneWidget);

      // Advance animation halfway
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('50.0'), findsOneWidget);

      // Complete animation
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('100.0'), findsOneWidget);
    });

    testWidgets('Handles onEnd callback', (tester) async {
      bool animationEnded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedValueBuilder<double>(
            initialValue: 0.0,
            value: 100.0,
            duration: const Duration(seconds: 1),
            curve: Curves.linear,
            onEnd: (value) {
              animationEnded = true;
              expect(value, 100.0);
            },
            builder: (context, value, child) {
              return Text(value.toString());
            },
          ),
        ),
      );

      // Complete the animation
      await tester.pump(const Duration(seconds: 1, milliseconds: 1));
      expect(animationEnded, isTrue);
    });

    testWidgets('Supports animationBuilder constructor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedValueBuilder<double>.animation(
            initialValue: 0.0,
            value: 50.0,
            duration: const Duration(seconds: 2),
            builder: (context, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return Text(animation.value.toString());
                },
              );
            },
          ),
        ),
      );

      // Initial value
      expect(find.text('0.0'), findsOneWidget);

      // Advance animation halfway
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('25.0'), findsOneWidget);

      // Complete animation
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('50.0'), findsOneWidget);
    });

    testWidgets('Updates correctly when target value changes', (tester) async {
      final widget = MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return AnimatedValueBuilder<double>(
              initialValue: 0.0,
              value: 50.0,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Text(value.toString());
              },
            );
          },
        ),
      );

      await tester.pumpWidget(widget);

      // Initial value
      expect(find.text('0.0'), findsOneWidget);

      // Advance animation halfway
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('25.0'), findsOneWidget);

      // Change target value
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedValueBuilder<double>(
            initialValue: 25.0,
            value: 100.0,
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Text(value.toString());
            },
          ),
        ),
      );

      // Animation resets and animates to the new target
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('62.5'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('100.0'), findsOneWidget);
    });

    test('AnimatableValue computes values correctly', () {
      final animatable = AnimatableValue<double>(
        start: 0.0,
        end: 100.0,
        lerp: (a, b, t) => a + (b - a) * t,
      );

      expect(animatable.transform(0.0), 0.0);
      expect(animatable.transform(0.5), 50.0);
      expect(animatable.transform(1.0), 100.0);
    });

    test('AnimatableValue equality and hashCode', () {
      double lerper(double a, double b, double t) => a + (b - a) * t;
      final animatable1 = AnimatableValue<double>(
        start: 0.0,
        end: 100.0,
        lerp: lerper,
      );

      final animatable2 = AnimatableValue<double>(
        start: 0.0,
        end: 100.0,
        lerp: lerper,
      );

      expect(animatable1, equals(animatable2));
      expect(animatable1.hashCode, equals(animatable2.hashCode));
    });
  });
}
