import 'package:brot/database.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logger.dart';
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

    createGame(userId).then((data) {
      final route = GameRoute(data.item1, data.item2);
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
