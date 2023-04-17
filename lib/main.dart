import 'package:brot/constants.dart';
import 'package:brot/models/state/user_id.dart';
import 'package:brot/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'logger.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  if (kDebugMode) {
    logI('using emulators for database');
    try {
      // Workaround for https://github.com/firebase/flutterfire/issues/8070
      final emulatorHost =
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              ? '10.0.2.2'
              : 'localhost';

      FirebaseDatabase.instance.useDatabaseEmulator(emulatorHost, 9000);
    } catch (e) {
      logE('setting up database emulator failed - error: $e');
      return;
    }
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<UserId> _userId;

  @override
  void initState() {
    super.initState();
    _userId = _prefs.then((SharedPreferences prefs) async {
      String? userId = prefs.getString('userId');

      if (userId != null) {
        logI('userId available');
      } else {
        logI('generating userId');
        userId = const Uuid().v1();
      }
      logI('userId is {}', ['$userId']);
      return userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    )));

    return MaterialApp.router(
      title: 'who-is-the-bread',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(241, 241, 241, 1.0),

        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue, accentColor: Colors.purple),

        // Define the default font family.
        fontFamily: 'Poppins',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(fontWeight: FontWeight.bold, letterSpacing: -5),
          displayMedium:
              TextStyle(fontWeight: FontWeight.bold, letterSpacing: -5),
          displaySmall:
              TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1, fontSize: 32),
          //   titleLarge: TextStyle(
          //       fontSize: 48.0, fontWeight: FontWeight.bold, letterSpacing: -1),
          //   titleMedium: TextStyle(
          //       fontSize: 36.0, fontWeight: FontWeight.bold, letterSpacing: -1),
          //   titleSmall: TextStyle(
          //       fontSize: 24.0, fontWeight: FontWeight.bold, letterSpacing: -1),
          //   bodyMedium: TextStyle(
          //       fontSize: 18.0,
          //       color: onScaffoldBackgroundColor),
          //   bodyLarge:
          //       TextStyle(fontSize: 24.0, color: onScaffoldBackgroundColor),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),

        inputDecorationTheme: InputDecorationTheme(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30))),

        // Needed - without buttons in web do not have margins.
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      routerConfig: router,
      builder: (context, child) => FutureBuilder(
        future: _userId,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError || snapshot.data == null) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Provider<UserId>(
                  create: (context) => snapshot.requireData,
                  child: Scaffold(
                    key: scaffoldKey,
                    body: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.asset(
                            'assets/images/page_background@2x.png',
                          ).image,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          if (constraints.maxWidth > 600) {
                            return Center(
                                child: SizedBox(
                              width: 600,
                              child: child,
                            ));
                          } else {
                            return Center(child: child);
                          }
                        },
                      ),
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

class SplashScreenWidget extends StatefulWidget {
  SplashScreenWidget({super.key});

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidget();
}

class _SplashScreenWidget extends State<SplashScreenWidget> {
  bool _shouldInitSplash = true;

  void _postFrameCallback(_) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) async {
      _shouldInitSplash = false;
      final pendingGameKey = prefs.getString(PENDING_GAME_PREFS_KEY);
      if (pendingGameKey != null && pendingGameKey.isNotEmpty) {
        final userId = context.read<UserId>();
        logI('pending game with key {} available, getting member key...',
            ['$pendingGameKey']);
        final dbSnap = await FirebaseDatabase.instance
            .ref('members/$pendingGameKey')
            .orderByChild('userId')
            .equalTo(userId)
            .get();

        if (dbSnap.exists) {
          final memberKey = dbSnap.children.first.key!;
          logI('member key is {}\nnavigating to game with key {}',
              ['$memberKey', '$pendingGameKey']);

          // ignore: use_build_context_synchronously
          if (!context.mounted) {
            const e = 'context not mounted, cannot navigate!';
            logE(e);
            throw StateError(e);
          } else {
            FlutterNativeSplash.remove();
            // ignore: use_build_context_synchronously
            GameRoute(pendingGameKey, memberKey).go(context);
            return;
          }
        } else {
          logW(
              'could not find a member entry for game $pendingGameKey and user $userId\nremoving pending game from cache');
          await prefs.remove('pendingGameKey');
        }
      } else {
        logI('user is not member of an active game');
      }
      FlutterNativeSplash.remove();
      // ignore: use_build_context_synchronously
      const HomeRoute().go(context);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldInitSplash) {
      SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);
    }
    return Container();
  }
}
