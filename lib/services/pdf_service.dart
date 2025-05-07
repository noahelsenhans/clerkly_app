import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFService {
  static Future<File> createPDFfromImage(File imageFile, String fileName) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(await imageFile.readAsBytes());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Image(image),
        ),
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}

