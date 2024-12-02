import 'dart:ui';

import 'package:animation_toolkit/animation_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Duration Utility Tests', () {
    test('maxDuration returns the larger duration', () {
      final result = maxDuration(const Duration(seconds: 2), const Duration(seconds: 5));
      expect(result, const Duration(seconds: 5));
    });

    test('minDuration returns the smaller duration', () {
      final result = minDuration(const Duration(seconds: 2), const Duration(seconds: 5));
      expect(result, const Duration(seconds: 2));
    });

    test('timelineMaxDuration returns the longest duration from timelines', () {
      final timeline1 = TimelineAnimation<int>(
        keyframes: [
          const AbsoluteKeyframe(Duration(seconds: 3), 0, 10),
        ],
      );
      final timeline2 = TimelineAnimation<int>(
        keyframes: [
          const AbsoluteKeyframe(Duration(seconds: 5), 0, 10),
        ],
      );
      final timelines = [timeline1, timeline2];
      final result = timelineMaxDuration(timelines);
      expect(result, const Duration(seconds: 5));
    });
  });

  group('Transformers Tests', () {
    test('typeDouble interpolates correctly', () {
      final result = Transformers.typeDouble(0.0, 10.0, 0.5);
      expect(result, 5.0);
    });

    test('typeInt interpolates correctly', () {
      final result = Transformers.typeInt(0, 10, 0.5);
      expect(result, 5);
    });

    test('typeColor interpolates colors correctly', () {
      final result = Transformers.typeColor(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
        0.5,
      );
      expect(result, const Color(0xFF7F7F7F));
    });

    test('typeOffset interpolates offsets correctly', () {
      final result = Transformers.typeOffset(
        const Offset(0.0, 0.0),
        const Offset(10.0, 10.0),
        0.5,
      );
      expect(result, const Offset(5.0, 5.0));
    });

    test('typeSize interpolates sizes correctly', () {
      final result = Transformers.typeSize(
        const Size(0.0, 0.0),
        const Size(10.0, 20.0),
        0.5,
      );
      expect(result, const Size(5.0, 10.0));
    });

    test('typeDouble returns null if one input is null', () {
      final result = Transformers.typeDouble(null, 10.0, 0.5);
      expect(result, isNull);
    });

    test('typeInt returns null if one input is null', () {
      final result = Transformers.typeInt(5, null, 0.5);
      expect(result, isNull);
    });

    test('typeColor returns null if one input is null', () {
      final result = Transformers.typeColor(null, const Color(0xFFFFFFFF), 0.5);
      expect(result, isNull);
    });

    test('typeOffset returns null if one input is null', () {
      final result = Transformers.typeOffset(null, const Offset(10.0, 10.0), 0.5);
      expect(result, isNull);
    });

    test('typeSize returns null if one input is null', () {
      final result = Transformers.typeSize(null, const Size(10.0, 20.0), 0.5);
      expect(result, isNull);
    });
  });
}
