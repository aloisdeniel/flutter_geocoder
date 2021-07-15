import 'package:geocoder/services/base.dart';
import 'package:geocoder/services/distant_google.dart';
import 'package:geocoder/services/local.dart';

export 'model.dart';

class Geocoder {
  static final Geocoding local = LocalGeocoding();
  static Geocoding google(
    String apiKey, {
    String? language,
    Map<String, Object>? headers,
    bool preserveHeaderCase = false,
  }) =>
      GoogleGeocoding(apiKey,
          language: language,
          headers: headers,
          preserveHeaderCase: preserveHeaderCase);
}
