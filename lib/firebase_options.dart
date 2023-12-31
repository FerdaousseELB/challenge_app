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
        return macos;
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
    apiKey: 'AIzaSyCgPHFtERv2IBstHo1cp8qe3DVus8yBuAg',
    appId: '1:291673035555:web:547374726334efb146f296',
    messagingSenderId: '291673035555',
    projectId: 'challenge-d50e0',
    authDomain: 'challenge-d50e0.firebaseapp.com',
    databaseURL: 'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'challenge-d50e0.appspot.com',
    measurementId: 'G-G84VDNWY4V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC21qx5uKVeCFJ6qz01wk8s6IId4W8rsiY',
    appId: '1:291673035555:android:bfcdbf5e828b6fee46f296',
    messagingSenderId: '291673035555',
    projectId: 'challenge-d50e0',
    databaseURL: 'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'challenge-d50e0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlQRZ_o5gwc5GuBAVfN_H_CW8XNsTTsnk',
    appId: '1:291673035555:ios:c733b05694287ccf46f296',
    messagingSenderId: '291673035555',
    projectId: 'challenge-d50e0',
    databaseURL: 'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'challenge-d50e0.appspot.com',
    iosClientId: '291673035555-4hadl01sv25cqvpri2r0cbuklvfbmvs9.apps.googleusercontent.com',
    iosBundleId: 'com.example.challengeApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBlQRZ_o5gwc5GuBAVfN_H_CW8XNsTTsnk',
    appId: '1:291673035555:ios:c733b05694287ccf46f296',
    messagingSenderId: '291673035555',
    projectId: 'challenge-d50e0',
    databaseURL: 'https://challenge-d50e0-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'challenge-d50e0.appspot.com',
    iosClientId: '291673035555-4hadl01sv25cqvpri2r0cbuklvfbmvs9.apps.googleusercontent.com',
    iosBundleId: 'com.example.challengeApp',
  );
}
