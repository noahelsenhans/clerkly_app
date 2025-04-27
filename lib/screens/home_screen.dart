import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'saved_documents_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clerkly'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Dokument scannen'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ScanScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.folder_open),
              label: Text('Gespeicherte Dokumente'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SavedDocumentsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
