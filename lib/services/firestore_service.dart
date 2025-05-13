import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _col = FirebaseFirestore.instance.collection('documents');

  /// Stream aller Dokumente, sortiert nach Timestamp absteigend
  static Stream<QuerySnapshot<Map<String, dynamic>>> getDocumentsStream() {
    return _col.orderBy('timestamp', descending: true).snapshots();
  }

  /// Dokument speichern
  static Future<void> saveDocument({
    required String path,
    required String text,
    required String category,
  }) {
    return _col.add({
      'path': path,
      'text': text,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

