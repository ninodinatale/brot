import 'package:brot/pages/game/playing_header_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/json_serializable/game_model.dart';
import '../../models/state/GameState.dart';
import '../../models/state/MembersState.dart';
import 'lobby_header_widget.dart';
import 'members_widget.dart';

class GamePageWidget extends StatefulWidget {
  const GamePageWidget({Key? key, this.gameState})
      : assert(gameState != null),
        super(key: key);
  final GameState? gameState;

  @override
  GamePageWidgetState createState() => GamePageWidgetState();
}

class GamePageWidgetState extends State<GamePageWidget> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameState>(
            create: (context) => widget.gameState!),
        ChangeNotifierProvider<MembersState>(
            create: (context) => MembersState())
      ],
      builder: (context, child) => const GameStateInitializerWidget(),
    );
  }
}

class GameStateInitializerWidget extends StatefulWidget {
  const GameStateInitializerWidget({
    super.key,
  });

  @override
  State<GameStateInitializerWidget> createState() =>
      _GameStateInitializerWidgetState();
}

class _GameStateInitializerWidgetState
    extends State<GameStateInitializerWidget> {
  late GameState _game;

  Widget get _headerWidget {
    switch (_game.status) {
      case GameStatus.lobby:
        return LobbyHeaderWidget(userId: _game.userId);
        return PlayingHeaderWidget(userId: _game.userId);
      case GameStatus.playing:
        return PlayingHeaderWidget(userId: _game.userId);
    }
  }

  @override
  void initState() {
    super.initState();
    _game = Provider.of<GameState>(context, listen: false);
    FirebaseDatabase.instance
        .ref('/games/${_game.id}/members')
        .onValue
        .listen((event) {
      final membersModel = MembersModel.fromJson(
          {'members': Map<String, Map>.from(event.snapshot.value as Map)});

      Provider.of<MembersState>(context, listen: false)
          .updateMembers(membersModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
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
            child: _headerWidget,
          ),
        ),
        const Expanded(
          child: Padding(padding: EdgeInsets.all(20), child: MembersWidget()),
        )
      ],
    );
  }
}
