import 'package:brot/models/state/member.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'is_bread_voting_words_content_widget.dart';
import 'is_not_bread_voting_words_content_widget.dart';

class VotingWordsWrapperWidget extends StatefulWidget {
  final String gameKey;

  const VotingWordsWrapperWidget({Key? key, required this.gameKey})
      : super(key: key);

  @override
  State<VotingWordsWrapperWidget> createState() =>
      _VotingWordsWrapperWidgetState();
}

class _VotingWordsWrapperWidgetState extends State<VotingWordsWrapperWidget> {
  @override
  Widget build(BuildContext context) {
    final userIsBread = Provider.of<UserIsBread>(context).value;
    return userIsBread
        ? const IsBreadVotingWordsContentWidget()
        : IsNotBreadVotingWordsContentWidget(gameKey: widget.gameKey);
  }
}
