import 'package:brot/firebase_functions.dart';
import 'package:brot/models/json_serializable/game_model.dart';
import 'package:brot/models/json_serializable/payload.dart';
import 'package:brot/models/state/GameState.dart';
import 'package:brot/models/state/UserIdState.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../router.dart';

final logger = Logger();

class JoinGameButtonWidget extends StatefulWidget {
  const JoinGameButtonWidget({Key? key}) : super(key: key);

  @override
  JoinGameButtonWidgetState createState() => JoinGameButtonWidgetState();
}

class JoinGameButtonWidgetState extends State<JoinGameButtonWidget> {
  late TextEditingController _controller;

  bool _isValid = false;
  var _isGameNotFound = false;
  var _isJoinGameLoading = false;

  void _joinGame(void Function(void Function()) setState,
      DataPayload<JoinGamePayload> payload) {
    logger.v(
        'joining game for user ${payload.userId} with gameId ${payload.data.gameId}');
    setState(() {
      _isJoinGameLoading = true;
      _isGameNotFound = false;
    });

    callFbFunction('joinGame', payload).then((result) {
      logger.v('game created, navigating...');
      final game = GameModel.fromJson(result.data);
      GameRoute(
              gameId: game.gameId.toString(),
              $extra: GameState.fromGameModel(game))
          .go(context);
    }).catchError((error, stackTrace) {
      // TODO add user notification
      if (error.code == 'not-found') {
        setState(() {
          _isGameNotFound = true;
        });
      } else {
        logger.e('joining game failed', error, stackTrace);
      }
    }).whenComplete(() => setState(() => _isJoinGameLoading = false));
  }

  void _joinGamePressed() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Spiel beitreten'),
                content: TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  onChanged: (value) {
                    _isGameNotFound = false;
                    setState(() {
                      _isValid = value.length == 6;
                    });
                  },
                  controller: _controller,
                  decoration: InputDecoration(
                      label: const Text('Spiel-Code'),
                      errorText: _isGameNotFound
                          ? 'Spiel mit diesem Code existiert nicht'
                          : null),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Abbrechen'),
                  ),
                  Consumer<UserIdState>(
                    builder: (context, userIdState, child) => ElevatedButton(
                      onPressed: _isValid
                          ? () => _joinGame(
                              setState,
                              DataPayload<JoinGamePayload>(
                                  data: JoinGamePayload(
                                      gameId: _controller.value.text),
                                  userId: userIdState.userId))
                          : null,
                      child: _isJoinGameLoading
                          ? CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : const Text('Beitreten'),
                    ),
                  ),
                ],
              ),
            ));
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
        onPressed: () => _joinGamePressed(),
        style: ElevatedButton.styleFrom(
            fixedSize: Size.fromWidth(500),
            tapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: theme.colorScheme.secondary,
            padding: EdgeInsets.all(20)),
        child: Text(
          'spiel beitreten',
          style: theme.textTheme.titleSmall!
              .copyWith(color: theme.colorScheme.onSecondary),
        ));
  }
}
