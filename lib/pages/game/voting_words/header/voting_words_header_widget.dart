import 'package:brot/models/state/member.dart';
import 'package:brot/pages/game/voting_words/header/is_bread_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'not_bread_header_widget.dart';

class VotingWordsHeaderWidget extends StatelessWidget {
  const VotingWordsHeaderWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final isBread = Provider.of<UserIsBread>(context).value;
    return isBread ? const IsBreadHeaderWidget() : NotBreadHeaderWidget();
  }
}
