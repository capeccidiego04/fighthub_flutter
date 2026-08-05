import 'package:flutter/material.dart';
import 'view/login_screen.dart'; // Importa la nuova schermata

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FightHub App',
      theme: ThemeData(
        brightness: Brightness.dark, // Imposta il tema scuro di base
        primarySwatch: Colors.red, // Eventuale colore primario
      ),
      home: const LoginScreen(), // Imposta LoginScreen come schermata iniziale
    );
  }
}