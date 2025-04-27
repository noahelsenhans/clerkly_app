import 'dart:io';
import 'package:flutter/material.dart';
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
  String _text = '';
  String _category = '';
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _runOCR();
  }

  Future<void> _runOCR() async {
    final recognized = await OCRService.extractText(widget.imagePath);
    final cat = CategoryService.classify(recognized);
    setState(() {
      _text = recognized;
      _category = cat;
      _busy = false;
    });
  }

  Future<void> _save() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final filename = widget.imagePath.split('/').last;
    final newPath = docsDir.path + '/' + filename;

    try {
      await File(widget.imagePath).copy(newPath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Kopieren: \$e')),
      );
      return;
    }

    await FirestoreService.saveDocument(
      path: newPath,
      text: _text,
      category: _category,
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gespeichert in \"\$_category\"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Ergebnis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(File(widget.imagePath), width: double.infinity),
            const SizedBox(height: 16),
            Text(
              'Kategorie: \$_category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
