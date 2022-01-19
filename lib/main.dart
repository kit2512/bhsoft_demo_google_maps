import 'package:demo_google_maps/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_style.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: MapView(),
      ),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({
    Key? key,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController _mapController;
  final LocationService locationService = LocationService();

  Marker? origin;
  Marker? destination;
  Marker? currentLocation;
  MapType mapType = MapType.normal;

  final _initalPosition = LatLng(20.100000, 106.126288);

  void _onCreate(GoogleMapController controller) async {
    _mapController = controller;
    _mapController.setMapStyle(mapStyle);
    final currentPosition = await locationService.getPosition();
    final currentLatLng =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    currentLocation = Marker(
      markerId: MarkerId("currentLocation"),
      position: currentLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    _mapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    setState(() {});
  }

  void _onTap(LatLng latLng) {
    _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
    setState(() {
      origin = Marker(
        markerId: MarkerId("origin"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarker,
      );
    });
  }

  void _onLongPressed(LatLng latLng) {
    _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
    setState(() {
      destination = Marker(
        markerId: MarkerId("destination"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: GoogleMap(
            onMapCreated: _onCreate,
            initialCameraPosition: CameraPosition(
              target: _initalPosition,
              zoom: 15,
            ),
            markers: {
              if (currentLocation != null) currentLocation!,
              if (origin != null) origin!,
              if (destination != null) destination!,
            },
            onTap: _onTap,
            onLongPress: _onLongPressed,
            mapType: mapType,
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final position = await locationService.getPosition();
                  final latLng = LatLng(position.latitude, position.longitude);
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      latLng,
                      16.0,
                    ),
                  );
                },
                child: Icon(Icons.location_on),
              ),
              ElevatedButton(
                child: Text("Toggle map type"),
                onPressed: () {
                  setState(() {
                    mapType = mapType == MapType.normal
                        ? MapType.satellite
                        : MapType.normal;
                  });
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
