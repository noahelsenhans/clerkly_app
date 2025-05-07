import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PDFService {
  static Future<File> createPDFfromImage(File imageFile, String fileName) async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(
      await imageFile.readAsBytes(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final pdfFile = File('${outputDir.path}/$fileName.pdf');

    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile;
  }
}

