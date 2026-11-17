import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/repositories/incident_repository_impl.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/services/police_data_service.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/services/postcode_service.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/monthly_incidents.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';

class MockPostcodeService extends Mock implements PostcodeService {}

class MockPoliceService extends Mock implements PoliceDataService {}

void main() {
  const location = PostcodeLocation(
    postcode: 'SW1A 1AA',
    latitude: 51.5,
    longitude: -0.14,
  );
  const sept = YearMonth(2026, 9);
  const aug = YearMonth(2026, 8);
  const septData =
  MonthlyIncidents(month: '2026-09', countsByCategory: {'burglary': 5});
  const augData =
  MonthlyIncidents(month: '2026-08', countsByCategory: {'burglary': 4});

  late MockPostcodeService postcodes;
  late MockPoliceService police;
  late IncidentRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(location);
    registerFallbackValue(sept);
  });

  setUp(() {
    postcodes = MockPostcodeService();
    police = MockPoliceService();
    repo = IncidentRepositoryImpl(
      postcodeService: postcodes,
      policeService: police,
    );
    when(() => postcodes.lookup(any())).thenAnswer((_) async => location);
  });

  test('returns both months when both load', () async {
    when(() => police.fetchMonth(location, sept))
        .thenAnswer((_) async => septData);
    when(() => police.fetchMonth(location, aug))
        .thenAnswer((_) async => augData);

    final summary = await repo.getSummary('SW1A 1AA', sept);
    expect(summary.current, septData);
    expect(summary.previous, augData);
  });

  test('partial failure: August fails, September still shows', () async {
    when(() => police.fetchMonth(location, sept))
        .thenAnswer((_) async => septData);
    when(() => police.fetchMonth(location, aug))
        .thenThrow(const ServerFailure(503));

    final summary = await repo.getSummary('SW1A 1AA', sept);
    expect(summary.current, septData);
    expect(summary.previous, isNull);
  });

  test('selected month failing throws its failure', () async {
    when(() => police.fetchMonth(location, sept))
        .thenThrow(const DataNotAvailableFailure());
    when(() => police.fetchMonth(location, aug))
        .thenAnswer((_) async => augData);

    await expectLater(
      repo.getSummary('SW1A 1AA', sept),
      throwsA(const DataNotAvailableFailure()),
    );
  });

  test('postcode not found stops before any police request', () async {
    when(() => postcodes.lookup(any()))
        .thenThrow(const PostcodeNotFoundFailure());

    await expectLater(
      repo.getSummary('ZZ99 9ZZ', sept),
      throwsA(const PostcodeNotFoundFailure()),
    );
    verifyNever(() => police.fetchMonth(any(), any()));
  });
}