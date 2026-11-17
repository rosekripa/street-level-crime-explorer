import 'package:equatable/equatable.dart';

class YearMonth extends Equatable implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month);

  final int year;
  final int month; // 1 to 12

  static const _names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Accepts "2026-09" or "2026-09-01". Returns null if it cannot be read.
  static YearMonth? tryParse(String raw) {
    final match = RegExp(r'^(\d{4})-(\d{2})').firstMatch(raw.trim());
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) return null;
    return YearMonth(year, month);
  }

  YearMonth get previous =>
      month == 1 ? YearMonth(year - 1, 12) : YearMonth(year, month - 1);

  /// This month first, then going back. Example: 12 months for the picker.
  List<YearMonth> lastMonths(int count) {
    final result = <YearMonth>[];
    var current = this;
    for (var i = 0; i < count; i++) {
      result.add(current);
      current = current.previous;
    }
    return result;
  }

  /// "2026-09", the format the Police API expects.
  String get apiFormat => '$year-${month.toString().padLeft(2, '0')}';

  /// "September 2026", for the screen.
  String get label => '${_names[month - 1]} $year';

  @override
  int compareTo(YearMonth other) =>
      year != other.year ? year.compareTo(other.year) : month.compareTo(other.month);

  @override
  List<Object> get props => [year, month];
}