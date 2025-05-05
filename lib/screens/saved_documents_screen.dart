import 'document_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'document_detail_screen.dart';

class SavedDocumentsScreen extends StatefulWidget {
  const SavedDocumentsScreen({Key? key}) : super(key: key);

  @override
  _SavedDocumentsScreenState createState() => _SavedDocumentsScreenState();
}

class _SavedDocumentsScreenState extends State<SavedDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: const Text('Gespeicherte Dokumente'),
  backgroundColor: Colors.blueAccent,
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        showSearch(
          context: context,
          delegate: DocumentSearchDelegate(),
        );
      },
    ),
  ],
),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Keine Dokumente gefunden.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final path = doc['path'] ?? '';
              final category = doc.data().containsKey('category') ? doc['category'] : 'Unbekannt';
              final timestamp = doc['timestamp'] != null
                  ? (doc['timestamp'] as Timestamp).toDate()
                  : DateTime.now();

              final formattedDate = DateFormat('dd.MM.yyyy').format(timestamp);

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
      ),
    );
  }
}

