import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psibem/widget/PageRotation.dart';
import 'package:psibem/widget/custom_text_field.dart';
import 'package:psibem/widget/error_dialog.dart';
import 'package:psibem/widget/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  formValidation() {
    if (_formKey.currentState!.validate()) {
      if (emailController.text.isNotEmpty && senhaController.text.isNotEmpty) {
        loginNow();
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(message: "Email ou senha inválidos");
          },
        );
      }
    }
  }

  Future<void> loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialog(message: "Checando credenciais");
      },
    );

    User? currentUser;
    try {
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );
      currentUser = authResult.user;
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(message: error.toString());
        },
      );
      return;
    }

    if (currentUser != null) {
      await readDataAndSetDataLocally(currentUser).then((userName) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (c) => Pagerotation(),
          ),
        );
      });
    }
  }

  Future<String> readDataAndSetDataLocally(User currentUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(currentUser.uid)
        .get();

    if (snapshot.exists) {
      await prefs.setString("uid", currentUser.uid);
      await prefs.setString("email", emailController.text.trim());

      String userName = snapshot['apelido'];
      return userName;
    }
    return "Usuário"; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF81c7c6),
      ),
      backgroundColor: const Color(0xFF81c7c6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: ListTile(
                title: Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 70),
                ),
                subtitle: Text(
                  'Vamos iniciar a sua jornada?',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 20),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'E-mail',
                    style: TextStyle(color: Colors.white),
                  ),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'E-mail',
                    prefixIcon: Icons.email,
                  ),
                  Text(
                    'Senha',
                    style: TextStyle(color: Colors.white),
                  ),
                  CustomTextField(
                    controller: senhaController,
                    hintText: 'Senha',
                    isObscure: true,
                    prefixIcon: Icons.lock,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                formValidation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                    color: Color(0xff81c7c6), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
