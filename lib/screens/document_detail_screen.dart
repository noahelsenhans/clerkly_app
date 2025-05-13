import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class DocumentDetailScreen extends StatelessWidget {
  final String path;
  final String text;
  final String category;
  final DateTime timestamp;

  const DocumentDetailScreen({
    Key? key,
    required this.path,
    required this.text,
    required this.category,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPdf = path.toLowerCase().endsWith('.pdf');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokument-Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Kategorie: $category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Volltext:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: SingleChildScrollView(child: Text(text)),
            ),
            const SizedBox(height: 10),
            Text(
              'Gespeichert am: ${DateFormat('dd.MM.yyyy').format(timestamp)}',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isPdf
                  ? PdfPreview(
                      build: (format) async => File(path).readAsBytes(),
                    )
                  : Image.file(File(path)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF anzeigen'),
              onPressed: isPdf
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('PDF Vorschau')),
                            body: PdfPreview(
                              build: (format) async => File(path).readAsBytes(),
                            ),
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _shareDocument() {
    Share.shareXFiles([XFile(path)], text: 'Mein Dokument aus Clerkly');
  }
}

