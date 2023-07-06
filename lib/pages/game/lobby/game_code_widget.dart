import 'package:brot/main.dart';
import 'package:brot/models/payload/payloads.dart';
import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/member.dart';
import 'package:brot/router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:provider/provider.dart';

import '../../../firebase_functions.dart';
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
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Spiel verlassen?'),
                actions: <Widget>[
                  TextButton(
                      child: Text('Abbrechen'),
                      onPressed: () => Navigator.pop(context)),
                  FilledButton(
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
            ));
  }

  void _startGamePressed(Game game, String userId) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Spiel starten?'),
                content: Text(
                    'Es können keine Spieler mehr dem Spiel beitreten, wenn es gestartet wurde.'),
                actions: <Widget>[
                  TextButton(
                      child: Text('Abbrechen'),
                      onPressed: () => Navigator.pop(context)),
                  FilledButton(
                    child: const Text('Starten'),
                    onPressed: () {
                      _startGame(game, userId);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ));
  }

  /// Starts the game.
  void _startGame(Game game, String userId) {
    logI('starting game {}', ['$game']);
    setState(() {
      _isStartGameLoading = true;
    });
    BrotFirebaseFunctions.callStartGame(StartGamePayload(gameKey: game.key, userId: userId));
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
                .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                      BrotSnackBar(
                          context: context,
                          content: const Text('Code kopiert')),
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
                FilledButton(
                    onPressed: () => _startGamePressed(game, userMember.userId),
                    child: _startGameButtonChild)
            ],
          ),
        )
      ],
    );
  }
}

SnackBar BrotSnackBar(
    {required BuildContext context,
    required Widget content,
    SnackBarAction? action}) {
  return SnackBar(
    action: action,
    content: content,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  );
}
