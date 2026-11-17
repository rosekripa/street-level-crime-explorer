import 'package:flutter_test/flutter_test.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/incident_summary.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/monthly_incidents.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';

void main() {
  const location = PostcodeLocation(
    postcode: 'SW1A 1AA',
    latitude: 51.501,
    longitude: -0.141,
    country: 'England',
  );

  // Top 6 are real September numbers. The 8 "rest" categories are invented
  // but add up to the real 436.
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

  test('total adds up to 2,929', () {
    expect(september.total, 2929);
  });

  test('top categories are the 6 largest, biggest first', () {
    const summary = IncidentSummary(location: location, current: september);
    expect(summary.topCategories.length, 6);
    expect(summary.topCategories.first.category, 'other-theft');
    expect(summary.topCategories.last.category, 'public-order');
  });

  test('the rest is 8 categories totalling 436', () {
    const summary = IncidentSummary(location: location, current: september);
    expect(summary.otherCategoryCount, 8);
    expect(summary.otherIncidentCount, 436);
  });

  test('change is about -6.2% against August', () {
    const summary = IncidentSummary(
      location: location,
      current: september,
      previous: august,
    );
    expect(summary.changePercent, closeTo(-6.2, 0.05));
  });

  test('change is null with no previous month', () {
    const summary = IncidentSummary(location: location, current: september);
    expect(summary.changePercent, isNull);
  });

  test('change is null when previous total is zero (no divide by zero)', () {
    const summary = IncidentSummary(
      location: location,
      current: september,
      previous: MonthlyIncidents(month: '2026-08', countsByCategory: {}),
    );
    expect(summary.changePercent, isNull);
  });

  test('equal counts are ordered by name, so the order is stable', () {
    const tied = MonthlyIncidents(
      month: '2026-09',
      countsByCategory: {'zebra': 5, 'apple': 5},
    );
    expect(tied.sortedCategories.first.category, 'apple');
  });
}