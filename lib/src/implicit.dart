import 'package:flutter/widgets.dart';

/// A typedef for building a widget with an animated value.
/// - [T]: The type of the value being animated.
/// - [context]: The build context.
/// - [value]: The current animated value.
/// - [child]: An optional child widget for optimization.
typedef AnimatedChildBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

/// A typedef for building a widget based on an animation object.
/// - [T]: The type of the animation's value.
/// - [context]: The build context.
/// - [animation]: The animation object providing the value.
typedef AnimationBuilder<T> = Widget Function(
    BuildContext context, Animation<T> animation);

/// A widget that animates between two values of type [T].
class AnimatedValueBuilder<T> extends StatefulWidget {
  /// The initial value of the animation.
  final T? initialValue;

  /// The target value of the animation.
  final T value;

  /// The duration of the animation.
  final Duration? duration;

  /// A function to compute the animation duration dynamically based on values.
  final Duration Function(T a, T b)? durationBuilder;

  /// A builder function for creating the animated widget.
  final AnimatedChildBuilder<T>? builder;

  /// A builder function for creating a widget from an animation.
  final AnimationBuilder<T>? animationBuilder;

  /// A callback triggered when the animation ends.
  final void Function(T value)? onEnd;

  /// The animation curve.
  final Curve curve;

  /// A function to interpolate between two values.
  final T Function(T a, T b, double t)? lerp;

  /// An optional static child widget for optimization.
  final Widget? child;

  /// Constructor for building an animated value using a child builder.
  const AnimatedValueBuilder({
    super.key,
    this.initialValue,
    required this.value,
    this.duration,
    this.durationBuilder,
    required AnimatedChildBuilder<T> this.builder,
    this.onEnd,
    this.curve = Curves.linear,
    this.lerp,
    this.child,
  })  : animationBuilder = null,
        assert(duration != null || durationBuilder != null,
            'You must provide a duration or a durationBuilder.');

  /// Constructor for building an animated value using an animation builder.
  const AnimatedValueBuilder.animation({
    super.key,
    this.initialValue,
    required this.value,
    this.duration,
    this.durationBuilder,
    required AnimationBuilder<T> builder,
    this.onEnd,
    this.curve = Curves.linear,
    this.lerp,
  })  : builder = null,
        animationBuilder = builder,
        child = null,
        assert(duration != null || durationBuilder != null,
            'You must provide a duration or a durationBuilder.');

  @override
  State<StatefulWidget> createState() {
    return AnimatedValueBuilderState<T>();
  }
}

/// An internal class for handling animatable values.
class AnimatableValue<T> extends Animatable<T> {
  /// The starting value of the animation.
  final T start;

  /// The ending value of the animation.
  final T end;

  /// A function to interpolate between two values.
  final T Function(T a, T b, double t) lerp;

  /// Constructor for creating an animatable value.
  AnimatableValue({
    required this.start,
    required this.end,
    required this.lerp,
  });

  @override
  T transform(double t) {
    return lerp(start, end, t);
  }

  @override
  String toString() {
    return 'AnimatableValue($start, $end)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimatableValue<T> &&
        other.start == start &&
        other.end == end &&
        other.lerp == lerp;
  }

  @override
  int get hashCode {
    return Object.hash(start, end, lerp);
  }
}

/// The state class for [AnimatedValueBuilder].
class AnimatedValueBuilderState<T> extends State<AnimatedValueBuilder<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Animation<T> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ??
          widget.durationBuilder!(
              widget.initialValue ?? widget.value, widget.value),
    );

    // Create a curved animation
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    // Add a listener for animation completion
    _curvedAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onEnd();
      }
    });

    // Initialize the animatable value
    _animation = _curvedAnimation.drive(
      AnimatableValue(
        start: widget.initialValue ?? widget.value,
        end: widget.value,
        lerp: lerpedValue,
      ),
    );

    if (widget.initialValue != null) {
      _controller.forward();
    }
  }

  /// Custom interpolation logic
  T lerpedValue(T a, T b, double t) {
    if (widget.lerp != null) {
      return widget.lerp!(a, b, t);
    }
    try {
      return (a as dynamic) + ((b as dynamic) - (a as dynamic)) * t;
    } catch (e) {
      throw Exception(
        'Could not lerp $a and $b. You must provide a custom lerp function.',
      );
    }
  }

  @override
  void didUpdateWidget(AnimatedValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    T currentValue = _animation.value;

    if (widget.duration != oldWidget.duration ||
        widget.durationBuilder != oldWidget.durationBuilder) {
      _controller.duration = widget.duration ??
          widget.durationBuilder!(currentValue, widget.value);
    }

    if (widget.curve != oldWidget.curve) {
      _curvedAnimation.dispose();
      _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      );
    }

    if (oldWidget.value != widget.value || oldWidget.lerp != widget.lerp) {
      _animation = _curvedAnimation.drive(
        AnimatableValue(
          start: currentValue,
          end: widget.value,
          lerp: lerpedValue,
        ),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnd() {
    if (widget.onEnd != null) {
      widget.onEnd!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!(context, _animation);
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: _builder,
      child: widget.child,
    );
  }

  Widget _builder(BuildContext context, Widget? child) {
    T newValue = _animation.value;
    return widget.builder!(context, newValue, child);
  }
}
