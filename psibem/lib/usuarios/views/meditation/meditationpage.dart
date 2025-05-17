import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psibem/usuarios/views/meditation/playerpage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditações Guiadas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MeditationPage(),
    );
  }
}

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  _MeditationPageState createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função para navegar para a página do player
  void _navigateToAudioPage(BuildContext context, String title,
      String description, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeditationPlayerPage(
          title: title,
          description: description,
          imagePath: imagePath,
          audioUrl: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: const Color(0xFF81C7C6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Meditações Guiadas',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'HelveticaNeue',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF81C7C6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('lib/assets/images/menditation1.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                textAlign: TextAlign.center,
                'Meditações',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavigationButton('Iniciantes', 0),
                  _buildNavigationButton('Para Relaxar', 1),
                  _buildNavigationButton('Diário', 2),
                ],
              ),
            ),

            // Seções
            _buildSection(
              title: 'Para Iniciantes',
              isVisible: _selectedIndex == 0,
              button1Title: 'Encontrando a Paz Interior',
              button1Duration: '5min',
              button1Image: 'lib/assets/images/meditation7.jpg',
              button2Title: 'A Força do Silêncio',
              button2Duration: '10min',
              button2Image: 'lib/assets/images/meditation2.jpg',
            ),
            _buildSection(
              title: 'Para Relaxar',
              isVisible: _selectedIndex == 1,
              button1Title: 'Respiração Profunda',
              button1Duration: '7min',
              button1Image: 'lib/assets/images/meditation3.jpg',
              button2Title: 'Meditação Guiada',
              button2Duration: '15min',
              button2Image: 'lib/assets/images/meditation4.jpg',
            ),
            _buildSection(
              title: 'Diário',
              isVisible: _selectedIndex == 2,
              button1Title: 'Reflexão Matinal',
              button1Duration: '5min',
              button1Image: 'lib/assets/images/meditation5.jpg',
              button2Title: 'Gratidão',
              button2Duration: '10min',
              button2Image: 'lib/assets/images/meditation6.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String text, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color:
              _selectedIndex == index ? Colors.white : const Color(0xFFF6F9FC),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF208584),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isVisible,
    required String button1Title,
    required String button1Duration,
    required String button1Image,
    required String button2Title,
    required String button2Duration,
    required String button2Image,
  }) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF208584),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMeditationButton(
                    title: button1Title,
                    duration: button1Duration,
                    imagePath: button1Image,
                    audioUrl: ''),
                _buildMeditationButton(
                    title: button2Title,
                    duration: button2Duration,
                    imagePath: button2Image,
                    audioUrl: ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationButton(
      {required String title,
      required String duration,
      required String imagePath,
      required String audioUrl}) {
    return GestureDetector(
      onTap: () => _navigateToAudioPage(
        context,
        title,
        'Descrição da meditação...',
        imagePath,
      ),
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF208584),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 150,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF208584),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  duration,
                  style: const TextStyle(
                    color: Color(0xFF208584),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
