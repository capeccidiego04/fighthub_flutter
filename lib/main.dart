import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_wrapper.dart';
import 'controller/firebase_options.dart';
import 'view/login_screen.dart'; // Importa la nuova schermata

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print(">>> Firebase inizializzato correttamente! <<<");
  } catch (e, stacktrace) {
    print(">>> ERRORE INIZIALIZZAZIONE FIREBASE: $e <<<");
    print(">>> STACKTRACE: $stacktrace <<<");
  }

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
      home: const AuthWrapper(), // Imposta LoginScreen come schermata iniziale
    );
  }
}