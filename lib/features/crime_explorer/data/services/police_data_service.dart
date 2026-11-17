import 'package:street_level_crime_explorer/core/constants/api_constants.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/core/network/api_client.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/models/monthly_incidents_model.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/monthly_incidents.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';

class PoliceDataService {
  PoliceDataService(this._api);

  final ApiClient _api;

  /// The latest month the API has published, or null if unreadable.
  Future<YearMonth?> latestMonth() async {
    final json = await _api.getJson(
      Uri.parse('${ApiConstants.policeBaseUrl}/crime-last-updated'),
    );
    if (json is Map) {
      final date = json['date'];
      if (date is String) return YearMonth.tryParse(date);
    }
    return null;
  }

  Future<MonthlyIncidents> fetchMonth(
      PostcodeLocation location,
      YearMonth month,
      ) async {
    final uri = Uri.parse('${ApiConstants.policeBaseUrl}/crimes-street/all-crime')
        .replace(queryParameters: {
      'lat': location.latitude.toString(),
      'lng': location.longitude.toString(),
      'date': month.apiFormat,
    });
    final json = await _api.getJson(
      uri,
      notFound: const DataNotAvailableFailure(),
    );
    return MonthlyIncidentsModel.fromJson(json).toEntity(month);
  }
}