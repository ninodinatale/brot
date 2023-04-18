import 'package:flutter/material.dart';

class AnimatedInt extends StatefulWidget {
  final int value;
  final TextStyle? textStyle;

  const AnimatedInt({Key? key, required this.value, this.textStyle})
      : super(key: key);

  @override
  _AnimatedIntState createState() => _AnimatedIntState();
}

class _AnimatedIntState extends State<AnimatedInt> {
  int _previous = -1;

  @override
  void didUpdateWidget(AnimatedInt oldWidget) {
    _previous = oldWidget.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final position = Tween<Offset>(
                begin: (_previous < widget.value)
                    ? (animation.status == AnimationStatus.completed)
                        ? const Offset(0, 1)
                        : const Offset(0, -1)
                    : (animation.status == AnimationStatus.completed)
                        ? const Offset(0, -1)
                        : const Offset(0, 1),
                end: Offset.zero)
            .animate(animation);

        final scale = CurveTween(
                curve: (_previous < widget.value)
                    ? (animation.status == AnimationStatus.completed)
                        ? Curves.easeInOutBack
                        : Curves.easeInOutBack.flipped
                    : (animation.status == AnimationStatus.completed)
                        ? Curves.easeInOutBack.flipped
                        : Curves.easeInOutBack)
            .animate(animation);
        return ScaleTransition(
            scale: scale,
            child: SlideTransition(
              position: position,
              child: child,
            ));
      },
      child: Text(
        '${widget.value}',
        key: ValueKey<int>(widget.value),
        style: widget.textStyle,
      ),
    );
  }
}
