import 'package:brot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/animation/animation_preferences.dart';
import 'package:flutter_animator/animation/animator_play_states.dart';
import 'package:flutter_animator/widgets/attention_seekers/pulse.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

class IsBreadHeaderWidget extends StatelessWidget {
  const IsBreadHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Pulse(
            preferences: const AnimationPreferences(
                offset: Duration(milliseconds: 500),
                magnitude: 5,
                autoPlay: AnimationPlayStates.Loop),
            child: SvgPicture.asset('assets/images/bread.svg', height: 150)),
        Text(
          'Du bist das Brot! 😱',
          style: theme.textTheme.header1,
        )
      ],
    );
  }
}
