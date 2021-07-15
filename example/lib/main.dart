import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class AppState extends InheritedWidget {
  const AppState({
    Key? key,
    required this.mode,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final Geocoding mode;

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>()!;
  }

  @override
  bool updateShouldNotify(AppState old) => mode != old.mode;
}

class GeocodeView extends StatefulWidget {
  GeocodeView();

  @override
  _GeocodeViewState createState() => _GeocodeViewState();
}

class _GeocodeViewState extends State<GeocodeView> {
  _GeocodeViewState();

  final TextEditingController _controller = TextEditingController();

  List<Address> results = [];

  bool isLoading = false;

  Future search() async {
    this.setState(() {
      this.isLoading = true;
    });

    try {
      var geocoding = AppState.of(context).mode;
      var results = await geocoding.findAddressesFromQuery(_controller.text);
      this.setState(() {
        this.results = results;
      });
    } catch (e) {
      print("Error occured: $e");
    } finally {
      this.setState(() {
        this.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter an address",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => search(),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: AddressListView(
            this.isLoading,
            this.results,
          ),
        ),
      ],
    );
  }
}

class ReverseGeocodeView extends StatefulWidget {
  ReverseGeocodeView();

  @override
  _ReverseGeocodeViewState createState() => _ReverseGeocodeViewState();
}

class _ReverseGeocodeViewState extends State<ReverseGeocodeView> {
  final TextEditingController _controllerLongitude = TextEditingController();
  final TextEditingController _controllerLatitude = TextEditingController();

  _ReverseGeocodeViewState();

  List<Address> results = [];

  bool isLoading = false;

  Future search() async {
    this.setState(() {
      this.isLoading = true;
    });

    try {
      var geocoding = AppState.of(context).mode;
      var longitude = double.parse(_controllerLongitude.text);
      var latitude = double.parse(_controllerLatitude.text);
      var results = await geocoding
          .findAddressesFromCoordinates(Coordinates(latitude, longitude));
      this.setState(() {
        this.results = results;
      });
    } catch (e) {
      print("Error occured: $e");
    } finally {
      this.setState(() {
        this.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _controllerLatitude,
                      decoration: InputDecoration(
                        hintText: "Latitude",
                      ),
                    ),
                    TextField(
                      controller: _controllerLongitude,
                      decoration: InputDecoration(
                        hintText: "Longitude",
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => search(),
              )
            ],
          ),
        ),
      ),
      Expanded(
        child: AddressListView(
          this.isLoading,
          this.results,
        ),
      ),
    ]);
  }
}

class _MyAppState extends State<MyApp> {
  Geocoding geocoding = Geocoder.local;

  final Map<String, Geocoding> modes = {
    "Local": Geocoder.local,
    "Google (distant)": Geocoder.google("<API-KEY>"),
  };

  void _changeMode(Geocoding mode) {
    this.setState(() {
      geocoding = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      mode: this.geocoding,
      child: MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Geocoder'),
              actions: <Widget>[
                PopupMenuButton<Geocoding>(
                  // overflow menu
                  onSelected: _changeMode,
                  itemBuilder: (BuildContext context) {
                    return modes.keys.map((String mode) {
                      return CheckedPopupMenuItem<Geocoding>(
                        checked: modes[mode] == this.geocoding,
                        value: modes[mode],
                        child: Text(mode),
                      );
                    }).toList();
                  },
                ),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(
                    text: "Query",
                    icon: Icon(Icons.search),
                  ),
                  Tab(
                    text: "Coordinates",
                    icon: Icon(Icons.pin_drop),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                GeocodeView(),
                ReverseGeocodeView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
