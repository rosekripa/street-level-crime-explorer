import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/core/network/api_client.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/models/monthly_incidents_model.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/models/postcode_model.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/services/police_data_service.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/services/postcode_service.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';

ApiClient apiWith(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(
      client: MockClient(handler),
      timeout: const Duration(seconds: 1),
      maxRetries: 0,
      retryDelay: Duration.zero,
    );

void main() {
  group('PostcodeModel', () {
    test('reads numbers and a country', () {
      final model = PostcodeModel.fromJson({
        'result': {
          'postcode': 'SW1A 1AA',
          'latitude': 51.5,
          'longitude': -0.14,
          'country': 'England',
        }
      });
      expect(model.toEntity().country, 'England');
      expect(model.latitude, 51.5);
    });

    test('accepts coordinates sent as strings', () {
      final model = PostcodeModel.fromJson({
        'result': {'postcode': 'X', 'latitude': '51.5', 'longitude': '-0.14'}
      });
      expect(model.longitude, -0.14);
      expect(model.country, isNull);
    });

    test('missing coordinates is an invalid response', () {
      expect(
            () => PostcodeModel.fromJson({
          'result': {'postcode': 'X', 'latitude': null, 'longitude': null}
        }),
        throwsA(const InvalidResponseFailure()),
      );
    });
  });

  group('MonthlyIncidentsModel', () {
    test('counts incidents per category and skips junk', () {
      final model = MonthlyIncidentsModel.fromJson([
        {'category': 'shoplifting'},
        {'category': 'shoplifting'},
        {'category': 'burglary'},
        {'no_category': true},
        'junk',
        null,
      ]);
      expect(model.countsByCategory, {'shoplifting': 2, 'burglary': 1});
    });

    test('an empty list gives an empty count, not an error', () {
      final entity = MonthlyIncidentsModel.fromJson([])
          .toEntity(const YearMonth(2026, 10));
      expect(entity.isEmpty, isTrue);
      expect(entity.month, '2026-10');
    });

    test('a non-list body is an invalid response', () {
      expect(
            () => MonthlyIncidentsModel.fromJson({'error': 'x'}),
        throwsA(const InvalidResponseFailure()),
      );
    });
  });

  group('PostcodeService', () {
    test('encodes the space and returns a location', () async {
      late Uri seen;
      final service = PostcodeService(apiWith((req) async {
        seen = req.url;
        return http.Response(
          '{"status":200,"result":{"postcode":"SW1A 1AA",'
              '"latitude":51.5,"longitude":-0.14,"country":"England"}}',
          200,
        );
      }));
      final location = await service.lookup(' SW1A 1AA ');
      expect(seen.toString(), contains('/postcodes/SW1A%201AA'));
      expect(location.postcode, 'SW1A 1AA');
    });

    test('404 becomes postcode not found', () async {
      final service = PostcodeService(
        apiWith((_) async => http.Response('{"error":"Postcode not found"}', 404)),
      );
      await expectLater(
        service.lookup('ZZ99 9ZZ'),
        throwsA(const PostcodeNotFoundFailure()),
      );
    });
  });

  group('PoliceService', () {
    const location = PostcodeLocation(
      postcode: 'SW1A 1AA',
      latitude: 51.5,
      longitude: -0.14,
    );

    test('builds the right URL and counts categories', () async {
      late Uri seen;
      final service = PoliceDataService(apiWith((req) async {
        seen = req.url;
        return http.Response(
          '[{"category":"burglary"},{"category":"burglary"}]',
          200,
        );
      }));
      final result =
      await service.fetchMonth(location, const YearMonth(2026, 9));
      expect(seen.queryParameters['date'], '2026-09');
      expect(seen.queryParameters['lat'], '51.5');
      expect(result.countsByCategory, {'burglary': 2});
    });

    test('404 becomes data not available', () async {
      final service =
      PoliceDataService(apiWith((_) async => http.Response('', 404)));
      await expectLater(
        service.fetchMonth(location, const YearMonth(2026, 11)),
        throwsA(const DataNotAvailableFailure()),
      );
    });

    test('latestMonth reads the date', () async {
      final service = PoliceDataService(
        apiWith((_) async => http.Response('{"date":"2026-09-01"}', 200)),
      );
      expect(await service.latestMonth(), const YearMonth(2026, 9));
    });

    test('latestMonth gives null for an unreadable body', () async {
      final service =
      PoliceDataService(apiWith((_) async => http.Response('{}', 200)));
      expect(await service.latestMonth(), isNull);
    });
  });
}