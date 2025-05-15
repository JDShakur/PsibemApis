import 'package:flutter/material.dart';

class CustomBottomNavbarpac extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavbarpac({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: const Color(0xFF81C7C6),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('lib/assets/images/home_icon.png')),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('lib/assets/images/emotions_icon.png')),
          label: 'Emoções',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('lib/assets/images/breath_icon.png')),
          label: 'Respire',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('lib/assets/images/psi_icon.png')),
          label: 'Psicólogos',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('lib/assets/images/profile_icon.png')),
          label: 'Meu Perfil',
        ),
      ],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
    );
  }
}
