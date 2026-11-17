import 'package:equatable/equatable.dart';

import 'category_count.dart';

class MonthlyIncidents extends Equatable {
  /// Format: "2026-09"
  final String month;
  final Map<String, int> countsByCategory;

  const MonthlyIncidents({
    required this.month,
    required this.countsByCategory,
  });

  int get total => countsByCategory.values.fold(0, (sum, c) => sum + c);

  bool get isEmpty => total == 0;

  /// Largest first. Ties are ordered by name so the order never changes.
  List<CategoryCount> get sortedCategories {
    final list = countsByCategory.entries
        .map((e) => CategoryCount(category: e.key, count: e.value))
        .toList();
    list.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.category.compareTo(b.category);
    });
    return list;
  }

  @override
  List<Object> get props => [month, countsByCategory];
}