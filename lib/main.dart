import 'package:brot/firebase_functions.dart';
import 'package:brot/models/state/UserIdState.dart';
import 'package:brot/pages/home/home_page_widget.dart';
import 'package:brot/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    logger.i('using emulators for cloud functions and databse...');
    try {
      // Workaround for https://github.com/firebase/flutterfire/issues/8070
      final emulatorHost =
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              ? '10.0.2.2'
              : 'localhost';

      fbFunctionInstance.useFunctionsEmulator(emulatorHost, 5001);
      FirebaseDatabase.instance.useDatabaseEmulator(emulatorHost, 9000);
    } catch (e) {
      logger.e(e);
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
  late Future<String> _userId;

  @override
  void initState() {
    super.initState();
    _userId = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('userId');
    }).then((value) {
      if (value != null) {
        return Future.value(value);
      } else {
        return callFbFunction('generateUserId')
            .then((value) => value.data as String);
      }
    }).then((userId) {
      _prefs.then((prefs) => prefs.setString('userId', userId)).catchError(
          (error, stackTrace) => logger.e('failed to save userId to prefs'));
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
              TextStyle(fontWeight: FontWeight.bold, letterSpacing: -5),
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
                return Provider<UserIdState>(
                  create: (context) => UserIdState(snapshot.data!),
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
