import 'package:brot/models/state/game.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../../models/state/member.dart';

class EnterNameWidget extends StatefulWidget {
  const EnterNameWidget({Key? key}) : super(key: key);

  @override
  _EnterNameWidgetState createState() => _EnterNameWidgetState();
}

class _EnterNameWidgetState extends State<EnterNameWidget> {
  late TextEditingController _controller;
  bool _isLoading = false;
  bool _isValid = false;

  void _setUserName(Game game, Member userMember) {
    logI('set name for member {} to {} for game {}',
        ['$userMember', '${_controller.value.text}', '$game']);
    setState(() {
      _isLoading = true;
    });
    FirebaseDatabase.instance
        .ref('/members/${game.key}/${userMember.key}')
        .update({'name': _controller.value.text});
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
    final game = Provider.of<Game>(context);
    final userMember = Provider.of<Member>(context);

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
            style: theme.textTheme.bodyMedium,
            decoration: const InputDecoration(label: Text('Dein Name')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            child: FilledButton(
                onPressed:
                    _isValid ? () => _setUserName(game, userMember) : null,
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
  }
}
