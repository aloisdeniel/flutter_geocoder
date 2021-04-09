import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:geocoder/model.dart';
import 'package:geocoder/services/base.dart';

/// Geocoding and reverse geocoding through requests to Google APIs.
class GoogleGeocoding implements Geocoding {
  GoogleGeocoding(this.apiKey, {required this.language})
      : _httpClient = HttpClient(),
        assert(apiKey != null, 'apiKey must not be null');
  static const String _host = 'https://maps.google.com/maps/api/geocode/json';

  final String? apiKey;
  final String? language;

  final HttpClient _httpClient;

  @override
  Future<List<Address>> findAddressesFromCoordinates(
      Coordinates coordinates) async {
    String url = '''
$_host?key=$apiKey${language != null ? '&language=' + language! : ''}&latlng=${coordinates.latitude},${coordinates.longitude}''';
    return _send(url);
  }

  @override
  Future<List<Address>> findAddressesFromQuery(String address) async {
    String encoded = Uri.encodeComponent(address);
    String url = '$_host?key=$apiKey&address=$encoded';
    return _send(url);
  }

  Future<List<Address>> _send(String url) async {
    //print("Sending $url...");
    Uri uri = Uri.parse(url);
    HttpClientRequest request = await this._httpClient.getUrl(uri);
    HttpClientResponse response = await request.close();
    String responseBody = await utf8.decoder.bind(response).join();
    //print("Received $responseBody...");
    dynamic data = jsonDecode(responseBody);

    List<String>? results = data['results'];

    if (results == null) {
      return <Address>[];
    }

    return results
        .map(_convertAddress)
        .map<Address>(
          (Map<dynamic, dynamic> map) => Address.fromMap(map),
        )
        .toList();
  }

  Map<String, dynamic>? _convertCoordinates(dynamic geometry) {
    if (geometry == null) return null;

    dynamic location = geometry['location'];
    if (location == null) return null;

    return <String, dynamic>{
      'latitude': location['lat'],
      'longitude': location['lng'],
    };
  }

  Map<String, dynamic> _convertAddress(dynamic data) {
    Map<String, dynamic> result = Map<String, dynamic>();

    result['coordinates'] = _convertCoordinates(data['geometry']);
    result['addressLine'] = data['formatted_address'];

    dynamic addressComponents = data['address_components'];

    addressComponents.forEach((dynamic item) {
      List<String> types = item['types'];

      if (types.contains('route')) {
        result['thoroughfare'] = item['long_name'];
      } else if (types.contains('street_number')) {
        result['subThoroughfare'] = item['long_name'];
      } else if (types.contains('country')) {
        result['countryName'] = item['long_name'];
        result['countryCode'] = item['short_name'];
      } else if (types.contains('locality')) {
        result['locality'] = item['long_name'];
      } else if (types.contains('postal_code')) {
        result['postalCode'] = item['long_name'];
      } else if (types.contains('postal_code')) {
        result['postalCode'] = item['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        result['adminArea'] = item['long_name'];
      } else if (types.contains('administrative_area_level_2')) {
        result['subAdminArea'] = item['long_name'];
      } else if (types.contains('sublocality') ||
          types.contains('sublocality_level_1')) {
        result['subLocality'] = item['long_name'];
      } else if (types.contains('premise')) {
        result['featureName'] = item['long_name'];
      }

      result['featureName'] = result['featureName'] ?? result['addressLine'];
    });

    return result;
  }
}
