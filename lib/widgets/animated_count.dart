import 'package:flutter/cupertino.dart';

class AnimatedCount extends ImplicitlyAnimatedWidget {
  const AnimatedCount({
    Key? key,
    required this.count,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.fastOutSlowIn,
  }) : super(duration: duration, curve: curve, key: key);

  final num count;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _AnimatedCountState();
  }
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCount> {
  IntTween _intCount = IntTween(begin: 0, end: 1);
  Tween<double> _doubleCount = Tween<double>();

  @override
  Widget build(BuildContext context) {
    return widget.count is int
        ? Text(_intCount.evaluate(animation).toString())
        : Text(_doubleCount.evaluate(animation).toStringAsFixed(1));
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    if (widget.count is int) {
      _intCount = visitor(
        _intCount,
        widget.count,
            (dynamic value) => IntTween(begin: value),
      ) as IntTween;
    } else {
      _doubleCount = visitor(
        _doubleCount,
        widget.count,
            (dynamic value) => Tween<double>(begin: value),
      ) as Tween<double>;
    }
  }
}