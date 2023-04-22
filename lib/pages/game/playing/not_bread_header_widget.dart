import 'package:brot/models/state/member.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../../models/state/game.dart';
import '../../../models/state/user_id.dart';
import '../../../models/state/word.dart';

class NotBreadHeaderWidget extends StatefulWidget {
  const NotBreadHeaderWidget({
    super.key,
  });

  @override
  State<NotBreadHeaderWidget> createState() => _NotBreadHeaderWidgetState();
}

class _NotBreadHeaderWidgetState extends State<NotBreadHeaderWidget> {
  late TextEditingController _controller;
  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(NotBreadHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _enterWord() {
    showModalBottomSheet<void>(
        isDismissible: false,
        context: context,
        builder: (BuildContext modalContext) {
          final theme = Theme.of(context);
          return StatefulBuilder(
            builder: (statefulBuilderCtx, setState) => Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                      style: theme.textTheme.bodyMedium,
                      decoration: const InputDecoration(
                          label: Text('Wort vorschlagen...')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: FilledButton(
                        onPressed: _isValid
                            ? () {
                                final game = context.read<Game>();
                                final userId = context.read<UserId>();
                                logI(
                                    'setting word {} for game {} with userId {}',
                                    [
                                      '${_controller.value.text}',
                                      '$game',
                                      '$userId'
                                    ]);
                                setState(() {
                                  _isLoading = true;
                                });
                                final ref = FirebaseDatabase.instance
                                    .ref('/words/${game.key}')
                                    .push();
                                final word = Word(
                                    key: ref.key!,
                                    gameKey: game.key,
                                    value: _controller.value.text,
                                    userId: userId);
                                ref.set(word.toJson()).then((value) {
                                  logI('word {} created', ['$word']);
                                  Navigator.pop(context);
                                });
                              }
                            : null,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.check)),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userHasWord = Provider.of<UserHasWord>(context);
    final userIsBread = Provider.of<UserIsBread>(context);

    if (userHasWord.value == null) {
      return Container();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!userIsBread.value && !userHasWord.value!) {
        _enterWord();
      }
    });
    return Center(
      child: Text(
        'Vote für ein Wort 👇',
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
