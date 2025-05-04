import 'package:flutter/material.dart';
import 'package:clerkly_app/services/ocr_service.dart';
import 'package:clerkly_app/services/openai_service.dart';
import 'package:clerkly_app/services/firestore_service.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    final text = await OCRService.extractText(widget.imagePath);
    final summary = await OpenAIService.summarize(text);

    setState(() {
      _ocrText = text;
      _summary = summary;
      _isLoading = false;
    });
  }

  void _saveDocument() {
    FirestoreService.saveDocument(
      path: widget.imagePath,
      text: _ocrText,
      category: _selectedCategory,
    );

    Navigator.pop(context);
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
                children: [
                  Text('Zusammenfassung:', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(_summary),
                  const SizedBox(height: 16),
                  Text('Kategorie auswählen:'),
                  Wrap(
                    spacing: 8.0,
                    children: ['Allgemein', 'Rechnung', 'Zeugnis'].map((cat) {
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
                    onPressed: _saveDocument,
                    child: const Text('Speichern'),
                  ),
                ],
              ),
            ),
    );
  }
}

