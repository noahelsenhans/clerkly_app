import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../services/ocr_service.dart';
import '../services/category_service.dart';
import '../services/firestore_service.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  const ResultScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? _text;
  bool _busy = true;
  String? _category;

  @override
  void initState() {
    super.initState();
    _runOCR();
  }

  Future<void> _runOCR() async {
    final recognized = await OCRService.extractText(widget.imagePath);
    final category = CategoryService.classify(recognized);
    setState(() {
      _text = recognized;
      _category = category;
      _busy = false;
    });
  }

  Future<void> _save() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final filename = p.basename(widget.imagePath);
    final newPath = '\${docsDir.path}/\$filename';
    await File(widget.imagePath).copy(newPath);

    await FirestoreService.saveDocument(
      path: newPath,
      text: _text ?? '',
      category: _category ?? 'Sonstiges',
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gespeichert in \"\$_category\"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Ergebnis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(File(widget.imagePath), width: MediaQuery.of(context).size.width * 0.8),
            const SizedBox(height: 16),
            Text(_text ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Kategorie: \$_category', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Speichern'),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
