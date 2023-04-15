import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../models/state/user_id.dart';
import 'enter_word_widget.dart';

class NotBreadHeaderWidget extends StatelessWidget {
  const NotBreadHeaderWidget({
    super.key,
    required this.gameKey,
    required this.userId,
  });

  final String gameKey;
  final UserId userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseDatabase.instance
            .ref('/words/$gameKey')
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
