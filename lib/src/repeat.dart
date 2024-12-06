import 'package:flutter/widgets.dart';

import '../animation_toolkit.dart';

/// Enum defining different repeat modes for animations.
enum RepeatMode {
  /// Repeats the animation from start to end.
  repeat,

  /// Repeats the animation in reverse direction after it completes.
  reverse,

  /// Repeats the animation, playing it forward and then in reverse (ping-pong effect).
  pingPong,

  /// Same as [pingPong], but starts the animation in reverse direction.
  pingPongReverse,
}

/// A widget that animates between two values of type [T] repeatedly, based on the specified [RepeatMode].
///
/// - [start]: The initial value of the animation.
/// - [end]: The target value of the animation.
/// - [duration]: The duration for a single animation cycle.
/// - [reverseDuration]: The duration of the reverse cycle (only applicable in certain repeat modes).
/// - [curve]: The curve applied to the animation.
/// - [reverseCurve]: The curve applied to the reverse animation (optional).
/// - [mode]: The repeat mode (e.g., repeat, reverse, ping-pong, ping-pong-reverse).
/// - [builder]: A builder function to build the widget based on the animation value.
/// - [animationBuilder]: A builder function for creating a widget using the animation object (optional, mutually exclusive with [builder]).
class RepeatedAnimationBuilder<T> extends StatefulWidget {
  /// The starting value of the animation.
  final T start;

  /// The target value of the animation.
  final T end;

  /// The duration of one animation cycle.
  final Duration duration;

  /// The duration of the reverse cycle (optional).
  final Duration? reverseDuration;

  /// The curve applied to the animation.
  final Curve curve;

  /// The curve applied to the reverse animation (optional).
  final Curve? reverseCurve;

  /// The repeat mode controlling how the animation repeats.
  final RepeatMode mode;

  /// A builder function to create a widget using the animated value.
  final Widget Function(BuildContext context, T value, Widget? child)? builder;

  /// A builder function that creates a widget using the animation object.
  final Widget Function(BuildContext context, Animation<T> animation)?
      animationBuilder;

  /// An optional child widget for optimization.
  final Widget? child;

  /// A custom function to interpolate between two values.
  final T Function(T a, T b, double t)? lerp;

  /// Whether the animation should play immediately or not.
  final bool play;

  /// Constructor for using a builder function.
  const RepeatedAnimationBuilder({
    super.key,
    required this.start,
    required this.end,
    required this.duration,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.mode = RepeatMode.repeat,
    required this.builder,
    this.child,
    this.lerp,
    this.play = true,
    this.reverseDuration,
  }) : animationBuilder = null;

  /// Constructor for using an animation builder function.
  const RepeatedAnimationBuilder.animation({
    super.key,
    required this.start,
    required this.end,
    required this.duration,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.mode = RepeatMode.repeat,
    required this.animationBuilder,
    this.child,
    this.lerp,
    this.play = true,
    this.reverseDuration,
  }) : builder = null;

  @override
  State<RepeatedAnimationBuilder<T>> createState() =>
      _RepeatedAnimationBuilderState<T>();
}

/// The internal state for [RepeatedAnimationBuilder], handling animation logic and controls.
class _RepeatedAnimationBuilderState<T>
    extends State<RepeatedAnimationBuilder<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Animation<T> _animation;

  bool _reverse = false;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller.
    _controller = AnimationController(
      vsync: this,
    );

    // Set up the animation depending on the repeat mode.
    if (widget.mode == RepeatMode.reverse ||
        widget.mode == RepeatMode.pingPongReverse) {
      _reverse = true;
      _controller.duration = widget.reverseDuration ?? widget.duration;
      _controller.reverseDuration = widget.duration;
      _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.reverseCurve ?? widget.curve,
        reverseCurve: widget.curve,
      );
      _animation = _curvedAnimation.drive(
        AnimatableValue(
          start: widget.end,
          end: widget.start,
          lerp: lerpedValue,
        ),
      );
    } else {
      _controller.duration = widget.duration;
      _controller.reverseDuration = widget.reverseDuration;
      _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve ?? widget.curve,
      );
      _animation = _curvedAnimation.drive(
        AnimatableValue(
          start: widget.start,
          end: widget.end,
          lerp: lerpedValue,
        ),
      );
    }

    // Add listener to handle animation status changes.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.mode == RepeatMode.pingPong ||
            widget.mode == RepeatMode.pingPongReverse) {
          _controller.reverse();
          _reverse = true;
        } else {
          _controller.reset();
          _controller.forward();
        }
      } else if (status == AnimationStatus.dismissed) {
        if (widget.mode == RepeatMode.pingPong ||
            widget.mode == RepeatMode.pingPongReverse) {
          _controller.forward();
          _reverse = false;
        } else {
          _controller.reset();
          _controller.forward();
        }
      }
    });

    // Start animation if [play] is true.
    if (widget.play) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant RepeatedAnimationBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle updates to the widget properties that affect animation.
    if (oldWidget.duration != widget.duration) {}
    if (oldWidget.start != widget.start ||
        oldWidget.end != widget.end ||
        oldWidget.duration != widget.duration ||
        oldWidget.reverseDuration != widget.reverseDuration ||
        oldWidget.curve != widget.curve ||
        oldWidget.reverseCurve != widget.reverseCurve ||
        oldWidget.mode != widget.mode ||
        oldWidget.play != widget.play) {
      if (widget.mode == RepeatMode.reverse ||
          widget.mode == RepeatMode.pingPongReverse) {
        _controller.duration = widget.reverseDuration ?? widget.duration;
        _controller.reverseDuration = widget.duration;
        _curvedAnimation.dispose();
        _curvedAnimation = CurvedAnimation(
          parent: _controller,
          curve: widget.reverseCurve ?? widget.curve,
          reverseCurve: widget.curve,
        );
        _animation = _curvedAnimation.drive(
          AnimatableValue(
            start: widget.end,
            end: widget.start,
            lerp: lerpedValue,
          ),
        );
      } else {
        _controller.duration = widget.duration;
        _controller.reverseDuration = widget.reverseDuration;
        _curvedAnimation.dispose();
        _curvedAnimation = CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
          reverseCurve: widget.reverseCurve ?? widget.curve,
        );
        _animation = _curvedAnimation.drive(
          AnimatableValue(
            start: widget.start,
            end: widget.end,
            lerp: lerpedValue,
          ),
        );
      }
    }

    // Handle changes to play state.
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        if (_reverse) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Custom interpolation function to calculate intermediate values between [start] and [end].
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
  Widget build(BuildContext context) {
    // Use the animation builder if provided, otherwise fall back to the default builder.
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!(context, _animation);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        T value = _animation.value;
        return widget.builder!(context, value, widget.child);
      },
    );
  }
}
