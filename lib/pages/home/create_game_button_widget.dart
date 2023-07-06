import 'package:brot/firebase_functions.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logger.dart';
import '../../models/payload/payloads.dart';
import '../../router.dart';

class CreateGameButtonWidget extends StatefulWidget {
  const CreateGameButtonWidget({Key? key}) : super(key: key);

  @override
  CreateGameButtonWidgetState createState() => CreateGameButtonWidgetState();
}

class CreateGameButtonWidgetState extends State<CreateGameButtonWidget> {
  bool _isCreateGameLoading = false;

  void _createGamePressed(String userId) {
    assert(!_isCreateGameLoading);

    setState(() {
      _isCreateGameLoading = true;
    });

    BrotFirebaseFunctions.callCreateGame(CreateGamePayload(userId: userId))
        .then((result) {
      final route = GameRoute(result.gameKey, result.memberKey);
      logI('navigating to ', ['${route.location}']);
      route.go(context);
    }).whenComplete(() => setState(() {
              _isCreateGameLoading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserId>(
      builder: (context, userId, child) => ElevatedButton(
          onPressed:
              _isCreateGameLoading ? null : () => _createGamePressed(userId),
          style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              fixedSize: const Size.fromWidth(500),
              padding: const EdgeInsets.all(20)),
          child: _isCreateGameLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text(
                  'Spiel erstellen',
                )),
    );
  }
}
