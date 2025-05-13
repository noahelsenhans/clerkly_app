import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'document_detail_screen.dart';

class DocumentSearchDelegate extends SearchDelegate<String> {
  DocumentSearchDelegate() : super(searchFieldLabel: 'Dokumente suchen');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.getDocumentsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!.docs.where((doc) {
          final data = doc.data();
          final text = data['text'] as String? ?? '';
          final category = data['category'] as String? ?? '';
          return text.toLowerCase().contains(query.toLowerCase()) ||
                 category.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (results.isEmpty) {
          return const Center(child: Text('Keine Ergebnisse'));
        }

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final data = results[i].data();
            final path = data['path'] as String;
            final text = data['text'] as String;
            final category = data['category'] as String;
            final ts = results[i]['timestamp'] as Timestamp?;
            final date = ts != null
                ? DateFormat('dd.MM.yyyy').format(ts.toDate())
                : 'Unbekannt';
            return ListTile(
              title: Text(category),
              subtitle: Text('Am $date'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentDetailScreen(
                      path: path,
                      text: text,
                      category: category,
                      timestamp: ts?.toDate() ?? DateTime.now(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

