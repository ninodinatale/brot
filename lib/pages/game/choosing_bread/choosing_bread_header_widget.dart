import 'package:brot/widgets/dot3_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

class ChoosingBreadHeaderWidget extends StatelessWidget {
  const ChoosingBreadHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleText =
        theme.textTheme.titleLarge!.copyWith(color: theme.primaryColor);
    final styleIcons = theme.textTheme.titleLarge!.copyWith(
        color: theme.primaryColor,
        fontSize: theme.textTheme.titleLarge!.fontSize! * 2);
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🤫',
                style: styleIcons,
              ),
              SvgPicture.asset('assets/images/bread.svg',
                  height: styleIcons.fontSize),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Brot wird ausgewählt',
                style: styleText,
              ),
              Dot3ProgressIndicator(textStyle: styleText),
            ],
          ),
        ],
      ),
    );
  }
}
