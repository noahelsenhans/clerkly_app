import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Future<void> _openResult(String path) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(imagePath: path)),
    );
  }

  Future<void> _scanWithCamera() async {
    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo != null) await _openResult(photo.path);
  }

  Future<void> _importFromGallery() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) await _openResult(image.path);
  }

  Future<void> _importFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      await _openResult(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(title: const Text('Dokument auswählen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Dokument scannen'),
                  onPressed: _scanWithCamera,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Aus Galerie importieren'),
                  onPressed: _importFromGallery,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.folder),
                  label: const Text('Aus Dateien importieren'),
                  onPressed: _importFromFiles,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

