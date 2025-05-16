// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não são suportadas para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDrphS62M2xPO_lCtPvbUj-mrGdhMKw5zU",
      authDomain: "psibem-8274f.firebaseapp.com",
      databaseURL: "https://psibem-8274f-default-rtdb.firebaseio.com",
      projectId: "psibem-8274f",
      storageBucket: "psibem-8274f.appspot.com",
      messagingSenderId: "1096721280070",
      appId: "1:1096721280070:web:c03e3dc56116532f192e47",
      measurementId: "G-YLCZ6F8N3K");

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAP2D6VXyg76SDA0g6u0p_OUbBZM4fXPb4',
    appId: '1:1096721280070:android:a8d40c867e27c21c192e47',
    messagingSenderId: '1096721280070',
    projectId: 'psibem-8274f',
    storageBucket: 'psibem-8274f.appspot.com',
  );

  // Configuração para iOS (se necessário)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUA_API_KEY_IOS', // Encontre no app iOS no Firebase
    appId: '1:1096721280070:ios:3a9f1b2c4f5d6e7f8g9h0',
    messagingSenderId: '1096721280070',
    projectId: 'psibem-8274f',
    storageBucket: 'psibem-8274f.appspot.com',
    iosBundleId: 'com.example.psibem',
  );
}
