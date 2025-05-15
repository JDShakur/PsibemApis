import 'package:flutter/material.dart';
import 'package:psibem/login/login.dart';
import 'package:psibem/register/opcoes.dart';


class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff81c7c6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('lib/assets/images/light.png'),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (c) => opcadst()));
                },
                child: Text(
                  'Cadastre-se',
                  style: TextStyle(
                    color: const Color(0xFF81c7c6),
                  ),
                )),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (c) => Login()));
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: const Color(0xFF81c7c6),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
