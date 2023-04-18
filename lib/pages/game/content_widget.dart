import 'package:brot/pages/game/voting_words/voting_words_wrapper_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/state/game.dart';
import 'lobby/content_members_widget.dart';

class ContentWidget extends StatefulWidget {
  final String gameKey;

  const ContentWidget({Key? key, required this.gameKey}) : super(key: key);

  @override
  State<ContentWidget> createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  Widget _gameContentBuilder(GameStatus status) {
    switch (status) {
      case GameStatus.lobby:
      case GameStatus.choosingBread:
        return ContentMembersWidget(widget.gameKey);
      case GameStatus.votingWords:
        return VotingWordsWrapperWidget(gameKey: widget.gameKey);
      case GameStatus.playing:
        // TODO: Handle this case.
        return Text('UNIMPL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameStatus = Provider.of<GameStatus>(context);
    return _gameContentBuilder(gameStatus);
  }
}
