import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream aller Dokumente aus der Collection "documents",
  /// sortiert nach dem Feld "timestamp" (absteigend).
  Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentsStream() {
    return _db
        .collection('documents')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

