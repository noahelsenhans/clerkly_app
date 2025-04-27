import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  /// Stream aller Dokumente
  static Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentsStream() {
    return FirebaseFirestore.instance
      .collection('documents')
      .orderBy('timestamp', descending: true)
      .snapshots();
  }

  /// Speichert ein Dokument mit Bild-Pfad, OCR-Text und Kategorie
  static Future<void> saveDocument({
    required String path,
    required String text,
    required String category,
  }) {
    return FirebaseFirestore.instance
      .collection('documents')
      .add({
        'path': path,
        'text': text,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
      });
  }
}
