import 'package:flutter/material.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({Key? key}) : super(key: key);

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  String _search = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gespeicherte Dokumente'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Suche …',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _search = val.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allDocs = snap.data!.docs;
          // Filter lokal nach Suchbegriff im Text-Feld
          final filtered = allDocs.where((d) {
            final text = (d['text'] as String? ?? '').toLowerCase();
            return text.contains(_search);
          }).toList();
          if (filtered.isEmpty) {
            return const Center(child: Text('Keine Dokumente gefunden.'));
          }
          // Gruppieren nach Kategorie
          final Map<String, List<QueryDocumentSnapshot>> byCat = {};
          for (var d in filtered) {
final data = d.data()! as Map<String, dynamic>;
final cat = (data.containsKey('category') && data['category'] != null)
    ? data['category'] as String
    : 'Unkategorisiert';
            byCat.putIfAbsent(cat, () => []).add(d);
          }
          return ListView(
            children: byCat.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                children: entry.value.map((d) {
                  final data = d.data()! as Map<String, dynamic>;
                  final title =
                      (data['text'] as String).split('\n').first;
                  final ts = data['timestamp'] as Timestamp?;
                  final subtitle =
                      ts != null ? ts.toDate().toString() : '';
                  return ListTile(
                    title: Text(title),
                    subtitle: Text(subtitle),
                    onTap: () {
                      // später: Detail-View öffnen
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
