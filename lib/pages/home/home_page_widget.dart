import 'package:brot/pages/home/create_game_button_widget.dart';
import 'package:brot/pages/home/join_game_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  HomePageWidgetState createState() => HomePageWidgetState();
}

class HomePageWidgetState extends State<HomePageWidget> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: Padding(
        padding: const EdgeInsets.only(top: 100, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('brot.',
                    style: theme.textTheme.displayLarge!
                        .copyWith(color: theme.colorScheme.onPrimary)),
                SvgPicture.asset(
                  'assets/images/bread.svg',
                  fit: BoxFit.scaleDown,
                  height: 200,
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CreateGameButtonWidget(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: JoinGameButtonWidget(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
