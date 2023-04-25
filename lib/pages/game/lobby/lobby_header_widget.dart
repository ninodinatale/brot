import 'package:brot/pages/game/lobby/game_code_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../../models/state/game.dart';
import '../../../models/state/member.dart';
import '../../../widgets/bottom_sheet_modal.dart';

class LobbyHeaderWidget extends StatefulWidget {
  const LobbyHeaderWidget({super.key});

  @override
  State<LobbyHeaderWidget> createState() => _LobbyHeaderWidgetState();
}

class _LobbyHeaderWidgetState extends State<LobbyHeaderWidget> {
  bool _isLoading = false;
  bool _isValid = true;
  final _key = GlobalKey();
  late TextEditingController _controller;

  Future<void> _setUserName(Game game, Member userMember) {
    logI('set name for member {} to {} for game {}',
        ['$userMember', '${_controller.value.text}', '$game']);
    setState(() {
      _isLoading = true;
    });
    return FirebaseDatabase.instance
        .ref('/members/${game.key}/${userMember.key}')
        .update({'name': _controller.value.text});
  }

  void _enterName(BuildContext context, Game game, Member userMember) {
    brotModalBottomSheet<void>(
        context: context,
        child: StatefulBuilder(
          key: _key,
          builder: (statefulBuilderCtx, setState) {
            final theme = Theme.of(context);
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: !_isLoading,
                    onChanged: (value) {
                      if (_isValid && value.length < 3) {
                        setState(() {
                          _isValid = false;
                        });
                      } else if (!_isValid && value.length >= 3) {
                        setState(() {
                          _isValid = true;
                        });
                      }
                    },
                    controller: _controller,
                    decoration: const InputDecoration(label: Text('Dein Name')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    child: FilledButton(
                        onPressed: _isValid
                            ? () => _setUserName(game, userMember).whenComplete(() => statefulBuilderCtx.pop())
                            : null,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary),
                              )
                            : const Icon(Icons.check)),
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
    final userMember = Provider.of<Member>(context);
    final game = Provider.of<Game>(context);
    if (_key.currentWidget == null && userMember.name == '') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enterName(context, game, userMember);
      });
    }
    return const GameCodeWidget();
  }
}
