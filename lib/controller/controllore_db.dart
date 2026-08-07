import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // Istanza di Firestore privata all'interno della classe
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // READ: Stream per ascoltare i dati in tempo reale
  Stream<QuerySnapshot> ottieniProdottiStream() {
    return _db.collection('prodotti').orderBy('prezzo').snapshots();
  }

  // READ: Chiamata singola
  Future<DocumentSnapshot> ottieniProdottoPerId(String id) async {
    return await _db.collection('prodotti').doc(id).get();
  }

  // CREATE
  Future<void> aggiungiProdotto(Map<String, dynamic> dati) async {
    await _db.collection('prodotti').add(dati);
  }

  // UPDATE
  Future<void> aggiornaProdotto(String id, Map<String, dynamic> dati) async {
    await _db.collection('prodotti').doc(id).update(dati);
  }

  // DELETE
  Future<void> eliminaProdotto(String id) async {
    await _db.collection('prodotti').doc(id).delete();
  }
}