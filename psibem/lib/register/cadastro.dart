import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:psibem/usuarios/views/settings/termosdeuso.dart';
import 'package:psibem/widget/PageRotation.dart';
import 'package:psibem/widget/custom_datafild.dart';
import 'package:psibem/widget/custom_text_field.dart';
import 'package:psibem/widget/error_dialog.dart';
import 'package:psibem/widget/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController apelidocontroller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  TextEditingController confirmasenhaController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  TextEditingController dataController = TextEditingController();
  TextEditingController sexoController = TextEditingController();

  bool _isChecked = false;

  Future<void> registerUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print('User UID: $uid');

      await sendUserDataToBackend(uid, email);
    } on FirebaseAuthException catch (e) {
      print('Falha ao registrar: ${e.message}');
    }
  }

  Future<void> sendUserDataToBackend(String uid, String email) async {
    try {
      String formattedDate = dataController.text;
      List<String> dateParts = formattedDate.split('/');
      String mysqlDate = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

      final response = await http
          .post(
            Uri.parse(
                'http://192.168.1.15/projects/tcc/Phpigni/public/api/register-user'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'uid': uid,
              'email': email,
              'password': senhaController.text.trim(),
              'apelido': apelidocontroller.text.trim(),
              'nome': nomeController.text.trim(),
              'telefone': telefoneController.text.trim(),
              'data': mysqlDate,
              'sexo': sexoController.text.trim(),
            }),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Falha ao salvar na API: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sem conexão com o servidor');
    } on TimeoutException {
      throw Exception('Tempo de conexão esgotado');
    } catch (e) {
      throw Exception('Erro ao enviar dados: $e');
    }
  }

  Future<void> autenticarSalvar() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => LoadingDialog(message: "Registrando sua conta"),
    );

    try {
      // 1. Criar usuário no Firebase Auth
      UserCredential authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (authResult.user == null) throw Exception("Usuário não foi criado");

      // 2. Salvar no Firestore primeiro (mais rápido e confiável)
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(authResult.user!.uid)
          .set({
        "uid": authResult.user!.uid,
        "Email": authResult.user!.email,
        "apelido": apelidocontroller.text.trim(),
        "nome": nomeController.text.trim(),
        "telefone": telefoneController.text.trim(),
        "data": dataController.text.trim(),
        "sexo": sexoController.text.trim(),
        "dataCriacao": FieldValue.serverTimestamp(),
        "tipo": "Paciente",
      });

      // 3. Tentar salvar na API local (se falhar, não impede o cadastro)
      try {
        await sendUserDataToBackend(
          authResult.user!.uid,
          authResult.user!.email ?? emailController.text.trim(),
        );
      } catch (e) {
        debugPrint('Erro ao salvar na API local: $e');
        // Não mostramos erro para o usuário pois o cadastro principal foi feito
      }

      // 4. Salvar localmente
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("uid", authResult.user!.uid);
      await prefs.setString("nome", nomeController.text.trim());
      await prefs.setString("email", authResult.user!.email ?? "");

      // 5. Navegar para a tela principal
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (c) => Pagerotation()),
        );
      }
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context); // Fecha o loading
      String errorMessage = _getFirebaseErrorMessage(error);
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(message: errorMessage),
      );
    } catch (error) {
      Navigator.pop(context); // Fecha o loading
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(
          message: "Erro durante o cadastro: ${error.toString()}",
        ),
      );
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return "E-mail inválido.";
      case 'weak-password':
        return "Senha fraca. Use pelo menos 6 caracteres.";
      case 'email-already-in-use':
        return "E-mail já cadastrado.";
      case 'network-request-failed':
        return "Falha na conexão. Verifique sua internet.";
      default:
        return "Erro ao cadastrar: ${error.message}";
    }
  }

  bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r"^[0-9]{10,11}$").hasMatch(phone);
  }

  bool isValidDate(String date) {
    return RegExp(r"^\d{2}/\d{2}/\d{4}$").hasMatch(date);
  }

  Future<void> formValidation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (senhaController.text != confirmasenhaController.text) {
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(message: 'As senhas não são iguais'),
      );
      return;
    }

    if (!_isChecked) {
      showDialog(
        context: context,
        builder: (c) =>
            ErrorDialog(message: 'Você deve aceitar os termos de uso'),
      );
      return;
    }
    if (apelidocontroller.text.isEmpty ||
        emailController.text.isEmpty ||
        senhaController.text.isEmpty ||
        confirmasenhaController.text.isEmpty ||
        nomeController.text.isEmpty ||
        telefoneController.text.isEmpty ||
        dataController.text.isEmpty ||
        sexoController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: 'Preencha todos os campos de cadastro',
          );
        },
      );
    } else if (!isValidEmail(emailController.text)) {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: 'Por favor, insira um e-mail válido.',
          );
        },
      );
    } else if (!isValidPhone(telefoneController.text)) {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: 'Por favor, insira um telefone válido.',
          );
        },
      );
    } else if (!isValidDate(dataController.text)) {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: 'Por favor, insira uma data válida (DD/MM/AAAA).',
          );
        },
      );
    } else if (!_isChecked) {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: 'Você deve aceitar os termos de uso',
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return LoadingDialog(
            message: "Registrando sua conta",
          );
        },
      );
      autenticarSalvar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF81c7c6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF81c7c6),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: ListTile(
                  title: Text(
                    'Cadastro',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 70),
                  ),
                  subtitle: Text(
                    'Já tem uma conta? Entrar',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('E-mail',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      CustomTextField(
                        controller: emailController,
                        hintText: 'E-mail',
                        prefixIcon: Icons.mail,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (!isValidEmail(value)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      Text('Senha',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      CustomTextField(
                        controller: senhaController,
                        hintText: 'Senha',
                        isObscure: true,
                        prefixIcon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (value.length < 6) {
                            return 'Senha muito curta (mínimo 6 caracteres)';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      Text('Confirme sua senha',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      CustomTextField(
                        controller: confirmasenhaController,
                        hintText: 'Confirme sua senha',
                        isObscure: true,
                        prefixIcon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      Text('Nome completo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      CustomTextField(
                        controller: nomeController,
                        hintText: 'Nome Completo',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      Text('Como deseja ser Chamado?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      CustomTextField(
                        controller: apelidocontroller,
                        hintText: 'Apelido',
                        prefixIcon: Icons.star,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      Text('Telefone',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      PhoneNumberField(
                        controller: telefoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (!isValidPhone(value)) {
                            return 'Telefone inválido';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      Text('Data Nascimento',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      DateOfBirthField(
                        controller: dataController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (!isValidDate(value)) {
                            return 'Data inválida (DD/MM/AAAA)';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      Text('Sexo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      GenderField(
                        controller: sexoController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      boxxS(),
                      // Checkbox e termos de uso
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                          ),
                          Container(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Concordo com os ',
                                    style: TextStyle(color: Color(0xFF208584)),
                                  ),
                                  TextSpan(
                                    text: 'termos de privacidade',
                                    style: const TextStyle(
                                      color: Color(0xFF208584),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled:
                                              true, // Permite rolagem
                                          builder: (context) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.9,
                                              child: TermsOfUseContent(),
                                            ),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  formValidation();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    padding:
                        EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
                child: Text(
                  'Continuar',
                  style: TextStyle(
                      color: Color(0xff81c7c6), fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox boxxS() => SizedBox(height: 16);
}
