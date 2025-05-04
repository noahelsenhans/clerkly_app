import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _busy = false;
  Future<void> _register() async {
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: \$e')),
      );
    } finally {
      setState(() => _busy = false);
    }
  }
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'E-Mail')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Passwort'), obscureText: true),
            const SizedBox(height: 20),
            if (_busy) const CircularProgressIndicator(),
            if (!_busy)
              ElevatedButton(onPressed: _register, child: const Text('Konto erstellen')),
          ],
        ),
      ),
    );
  }
}
