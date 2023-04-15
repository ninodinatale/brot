import 'dart:async';

import 'package:brot/models/state/game.dart';
import 'package:brot/models/state/member.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:brot/models/state/user_member.dart';
import 'package:brot/models/state/word.dart';
import 'package:brot/pages/game/header_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import 'lobby/members_widget.dart';

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
  /// Game
  late Stream<Game> _valueGameStream;
  late Stream<Game> _changedGameStream;
  late Stream<GameStatus> _changedGameStatusStream;

  late Stream<UserMember> _changedUserMemberStream;
  late Stream<UserMember> _valueUserMemberStream;

  late Stream<bool> _userHasWordStream;

  @override
  void initState() {
    super.initState();
    _valueGameStream = FirebaseDatabase.instance
        .ref('/games/${widget.gameKey}')
        .onValue
        .map((event) {
      logI('onValue fired for path {} with value {}',
          ['/games/${widget.gameKey}', '${event.snapshot.value}']);

      return Game.fromJson(event.snapshot.value as Map);
    }).asBroadcastStream();
    _valueUserMemberStream = FirebaseDatabase.instance
        .ref('/members/${widget.gameKey}/${widget.memberKey}')
        .onValue
        .map((event) {
      logI('onValue fired for path {} with value {}', [
        '/members/${widget.gameKey}/${widget.memberKey}',
        '${event.snapshot.value}'
      ]);
      return UserMember.fromJson(event.snapshot.value as Map);
    }).asBroadcastStream();
    _userHasWordStream = FirebaseDatabase.instance
        .ref('/members/${widget.gameKey}')
        .onChildAdded
        .map((event) {
      logI('onChildAdded fired for path {} with value {}',
          ['/members/${widget.gameKey}', '${event.snapshot.value}']);
      return Word.fromJson(event.snapshot.value as Map).userId ==
          Provider.of<UserId>(context);
    }).asBroadcastStream();
    _changedGameStream = FirebaseDatabase.instance
        .ref('/games/${widget.gameKey}')
        .onChildChanged
        .asyncMap((event) {
      logI('onChildChanged fired for path {} with value {}',
          ['/games/${widget.gameKey}', '${event.snapshot.value}']);
      return event.snapshot.ref.parent!.get();
    }).map((event) {
      return Game.firstFromJson(event.value as Map);
    }).asBroadcastStream();
    _changedGameStatusStream = FirebaseDatabase.instance
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
        blog.e(msg);
        throw TypeError();
      }
    }).asBroadcastStream();
    _changedUserMemberStream = FirebaseDatabase.instance
        .ref('/members/${widget.gameKey}/${widget.memberKey}')
        .onChildChanged
        .asyncMap((event) {
      logI('onChildChanged fired for path {} with value {}', [
        '/members/${widget.gameKey}/${widget.memberKey}',
        '${event.snapshot.value}'
      ]);
      return event.snapshot.ref.parent!.get();
    }).map((event) {
      return UserMember.firstFromJson(event.value as Map);
    }).asBroadcastStream();
  }

  Widget _gameContentBuilder(BuildContext context, GameStatus status) {
    switch (status) {
      case GameStatus.lobby:
      case GameStatus.choosingBread:
        return MembersWidget(widget.gameKey);
      case GameStatus.votingWords:
        // TODO: Handle this case.
        return Text('UNIMPL');
      case GameStatus.playing:
        // TODO: Handle this case.
        return Text('UNIMPL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
        future: _valueGameStream.first.then(
            (game) async => Tuple2(game, await _valueUserMemberStream.first)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MultiProvider(
              providers: [
                StreamProvider<Game>(
                    initialData: snapshot.requireData.item1,
                    create: (context) => _changedGameStream),
                StreamProvider<Member>(
                    initialData: snapshot.requireData.item2,
                    create: (context) => _changedUserMemberStream),
                StreamProvider<GameStatus>(
                    initialData: snapshot.requireData.item1.status,
                    create: (context) => _changedGameStatusStream),
                StreamProvider<UserHasWord>(
                    initialData: false, create: (context) => _userHasWordStream)
              ],
              builder: (context, child) => Column(
                children: [
                  Material(
                      color: Colors.transparent,
                      elevation: 20.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(0.0),
                        ),
                      ),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          child: const HeaderWidget())),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(20), child: child),
                  )
                ],
              ),
              child: Consumer<GameStatus>(
                builder: (context, status, child) =>
                    _gameContentBuilder(context, status),
              ),
            );
          } else {
            return CircularProgressIndicator(
                color: theme.colorScheme.onPrimary);
          }
        });
  }
}
