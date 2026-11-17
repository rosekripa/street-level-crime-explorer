import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/failure.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    Duration timeout = ApiConstants.requestTimeout,
    int maxRetries = ApiConstants.maxRetries,
    Duration retryDelay = ApiConstants.retryDelay,
  })  : _client = client ?? http.Client(),
        _timeout = timeout,
        _maxRetries = maxRetries,
        _retryDelay = retryDelay;

  final http.Client _client;
  final Duration _timeout;
  final int _maxRetries;
  final Duration _retryDelay;

  /// GET a URL and return the decoded JSON.
  /// [notFound] is the failure to throw on a 404, because the meaning
  /// of a 404 depends on which API we are calling.
  Future<Object?> getJson(
      Uri uri, {
        Failure notFound = const InvalidResponseFailure(),
      }) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await _getOnce(uri, notFound);
      } on Failure catch (failure) {
        final canRetry = failure.isRetryable && attempt <= _maxRetries;
        if (!canRetry) rethrow;
        await Future<void>.delayed(_retryDelay * attempt);
      }
    }
  }

  Future<Object?> _getOnce(Uri uri, Failure notFound) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const RequestTimeoutFailure();
    } on http.ClientException {
      throw const NoConnectionFailure();
    }

    final status = response.statusCode;
    if (status == 404) throw notFound;
    if (status == 429 || status >= 500) throw ServerFailure(status);
    if (status != 200) throw const InvalidResponseFailure();

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const InvalidResponseFailure();
    }
  }

  void close() => _client.close();
}