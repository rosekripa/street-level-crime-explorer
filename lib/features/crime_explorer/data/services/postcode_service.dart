import 'package:street_level_crime_explorer/core/constants/api_constants.dart';
import 'package:street_level_crime_explorer/core/errors/failure.dart';
import 'package:street_level_crime_explorer/core/network/api_client.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/data/models/postcode_model.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/postcode_location.dart';

class PostcodeService {
  PostcodeService(this._api);

  final ApiClient _api;

  Future<PostcodeLocation> lookup(String postcode) async {
    final cleaned = postcode.trim();
    if (cleaned.isEmpty) throw const PostcodeNotFoundFailure();

    final uri = Uri.parse(
      '${ApiConstants.postcodesBaseUrl}/postcodes/${Uri.encodeComponent(cleaned)}',
    );
    final json = await _api.getJson(
      uri,
      notFound: const PostcodeNotFoundFailure(),
    );
    return PostcodeModel.fromJson(json).toEntity();
  }
}