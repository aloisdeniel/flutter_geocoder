import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geocoder/model.dart';
import 'package:geocoder/services/base.dart';

/// Geocoding and reverse geocoding through built-lin local platform services.
class LocalGeocoding implements Geocoding {
  static const MethodChannel _channel =
      MethodChannel('github.com/aloisdeniel/geocoder');

  @override
  Future<List<Address>> findAddressesFromCoordinates(
      Coordinates coordinates) async {
    Iterable<String> addresses = await _channel.invokeMethod(
        'findAddressesFromCoordinates', coordinates.toMap());
    return addresses.map((dynamic x) => Address.fromMap(x)).toList();
  }

  @override
  Future<List<Address>> findAddressesFromQuery(String address) async {
    Iterable<double> coordinates = await _channel.invokeMethod(
        'findAddressesFromQuery', <String, String>{'address': address});
    return coordinates.map((dynamic x) => Address.fromMap(x)).toList();
  }
}
