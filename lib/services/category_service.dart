import 'openai_service.dart';

class CategoryService {
  /// Dynamische Kategorie‐Vorschläge via GPT
  static Future<List<String>> getSuggestions(String text) async {
    try {
      return await OpenAIService.suggestCategories(text);
    } catch (_) {
      return ['Sonstiges'];
    }
  }

  /// Kurz‐Zusammenfassung via GPT
  static Future<String> getSummary(String text) async {
    try {
      return await OpenAIService.summarize(text);
    } catch (_) {
      return text.split('\\n').first;
    }
  }
}
