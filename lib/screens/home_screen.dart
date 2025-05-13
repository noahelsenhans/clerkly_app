import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'saved_documents_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gemeinsame Breite für beide Buttons
    final buttonWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clerkly'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Neues Dokument'),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ScanScreen())),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: const Text('Gespeicherte Dokumente'),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const SavedDocumentsScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

