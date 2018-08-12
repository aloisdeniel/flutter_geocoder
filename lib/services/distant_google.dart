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
    _httpClient = new HttpClient(),
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
    final responseBody = await response.transform(utf8.decoder).join();
    print("Received $responseBody...");
    Map data = jsonDecode(responseBody);

    List<Map> results = data["results"];

    if(results == null)
      return null;

    return results.map(_convertAddress)
                  .map((map) => new Address.fromMap(map))
                  .toList();
  }

  Map _convertCoordinates(Map geometry) {
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

  Map _convertAddress(Map data) {

    Map result = new Map();

    result["coordinates"] = _convertCoordinates(data["geometry"]);
    result["addressLine"] = data["formatted_address"];

    List<Map> addressComponents = data["address_components"];

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
