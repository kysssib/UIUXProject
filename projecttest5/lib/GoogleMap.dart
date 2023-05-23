import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapBody extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  GoogleMapBody({required this.initialLatitude, required this.initialLongitude});

  @override
  _GoogleMapBodyState createState() => _GoogleMapBodyState();
}

class _GoogleMapBodyState extends State<GoogleMapBody> {
  double latitude = 0.0;
  double longitude = 0.0;

  late CameraPosition _kGooglePlex;
  List<Marker> _markers = [];
  late GoogleMapController _mapController;
  late Timer _timer;
  double _zoomLevel = 17.14;

  @override
  void initState() {
    super.initState();

    latitude = widget.initialLatitude;
    longitude = widget.initialLongitude;

    _kGooglePlex = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: _zoomLevel,
    );

    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(latitude, longitude),
      ),
    );

    _startUpdatingLocation();
  }

  @override
  void dispose() {
    _stopUpdatingLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        mapType: MapType.normal,
        markers: Set.from(_markers),
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onCameraMove: (position) {
          _zoomLevel = position.zoom;
        },
        onCameraIdle: () {
          _updateCameraPosition();
        },
      ),
    );
  }

  void _startUpdatingLocation() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateMarkerPosition();
    });
  }

  void _stopUpdatingLocation() {
    _timer?.cancel();
  }

  Future<void> _updateMarkerPosition() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;

      // Clear existing marker
      _markers.clear();

      // Add new marker
      _markers.add(
        Marker(
          markerId: MarkerId("1"),
          position: LatLng(latitude, longitude),
        ),
      );
    });
  }

  void _updateCameraPosition() {
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: _zoomLevel,
          ),
        ),
      );
    }
  }
}
