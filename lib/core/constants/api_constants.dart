class ApiConstants {
  const ApiConstants._();

  static const postcodesBaseUrl = 'https://api.postcodes.io';
  static const policeBaseUrl = 'https://data.police.uk/api';

  /// How long we wait for one request before giving up.
  static const requestTimeout = Duration(seconds: 15);

  /// Extra attempts after the first one, so 3 tries in total.
  static const maxRetries = 2;

  /// Wait before a retry. Multiplied by the attempt number.
  static const retryDelay = Duration(milliseconds: 500);
}