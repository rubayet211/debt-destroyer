class Parsers {
  static double parseMoney(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final normalized = raw.trim();
    final slashParts = normalized.split('/');
    if (slashParts.length == 3) {
      final month = int.tryParse(slashParts[0]);
      final day = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);
      if (month != null && day != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.tryParse(normalized);
  }
}
