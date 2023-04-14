import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:brot/models/state/word.dart';
import 'package:brot/widgets/suited_loading_spinner_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterWordWidget extends StatefulWidget {
  const EnterWordWidget({Key? key}) : super(key: key);

  @override
  _EnterWordWidgetState createState() => _EnterWordWidgetState();
}

class _EnterWordWidgetState extends State<EnterWordWidget> {
  late TextEditingController _controller;
  bool _isLoading = false;
  bool _isValid = false;

  void _setWord(Game game, String userId) {
    setState(() {
      _isLoading = true;
    });
    final word = Word(value: _controller.value.text, userId: userId);
    FirebaseDatabase.instance
        .ref('/words/${game.key}')
        .push()
        .set(word.toJson());
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
    final userId = Provider.of<UserId>(context);

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
            decoration:
                const InputDecoration(label: Text('Wort vorschlagen...')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            child: FilledButton(
                onPressed: _isValid ? () => _setWord(game, userId) : null,
                child: !_isLoading
                    ? SuitedLoadingSpinner(
                        color: theme.colorScheme.onPrimary,
                      )
                    : const Icon(Icons.check)),
          ),
        )
      ],
    );
  }
}
