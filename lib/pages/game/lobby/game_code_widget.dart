import 'dart:async';

import 'package:brot/database.dart';
import 'package:brot/main.dart';
import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/member.dart';
import 'package:brot/router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../../widgets/bottom_sheet_modal.dart';

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
          color: Theme
              .of(context)
              .colorScheme
              .onPrimary,
        ))
        : const Text('Start');
  }

  /// Leaves the game as member.
  void _leaveGame(Game game, Member member) {
    brotModalBottomSheet<void>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) =>
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Spiel verlassen?',
                      style: Theme
                          .of(context)
                          .textTheme
                          .header1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                            child: Text('Abbrechen'),
                            onPressed: () => Navigator.pop(context)),
                        const Spacer(),
                        ElevatedButton(
                          child: const Text('Verlassen'),
                          onPressed: () {
                            logI('leaving game {} for member {}',
                                ['$game', '$member']);
                            FirebaseDatabase.instance
                                .ref('/members/${game.key}/${member.key}')
                                .remove();

                            const route = HomeRoute();
                            logI('navigating to {}', ['${route.location}']);
                            route.go(context);
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  void _startGamePressed(Game game) {
    brotModalBottomSheet<void>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) =>
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Spiel starten?',
                      style: Theme
                          .of(context)
                          .textTheme
                          .header1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                            child: Text('Abbrechen'),
                            onPressed: () => Navigator.pop(context)),
                        const Spacer(),
                        ElevatedButton(
                          child: const Text('Starten'),
                          onPressed: () {
                            _startGame(game);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
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
    final userMember = Provider.of<Member>(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: game.gameCode))
                .then((_) =>
                ScaffoldMessenger.of(context).showSnackBar(
                  BrotSnackBar(context: context, content: const Text('Code kopiert')),
                ));
          },
          child: Center(
            child: Pulse(
                preferences: const AnimationPreferences(
                    offset: Duration(seconds: 2),
                    magnitude: 10,
                    autoPlay: AnimationPlayStates.Loop),
                child: Text(game.gameCode, style: theme.textTheme.header1)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                  onPressed: () => _leaveGame(game, userMember),
                  child: const Text('Verlassen')),
              if (userMember.isAdmin)
                ElevatedButton(
                    onPressed: () => _startGamePressed(game),
                    child: _startGameButtonChild)
            ],
          ),
        )
      ],
    );
  }
}

SnackBar BrotSnackBar({required BuildContext context,
  required Widget content,
  SnackBarAction? action}) {
  return SnackBar(
    action: action,
    content: content,
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14
    ),
  );
}
