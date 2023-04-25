import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';

class ShakeOnChange extends StatefulWidget {
  final Object triggerValue;
  final Widget child;
  final TextStyle? textStyle;

  const ShakeOnChange(
      {Key? key,
      required this.triggerValue,
      this.textStyle,
      required this.child})
      : super(key: key);

  @override
  _ShakeOnChangeState createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange>
    with SingleTickerProviderStateMixin {
  final _shakeKey = GlobalKey<AnimatorWidgetState>();

  @override
  void didUpdateWidget(ShakeOnChange oldWidget) {
    if (oldWidget.triggerValue != widget.triggerValue) {
      _shakeKey.currentState?.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Shake(
      key: _shakeKey,
      preferences: const AnimationPreferences(
          autoPlay: AnimationPlayStates.None,
          magnitude: 0.5,
          duration: Duration(milliseconds: 500)),
      child: widget.child,
    );
  }
}
