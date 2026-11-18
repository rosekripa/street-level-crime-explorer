import 'package:flutter_test/flutter_test.dart';
import 'package:street_level_crime_explorer/core/utils/format.dart';

void main() {
  test('formatCount adds thousands separators', () {
    expect(formatCount(0), '0');
    expect(formatCount(999), '999');
    expect(formatCount(1000), '1,000');
    expect(formatCount(2929), '2,929');
    expect(formatCount(1234567), '1,234,567');
  });

  test('prettyCategory makes slugs readable', () {
    expect(prettyCategory('theft-from-the-person'), 'Theft from the person');
    expect(prettyCategory('anti-social-behaviour'), 'Anti-social behaviour');
    expect(prettyCategory(''), '');
  });
}