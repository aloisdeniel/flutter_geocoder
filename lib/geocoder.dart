import 'package:geocoder/services/base.dart';
import 'package:geocoder/services/distant_google.dart';
import 'package:geocoder/services/local.dart';

export 'model.dart';

class Geocoder {
  static final Geocoding local = LocalGeocoding();
  static Geocoding withLanguage(String language) => LocalGeocoding(language: language);
  static Geocoding google(String apiKey, { String language }) => GoogleGeocoding(apiKey, language: language);
}
