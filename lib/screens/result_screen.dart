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

  final List<String> _categorySuggestions = ['Allgemein', 'Rechnung', 'Zeugnis', 'Rezept'];

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
      appBar: AppBar(
        title: const Text('Scan Ergebnis'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zusammenfassung:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _summary,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kategorie auswählen:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: _categorySuggestions.map((cat) {
                      return ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        selectedColor: Colors.blueAccent,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _saveDocument,
                      child: const Text('Speichern', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

