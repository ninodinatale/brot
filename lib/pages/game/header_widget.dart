import 'package:brot/models/state/game.dart';
import 'package:brot/pages/game/choosing_bread/choosing_bread_header_widget.dart';
import 'package:brot/pages/game/lobby/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'playing/playing_header_widget.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  Widget _getHeaderWidget(GameStatus status) {
    switch (status) {
      case GameStatus.lobby:
        return const LobbyHeaderWidget();
      case GameStatus.choosingBread:
        return const ChoosingBreadHeaderWidget();
      case GameStatus.votingWords:
        // TODO: Handle this case.
        return Text('UNIMPL');
        break;
      case GameStatus.playing:
        return const PlayingHeaderWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Game>(
      builder: (context, game, child) => _getHeaderWidget(game.status),
    );
  }
}
