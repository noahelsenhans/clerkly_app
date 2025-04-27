import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokument scannen')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Galerie'),
              onPressed: () => _pickImage(context, ImageSource.gallery),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kamera'),
              onPressed: () => _pickImage(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image == null) return; // Abbruch, wenn nichts gewählt
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(imagePath: image.path),
      ),
    );
  }
}

