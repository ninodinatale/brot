import 'package:brot/firebase_functions.dart';
import 'package:brot/models/json_serializable/game_model.dart';
import 'package:brot/models/json_serializable/payload.dart';
import 'package:brot/models/state/GameState.dart';
import 'package:brot/models/state/UserIdState.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../router.dart';

final logger = Logger();

class CreateGameButtonWidget extends StatefulWidget {
  const CreateGameButtonWidget({Key? key}) : super(key: key);

  @override
  CreateGameButtonWidgetState createState() => CreateGameButtonWidgetState();
}

class CreateGameButtonWidgetState extends State<CreateGameButtonWidget> {
  bool _isCreateGameLoading = false;

  void _createGamePressed(Payload payload) {
    assert(!_isCreateGameLoading);
    logger.v('creating game for user ${payload.userId}');

    setState(() {
      _isCreateGameLoading = true;
    });

    callFbFunction('createGame', payload).then((result) {
      logger.v('game created, navigating to GameRoute');
      final createGame = GameModel.fromJson(result.data);
      GameRoute(
              gameId: createGame.gameId.toString(),
              $extra: GameState.fromGameModel(createGame))
          .go(context);
    }).catchError((error, stackTrace) {
      logger.e('creating game failed', error, stackTrace);
      // TODO add user notification
    }).whenComplete(() => setState(() {
          _isCreateGameLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserIdState>(
      builder: (context, userIdState, child) => ElevatedButton(
          onPressed: _isCreateGameLoading
              ? null
              : () => _createGamePressed(Payload(userId: userIdState.userId)),
          style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromWidth(500),
              tapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.all(20)),
          child: _isCreateGameLoading
              ? CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                )
              : Text(
                  'spiel erstellen',
                  style: theme.textTheme.titleSmall!
                      .copyWith(color: theme.colorScheme.onPrimary),
                )),
    );
  }
}
