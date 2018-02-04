import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';


class AddressTile extends StatelessWidget {

  final Address address;

  AddressTile(this.address);

  final titleStyle = const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return new Padding(
           padding: const EdgeInsets.all(10.0),
          child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new ErrorLabel("feature name", this.address.featureName, fontSize: 15.0, isBold: true, ),
            new ErrorLabel("address lines", this.address.addressLine),
            new ErrorLabel("country name", this.address.countryName),
            new ErrorLabel("locality", this.address.locality),
            new ErrorLabel("sub-locality", this.address.subLocality),
            new ErrorLabel("admin-area", this.address.adminArea),
            new ErrorLabel("sub-admin-area", this.address.subAdminArea),
            new ErrorLabel("thoroughfare", this.address.thoroughfare),
            new ErrorLabel("sub-thoroughfare", this.address.subThoroughfare),
            new ErrorLabel("postal code", this.address.postalCode),
            this.address.coordinates != null ? new ErrorLabel("", this.address.coordinates.toString()) : new ErrorLabel("coordinates", null),
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

    if(this.isLoading) {
      return new Center(child: new CircularProgressIndicator());
    }

    return new ListView.builder(
      itemCount: this.addresses.length,
      itemBuilder: (c,i) => new AddressTile(this.addresses[i]),
    );
  }
}

class ErrorLabel extends StatelessWidget {

  final String name, text;

  final TextStyle descriptionStyle;

  ErrorLabel(this.name, String text, { double fontSize = 9.0, bool isBold = false}) :
      this.text = text ?? "Unknown $name",
      this.descriptionStyle = new TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: text == null ? Colors.red : Colors.black);

  @override
  Widget build(BuildContext context) {
    return new Text(this.text, style: descriptionStyle);
  }
}