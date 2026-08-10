import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:intl/intl.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> registraUtente({
    required String email,
    required String password,
    required String nome,
    required String cognome,
    required Set<String> artiPraticate,
    DateTime? dataNascita,
    int? altezzaCm,
    int? pesoKg,
    String? descrizione,
    List<File>? fotoProfilo, // <-- Passiamo una LISTA di file
  }) async {
    // 1. Creazione dell'account su Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user == null) {
      throw Exception("Errore durante la creazione dell'account utente.");
    }

    String? dataFormattata;
    if (dataNascita != null) {
      dataFormattata = DateFormat('dd/MM/yyyy').format(dataNascita);
    }

    String uid = user.uid;
    List<String> photoUrls = []; // <-- Lista degli URL che salveremo su Firestore

    // 2. Upload di MULTIPLE immagini su Supabase Storage
    if (fotoProfilo != null && fotoProfilo.isNotEmpty) {
      for (int i = 0; i < fotoProfilo.length; i++) {
        File file = fotoProfilo[i];

        // Creiamo un nome file univoco combinando l'UID e l'indice dell'immagine (o un timestamp)
        final String fileName = '${uid}_$i.jpg'; // es. 12345_0.jpg, 12345_1.jpg

        await _supabase.storage
            .from('foto_fighthub')
            .upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

        // Recuperiamo l'URL pubblico e lo aggiungiamo alla lista
        final String publicUrl = _supabase.storage
            .from('foto_fighthub')
            .getPublicUrl(fileName);

        photoUrls.add(publicUrl);
      }
    }

    // 3. Creazione del documento su Firestore salvando la lista di URL
    await _db.collection('utente').doc(uid).set({
      'uid': uid,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'dataNascita': dataFormattata,
      'altezza': altezzaCm,
      'peso': pesoKg,
      'descrizione': descrizione ?? '',
      'urlFoto': photoUrls, // <-- Array di URL salvato su Firestore
      'artiPraticate': artiPraticate,
    });
  }
}