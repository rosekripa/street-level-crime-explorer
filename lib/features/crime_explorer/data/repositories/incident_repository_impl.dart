import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/services/police_data_service.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/services/postcode_service.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/incident_summary.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/monthly_incidents.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/repositories/incident_repository.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  IncidentRepositoryImpl({
    required PostcodeService postcodeService,
    required PoliceDataService policeService,
  })  : _postcodes = postcodeService,
        _police = policeService;

  final PostcodeService _postcodes;
  final PoliceDataService _police;

  @override
  Future<YearMonth?> latestMonth() => _police.latestMonth();

  @override
  Future<IncidentSummary> getSummary(String postcode, YearMonth month) async {
    final location = await _postcodes.lookup(postcode);

    final (current, previous) = await (
    _attempt(() => _police.fetchMonth(location, month)),
    _attempt(() => _police.fetchMonth(location, month.previous)),
    ).wait;

    if (current.failure != null) throw current.failure!;

    return IncidentSummary(
      location: location,
      current: current.data!,
      previous: previous.data, // null if that month failed
    );
  }

  /// Runs a request and returns either its data or its failure, never throws.
  Future<_Outcome> _attempt(Future<MonthlyIncidents> Function() request) async {
    try {
      return _Outcome(data: await request());
    } on Failure catch (failure) {
      return _Outcome(failure: failure);
    }
  }
}

class _Outcome {
  const _Outcome({this.data, this.failure});

  final MonthlyIncidents? data;
  final Failure? failure;
}