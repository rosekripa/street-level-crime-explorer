import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';

class PostcodeModel {
  const PostcodeModel({
    required this.postcode,
    required this.latitude,
    required this.longitude,
    this.country,
  });

  final String postcode;
  final double latitude;
  final double longitude;
  final String? country;

  factory PostcodeModel.fromJson(Object? json) {
    if (json is! Map) throw const InvalidResponseFailure();
    final result = json['result'];
    if (result is! Map) throw const InvalidResponseFailure();

    final postcode = result['postcode'];
    final latitude = _toDouble(result['latitude']);
    final longitude = _toDouble(result['longitude']);
    if (postcode is! String || latitude == null || longitude == null) {
      throw const InvalidResponseFailure();
    }

    final country = result['country'];
    return PostcodeModel(
      postcode: postcode,
      latitude: latitude,
      longitude: longitude,
      country: country is String ? country : null,
    );
  }

  PostcodeLocation toEntity() => PostcodeLocation(
    postcode: postcode,
    latitude: latitude,
    longitude: longitude,
    country: country,
  );

  /// Accepts a number or a numeric string. Anything else gives null.
  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}