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
  late Timer? _timer;
  double _zoomLevel = 17.14;

  @override
  void initState() {
    super.initState();

    latitude = widget.initialLatitude;
    longitude = widget.initialLongitude;

    //초기 카메라 위치
    _kGooglePlex = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: _zoomLevel,
    );

    //초기 마커 위치
    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(latitude, longitude),
      ),
    );

    //위치 갱신
    _startUpdatingLocation();
  }

  @override
  void dispose() {
    _stopUpdatingLocation(); //위치 갱신 중지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap( //맵 생성
      mapType: MapType.normal,
      markers: Set.from(_markers),
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      //카메라 움직이면 zoom레벨 갱신
      onCameraMove: (position) {
        _zoomLevel = position.zoom;
      },
      //카메라 이동 멈추면 카메라 위치정보 갱신
      onCameraIdle: () {
        _updateCameraPosition();
      },
    );
  }

  //1초마다 마커 위치 갱신 함수 호출
  void _startUpdatingLocation() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateMarkerPosition();
    });
  }

  //타이머 종료
  void _stopUpdatingLocation() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _updateMarkerPosition() async {
    //현재 위치 갱신
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    //마커 삭제 후 재생성
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;

      //마커 삭제
      _markers.clear();

      //마커 추가
      _markers.add(
        Marker(
          markerId: MarkerId("1"),
          position: LatLng(latitude, longitude),
        ),
      );
    });
  }

  //카메라 위치 정보 갱신
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
