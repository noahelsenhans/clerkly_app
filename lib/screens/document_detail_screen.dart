import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
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

  Future<String> _saveToDocuments(String originalPath) async {
    final docDir = await getApplicationDocumentsDirectory();
    final file = File(originalPath);
    final newPath = '${docDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    return await file.copy(newPath).then((f) => f.path);
  }

  Future<void> _exportPdf() async {
    final savedPath = await _saveToDocuments(path);
    final bytes = File(savedPath).readAsBytesSync();
    final pdf = pw.Document();
    final image = pw.MemoryImage(bytes);
    final dateStr = DateFormat.yMMMMd('de').add_Hm().format(timestamp);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Kategorie: $category', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Datum: $dateStr', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(text, style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Image(image)),
          ],
        ),
      ),
    );
    final pdfBytes = await pdf.save();
    await Printing.sharePdf(bytes: pdfBytes, filename: 'Clerkly_Dokument.pdf');
  }

  void _shareImage() {
    Share.shareXFiles([XFile(path)], text: 'Dokument: $category');
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMMd('de').add_Hm().format(timestamp);
    return Scaffold(
      appBar: AppBar(title: const Text('Dokument-Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (File(path).existsSync())
              Image.file(
                File(path),
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 240,
                color: Colors.grey[300],
                child: const Center(child: Text('Kein Bild gefunden')),
              ),
            const SizedBox(height: 16),
            Text('Kategorie: $category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Datum: $dateStr', style: Theme.of(context).textTheme.bodyMedium),
            const Divider(height: 32),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Teilen'),
              onPressed: _shareImage,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export als PDF'),
              onPressed: _exportPdf,
            ),
          ],
        ),
      ),
    );
  }
}
