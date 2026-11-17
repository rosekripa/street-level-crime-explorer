import '../entities/incident_summary.dart';
import '../entities/year_month.dart';

abstract class IncidentRepository {
  /// Newest month the police have published, or null if unknown.
  Future<YearMonth?> latestMonth();

  /// Summary for one postcode and month.
  /// Throws a [Failure] if the postcode or selected month cannot be loaded.
  /// If only the previous month fails, [IncidentSummary.previous] is null.
  Future<IncidentSummary> getSummary(String postcode, YearMonth month);
}