import 'dart:async';
import 'package:flutter/material.dart';
import 'package:psibem/login/login_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  startTimer() {
    Timer(const Duration(seconds: 5), () async {
      Navigator.push(context, MaterialPageRoute(builder: (c) => Loginscreen()));
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: const Color(0xff81c7c6),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset("lib/assets/images/light.png"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
