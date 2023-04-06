import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/state/GameState.dart';

class EnterNameWidget extends StatefulWidget {
  const EnterNameWidget({Key? key}) : super(key: key);

  @override
  _EnterNameWidgetState createState() => _EnterNameWidgetState();
}

class _EnterNameWidgetState extends State<EnterNameWidget> {
  late TextEditingController _controller;
  bool _isLoading = false;
  bool _isValid = false;

  void _setUserName(GameState game) {
    setState(() {
      _isLoading = true;
    });
    FirebaseDatabase.instance
        .ref('/games/${game.id}/members/${game.userId}/name')
        .set(_controller.value.text);
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
    final gameState = Provider.of<GameState>(context);

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
            decoration: InputDecoration(label: const Text('Dein Name')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            child: FilledButton(
                onPressed: _isValid ? () => _setUserName(gameState) : null,
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
