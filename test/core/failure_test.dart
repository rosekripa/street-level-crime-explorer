import 'package:flutter_test/flutter_test.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';

void main() {
  test('postcode not found is not retryable', () {
    expect(const PostcodeNotFoundFailure().isRetryable, isFalse);
  });

  test('timeout and server errors are retryable', () {
    expect(const RequestTimeoutFailure().isRetryable, isTrue);
    expect(const ServerFailure(503).isRetryable, isTrue);
  });

  test('server failures with the same code are equal', () {
    expect(const ServerFailure(503), const ServerFailure(503));
    expect(const ServerFailure(503), isNot(const ServerFailure(500)));
  });
}