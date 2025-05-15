import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:psibem/usuarios/views/meditation/meditationpage.dart';
import 'package:psibem/usuarios/views/moodtracker/emotions_page.dart';
import 'package:psibem/usuarios/views/respiration/respiration_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  @override
  void initState() {
    super.initState();
    _recuperarNomeUsuario();
  }

  Future<void> _recuperarNomeUsuario() async {
    try {     
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {       
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(
                'usuarios') 
            .doc(user.uid) 
            .get();
        if (userDoc.exists) {
          
          String nomeUsuario = userDoc['apelido'] ??
              'Usuário'; 
      
          setState(() {
            userName = nomeUsuario;
          });
        } else {         
          setState(() {
            userName = 'Usuário';
          });
        }
      } else {
        setState(() {
          userName = 'Usuário';
        });
      }
    } catch (e) {
      print("Erro ao recuperar nome do usuário: $e");
      setState(() {
        userName = 'Usuário';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oi, $userName!',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Como você está se sentindo hoje?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 20),
                // Calendário de emoções
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF81C7C6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 10,
                          itemBuilder: (context, index) => Container(
                            width: 70,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.emoji_emotions,
                                color: Colors.teal, size: 32),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                       ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Calendario()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Meu calendário',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontFamily: 'Roboto'),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.grey[700]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Recomendações',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nós selecionamos um plano para você hoje. ;)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 12),
                 _buildRecommendationButton(
                  context,
                  'Fazer uma pausa',
                  'Ansiedade é normal. Vamos respirar juntos?',
                  '5 min',
                  Icons.arrow_forward,
                  () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RespirationPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildRecommendationButton(
                  context,
                  'Meditação',
                  'Que tal uma meditação guiada para relaxar?',
                  '5 min',
                  Icons.arrow_forward,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MeditationPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildRecommendationButton(
                  context,
                  'Ver meu histórico',
                  'Como minhas emoções têm estado ultimamente?',
                  'Ir para calendário',
                  Icons.arrow_forward,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Calendario()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

//Transformar em um widget separado
Widget _buildRecommendationButton(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    IconData? icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal[100],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.teal[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      if (icon != null) Icon(icon, color: Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[800])),
                  if (time.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.teal),
                          const SizedBox(width: 4),
                          Text(time, style: const TextStyle(color: Colors.teal)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
