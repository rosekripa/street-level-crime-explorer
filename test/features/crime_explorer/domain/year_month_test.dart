import 'package:flutter_test/flutter_test.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';

void main() {
  group('YearMonth.tryParse', () {
    test('reads a full date from the API', () {
      expect(YearMonth.tryParse('2026-09-01'), const YearMonth(2026, 9));
    });

    test('reads year-month only', () {
      expect(YearMonth.tryParse('2026-09'), const YearMonth(2026, 9));
    });

    test('returns null for bad input instead of throwing', () {
      expect(YearMonth.tryParse(''), isNull);
      expect(YearMonth.tryParse('banana'), isNull);
      expect(YearMonth.tryParse('2026-13-01'), isNull);
    });
  });

  group('previous and lastMonths', () {
    test('previous goes back one month', () {
      expect(const YearMonth(2026, 9).previous, const YearMonth(2026, 8));
    });

    test('previous wraps from January to December', () {
      expect(const YearMonth(2026, 1).previous, const YearMonth(2025, 12));
    });

    test('lastMonths returns 12 months, newest first', () {
      final months = const YearMonth(2026, 9).lastMonths(12);
      expect(months.length, 12);
      expect(months.first, const YearMonth(2026, 9));
      expect(months.last, const YearMonth(2025, 10));
    });
  });

  group('formatting', () {
    test('apiFormat pads the month', () {
      expect(const YearMonth(2026, 9).apiFormat, '2026-09');
    });

    test('label is readable', () {
      expect(const YearMonth(2026, 9).label, 'September 2026');
    });
  });
}