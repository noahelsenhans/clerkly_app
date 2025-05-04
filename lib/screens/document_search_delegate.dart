import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'document_detail_screen.dart';

class DocumentSearchDelegate extends SearchDelegate<void> {
  DocumentSearchDelegate() : super(searchFieldLabel: 'Dokumente durchsuchen…');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.getDocumentsStream(),
      builder: (ctx, snap) {
        if (snap.hasError) {
          return Center(child: Text("Fehler: \${snap.error}"));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final hits = snap.data!.docs.where((d) {
          final data = d.data();
          final txt     = (data['text']    ?? '').toString().toLowerCase();
          final sum     = (data['summary'] ?? '').toString().toLowerCase();
          final cat     = (data['category']?? '').toString().toLowerCase();
          final q       = query.toLowerCase();
          return txt.contains(q) || sum.contains(q) || cat.contains(q);
        }).toList();

        if (hits.isEmpty) {
          return const Center(child: Text('Keine Treffer'));
        }

        return ListView.builder(
          itemCount: hits.length,
          itemBuilder: (context, index) {
            final d    = hits[index];
            final data = d.data();
            final preview = (data['summary'] ?? '').toString();
            final ts      = data['timestamp'] as Timestamp?;
            final date    = ts?.toDate() ?? DateTime.now();
            final dateStr = DateFormat.yMd('de').add_Hm().format(date);

            return ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(preview),
              subtitle: Text("\${data['category']} · \$dateStr"),
              onTap: () {
                close(context, null);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => DocumentDetailScreen(
                    path: data['path'] as String,
                    text: data['text'] as String,
                    category: data['category'] as String,
                    timestamp: date,
                  ),
                ));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Suchbegriff eingeben…'));
  }
}
