import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/incident_summary.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/monthly_incidents.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/repositories/incident_repository.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/cubit/crime_cubit.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/cubit/crime_state.dart';

class MockRepository extends Mock implements IncidentRepository {}

void main() {
  const sept = YearMonth(2026, 9);
  const location = PostcodeLocation(
    postcode: 'SW1A 1AA',
    latitude: 51.5,
    longitude: -0.14,
  );
  const withData = MonthlyIncidents(
    month: '2026-09',
    countsByCategory: {'burglary': 5},
  );
  const empty = MonthlyIncidents(month: '2026-09', countsByCategory: {});

  const summary = IncidentSummary(location: location, current: withData);
  const summaryOther = IncidentSummary(
    location: location,
    current: MonthlyIncidents(
      month: '2026-09',
      countsByCategory: {'shoplifting': 9},
    ),
  );

  late MockRepository repo;

  setUpAll(() => registerFallbackValue(sept));
  setUp(() => repo = MockRepository());

  group('search', () {
    blocTest<CrimeCubit, CrimeState>(
      'emits loading then loaded',
      setUp: () => when(() => repo.getSummary(any(), any()))
          .thenAnswer((_) async => summary),
      build: () => CrimeCubit(repo),
      act: (c) => c.search('SW1A 1AA', sept),
      expect: () => [const CrimeLoading(), const CrimeLoaded(summary)],
    );

    blocTest<CrimeCubit, CrimeState>(
      'loaded without a previous month still shows results',
      setUp: () => when(() => repo.getSummary(any(), any()))
          .thenAnswer((_) async => summary), // previous is null
      build: () => CrimeCubit(repo),
      act: (c) => c.search('SW1A 1AA', sept),
      verify: (c) {
        final state = c.state as CrimeLoaded;
        expect(state.summary.previous, isNull);
      },
    );

    blocTest<CrimeCubit, CrimeState>(
      'an empty month emits no data, not loaded',
      setUp: () => when(() => repo.getSummary(any(), any())).thenAnswer(
            (_) async => const IncidentSummary(location: location, current: empty),
      ),
      build: () => CrimeCubit(repo),
      act: (c) => c.search('SW1A 1AA', sept),
      expect: () => [
        const CrimeLoading(),
        const CrimeNoData(location: location, month: sept),
      ],
    );

    blocTest<CrimeCubit, CrimeState>(
      'unknown postcode emits postcode not found',
      setUp: () => when(() => repo.getSummary(any(), any()))
          .thenThrow(const PostcodeNotFoundFailure()),
      build: () => CrimeCubit(repo),
      act: (c) => c.search('ZZ99 9ZZ', sept),
      expect: () => [const CrimeLoading(), const CrimePostcodeNotFound()],
    );

    blocTest<CrimeCubit, CrimeState>(
      'a timeout emits failed with that failure',
      setUp: () => when(() => repo.getSummary(any(), any()))
          .thenThrow(const RequestTimeoutFailure()),
      build: () => CrimeCubit(repo),
      act: (c) => c.search('SW1A 1AA', sept),
      expect: () => [
        const CrimeLoading(),
        const CrimeFailed(RequestTimeoutFailure()),
      ],
    );

    blocTest<CrimeCubit, CrimeState>(
      'an unexpected error never leaves the screen loading',
      setUp: () => when(() => repo.getSummary(any(), any()))
          .thenThrow(StateError('bug')),
      build: () => CrimeCubit(repo),
      act: (c) => c.search('SW1A 1AA', sept),
      expect: () => [
        const CrimeLoading(),
        const CrimeFailed(InvalidResponseFailure()),
      ],
    );
  });

  group('stale responses', () {
    blocTest<CrimeCubit, CrimeState>(
      'a slow old search cannot overwrite a newer one',
      setUp: () {
        final slowFirst = Completer<IncidentSummary>();
        when(() => repo.getSummary('FIRST', any()))
            .thenAnswer((_) => slowFirst.future);
        when(() => repo.getSummary('SECOND', any()))
            .thenAnswer((_) async => summaryOther);
        // Finish the slow request AFTER the second one has completed.
        Future<void>.delayed(
          const Duration(milliseconds: 20),
              () => slowFirst.complete(summary),
        );
      },
      build: () => CrimeCubit(repo),
      act: (c) async {
        c.search('FIRST', sept);
        await c.search('SECOND', sept);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [const CrimeLoading(), const CrimeLoaded(summaryOther)],
    );
  });

  group('retry', () {
    blocTest<CrimeCubit, CrimeState>(
      'repeats the last search after a failure',
      setUp: () {
        var calls = 0;
        when(() => repo.getSummary(any(), any())).thenAnswer((_) async {
          calls++;
          if (calls == 1) throw const NoConnectionFailure();
          return summary;
        });
      },
      build: () => CrimeCubit(repo),
      act: (c) async {
        await c.search('SW1A 1AA', sept);
        await c.retry();
      },
      expect: () => [
        const CrimeLoading(),
        const CrimeFailed(NoConnectionFailure()),
        const CrimeLoading(),
        const CrimeLoaded(summary),
      ],
    );
  });

  group('latestMonth', () {
    final fakeToday = DateTime(2026, 11, 17);

    test('uses the API value when available', () async {
      when(() => repo.latestMonth()).thenAnswer((_) async => sept);
      final cubit = CrimeCubit(repo, now: () => fakeToday);
      expect(await cubit.latestMonth(), sept);
    });

    test('falls back to today minus 2 months when unreadable', () async {
      when(() => repo.latestMonth()).thenAnswer((_) async => null);
      final cubit = CrimeCubit(repo, now: () => fakeToday);
      expect(await cubit.latestMonth(), const YearMonth(2026, 9));
    });

    test('falls back when the call fails', () async {
      when(() => repo.latestMonth()).thenThrow(const RequestTimeoutFailure());
      final cubit = CrimeCubit(repo, now: () => fakeToday);
      expect(await cubit.latestMonth(), const YearMonth(2026, 9));
    });

    test('fallback wraps across the year end', () async {
      when(() => repo.latestMonth()).thenAnswer((_) async => null);
      final cubit = CrimeCubit(repo, now: () => DateTime(2026, 1, 10));
      expect(await cubit.latestMonth(), const YearMonth(2025, 11));
    });

    test('falls back even on an unexpected error', () async {
      when(() => repo.latestMonth()).thenThrow(StateError('bug'));
      final cubit = CrimeCubit(repo, now: () => fakeToday);
      expect(await cubit.latestMonth(), const YearMonth(2026, 9));
    });
  });

  group('reset', () {
    blocTest<CrimeCubit, CrimeState>(
      'goes back to the start state after results',
      setUp: () => when(() => repo.getSummary(any(), any()))
          .thenAnswer((_) async => summary),
      build: () => CrimeCubit(repo),
      act: (c) async {
        await c.search('SW1A 1AA', sept);
        c.reset();
      },
      expect: () => [
        const CrimeLoading(),
        const CrimeLoaded(summary),
        const CrimeInitial(),
      ],
    );

    blocTest<CrimeCubit, CrimeState>(
      'a search still in flight cannot bring results back after reset',
      setUp: () {
        final slow = Completer<IncidentSummary>();
        when(() => repo.getSummary(any(), any()))
            .thenAnswer((_) => slow.future);
        Future<void>.delayed(
          const Duration(milliseconds: 20),
              () => slow.complete(summary),
        );
      },
      build: () => CrimeCubit(repo),
      act: (c) async {
        c.search('SW1A 1AA', sept);
        c.reset();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [const CrimeLoading(), const CrimeInitial()],
    );

    blocTest<CrimeCubit, CrimeState>(
      'retry does nothing after reset',
      setUp: () => when(() => repo.getSummary(any(), any()))
          .thenAnswer((_) async => summary),
      build: () => CrimeCubit(repo),
      act: (c) async {
        await c.search('SW1A 1AA', sept);
        c.reset();
        await c.retry();
      },
      expect: () => [
        const CrimeLoading(),
        const CrimeLoaded(summary),
        const CrimeInitial(),
      ],
      verify: (_) => verify(() => repo.getSummary(any(), any())).called(1),
    );
  });
}