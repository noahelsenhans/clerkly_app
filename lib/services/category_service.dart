/// Einfache Schlüsselwort-Regeln zur ersten Kategorisierung
class CategoryService {
  static String classify(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('rechnung') || lower.contains('rechnungsnummer')) {
      return 'Rechnung';
    }
    if (lower.contains('gehalt') || lower.contains('lohn')) {
      return 'Lohnzettel';
    }
    if (lower.contains('kfz') || lower.contains('fahrgestell') || lower.contains('kennzeichen')) {
      return 'Versicherung-Auto';
    }
    if (lower.contains('haus') || lower.contains('immobilie') || lower.contains('wohn')) {
      return 'Versicherung-Haus';
    }
    if (lower.contains('zeugnis')) {
      return 'Zeugnis';
    }
    if (lower.contains('zertifikat') || lower.contains('certificate')) {
      return 'Zertifikat';
    }
    if (lower.contains('rezept')) {
      return 'Rezept';
    }
    if (lower.contains('führerschein')) {
      return 'Führerschein';
    }
    return 'Sonstiges';
  }
}
