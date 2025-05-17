import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:psibem/login/login.dart';
import 'package:psibem/widget/PageRotation.dart';
import 'package:psibem/widget/firebase_options.dart';
import 'package:psibem/login/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            initialRoute: '/splash',
            debugShowCheckedModeBanner: false,
            routes: {
              '/splash': (context) => const Splashscreen(),
              '/login': (context) => Login(),
              '/home': (context) => Pagerotation(),
            },
            title: 'Mood Tracker',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Splashscreen(),
          );
        }

        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
