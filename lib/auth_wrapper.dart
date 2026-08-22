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

        // Mostra una rotella in fase di avvio
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // L'utente è autenticato
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // L'utente non è autenticato
        else {
          return const LoginScreen();
        }
      },
    );
  }
}