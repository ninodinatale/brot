import 'package:brot/models/state/game.dart';
import 'package:brot/pages/game/choosing_bread/choosing_bread_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/slide_up_down_switcher.dart';
import 'lobby/lobby_header_widget.dart';
import 'playing/playing_header_widget.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameStatus>(
      builder: (context, gameStatus, child) =>
          AnimatedHeader(gameStatus: gameStatus),
    );
  }
}

class AnimatedHeader extends StatefulWidget {
  final GameStatus gameStatus;

  const AnimatedHeader({Key? key, required this.gameStatus}) : super(key: key);

  @override
  _AnimatedHeaderState createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader> {
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
    return Material(
      color: Colors.transparent,
      elevation: 20.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
      child: SlideUpDownSwitcher(
        triggerValue: widget.gameStatus,
        child: _getHeaderWidget(widget.gameStatus),
      ),
    );
  }
}
