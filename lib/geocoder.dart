import 'package:geocoder/services/base.dart';
import 'package:geocoder/services/distant_google.dart';
import 'package:geocoder/services/local.dart';

export 'model.dart';

class Geocoder {
  static final Geocoding local = LocalGeocoding();
  static Geocoding google(String apiKey,
          {String? language, Map<String, String>? headers}) =>
      GoogleGeocoding(apiKey, language: language, headers: headers);
}
