import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/state/word.dart';
import 'enter_word_widget.dart';

class NotBreadHeaderWidget extends StatelessWidget {
  const NotBreadHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userHasWord = Provider.of<UserHasWord>(context);
    return userHasWord.value
        ? Center(
            child: Text(
              'Vote für ein Wort 👇',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          )
        : const EnterWordWidget();
  }
}
