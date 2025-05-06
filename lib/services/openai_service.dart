import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  // OpenAI API Key direkt hier definieren
  static const String _apiKey = 'dummykey'; // HIER echten Key einsetzen

  // Text zusammenfassen
  static Future<String> summarize(String text) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty || apiKey == 'dummykey') {
      return 'Kein gültiger API Key gefunden.';
    }

    final prompt = "Fasse den folgenden Text in 1-2 Sätzen zusammen:\n$text";

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content.trim();
    } else {
      return 'Zusammenfassung fehlgeschlagen.';
    }
  }

  // Kategorie vorschlagen
  static Future<String> suggestCategory(String text) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty || apiKey == 'dummykey') {
      return 'Allgemein';
    }

    final prompt = """
Lies dir den folgenden Text durch und gib mir bitte NUR die passende Kategorie als EIN WORT zurück. Verwende einfache Kategorien wie: Rechnung, Vertrag, Zeugnis, Rezept, Garantie, Anleitung, Packliste, Gutschein, allgemein.

Text:
$text
""";

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 10,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content.trim();
    } else {
      return 'Allgemein';
    }
  }
}

