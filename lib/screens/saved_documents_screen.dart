import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'document_detail_screen.dart';

class SavedDocumentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: Text('Gespeicherte Dokumente')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: fs.getDocumentsStream(),
        builder: (ctx, snap) {
          if (snap.hasError) {
            return Center(child: Text('Fehler: \${snap.error}'));
          }
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('Noch keine Dokumente'));
          }
          // Gruppiere nach Kategorie
          final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> grouped = {};
          for (var d in docs) {
            final data = d.data();
            final cat = data['category'] as String? ?? 'Sonstiges';
            grouped.putIfAbsent(cat, () => []).add(d);
          }
          return ListView(
            children: grouped.entries.map((entry) {
              final cat = entry.key;
              final items = entry.value;
              return ExpansionTile(
                title: Text(
                  cat,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                children: items.map((d) {
                  final data = d.data();
                  final preview = (data['text'] as String).split('\n').first;
                  final ts = data['timestamp'] as Timestamp?;
                  final date = ts?.toDate() ?? DateTime.now();
                  final dateStr = DateFormat.yMd('de').add_Hm().format(date);
                  return ListTile(
                    leading: Icon(Icons.insert_drive_file),
                    title: Text(preview),
                    subtitle: Text(dateStr),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocumentDetailScreen(
                            path: data['imagePath'] as String,
                            text: data['text'] as String,
                            category: cat,
                            timestamp: date,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
