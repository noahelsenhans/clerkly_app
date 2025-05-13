import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch<String>(
                context: context,
                delegate: DocumentSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.getDocumentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Keine Dokumente gefunden.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final path = data['path'] as String;
              final text = data['text'] as String;
              final category = data['category'] as String;
              final ts = docs[index]['timestamp'] as Timestamp?;
              final date = ts != null
                  ? DateFormat('dd.MM.yyyy').format(ts.toDate())
                  : 'Unbekannt';
              return ListTile(
                title: Text(category),
                subtitle: Text('Am $date'),
                trailing: const Icon(Icons.arrow_forward_ios),
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
      ),
    );
  }
}

