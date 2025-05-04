import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'document_detail_screen.dart';
import 'document_search_delegate.dart';

class SavedDocumentsScreen extends StatefulWidget {
  const SavedDocumentsScreen({Key? key}) : super(key: key);

  @override
  _SavedDocumentsScreenState createState() => _SavedDocumentsScreenState();
}

class _SavedDocumentsScreenState extends State<SavedDocumentsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _categoryFilter;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: 
        _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate   = picked.end;
      });
    }
  }

  void _pickCategory() async {
    const categories = [
      'Alle',
      'Rechnung',
      'Lohnzettel',
      'Versicherung-Auto',
      'Versicherung-Haus',
      'Zeugnis',
      'Sonstiges'
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        children: categories.map((c) => ListTile(
          title: Text(c),
          onTap: () => Navigator.pop(context, c),
        )).toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        _categoryFilter = selected == 'Alle' ? null : selected;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate   = null;
      _categoryFilter = null;
    });
  }

  bool _passesFilters(QueryDocumentSnapshot<Map<String,dynamic>> d) {
    final data = d.data();
    final ts = data['timestamp'] as Timestamp?;
    final date = ts?.toDate() ?? DateTime.now();
    if (_startDate != null && date.isBefore(_startDate!)) return false;
    if (_endDate   != null && date.isAfter(_endDate!))   return false;
    if (_categoryFilter != null && data['category'] != _categoryFilter) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String subtitleFilters() {
      final parts = <String>[];
      if (_startDate != null && _endDate != null) {
        final f = DateFormat.yMd('de');
        parts.add('${f.format(_startDate!)}–${f.format(_endDate!)}');
      }
      if (_categoryFilter != null) {
        parts.add(_categoryFilter!);
      }
      return parts.join(' | ');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dokumente${subtitleFilters().isNotEmpty ? ' – \$subtitleFilters()' : ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Suche',
            onPressed: () => showSearch(
              context: context, 
              delegate: DocumentSearchDelegate(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Zeitraum wählen',
            onPressed: _pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Kategorie wählen',
            onPressed: _pickCategory,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Filter zurücksetzen',
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.getDocumentsStream(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text('Fehler: \${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs.where(_passesFilters).toList();
          if (docs.isEmpty) {
            return const Center(child: Text('Keine Dokumente für die gewählten Filter'));
          }
          final grouped = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
          for (var d in docs) {
            final cat = (d.data()['category'] as String?) ?? 'Sonstiges';
            grouped.putIfAbsent(cat, () => []).add(d);
          }
          return ListView(
            children: grouped.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                children: entry.value.map((d) {
                  final data = d.data();
                  final preview = (data['text'] as String).split('\n').first;
                  final ts = data['timestamp'] as Timestamp?;
                  final date = ts?.toDate() ?? DateTime.now();
                  final dateStr = DateFormat.yMd('de').add_Hm().format(date);
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(preview),
                    subtitle: Text(dateStr),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DocumentDetailScreen(
                          path: data['path'] as String,
                          text: data['text'] as String,
                          category: entry.key,
                          timestamp: date,
                        ),
                      ),
                    ),
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
