import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/state/game.dart';
import '../../../models/state/user_id.dart';
import 'enter_word_widget.dart';

class NotBreadHeaderWidget extends StatelessWidget {
  const NotBreadHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<Game>(context);
    final userId = Provider.of<UserId>(context);
    return FutureBuilder(
        future: FirebaseDatabase.instance
            .ref('/words/${game.key}')
            .orderByChild('userId')
            .equalTo(userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.requireData.exists) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('UNIMPL'),
                ),
              );
            } else {
              return const EnterWordWidget();
            }
          } else {
            return SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary),
            );
          }
        });
  }
}
