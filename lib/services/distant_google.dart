import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:geocoder/model.dart';
import 'package:geocoder/services/base.dart';

/// Geocoding and reverse geocoding through requests to Google APIs.
class GoogleGeocoding implements Geocoding {

  static const _host = 'https://maps.google.com/maps/api/geocode/json';

  final String apiKey;

  final HttpClient _httpClient;

  GoogleGeocoding(this.apiKey) :
    _httpClient = HttpClient(),
    assert(apiKey != null, "apiKey must not be null");

  Future<List<Address>> findAddressesFromCoordinates(Coordinates coordinates) async  {
    final url = '$_host?key=$apiKey&latlng=${coordinates.latitude},${coordinates.longitude}';
    return _send(url);
  }

  Future<List<Address>> findAddressesFromQuery(String address) async {
    var encoded = Uri.encodeComponent(address);
    final url = '$_host?key=$apiKey&address=$encoded';
    return _send(url);
  }

  Future<List<Address>> _send(String url) async {
    print("Sending $url...");
    final uri = Uri.parse(url);
    final request = await this._httpClient.getUrl(uri);
    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    print("Received $responseBody...");
    var data = jsonDecode(responseBody);

    var results = data["results"];

    if(results == null)
      return null;

    return results.map(_convertAddress)
                  .map<Address>((map) => Address.fromMap(map))
                  .toList();
  }

  Map _convertCoordinates(dynamic geometry) {
    if(geometry == null)
      return null;

    var location = geometry["location"];
    if(location == null)
      return null;

    return {
      "latitude" : location["lat"],
      "longitude" : location["lng"],
    };
  }

  Map _convertAddress(dynamic data) {

    Map result = Map();

    result["coordinates"] = _convertCoordinates(data["geometry"]);
    result["addressLine"] = data["formatted_address"];

    var addressComponents = data["address_components"];

    addressComponents.forEach((item) {

      List types = item["types"];

      if(types.contains("route")) {

        result["thoroughfare"] = item["long_name"];
      }
      else if(types.contains("street_number")) {

        result["subThoroughfare"] = item["long_name"];
      }
      else if(types.contains("country")) {
        result["countryName"] = item["long_name"];
        result["countryCode"] = item["short_name"];
      }
      else if(types.contains("locality")) {
        result["locality"] = item["long_name"];
      }
      else if(types.contains("postal_code")) {
        result["postalCode"] = item["long_name"];
      }
      else if(types.contains("postal_code")) {
        result["postalCode"] = item["long_name"];
      }
      else if(types.contains("administrative_area_level_1")) {
        result["adminArea"] = item["long_name"];
      }
      else if(types.contains("administrative_area_level_2")) {
        result["subAdminArea"] = item["long_name"];
      }
      else if(types.contains("sublocality") || types.contains("sublocality_level_1")) {
        result["subLocality"] = item["long_name"];
      }
      else if(types.contains("premise")) {
        result["featureName"] = item["long_name"];
      }

      result["featureName"] = result["featureName"] ?? result["addressLine"];

    });

    return result;
  }
}
