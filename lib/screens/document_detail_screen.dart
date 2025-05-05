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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokument-Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareDocument(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            (path.isNotEmpty && File(path).existsSync())
                ? Image.file(
                    File(path),
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                    ),
                    child: const Center(child: Text('Kein Bild gefunden')),
                  ),
            const SizedBox(height: 16),
            Text(
              'Kategorie: $category',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Datum: ${DateFormat.yMMMMd('de_DE').add_Hm().format(timestamp)}',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 32),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareDocument() async {
    final pdf = pw.Document();
    final ttf = await PdfGoogleFonts.robotoRegular();
    final ttfBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Kategorie: $category', style: pw.TextStyle(font: ttfBold)),
            pw.Text(
                'Datum: ${DateFormat.yMMMMd('de_DE').format(timestamp)}',
                style: pw.TextStyle(font: ttf)),
            pw.SizedBox(height: 20),
            pw.Text(text, style: pw.TextStyle(font: ttf)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/document.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Gescanntes Dokument');
  }
}

