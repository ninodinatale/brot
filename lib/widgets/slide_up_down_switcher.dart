import 'package:flutter/material.dart';

class SlideUpDownSwitcher<T> extends StatelessWidget {
  final Widget child;
  final T triggerValue;

  const SlideUpDownSwitcher(
      {Key? key, required this.child, required this.triggerValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final sizeAnimation = TweenSequence<double>([
            TweenSequenceItem(tween: ConstantTween(0.0), weight: 4),
            TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 2),
          ]).animate(animation);
          return SizeTransition(
            axisAlignment: 1,
            sizeFactor: sizeAnimation,
            child: child,
          );
        },
        child: Container(
            key: ValueKey<T>(triggerValue),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
                topLeft: Radius.circular(0.0),
                topRight: Radius.circular(0.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
              child: child,
            )));
  }
}
