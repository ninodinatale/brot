import 'dart:async';

import 'package:brot/firebase_functions.dart';
import 'package:brot/models/payload/payloads.dart';
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
    final game = await BrotFirebaseFunctions.callGetGame(
        GetGamePayload(gameKey: widget.gameKey));
    final member = await BrotFirebaseFunctions.callGetMember(GetMemberPayload(
        gameKey: widget.gameKey, memberKey: widget.memberKey!));

    return Tuple2(
        Game(
            key: game.key,
            adminUserId: game.adminUserId,
            gameCode: game.gameCode,
            status: game.status),
        Member(
            key: member.key,
            hasVotedForWord: member.hasVotedForWord,
            isAdmin: member.isAdmin,
            isBread: member.isBread,
            name: member.name,
            points: member.points,
            userId: member.userId));
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

  Stream<UserHasWord> _createUserHasWordStream(UserId userId) {
    return FirebaseDatabase.instance
        .ref('/words/${widget.gameKey}')
        .orderByChild(userId)
        .limitToFirst(1)
        .onValue
        .map((event) {
      logI('onValue fired for path {} with value {}',
          ['/words/${widget.gameKey}', '${event.snapshot.value}']);
      return UserHasWord(event.snapshot.exists);
    });
  }

  Stream<UserHasVotedForWord> _createUserHasVotedForWordStream() {
    return FirebaseDatabase.instance
        .ref('/members/${widget.gameKey}/${widget.memberKey}/hasVotedForWord')
        .onValue
        .map((event) {
      logI('onValue fired for path {} with value {}', [
        '/members/${widget.gameKey}/${widget.memberKey}/hasVotedForWord',
        '${event.snapshot.value}'
      ]);
      return UserHasVotedForWord(event.snapshot.value as bool);
    });
  }

  Stream<Member> _createMemberStream() {
    return FirebaseDatabase.instance
        .ref('/members/${widget.gameKey}/${widget.memberKey}')
        .onChildChanged
        .map((event) {
      logI('onChildChanged fired for path {} with value {}', [
        '/members/${widget.gameKey}/${widget.memberKey}',
        '${event.snapshot.value}'
      ]);
      return Member.fromJson(event.snapshot.value as Map);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = context.read<UserId>();
    return FutureBuilder(
        future: _dependentFutures(userId),
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
                StreamProvider<Member>(
                    initialData: member,
                    create: (context) => _createMemberStream()),
                StreamProvider<GameStatus>(
                    initialData: game.status,
                    create: (context) => _createGameStatusStream()),
                StreamProvider<UserHasWord>(
                    initialData: const UserHasWord(null),
                    create: (context) => _createUserHasWordStream(userId)),
                StreamProvider<UserHasVotedForWord>(
                    initialData: const UserHasVotedForWord(false),
                    create: (context) => _createUserHasVotedForWordStream()),
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
