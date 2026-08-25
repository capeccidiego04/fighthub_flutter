import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_wrapper.dart';
import 'controller/firebase_options.dart';
import 'view/login_screen.dart'; // Importa la nuova schermata
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inizializzato correttamente!");
  } catch (e, stacktrace) {
    print("ERRORE INIZIALIZZAZIONE FIREBASE: $e");
    print("STACKTRACE: $stacktrace");
  }

  try {
    await Supabase.initialize(
      url: 'https://guebusnndyspxxmlmltl.supabase.co',
      publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1ZWJ1c25uZHlzcHh4bWxtbHRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MjYzNDcsImV4cCI6MjA5MjUwMjM0N30.mSDdAg1nlRwEI6srJU_yL3QG2nhLJ4o3lIT7qOMJQuI',
    );
  } catch (e){
    print ("Errore: $e");
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