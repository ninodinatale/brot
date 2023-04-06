// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyApdA18Vq6fd5oMk9ajn6SnQaXl13IDcWU',
    appId: '1:157424518991:web:a9313cd1e431ff2093273a',
    messagingSenderId: '157424518991',
    projectId: 'who-is-the-bread',
    authDomain: 'who-is-the-bread.firebaseapp.com',
    databaseURL: 'https://who-is-the-bread-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'who-is-the-bread.appspot.com',
    measurementId: 'G-VM425S4ZMY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCunwiFI9qVJyhvhyyyx0YTr1JRlzVdqdI',
    appId: '1:157424518991:android:7ae0c70d48cadace93273a',
    messagingSenderId: '157424518991',
    projectId: 'who-is-the-bread',
    databaseURL: 'https://who-is-the-bread-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'who-is-the-bread.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3alwC6Tns9ySuiS7cOC6FTF7CiBPjx7c',
    appId: '1:157424518991:ios:f5d4c5206e77cc9593273a',
    messagingSenderId: '157424518991',
    projectId: 'who-is-the-bread',
    databaseURL: 'https://who-is-the-bread-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'who-is-the-bread.appspot.com',
    androidClientId: '157424518991-2ie1h3d15o9rjhcrmaqj913a8hptolvk.apps.googleusercontent.com',
    iosClientId: '157424518991-bnq4q9toommr61u8ba0lb0dlrpgith4h.apps.googleusercontent.com',
    iosBundleId: 'com.example.brot',
  );
}
