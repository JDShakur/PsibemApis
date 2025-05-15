import 'package:flutter/material.dart';
import 'package:psibem/register/cadastro.dart';
import 'package:psibem/register/cadastro_psi.dart';


class opcadst extends StatelessWidget {
  const opcadst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF81c7c6),
      ),
      backgroundColor: const Color(0xFF81c7c6),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: ListTile(
                  title: Text(
                    'Tipo De Perfil',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 50),
                  ),
                  subtitle: Text(
                    'Nos Ajude a criar a sua conta',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200,
            ),
            ElevatedButton( 
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => CadastroPsi()));
                },
                
                child: const Text(
                  'Psicólogos',
                  style: TextStyle(
                    color: Color(0xFF81c7c6),
                  ),
                ) ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (c) => Cadastro()));
                },
                child: const Text(
                  'Pacientes',
                  style: TextStyle(
                    color: Color(0xFF81c7c6),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
