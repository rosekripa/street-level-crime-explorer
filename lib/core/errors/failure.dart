import 'package:equatable/equatable.dart';

/// Exceptions/Errors when loading data.
sealed class Failure extends Equatable implements Exception {
  const Failure();

  String get message;

  bool get isRetryable;

  @override
  List<Object?> get props => [message];
}

class PostcodeNotFoundFailure extends Failure {
  const PostcodeNotFoundFailure();

  @override
  String get message =>
      'We could not find that postcode. Check it and try again.';

  @override
  bool get isRetryable => false;
}

class RequestTimeoutFailure extends Failure {
  const RequestTimeoutFailure();

  @override
  String get message => 'Something went wrong. Please try again.';

  @override
  bool get isRetryable => true;
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure();

  @override
  String get message =>
      'Something went wrong. Check your connection and try again.';

  @override
  bool get isRetryable => true;
}

class ServerFailure extends Failure {
  const ServerFailure(this.statusCode);

  final int statusCode;

  @override
  String get message =>
      'Something went wrong. Please try again.';

  @override
  bool get isRetryable => true;

  @override
  List<Object?> get props => [statusCode];
}

/// The Police API returns 404 (Eg: a month that is not published).
class DataNotAvailableFailure extends Failure {
  const DataNotAvailableFailure();

  @override
  String get message => 'This data has not been published yet.';

  @override
  bool get isRetryable => false;
}

/// Got the response, but the body was not what we expected.
class InvalidResponseFailure extends Failure {
  const InvalidResponseFailure();

  @override
  String get message => 'Something went wrong while retrieving the data. Please try again later.';

  @override
  bool get isRetryable => false;
}