import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/incident_summary.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/monthly_incidents.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/widgets/result_card.dart';

void main() {
  const location = PostcodeLocation(
    postcode: 'SW1A 1AA',
    latitude: 51.5,
    longitude: -0.14,
  );
  // Same numbers as the entity test: total 2,929.
  const september = MonthlyIncidents(month: '2026-09', countsByCategory: {
    'other-theft': 541,
    'violent-crime': 501,
    'theft-from-the-person': 472,
    'anti-social-behaviour': 412,
    'shoplifting': 403,
    'public-order': 164,
    'bicycle-theft': 100,
    'burglary': 90,
    'criminal-damage-arson': 80,
    'drugs': 60,
    'vehicle-crime': 50,
    'robbery': 30,
    'possession-of-weapons': 20,
    'other-crime': 6,
  });
  const august = MonthlyIncidents(
    month: '2026-08',
    countsByCategory: {'other-theft': 3123},
  );

  Future<void> show(WidgetTester tester, IncidentSummary summary) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: ResultsCard(summary: summary)),
      ),
    ));
  }

  group('comparisonText', () {
    test('lower than the previous month', () {
      const s = IncidentSummary(
          location: location, current: september, previous: august);
      expect(comparisonText(s), '6.2% lower than August 2026');
    });

    test('says so when the previous month is missing', () {
      const s = IncidentSummary(location: location, current: september);
      expect(comparisonText(s), contains('could not be loaded'));
    });

    test('says so when the previous month has no incidents', () {
      const s = IncidentSummary(
        location: location,
        current: september,
        previous: MonthlyIncidents(month: '2026-08', countsByCategory: {}),
      );
      expect(comparisonText(s), contains('No comparison available'));
    });
  });

  group('ResultsCard', () {
    testWidgets('shows total, comparison, top bars and the rest',
            (tester) async {
          await show(
            tester,
            const IncidentSummary(
                location: location, current: september, previous: august),
          );
          expect(find.text('2,929'), findsOneWidget);
          expect(find.text('incidents reported'), findsOneWidget);
         // expect(find.text('2,929 incidents reported'), findsOneWidget);
          expect(find.text('6.2% lower than August 2026'), findsOneWidget);
          expect(find.text('Other theft'), findsOneWidget);
          expect(find.text('Public order'), findsOneWidget);
          expect(find.text('Bicycle theft'), findsNothing); // not in top 6
          expect(find.textContaining('8 other categories'), findsOneWidget);
        });

    testWidgets('still renders when there is no comparison month',
            (tester) async {
          await show(
            tester,
            const IncidentSummary(location: location, current: september),
          );
          expect(find.text('2,929'), findsOneWidget);
          expect(find.text('incidents reported'), findsOneWidget);
          //expect(find.text('2,929 incidents reported'), findsOneWidget);
          expect(find.textContaining('could not be loaded'), findsOneWidget);
        });
  });
}