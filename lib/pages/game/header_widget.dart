import 'package:brot/models/state/game.dart';
import 'package:brot/pages/game/choosing_bread/choosing_bread_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';

import 'lobby/lobby_header_widget.dart';
import 'playing/playing_header_widget.dart';

class HeaderWidget extends StatefulWidget {
  HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  Widget _getHeaderWidget(GameStatus status) {
    switch (status) {
      case GameStatus.lobby:
        return const LobbyHeaderWidget();
      case GameStatus.choosingBread:
        return const ChoosingBreadHeaderWidget();
      case GameStatus.votingWords:
        return const VotingWordsHeaderWidget();
      case GameStatus.playing:
        // TODO: Handle this case.
        return Text('UNIMPL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<Game>(
      builder: (context, game, child) => SlideInDown(
        key: Provider.of<GlobalKey<AnimatorWidgetState>>(context),
        child: Material(
            color: Colors.transparent,
            elevation: 20.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
                topLeft: Radius.circular(0.0),
                topRight: Radius.circular(0.0),
              ),
            ),
            child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
                  child: _getHeaderWidget(game.status),
                ))),
      ),
    );
  }
}
