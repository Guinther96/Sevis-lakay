import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  Location? _pickedLocation;
  var _isgettingLocation = false;

  void getCurrentLocation() async {
    // Implement your location fetching logic here
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isgettingLocation = true;
    });

    locationData = await location.getLocation();

    setState(() {
      _isgettingLocation = false;
    });

    print(locationData.latitude);
    print(locationData.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'Aucune localisation choisie',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    );

    if (_isgettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: previewContent),
        ),
        Row(
          children: [
            IconButton(
              onPressed: getCurrentLocation,
              icon: Icon(Icons.location_on, color: Colors.blue),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.map, color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }
}
