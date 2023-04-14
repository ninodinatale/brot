import 'package:brot/main.dart';
import 'package:brot/pages/game/game_page_widget.dart';
import 'package:brot/pages/home/home_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'router.g.dart';

final router = GoRouter(routes: $appRoutes);

@TypedGoRoute<RootRoute>(
  path: '/',
)
@immutable
class RootRoute extends GoRouteData {
  const RootRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SplashScreenWidget();
  }
}

@TypedGoRoute<HomeRoute>(
  path: '/home',
)
@immutable
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePageWidget();
  }
}

@TypedGoRoute<GameRoute>(
  path: '/game/:gameKey',
)
@immutable
class GameRoute extends GoRouteData {
  const GameRoute(this.gameKey, [this.$extra]);

  final String gameKey;
  final String? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GamePageWidget(gameKey: gameKey, memberKey: $extra);
  }
}
