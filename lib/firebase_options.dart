// PLACEHOLDER - replace this file by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// FlutterFire CLI will overwrite this file with your Firebase project's keys.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured yet. Run "flutterfire configure" '
      'to generate lib/firebase_options.dart.',
    );
  }
}
