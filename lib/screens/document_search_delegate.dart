import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'document_detail_screen.dart';

class DocumentSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Suchbegriff eingeben.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('documents')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!.docs.where((doc) {
          final data = doc.data();
          final text = data['text']?.toString().toLowerCase() ?? '';
          final category = data['category']?.toString().toLowerCase() ?? '';
          return text.contains(query.toLowerCase()) || category.contains(query.toLowerCase());
        }).toList();

        if (results.isEmpty) {
          return const Center(child: Text('Keine passenden Dokumente gefunden.'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doc = results[index];
            final path = doc['path'] ?? '';
            final category = doc.data().containsKey('category') ? doc['category'] : 'Unbekannt';
            final timestamp = doc['timestamp'] != null
                ? (doc['timestamp'] as Timestamp).toDate()
                : DateTime.now();
            final formattedDate = '${timestamp.day}.${timestamp.month}.${timestamp.year}';

            return ListTile(
              title: Text(category),
              subtitle: Text('Gespeichert am: $formattedDate'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DocumentDetailScreen(
                      path: path,
                      text: doc.data().containsKey('text') ? doc['text'] : '',
                      category: category,
                      timestamp: timestamp,
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
}

