import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';

class AnimatedFlash extends StatefulWidget {
  final int value;
  final Widget child;
  final TextStyle? textStyle;

  const AnimatedFlash(
      {Key? key, required this.value, this.textStyle, required this.child})
      : super(key: key);

  @override
  _AnimatedFlashState createState() => _AnimatedFlashState();
}

class _AnimatedFlashState extends State<AnimatedFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  Color? _backgroundColor;
  final _pulseKey = GlobalKey<AnimatorWidgetState>();
  final _duration = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(_animationController);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedFlash oldWidget) {
    if (oldWidget.value != widget.value) {
      _pulseKey.currentState?.forward();
      _animationController.forward();
      _animationController.addListener(() {
        setState(() {
          _backgroundColor = Colors.green.withOpacity(_animation.value);
          // print(_animation.value);
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: _backgroundColor, child: widget.child);
  }
}
