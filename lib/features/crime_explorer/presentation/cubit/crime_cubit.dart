import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/repositories/incident_repository.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/cubit/crime_state.dart';

class CrimeCubit extends Cubit<CrimeState> {
  CrimeCubit(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(const CrimeInitial());

  final IncidentRepository _repository;
  final DateTime Function() _now;

  int _latestRequest = 0;
  String? _lastPostcode;
  YearMonth? _lastMonth;

  /// Newest published month. Never throws: if the API call fails or is
  /// unreadable, falls back to today's month minus 2.
  Future<YearMonth> latestMonth() async {
    try {
      final latest = await _repository.latestMonth();
      if (latest != null) return latest;
    } catch (_){
      // Any failure, expected or not, falls through to the estimate below.
    }
    final today = _now();
    return YearMonth(today.year, today.month).previous.previous;
  }

  Future<void> search(String postcode, YearMonth month) async {
    final requestId = ++_latestRequest;
    _lastPostcode = postcode;
    _lastMonth = month;
    emit(const CrimeLoading());

    try {
      final summary = await _repository.getSummary(postcode, month);
      if (_isStale(requestId)) return;
      emit(
        summary.current.isEmpty
            ? CrimeNoData(location: summary.location, month: month)
            : CrimeLoaded(summary),
      );
    } on PostcodeNotFoundFailure {
      if (_isStale(requestId)) return;
      emit(const CrimePostcodeNotFound());
    } on Failure catch (failure) {
      if (_isStale(requestId)) return;
      emit(CrimeFailed(failure));
    } catch (_) {
      // Anything unexpected must never leave the screen on "loading".
      if (_isStale(requestId)) return;
      emit(const CrimeFailed(InvalidResponseFailure()));
    }
  }

  /// Repeats the last search (used by the Retry button).
  Future<void> retry() async {
    final postcode = _lastPostcode;
    final month = _lastMonth;
    if (postcode == null || month == null) return;
    await search(postcode, month);
  }

  /// Back to the start screen. Also cancels any search still in flight,
  ///  bumping the counter makes its late answer look stale, so it is ignored.
  void reset() {
    _latestRequest++;
    _lastPostcode = null;
    _lastMonth = null;
    emit(const CrimeInitial());
  }

  /// True if a newer search started, or the Cubit was closed.
  bool _isStale(int requestId) => requestId != _latestRequest || isClosed;
}