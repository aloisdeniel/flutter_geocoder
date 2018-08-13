import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geocoder/model.dart';
import 'package:geocoder/services/base.dart';


/// Geocoding and reverse geocoding through built-lin local platform services.
class LocalGeocoding implements Geocoding {
  static const MethodChannel _channel = MethodChannel('github.com/aloisdeniel/geocoder');

  Future<List<Address>> findAddressesFromCoordinates(Coordinates coordinates) async  {
    Iterable addresses = await _channel.invokeMethod('findAddressesFromCoordinates', coordinates.toMap());
    return addresses.map((x) => Address.fromMap(x)).toList();
  }

  Future<List<Address>> findAddressesFromQuery(String address) async {
    Iterable coordinates = await _channel.invokeMethod('findAddressesFromQuery', { "address" : address });
    return coordinates.map((x) => Address.fromMap(x)).toList();
  }
}