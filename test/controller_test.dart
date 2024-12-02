import 'package:animation_toolkit/animation_toolkit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimationRequest Tests', () {
    test('Creates an AnimationRequest with correct properties', () {
      final request =
          AnimationRequest(100.0, const Duration(seconds: 2), Curves.easeIn);
      expect(request.target, 100.0);
      expect(request.duration, const Duration(seconds: 2));
      expect(request.curve, Curves.easeIn);
    });
  });

  group('AnimationRunner Tests', () {
    test('Progress is initialized correctly', () {
      final runner =
          AnimationRunner(0.0, 1.0, const Duration(seconds: 1), Curves.linear);
      expect(runner.progress, 0.0);
    });

    test('Interpolates correctly based on progress', () {
      final runner =
          AnimationRunner(0.0, 1.0, const Duration(seconds: 1), Curves.linear);
      runner.progress = 0.5;
      final interpolatedValue = runner.from +
          (runner.to - runner.from) * runner.curve.transform(runner.progress);
      expect(interpolatedValue, 0.5);
    });
  });

  group('AnimationQueueController Tests', () {
    late AnimationQueueController controller;

    setUp(() {
      controller = AnimationQueueController();
    });

    test('Initial value is correct', () {
      expect(controller.value, 0.0);
    });

    test('Push adds to queue', () {
      final request =
          AnimationRequest(100.0, const Duration(seconds: 2), Curves.easeIn);
      controller.push(request);
      expect(controller.shouldTick, true);
    });

    test('Push replaces queue when queue=false', () {
      final request1 =
          AnimationRequest(100.0, const Duration(seconds: 2), Curves.easeIn);
      final request2 =
          AnimationRequest(200.0, const Duration(seconds: 1), Curves.easeOut);
      controller.push(request1);
      controller.push(request2, false);
      expect(controller.requests.length, 1);
      expect(controller.requests[0].target, 200.0);
    });

    test('Value setter clears queue', () {
      controller.value = 50.0;
      expect(controller.value, 50.0);
      expect(controller.requests, isEmpty);
    });

    test('Tick updates value based on animation progress', () {
      final request =
          AnimationRequest(100.0, const Duration(seconds: 2), Curves.linear);
      controller.push(request);
      controller.tick(const Duration(seconds: 1));
      expect(controller.value, greaterThan(0.0));
      expect(controller.value, lessThan(100.0));
    });

    test('Tick completes and moves to next request', () {
      final request1 =
          AnimationRequest(100.0, const Duration(seconds: 1), Curves.linear);
      final request2 =
          AnimationRequest(200.0, const Duration(seconds: 1), Curves.linear);
      controller.push(request1);
      controller.push(request2);
      controller.tick(const Duration(seconds: 1));
      expect(controller.value, 100.0);
      controller.tick(const Duration(seconds: 1));
      expect(controller.value, 200.0);
    });
  });
}
