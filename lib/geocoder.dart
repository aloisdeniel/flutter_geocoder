import 'package:geocoder/services/base.dart';
import 'package:geocoder/services/distant_google.dart';
import 'package:geocoder/services/local.dart';

export 'model.dart';

class Geocoder {
  static final Geocoding local = new LocalGeocoding();
  static Geocoding google(String apiKey) => new GoogleGeocoding(apiKey);
}
