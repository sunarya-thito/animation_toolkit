import 'package:flutter/widgets.dart';

import '../animation_toolkit.dart';

/// Abstract base class for keyframes in a timeline animation.
///
/// A keyframe represents a specific animation step over a given [duration].
/// - [T]: The type of value being animated.
abstract class Keyframe<T> {
  /// Duration of this keyframe.
  Duration get duration;

  /// Computes the interpolated value for this keyframe at a specific point in time.
  ///
  /// - [timeline]: The parent timeline animation.
  /// - [index]: The index of this keyframe in the timeline.
  /// - [t]: The local progress of this keyframe (0.0 to 1.0).
  T compute(TimelineAnimation<T> timeline, int index, double t);
}

/// A keyframe that explicitly specifies a `from` and `to` value.
///
/// The animation interpolates between `from` and `to` over the given [duration].
class AbsoluteKeyframe<T> implements Keyframe<T> {
  /// The starting value of the animation.
  final T from;

  /// The ending value of the animation.
  final T to;

  @override
  final Duration duration;

  /// Creates an [AbsoluteKeyframe] with the specified [duration], [from], and [to] values.
  const AbsoluteKeyframe(
    this.duration,
    this.from,
    this.to,
  );

  @override
  T compute(TimelineAnimation<T> timeline, int index, double t) {
    return timeline.lerp(from, to, t)!;
  }
}

/// A keyframe that interpolates between the value of the previous keyframe
/// and a specified `target` value.
class RelativeKeyframe<T> implements Keyframe<T> {
  /// The target value of the animation.
  final T target;

  @override
  final Duration duration;

  /// Creates a [RelativeKeyframe] with the specified [duration] and [target].
  const RelativeKeyframe(
    this.duration,
    this.target,
  );

  @override
  T compute(TimelineAnimation<T> timeline, int index, double t) {
    if (index <= 0) {
      // Acts as a still keyframe if there is no previous keyframe.
      return target;
    }
    final previous =
        timeline.keyframes[index - 1].compute(timeline, index - 1, 1.0);
    return timeline.lerp(previous, target, t)!;
  }
}

/// A keyframe that holds a constant value for its duration.
///
/// If no value is provided, it holds the value of the previous keyframe.
class StillKeyframe<T> implements Keyframe<T> {
  /// The constant value held by this keyframe.
  final T? value;

  @override
  final Duration duration;

  /// Creates a [StillKeyframe] with the specified [duration] and optional [value].
  const StillKeyframe(this.duration, [this.value]);

  @override
  T compute(TimelineAnimation<T> timeline, int index, double t) {
    var value = this.value;
    if (value == null) {
      assert(
          index > 0, 'Relative still keyframe must have a previous keyframe');
      value = timeline.keyframes[index - 1].compute(timeline, index - 1, 1.0);
    }
    return value as T;
  }
}

/// Represents a timeline animation composed of multiple [Keyframe]s.
///
/// The animation interpolates through its keyframes over the total duration.
class TimelineAnimation<T> extends Animatable<T> {
  /// Default linear interpolation for values of type [T].
  static T defaultLerp<T>(T a, T b, double t) {
    return ((a as dynamic) + ((b as dynamic) - (a as dynamic)) * t) as T;
  }

  /// The interpolation function used to animate between values.
  final PropertyLerp<T> lerp;

  /// The total duration of the timeline animation.
  final Duration totalDuration;

  /// The list of keyframes in the timeline.
  final List<Keyframe<T>> keyframes;

  /// Private constructor for creating a [TimelineAnimation].
  TimelineAnimation._({
    required this.lerp,
    required this.totalDuration,
    required this.keyframes,
  });

  /// Creates a [TimelineAnimation] with the specified [keyframes] and optional [lerp].
  ///
  /// - [lerp]: A custom interpolation function. Defaults to [defaultLerp].
  /// - [keyframes]: A list of keyframes defining the animation.
  factory TimelineAnimation({
    PropertyLerp<T>? lerp,
    required List<Keyframe<T>> keyframes,
  }) {
    lerp ??= defaultLerp;
    assert(keyframes.isNotEmpty, 'No keyframes found');
    Duration current = Duration.zero;
    for (var i = 0; i < keyframes.length; i++) {
      final keyframe = keyframes[i];
      assert(keyframe.duration.inMilliseconds > 0, 'Invalid duration');
      current += keyframe.duration;
    }
    return TimelineAnimation._(
      lerp: lerp,
      totalDuration: current,
      keyframes: keyframes,
    );
  }

  /// Computes the total duration of the animation up to a given progress [t].
  Duration _computeDuration(double t) {
    final totalDuration = this.totalDuration;
    return Duration(milliseconds: (t * totalDuration.inMilliseconds).floor());
  }

  @override
  T transform(double t) {
    assert(t >= 0 && t <= 1, 'Invalid time $t');
    assert(keyframes.isNotEmpty, 'No keyframes found');
    var duration = _computeDuration(t);
    var current = Duration.zero;

    for (var i = 0; i < keyframes.length; i++) {
      final keyframe = keyframes[i];
      final next = current + keyframe.duration;

      if (duration < next) {
        final localT = (duration - current).inMilliseconds /
            keyframe.duration.inMilliseconds;
        return keyframe.compute(this, i, localT);
      }
      current = next;
    }

    // Fallback to the last keyframe if time exceeds.
    return keyframes.last.compute(this, keyframes.length - 1, 1.0);
  }
}
