// Text normalization for accent- and case-insensitive search.
//
// Latin: lowercase, then replace French diacritics (covers é è ê ë à
// â ç î ï ô ù û ü ÿ ñ …), turn hyphens/apostrophes into spaces and
// collapse whitespace. Arabic: strip tashkeel + tatweel, unify
// أ إ آ ٱ → ا, ة → ه, ى → ي, collapse whitespace. Both sides (query
// and dataset) go through the same functions so matching is stable.
const Map<String, String> _latinFold = <String, String>{
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'œ': 'oe',
  'æ': 'ae',
};

/// Normalizes Latin-script text for search comparison.
String normalizeLatin(String input) {
  final StringBuffer out = StringBuffer();
  final String lower = input.toLowerCase();
  for (int i = 0; i < lower.length; i++) {
    final String ch = lower[i];
    if (ch == '-' || ch == "'" || ch == '’' || ch == '.') {
      out.write(' ');
      continue;
    }
    out.write(_latinFold[ch] ?? ch);
  }
  return _squash(out.toString());
}

/// Normalizes Arabic-script text for search comparison.
String normalizeArabic(String input) {
  final StringBuffer out = StringBuffer();
  for (final int rune in input.runes) {
    // Skip tashkeel (U+064B–U+0652) and tatweel (U+0640).
    if ((rune >= 0x064B && rune <= 0x0652) || rune == 0x0640) {
      continue;
    }
    final String ch = String.fromCharCode(rune);
    switch (ch) {
      case 'أ':
      case 'إ':
      case 'آ':
      case 'ٱ':
        out.write('ا');
      case 'ة':
        out.write('ه');
      case 'ى':
        out.write('ي');
      default:
        out.write(ch);
    }
  }
  return _squash(out.toString());
}

String _squash(String input) {
  return input.trim().replaceAll(RegExp(r'\s+'), ' ');
}
