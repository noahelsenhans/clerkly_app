import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clerkly_app/services/ocr_service.dart';
import 'package:clerkly_app/services/openai_service.dart';
import 'package:clerkly_app/services/firestore_service.dart';
import 'package:clerkly_app/services/pdf_service.dart';
import 'document_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _ocrText = '';
  String _summary = '';
  String _selectedCategory = 'Allgemein';
  String _pdfPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    final text = await OCRService.extractText(widget.imagePath);
    final summary = await OpenAIService.summarize(text);

    // PDF erzeugen
    File imageFile = File(widget.imagePath);
    File pdfFile = await PDFService.createPDFfromImage(
      imageFile,
      'dokument_${DateTime.now().millisecondsSinceEpoch}'
    );

    setState(() {
      _ocrText = text;
      _summary = summary;
      _pdfPath = pdfFile.path;
      _isLoading = false;
    });
  }

  void _saveAndOpenDocument() {
    FirestoreService.saveDocument(
      path: _pdfPath,
      text: _ocrText,
      summary: _summary,
      category: _selectedCategory,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentDetailScreen(
          path: _pdfPath,
          text: _ocrText,
          summary: _summary,
          category: _selectedCategory,
          timestamp: DateTime.now(),
        ),
      ),
    );
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
                  Text(
                    'Zusammenfassung:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_summary),
                  const SizedBox(height: 16),
                  Text('Kategorie auswählen:'),
                  Wrap(
                    spacing: 8.0,
                    children: ['Allgemein', 'Rechnung', 'Vertrag', 'Zeugnis'].map((cat) {
                      return ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                      );
                    }).toList(),
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

