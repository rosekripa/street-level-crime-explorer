import 'package:equatable/equatable.dart';

class PostcodeLocation extends Equatable{
  final String postcode;
  final double latitude;
  final double longitude;
  final String? country;

  const PostcodeLocation({
    required this.postcode,
    required this.latitude,
    required this.longitude,
    this.country });

  bool get isScotland => country == 'Scotland';

  @override
  List<Object?> get props => [postcode, latitude, longitude, country];
}