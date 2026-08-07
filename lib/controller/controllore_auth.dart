import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream per ascoltare se l'utente è loggato o no
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Ottieni l'utente attualmente loggato
  User? get currentUser => _auth.currentUser;

  // Login
  Future<UserCredential?> accediConEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Registrazione
  Future<UserCredential?> registraConEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}