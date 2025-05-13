import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

class PDFService {
  /// Erzeugt aus einem Bildfile eine PDF und gibt das File zurück.
  static Future<File> createPDFfromImage(File imageFile, String fileName) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(await imageFile.readAsBytes());

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final outFile = File('${dir.path}/$fileName.pdf');
    await outFile.writeAsBytes(await doc.save());
    return outFile;
  }
}

