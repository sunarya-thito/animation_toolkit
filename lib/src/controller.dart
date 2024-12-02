import 'package:flutter/widgets.dart';

/// Represents a single animation request with a target, duration, and curve.
class AnimationRequest {
  /// The target value of the animation.
  final double target;

  /// The duration of the animation.
  final Duration duration;

  /// The curve to be applied for the animation interpolation.
  final Curve curve;

  /// Constructor to create an animation request.
  AnimationRequest(this.target, this.duration, this.curve);
}

/// A utility class to run animations manually with specified parameters.
class AnimationRunner {
  /// Starting value of the animation.
  final double from;

  /// Target value of the animation.
  final double to;

  /// Duration of the animation.
  final Duration duration;

  /// Curve for the animation.
  final Curve curve;

  /// Tracks the progress of the animation (0.0 to 1.0).
  double _progress = 0.0;

  /// Tracks the progress of the animation (0.0 to 1.0).
  @visibleForTesting
  @protected
  double get progress => _progress;

  /// Sets the progress of the animation.
  /// - [value]: The progress value to set.
  @visibleForTesting
  @protected
  set progress(double value) {
    _progress = value;
  }

  /// Constructor to create an `AnimationRunner`.
  AnimationRunner(this.from, this.to, this.duration, this.curve);
}

/// A controller that queues and manages multiple animation requests.
class AnimationQueueController extends ChangeNotifier {
  /// Current value of the animation.
  double _value;

  /// Constructor for the `AnimationQueueController`.
  ///
  /// - [value]: Initial value of the animation. Defaults to 0.0.
  AnimationQueueController([this._value = 0.0]);

  /// List of queued animation requests.
  List<AnimationRequest> _requests = [];

  /// Current animation runner, if one is in progress.
  AnimationRunner? _runner;

  /// List of queued animation requests.
  @visibleForTesting
  @protected
  List<AnimationRequest> get requests => List.unmodifiable(_requests);

  /// Adds an animation request to the queue.
  ///
  /// - [request]: The animation request to be added.
  /// - [queue]: If `true`, appends to the queue. If `false`, replaces the queue.
  void push(AnimationRequest request, [bool queue = true]) {
    if (queue) {
      _requests.add(request);
    } else {
      _runner = null;
      _requests = [request];
    }
    _runner ??= AnimationRunner(
        _value, request.target, request.duration, request.curve);
    notifyListeners();
  }

  /// Sets the current value of the animation, clearing all queued requests.
  set value(double value) {
    _value = value;
    _runner = null;
    _requests.clear();
    notifyListeners();
  }

  /// Gets the current value of the animation.
  double get value => _value;

  /// Indicates whether the animation controller should tick.
  bool get shouldTick => _runner != null || _requests.isNotEmpty;

  /// Advances the animation by the given time delta.
  ///
  /// - [delta]: The elapsed time since the last tick.
  void tick(Duration delta) {
    if (_requests.isNotEmpty) {
      final request = _requests.removeAt(0);
      _runner = AnimationRunner(
          _value, request.target, request.duration, request.curve);
    }
    final runner = _runner;
    if (runner != null) {
      runner._progress += delta.inMilliseconds / runner.duration.inMilliseconds;
      _value = runner.from +
          (runner.to - runner.from) *
              runner.curve.transform(runner._progress.clamp(0, 1));
      if (runner._progress >= 1.0) {
        _runner = null;
      }
      notifyListeners();
    }
  }
}
