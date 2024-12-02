import 'package:animation_toolkit/animation_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Keyframe Tests', () {
    test('AbsoluteKeyframe computes values correctly', () {
      const keyframe = AbsoluteKeyframe<double>(
        Duration(seconds: 2),
        0.0,
        100.0,
      );
      final timeline = TimelineAnimation<double>(
        keyframes: [keyframe],
      );

      expect(keyframe.compute(timeline, 0, 0.0), 0.0);
      expect(keyframe.compute(timeline, 0, 0.5), 50.0);
      expect(keyframe.compute(timeline, 0, 1.0), 100.0);
    });

    test('RelativeKeyframe computes values based on the previous keyframe', () {
      final keyframes = [
        const AbsoluteKeyframe<double>(
          Duration(seconds: 1),
          0.0,
          50.0,
        ),
        const RelativeKeyframe<double>(
          Duration(seconds: 1),
          100.0,
        ),
      ];
      final timeline = TimelineAnimation<double>(
        keyframes: keyframes,
      );

      expect(keyframes[1].compute(timeline, 1, 0.0), 50.0);
      expect(keyframes[1].compute(timeline, 1, 0.5), 75.0);
      expect(keyframes[1].compute(timeline, 1, 1.0), 100.0);
    });

    test('StillKeyframe computes a constant value', () {
      const keyframe = StillKeyframe<double>(
        Duration(seconds: 1),
        42.0,
      );
      final timeline = TimelineAnimation<double>(
        keyframes: [keyframe],
      );

      expect(keyframe.compute(timeline, 0, 0.0), 42.0);
      expect(keyframe.compute(timeline, 0, 0.5), 42.0);
      expect(keyframe.compute(timeline, 0, 1.0), 42.0);
    });

    test('StillKeyframe inherits value from the previous keyframe', () {
      final keyframes = [
        const AbsoluteKeyframe<double>(
          Duration(seconds: 1),
          0.0,
          50.0,
        ),
        const StillKeyframe<double>(
          Duration(seconds: 1),
        ),
      ];
      final timeline = TimelineAnimation<double>(
        keyframes: keyframes,
      );

      expect(keyframes[1].compute(timeline, 1, 0.0), 50.0);
      expect(keyframes[1].compute(timeline, 1, 0.5), 50.0);
      expect(keyframes[1].compute(timeline, 1, 1.0), 50.0);
    });
  });

  group('TimelineAnimation Tests', () {
    test('TimelineAnimation transforms correctly over time', () {
      final keyframes = [
        const AbsoluteKeyframe<double>(
          Duration(seconds: 1),
          0.0,
          50.0,
        ),
        const AbsoluteKeyframe<double>(
          Duration(seconds: 1),
          50.0,
          100.0,
        ),
      ];
      final timeline = TimelineAnimation<double>(
        keyframes: keyframes,
      );

      expect(timeline.transform(0.0), 0.0);
      expect(timeline.transform(0.5), 50.0);
      expect(timeline.transform(1.0), 100.0);
    });

    test('Throws assertion if keyframes are empty', () {
      expect(
          () => TimelineAnimation<double>(keyframes: []), throwsAssertionError);
    });

    test('Throws assertion if keyframe duration is invalid', () {
      expect(
        () => TimelineAnimation<double>(
          keyframes: [
            const AbsoluteKeyframe<double>(Duration.zero, 0.0, 100.0),
          ],
        ),
        throwsAssertionError,
      );
    });
  });
}
