import 'package:brot/constants.dart';
import 'package:brot/database.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logger.dart';
import '../../router.dart';
import '../../widgets/bottom_sheet_modal.dart';

class JoinGameButtonWidget extends StatefulWidget {
  const JoinGameButtonWidget({Key? key}) : super(key: key);

  @override
  JoinGameButtonWidgetState createState() => JoinGameButtonWidgetState();
}

class JoinGameButtonWidgetState extends State<JoinGameButtonWidget> {
  late TextEditingController _controller;

  bool _isValid = false;
  var _isGameNotFound = false;
  var _isGameStarted = false;
  var _isJoinGameLoading = false;

  String? get _errorText {
    if (_isGameNotFound) {
      return 'Spiel mit diesem Code existiert nicht';
    }
    if (_isGameStarted) {
      return 'Spiel bereits gestartet';
    }
    return null;
  }

  void _joinGame(
      void Function(void Function()) setState, String userId, String gameCode) {
    setState(() {
      _isJoinGameLoading = true;
      _isGameNotFound = false;
    });

    joinGame(userId, gameCode).then((data) {
      final route = GameRoute(data.item1, data.item2);
      logI('navigating to {}', ['${route.location}']);
      route.go(context);
    }).catchError((error, stackTrace) {
      if (error['code'] == ErrorCodes.gameNotFound) {
        setState(() {
          _isGameNotFound = true;
        });
      } else if (error['code'] == ErrorCodes.gameAlreadyStarted) {
        setState(() {
          _isGameStarted = true;
        });
      } else {
        logE('joining game failed, error: $error');
      }
    }).whenComplete(() => setState(() => _isJoinGameLoading = false));
  }

  void _joinGamePressed() {
    brotModalBottomSheet<void>(
        isDismissible: true,
        context: context,
        child: StatefulBuilder(
          builder: (statefulBuilderCtx, setState) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: false, signed: false),
                    onChanged: (value) {
                      _isGameNotFound = false;
                      _isGameStarted = false;
                      setState(() {
                        _isValid = value.length == 6;
                      });
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                        label: const Text('Spiel-Code'), errorText: _errorText),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    child: FilledButton(
                      onPressed: _isValid
                          ? () => _joinGame(
                              setState,
                              statefulBuilderCtx.read<UserId>(),
                              _controller.value.text)
                          : null,
                      child: _isJoinGameLoading
                          ? CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : const Text('Beitreten'),
                    ),
                  ),
                )
              ],
            );
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
        ));
  }
}
