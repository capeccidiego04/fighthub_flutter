import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'controller/controllore_auth.dart';
import 'view/home_screen.dart';
import 'view/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      // Ascolta in tempo reale se l'utente è loggato o no
      stream: authService.authStateChanges,
      builder: (context, snapshot) {

        // 1. In fase di caricamento (es. avvio dell'app) mostra una rotella
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Se l'utente è autenticato -> Vai alla Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 3. Se l'utente NON è autenticato -> Vai al Login
        else {
          return const LoginScreen();
        }
      },
    );
  }
}