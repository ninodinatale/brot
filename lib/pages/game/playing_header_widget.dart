import 'dart:math';

import 'package:brot/widgets/dot3_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PlayingHeaderWidget extends StatefulWidget {
  const PlayingHeaderWidget({
    super.key,
    required String userId,
  }) : _userId = userId;

  final String _userId;

  @override
  State<PlayingHeaderWidget> createState() => _PlayingHeaderWidgetState();
}

class _PlayingHeaderWidgetState extends State<PlayingHeaderWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    late final AnimationController _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            width: 50,
            height: 50,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * pi,
                  child: child,
                );
              },
              child: SvgPicture.asset('assets/images/bread.svg',
                  fit: BoxFit.scaleDown),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Dot3ProgressIndicator(
              prefix: 'laden',
              textStyle: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            )),
      ]),
    );
  }
}
