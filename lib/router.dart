import 'package:brot/models/json_serializable/game_model.dart';
import 'package:brot/pages/game/game_page_widget.dart';
import 'package:brot/pages/home/home_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/state/GameState.dart';

part 'router.g.dart';

final router = GoRouter(routes: $appRoutes);

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<GameRoute>(path: 'game/:gameId'),
  ],
)
@immutable
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePageWidget();
  }
}

@immutable
class GameRoute extends GoRouteData {
  const GameRoute({required this.gameId, this.$extra});

  final String gameId;
  final GameState? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GamePageWidget(gameState: $extra);
  }
}
