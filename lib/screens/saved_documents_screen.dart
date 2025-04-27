import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'document_detail_screen.dart';
import 'document_search_delegate.dart';

class SavedDocumentsScreen extends StatelessWidget {
  const SavedDocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gespeicherte Dokumente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DocumentSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.getDocumentsStream(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Noch keine Dokumente'));
          // Gruppieren nach Kategorie
          final grouped = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
          for (var d in docs) {
            final cat = (d.data()['category'] as String?) ?? 'Sonstiges';
            grouped.putIfAbsent(cat, () => []).add(d);
          }
          return ListView(
            children: grouped.entries.map((entry) {
              final cat = entry.key;
              return ExpansionTile(
                title: Text(cat, style: Theme.of(context).textTheme.titleMedium),
                children: entry.value.map((d) {
                  final data = d.data();
                  final preview = (data['text'] as String).split('\n').first;
                  final ts = data['timestamp'] as Timestamp?;
                  final date = ts?.toDate() ?? DateTime.now();
                  final dateStr = DateFormat.yMd('de').add_Hm().format(date);
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(preview),
                    subtitle: Text('\$dateStr'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocumentDetailScreen(
                            path: data['path'] as String,
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
