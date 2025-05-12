import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clerkly_app/services/ocr_service.dart';
import 'package:clerkly_app/services/pdf_service.dart';
import 'package:clerkly_app/services/firestore_service.dart';
import 'document_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  const ResultScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _ocrText = '';
  String _selectedCategory = 'Allgemein';
  String _pdfPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    // OCR
    final text = await OCRService.extractText(widget.imagePath);

    // PDF erzeugen
    final pdfFile = await PDFService.createPDFfromImage(
      File(widget.imagePath),
      'doc_${DateTime.now().millisecondsSinceEpoch}',
    );

    setState(() {
      _ocrText = text;
      _pdfPath = pdfFile.path;
      _isLoading = false;
    });
  }

  Future<void> _saveAndOpenDocument() async {
    // In Firestore speichern
    await FirestoreService.saveDocument(
      path: _pdfPath,
      text: _ocrText,
      category: _selectedCategory,
    );

    // Zurück zum allerersten Route (HomeScreen)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ergebnis')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OCR Text:',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(_ocrText),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Kategorie auswählen:'),
                  Wrap(
                    spacing: 8.0,
                    children: ['Allgemein', 'Rechnung', 'Zeugnis']
                        .map((cat) => ChoiceChip(
                              label: Text(cat),
                              selected: _selectedCategory == cat,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveAndOpenDocument,
                    child: const Text('Speichern & Öffnen'),
                  ),
                ],
              ),
            ),
    );
  }
}

