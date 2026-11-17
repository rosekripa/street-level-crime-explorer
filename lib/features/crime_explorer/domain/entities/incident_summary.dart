import 'package:equatable/equatable.dart';

import 'category_count.dart';
import 'monthly_incidents.dart';
import 'postcode_location.dart';

class IncidentSummary extends Equatable {
  const IncidentSummary({
    required this.location,
    required this.current,
    this.previous,
  });

  static const topLimit = 6;

  final PostcodeLocation location;
  final MonthlyIncidents current;

  /// Null when the comparison month could not be loaded.
  final MonthlyIncidents? previous;

  List<CategoryCount> get topCategories =>
      current.sortedCategories.take(topLimit).toList();

  List<CategoryCount> get _rest =>
      current.sortedCategories.skip(topLimit).toList();

  int get otherIncidentCount => _rest.fold(0, (sum, c) => sum + c.count);

  int get otherCategoryCount => _rest.length;

  /// Month-on-month change in percent, or null if it cannot be calculated.
  double? get changePercent {
    final prev = previous;
    if (prev == null || prev.total == 0) return null;
    return (current.total - prev.total) / prev.total * 100;
  }

  @override
  List<Object?> get props => [location, current, previous];
}