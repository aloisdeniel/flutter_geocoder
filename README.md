# geocoder

Forward and reverse geocoding.

# Usage

Import `package:geocoder/geocoder.dart`, and use the `Geocoder.local` to access geocoding services provided by the device system.

Example:

```dart
import 'package:geocoder/geocoder.dart';

// From a query
final query = "1600 Amphiteatre Parkway, Mountain View";
var addresses = await Geocoder.local.findAddressesFromQuery(query);
var first = addresses.first;
print("${first.featureName} : ${first.coordinates}");

// From coordinates
final coordinates = new Coordinates(1.10, 45.50);
addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
first = addresses.first;
print("${first.featureName} : ${first.addressLine}");
```

You can alternatively use `Geocoder.google` member for requesting distant data from google services instead of native ones.

You will find links to the API docs on the [pub page](https://pub.dartlang.org/packages/geocoder).

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).