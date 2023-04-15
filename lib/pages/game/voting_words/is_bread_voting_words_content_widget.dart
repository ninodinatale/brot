import 'package:brot/widgets/dot3_progress_indicator.dart';
import 'package:flutter/material.dart';

class IsBreadVotingWordsContentWidget extends StatelessWidget {
  const IsBreadVotingWordsContentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
        child: Dot3ProgressIndicator(
      prefix: 'Die Brotlosen wählen ein Wort, bitte warten',
      textStyle: theme.textTheme.displaySmall!
          .copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.85)),
    ));
  }
}
