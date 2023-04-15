import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:brot/pages/game/playing/enter_word_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayingHeaderWidget extends StatelessWidget {
  const PlayingHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final gameKey = Provider.of<Game>(context).key;
    final userId = Provider.of<UserId>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
      child: FutureBuilder(
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
                    child: Text('???'),
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
          }),
    );
  }
}
