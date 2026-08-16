import 'package:flutter/material.dart';
import 'tabs/chat_tab.dart';
import 'tabs/fight_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Parte dal tab "Fight" (indice 1)

  // Lista delle 3 viste principali
  final List<Widget> _tabs = const [
    ChatTab(),
    FightTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: SafeArea(
        // IndexedStack mantiene attivo lo stato delle schermate quando cambi tab
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      // BARRA DI NAVIGAZIONE IN BASSO
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, left: 30, right: 30),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.chat_bubble_outline, 'Chat'),
              _buildNavItem(1, Icons.fitness_center, 'Fight'),
              _buildNavItem(2, Icons.account_circle_outlined, 'Profilo'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index; // Cambia il tab visibile
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black87,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}