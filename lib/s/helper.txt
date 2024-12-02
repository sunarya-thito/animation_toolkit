import 'dart:ui';

import 'package:animation_toolkit/src/timeline.dart';

/// A typedef for a generic property interpolation function.
///
/// - [T]: The type of the property to interpolate.
/// - [a]: The starting value.
/// - [b]: The ending value.
/// - [t]: The interpolation factor (0.0 to 1.0).
typedef PropertyLerp<T> = T? Function(T? a, T? b, double t);

/// Returns the maximum of two [Duration] objects.
Duration maxDuration(Duration a, Duration b) {
  return a > b ? a : b;
}

/// Returns the minimum of two [Duration] objects.
Duration minDuration(Duration a, Duration b) {
  return a < b ? a : b;
}

/// Returns the maximum total duration from a collection of [TimelineAnimation] objects.
///
/// - [timelines]: A collection of timeline animations.
/// - Returns: The longest duration among all timelines.
Duration timelineMaxDuration(Iterable<TimelineAnimation> timelines) {
  Duration max = Duration.zero;
  for (final timeline in timelines) {
    max = maxDuration(max, timeline.totalDuration);
  }
  return max;
}

/// A utility class containing static methods for type-specific interpolation
/// of common properties like `double`, `int`, `Color`, `Offset`, and `Size`.
class Transformers {
  /// Interpolates between two [double] values.
  ///
  /// - [a]: Starting value.
  /// - [b]: Ending value.
  /// - [t]: Interpolation factor (0.0 to 1.0).
  /// - Returns: The interpolated value or `null` if either `a` or `b` is `null`.
  static double? typeDouble(double? a, double? b, double t) {
    if (a == null || b == null) {
      return null;
    }
    return a + (b - a) * t;
  }

  /// Interpolates between two [int] values.
  ///
  /// - [a]: Starting value.
  /// - [b]: Ending value.
  /// - [t]: Interpolation factor (0.0 to 1.0).
  /// - Returns: The interpolated value as an integer or `null` if either `a` or `b` is `null`.
  static int? typeInt(int? a, int? b, double t) {
    if (a == null || b == null) {
      return null;
    }
    return (a + (b - a) * t).round();
  }

  /// Interpolates between two [Color] values.
  ///
  /// - [a]: Starting color.
  /// - [b]: Ending color.
  /// - [t]: Interpolation factor (0.0 to 1.0).
  /// - Returns: The interpolated color or `null` if either `a` or `b` is `null`.
  static Color? typeColor(Color? a, Color? b, double t) {
    if (a == null || b == null) {
      return null;
    }
    return Color.lerp(a, b, t);
  }

  /// Interpolates between two [Offset] values.
  ///
  /// - [a]: Starting offset.
  /// - [b]: Ending offset.
  /// - [t]: Interpolation factor (0.0 to 1.0).
  /// - Returns: The interpolated offset or `null` if either `a` or `b` is `null`.
  static Offset? typeOffset(Offset? a, Offset? b, double t) {
    if (a == null || b == null) {
      return null;
    }
    return Offset(
      typeDouble(a.dx, b.dx, t)!,
      typeDouble(a.dy, b.dy, t)!,
    );
  }

  /// Interpolates between two [Size] values.
  ///
  /// - [a]: Starting size.
  /// - [b]: Ending size.
  /// - [t]: Interpolation factor (0.0 to 1.0).
  /// - Returns: The interpolated size or `null` if either `a` or `b` is `null`.
  static Size? typeSize(Size? a, Size? b, double t) {
    if (a == null || b == null) {
      return null;
    }
    return Size(
      typeDouble(a.width, b.width, t)!,
      typeDouble(a.height, b.height, t)!,
    );
  }
}
