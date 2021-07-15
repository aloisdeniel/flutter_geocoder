import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';

class AddressTile extends StatelessWidget {
  final Address address;

  AddressTile(this.address);

  final titleStyle =
      const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ErrorLabel(
              'feature name',
              this.address.featureName,
              fontSize: 15.0,
              isBold: true,
            ),
            ErrorLabel('address lines', this.address.addressLine),
            ErrorLabel('country name', this.address.countryName),
            ErrorLabel('locality', this.address.locality),
            ErrorLabel('sub-locality', this.address.subLocality),
            ErrorLabel('admin-area', this.address.adminArea),
            ErrorLabel('sub-admin-area', this.address.subAdminArea),
            ErrorLabel('thoroughfare', this.address.thoroughfare),
            ErrorLabel('sub-thoroughfare', this.address.subThoroughfare),
            ErrorLabel('postal code', this.address.postalCode),
            this.address.coordinates != null
                ? ErrorLabel("", this.address.coordinates.toString())
                : new ErrorLabel("coordinates", null),
          ]),
    );
  }
}

class AddressListView extends StatelessWidget {
  final List<Address> addresses;

  final bool isLoading;

  AddressListView(this.isLoading, this.addresses);

  @override
  Widget build(BuildContext context) {
    if (this.isLoading) {
      return new Center(child: new CircularProgressIndicator());
    }

    return new ListView.builder(
      itemCount: this.addresses.length,
      itemBuilder: (c, i) => new AddressTile(this.addresses[i]),
    );
  }
}

class ErrorLabel extends StatelessWidget {
  final String name;
  final String text;

  final TextStyle descriptionStyle;

  ErrorLabel(this.name, String? text,
      {double fontSize = 9.0, bool isBold = false})
      : this.text = text ?? 'Unknown $name',
        this.descriptionStyle = new TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: text == null ? Colors.red : Colors.black);

  @override
  Widget build(BuildContext context) {
    return Text(this.text, style: descriptionStyle);
  }
}
