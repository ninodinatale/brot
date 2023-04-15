import 'dart:async';

import 'package:brot/database.dart';
import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/member.dart';
import 'package:brot/models/state/user_member.dart';
import 'package:brot/router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';

class GameCodeWidget extends StatefulWidget {
  const GameCodeWidget({Key? key}) : super(key: key);

  @override
  _GameCodeWidgetState createState() => _GameCodeWidgetState();
}

class _GameCodeWidgetState extends State<GameCodeWidget> {
  var _isStartGameLoading = false;

  Widget get _startGameButtonChild {
    return _isStartGameLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ))
        : const Text('Start');
  }

  /// Leaves the game as member.
  void _leaveGame(Game game, Member member) {
    logI('leaving game {} for member {}', ['$game', '$member']);
    FirebaseDatabase.instance
        .ref('/members/${game.key}/${member.key}')
        .remove();

    const route = HomeRoute();
    logI('navigating to {}', ['${route.location}']);
    route.go(context);
  }

  /// Starts the game.
  void _startGame(Game game) {
    logI('starting game {}', ['$game']);
    setState(() {
      _isStartGameLoading = true;
    });
    const newGameStatus = GameStatus.choosingBread;
    logI('setting game.status to {}', ['$newGameStatus']);
    FirebaseDatabase.instance
        .ref('/games/${game.key}/status')
        .set(newGameStatus.index)
        .then((_) async {
      await chooseBread(game.key);
      const waitDuration = Duration(seconds: 5);
      logI('generating artificial loading time of {}', ['$waitDuration']);
      return Timer(waitDuration, () {
        logI('artificial loading time over');
        const playingGameStatus = GameStatus.votingWords;
        logI('setting game.status to {}', ['$playingGameStatus']);
        FirebaseDatabase.instance
            .ref('/games/${game.key}/status')
            .set(playingGameStatus.index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = Provider.of<Game>(context);
    final userMember = Provider.of<UserMember>(context);

    return Column(
      children: [
        Center(
          child: Pulse(
              preferences: const AnimationPreferences(
                  offset: Duration(seconds: 2),
                  magnitude: 10,
                  autoPlay: AnimationPlayStates.Loop),
              child: Text(game.gameCode,
                  style: theme.textTheme.displaySmall
                      ?.copyWith(color: theme.colorScheme.primary))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                  onPressed: () => {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Spiel verlassen?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: const Text('Abbrechen'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _leaveGame(game, userMember),
                                      child: Text('Verlassen',
                                          style: TextStyle(
                                              color: theme.colorScheme.error)),
                                    ),
                                  ],
                                )),
                      },
                  child: const Text('Verlassen')),
              ElevatedButton(
                  onPressed: () => _startGame(game),
                  child: _startGameButtonChild)
            ],
          ),
        )
      ],
    );
  }
}
