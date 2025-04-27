import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extrahiert den Text aus dem Bild unter [imagePath].
  static Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);

    // Alle Text-Blöcke zusammenfassen
    final buffer = StringBuffer();
    for (final block in result.blocks) {
      buffer.writeln(block.text);
    }
    return buffer.toString();
  }

  /// Recognizer freigeben (optional)
  static void dispose() {
    _recognizer.close();
  }
}
