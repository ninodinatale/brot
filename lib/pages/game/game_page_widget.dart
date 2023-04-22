import 'dart:async';

import 'package:brot/database.dart';
import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/member.dart';
import 'package:brot/models/state/word.dart';
import 'package:brot/pages/game/content_widget.dart';
import 'package:brot/pages/game/header_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../../models/state/user_id.dart';

class GamePageWidget extends StatefulWidget {
  const GamePageWidget({Key? key, required this.gameKey, this.memberKey})
      : assert(memberKey != null),
        super(key: key);
  final String gameKey;
  final String? memberKey;

  @override
  _GamePageWidgetState createState() => _GamePageWidgetState();
}

class _GamePageWidgetState extends State<GamePageWidget> {

  Future<Tuple2<Game, Member>> _dependentFutures(UserId userId) async {
    final game = await getGame(widget.gameKey);
    final member = await getMember(widget.gameKey, widget.memberKey!);

    return Tuple2(game, member);
  }

  Stream<GameStatus> _createGameStatusStream() {
    return FirebaseDatabase.instance
        .ref('/games/${widget.gameKey}/status')
        .onValue
        .map((event) {
      logI('onValue fired for path {} with value {}',
          ['/games/${widget.gameKey}/status', '${event.snapshot.value}']);
      if (event.snapshot.value is int) {
        return GameStatus.values[event.snapshot.value as int];
      } else {
        final msg =
            'expected value to be of type int, but was ${event.snapshot.value.runtimeType}';
        logE(msg);
        throw TypeError();
      }
    });
  }

  Stream<UserIsBread> _createUserIsBreadStream() {
    return FirebaseDatabase.instance
        .ref('/members/${widget.gameKey}/${widget.memberKey}')
        .onValue
        .map((event) {
      logI('onValue fired for path {} with value {}', [
        '/members/${widget.gameKey}/${widget.memberKey}',
        '${event.snapshot.value}'
      ]);
      return UserIsBread(Member.fromJson(event.snapshot.value as Map).isBread);
    });
  }

  Stream<UserHasWord> _createUserHasWordStream() {
    return FirebaseDatabase.instance
        .ref('/members/${widget.gameKey}/${widget.memberKey}/hasVotedForWord')
        .onValue
        .map((event) {
      logI('onValue fired for path {} with value {}', [
        '/members/${widget.gameKey}/${widget.memberKey}/hasVotedForWord',
        '${event.snapshot.value}'
      ]);
      return UserHasWord(event.snapshot.value as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
        future: _dependentFutures(context.read<UserId>()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logE(snapshot.error.toString());
            return Center(child: Text('There was a problem :( try again.'));
          }
          if (snapshot.hasData) {
            final game = snapshot.requireData.item1;
            final member = snapshot.requireData.item2;
            return MultiProvider(
              providers: [
                ListenableProvider<Game>(create: (context) => game),
                ListenableProvider<Member>(create: (context) => member),
                StreamProvider<GameStatus>(
                    initialData: game.status,
                    create: (context) => _createGameStatusStream()),
                StreamProvider<UserHasWord>(
                    initialData: const UserHasWord(null),
                    create: (context) => _createUserHasWordStream()),
                StreamProvider<UserIsBread>(
                    initialData: UserIsBread(member.isBread),
                    create: (context) => _createUserIsBreadStream()),
              ],
              builder: (context, child) => Column(
                children: [
                  const HeaderWidget(),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(20), child: child),
                  )
                ],
              ),
              child: Consumer<Game>(
                  builder: (context, game, child) => ContentWidget(
                        gameKey: game.key,
                      )),
            );
          } else {
            return CircularProgressIndicator(
                color: theme.colorScheme.onPrimary);
          }
        });
  }
}
