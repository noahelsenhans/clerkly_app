class OpenAIService {
  /// Dummy-Zusammenfassung
  static Future<String> summarize(String text) async {
    return text.length > 100 ? text.substring(0, 100) + '...' : text;
  }
}

