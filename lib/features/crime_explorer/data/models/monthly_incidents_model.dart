import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/monthly_incidents.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';

class MonthlyIncidentsModel {
  const MonthlyIncidentsModel(this.countsByCategory);

  final Map<String, int> countsByCategory;

  /// The API returns one record per incident. We count them per category.
  factory MonthlyIncidentsModel.fromJson(Object? json) {
    if (json is! List) throw const InvalidResponseFailure();

    final counts = <String, int>{};
    for (final item in json) {
      if (item is! Map) continue; // skip junk instead of crashing
      final category = item['category'];
      if (category is! String || category.isEmpty) continue;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return MonthlyIncidentsModel(counts);
  }

  MonthlyIncidents toEntity(YearMonth month) => MonthlyIncidents(
    month: month.apiFormat,
    countsByCategory: countsByCategory,
  );
}