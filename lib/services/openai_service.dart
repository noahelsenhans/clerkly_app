class OpenAIService {
  /// Dummy-Methode zur Zusammenfassung.
  /// Später kannst du hier deine OpenAI-API integrieren.
  static Future<String> summarize(String text) async {
    // Dummy-Zusammenfassung
    if (text.length > 100) {
      return text.substring(0, 100) + '...';
    } else {
      return text;
    }
  }
}

