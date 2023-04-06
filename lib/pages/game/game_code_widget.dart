import 'package:brot/router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/state/GameState.dart';

class GameCodeWidget extends StatefulWidget {
  const GameCodeWidget({Key? key}) : super(key: key);

  @override
  _GameCodeWidgetState createState() => _GameCodeWidgetState();
}

class _GameCodeWidgetState extends State<GameCodeWidget> {
  void leaveGame(GameState game) {
    FirebaseDatabase.instance
        .ref('/games/${game.id}/members/${game.userId}')
        .remove();
    const HomeRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = Provider.of<GameState>(context);

    return Column(
      children: [
        Center(
          child: Pulse(
              preferences: const AnimationPreferences(
                  offset: Duration(seconds: 2),
                  magnitude: 10,
                  autoPlay: AnimationPlayStates.Loop),
              child: Text(gameState.id.toString(),
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
                                      onPressed: () => leaveGame(gameState),
                                      child: Text('Verlassen',
                                          style: TextStyle(
                                              color: theme.colorScheme.error)),
                                    ),
                                  ],
                                )),
                      },
                  child: const Text('Verlassen')),
              ElevatedButton(onPressed: () => {}, child: const Text('Start'))
            ],
          ),
        )
      ],
    );
  }
}
