import 'package:equatable/equatable.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/incident_summary.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';

sealed class CrimeState extends Equatable {
  const CrimeState();

  @override
  List<Object?> get props => [];
}

class CrimeInitial extends CrimeState {
  const CrimeInitial();
}

class CrimeLoading extends CrimeState {
  const CrimeLoading();
}

/// If summary.previous is null, the screen hides the comparison line.
class CrimeLoaded extends CrimeState {
  const CrimeLoaded(this.summary);

  final IncidentSummary summary;

  @override
  List<Object?> get props => [summary];
}

/// The API answered, but with zero incidents. This is NOT "no crime":
/// the month may be unpublished or the area may not be covered.
class CrimeNoData extends CrimeState {
  const CrimeNoData({required this.location, required this.month});

  final PostcodeLocation location;
  final YearMonth month;

  @override
  List<Object?> get props => [location, month];
}

class CrimePostcodeNotFound extends CrimeState {
  const CrimePostcodeNotFound();
}

class CrimeFailed extends CrimeState {
  const CrimeFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}