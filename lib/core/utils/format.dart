/// 2929 -> "2,929"
String formatCount(int n) {
  final digits = n.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return n < 0 ? '-$buffer' : buffer.toString();
}

const _categoryOverrides = {
  'anti-social-behaviour': 'Anti-social behaviour',
};

/// "theft-from-the-person" -> "Theft from the person"
String prettyCategory(String slug) {
  final override = _categoryOverrides[slug];
  if (override != null) return override;
  if (slug.isEmpty) return slug;
  final words = slug.replaceAll('-', ' ');
  return words[0].toUpperCase() + words.substring(1);
}