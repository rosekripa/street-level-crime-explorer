import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/core/network/api_client.dart';

void main() {
  final uri = Uri.parse('https://example.test/data');

  ApiClient clientFor(
      Future<http.Response> Function(http.Request) handler, {
        Duration timeout = const Duration(seconds: 1),
      }) {
    return ApiClient(
      client: MockClient(handler),
      timeout: timeout,
      maxRetries: 2,
      retryDelay: Duration.zero,
    );
  }

  test('returns decoded JSON on 200', () async {
    final api = clientFor((_) async => http.Response('[{"a":1}]', 200));
    expect(await api.getJson(uri), [
      {'a': 1}
    ]);
  });

  test('404 throws the failure the caller supplied, with no retry', () async {
    var calls = 0;
    final api = clientFor((_) async {
      calls++;
      return http.Response('', 404);
    });
    await expectLater(
      api.getJson(uri, notFound: const PostcodeNotFoundFailure()),
      throwsA(const PostcodeNotFoundFailure()),
    );
    expect(calls, 1);
  });

  test('retries a 503 and succeeds on the second try', () async {
    var calls = 0;
    final api = clientFor((_) async {
      calls++;
      return calls == 1 ? http.Response('', 503) : http.Response('[]', 200);
    });
    expect(await api.getJson(uri), <Object?>[]);
    expect(calls, 2);
  });

  test('gives up after 3 tries on a constant 503', () async {
    var calls = 0;
    final api = clientFor((_) async {
      calls++;
      return http.Response('', 503);
    });
    await expectLater(api.getJson(uri), throwsA(const ServerFailure(503)));
    expect(calls, 3);
  });

  test('a slow response becomes a timeout failure', () async {
    final api = clientFor(
          (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return http.Response('[]', 200);
      },
      timeout: const Duration(milliseconds: 10),
    );
    await expectLater(
      api.getJson(uri),
      throwsA(const RequestTimeoutFailure()),
    );
  });

  test('a network error becomes a no-connection failure', () async {
    final api = clientFor((_) async => throw http.ClientException('offline'));
    await expectLater(
      api.getJson(uri),
      throwsA(const NoConnectionFailure()),
    );
  });

  test('bad JSON becomes an invalid response, with no retry', () async {
    var calls = 0;
    final api = clientFor((_) async {
      calls++;
      return http.Response('<html>oops</html>', 200);
    });
    await expectLater(
      api.getJson(uri),
      throwsA(const InvalidResponseFailure()),
    );
    expect(calls, 1);
  });

  test('an empty 200 body is an invalid response, not a crash', () async {
    final api = clientFor((_) async => http.Response('', 200));
    await expectLater(
      api.getJson(uri),
      throwsA(const InvalidResponseFailure()),
    );
  });
}