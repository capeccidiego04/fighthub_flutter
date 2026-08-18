import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:intl/intl.dart';
import 'dart:math';

import '../model/recensione.dart';
import '../model/risposta.dart';
import '../model/utente.dart';

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
    List<File>? fotoProfilo,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;
    if (user == null) {
      throw Exception("Errore durante la creazione dell'account utente.");
    }

    String? dataFormattata;
    if (dataNascita != null) {
      dataFormattata = DateFormat('dd/MM/yyyy').format(dataNascita);
    }

    String uid = user.uid;
    List<String> photoUrls = [];

    // 2. Upload immagini su Supabase
    if (fotoProfilo != null && fotoProfilo.isNotEmpty) {
      for (int i = 0; i < fotoProfilo.length; i++) {
        File file = fotoProfilo[i];

        final String fileName = '${uid}_$i.jpg';

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
      'urlFoto': photoUrls,
      'artiPraticate': artiPraticate,
    });
  }

  Future<List<Utente>> getTuttiGliUtenti(String uid) async {
    final QuerySnapshot querySnapshot = await _db.collection('utente').get();
    final QuerySnapshot queryRisposte = await _db.collection('risposta').where('fromUid', isEqualTo: uid).get();
    List<Utente> utenti = [];
    List<String> risposte = [];
    for (var doc in queryRisposte.docs) {
      final data = doc.data() as Map<String, dynamic>;
      risposte.add(data['toUid']);
      print(data['toUid']);
    }

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if(data['uid'] == uid || risposte.contains(data['uid'])){
        print("Già valutato");
      }else{
        print("mio uid: ${uid}, utente: ${data['uid']}");
        utenti.add(
          Utente(
            id: data['uid'],
            email: data['email'] ?? '',
            nome: data['nome'] ?? '',
            cognome: data['cognome'] ?? '',
            descrizione: data['descrizione'] ?? '',
            altezza: (data['altezza'] as num?)?.toInt() ?? 0,
            peso: (data['peso'] as num?)?.toInt() ?? 0,
            dataNascita: data['dataNascita'] ?? '',
            arti: List<String>.from(data['artiPraticate'] ?? []),
            imgs: List<String>.from(data['urlFoto'] ?? []),
            lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
            lon: (data['lon'] as num?)?.toDouble() ?? 0.0,
          ),
        );
      }
    }

    return utenti;
  }

  Future<Utente?> getUtente(String uid) async{
    final QuerySnapshot query = await _db.collection('utente').where('uid', isEqualTo: uid).get();
    if (query.docs.isEmpty) {
      return null;
    }
    final data = query.docs[0].data() as Map<String, dynamic>;
    return Utente(
      id: data['uid'],
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      cognome: data['cognome'] ?? '',
      descrizione: data['descrizione'] ?? '',
      altezza: (data['altezza'] as num?)?.toInt() ?? 0,
      peso: (data['peso'] as num?)?.toInt() ?? 0,
      dataNascita: data['dataNascita'] ?? '',
      arti: List<String>.from(data['artiPraticate'] ?? []),
      imgs: List<String>.from(data['urlFoto'] ?? []),
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (data['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<List<Recensione?>> getRecensioni(String uid) async {
    final QuerySnapshot query = await _db.collection('recensione').where('recensitoUid', isEqualTo: uid).get();
    List<Recensione?> recensioni = [];
    for(var doc in query.docs){
      final data = doc.data() as Map<String, dynamic>;
      Utente? u = await getUtente(data['recensoreUid']);
      var nome;
      var foto;
      if(u != null){
        nome = "${u.nome} ${u.cognome}";
        foto = u.imgs[0];
      }
      final Recensione? recensione = Recensione(
        recensitoUid: data['recensitoUid'] ?? '',
        recensoreUid: data['recensoreUid'] ?? '',
        testo: data['testo'] ?? '',
        valutazione: (data['valutazione'] as num?)?.toInt() ?? 0,
        nome: nome ?? '',
        foto: foto ?? '',
      );
      recensioni.add(recensione);
    }
    return recensioni;
  }

  Future<void> inviaRisposta({
    required String from_id,
    required String to_id,
    required String tipo}) async {
      await _db.collection('risposta').add({
        'fromUid': from_id,
        'toUid': to_id,
        'tipo': tipo,
      });
    }

  String calcolaEta(String? dataNascitaStringa) {
    if (dataNascitaStringa == null || dataNascitaStringa.isEmpty) {
      return 'N/D';
    }
    try {
      List<String> parti = dataNascitaStringa.split('/');
      if (parti.length != 3) return 'N/D';
      int giorno = int.parse(parti[0]);
      int mese = int.parse(parti[1]);
      int anno = int.parse(parti[2]);

      DateTime dataNascita = DateTime(anno, mese, giorno);
      DateTime oggi = DateTime.now();

      int eta = oggi.year - dataNascita.year;

      if (oggi.month < dataNascita.month ||
          (oggi.month == dataNascita.month && oggi.day < dataNascita.day)) {
        eta--;
      }
      return eta.toString();
    } catch (e) {
      return 'N/D';
    }
  }

  String calcolaDistanza(double? lat1, double? lon1, double? lat2, double? lon2) {
    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
      return 'N/D';
    }

    const double raggioTerra = 6371.0;

    double deltaLat = _degToRad(lat2 - lat1);
    double deltaLon = _degToRad(lon2 - lon1);

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
        sin(deltaLon / 2) * sin(deltaLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanzaInKm = raggioTerra * c;

    return '${distanzaInKm.toStringAsFixed(1)} km';
  }

  double _degToRad(double deg) {
    return deg * (pi / 180.0);
  }
}