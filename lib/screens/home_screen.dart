import 'package:flutter/material.dart';
import 'package:clerkly_app/screens/scan_screen.dart';
import 'package:clerkly_app/screens/saved_documents_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clerkly'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Neues Dokument'),
              onPressed: () async {
                final path = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                );
                if (path != null) {
                  // TODO: Weiterverarbeitung (OCR/PDF) später
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ausgewählter Pfad: $path')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('Gespeicherte Dokumente'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedDocumentsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

