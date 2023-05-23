import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:geolocator/geolocator.dart';

const String kakaoMapKey = 'f8e353133815938c664a84cf3f5af459';

class KakaoMapTest extends StatefulWidget {
  @override
  _KakaoMapTestState createState() => _KakaoMapTestState();
}

class _KakaoMapTestState extends State<KakaoMapTest> {
  late Stream<Position> _positionStream;

  //초기 값 설정
  double latitude = 126.989703;
  double longitude = 37.285068;

  Stream<Position> _getPositionStream() async* {
    final geolocator = GeolocatorPlatform.instance;
    bool isLocationServiceEnabled = await geolocator.isLocationServiceEnabled();
    LocationPermission permission = await geolocator.checkPermission();

    if (isLocationServiceEnabled && permission == LocationPermission.whileInUse) {
      await for (var position in geolocator.getPositionStream()) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });
        yield position;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _positionStream = _getPositionStream();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: StreamBuilder(
        stream: _positionStream,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to get location'),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return KakaoMapView(
              width: size.width,
              height: size.height,
              kakaoMapKey: kakaoMapKey,
              lat: latitude,
              lng: longitude,
              markerImageURL:
              'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
              overlayText: 'Your Position',
            );
          }
        },
      ),
    );
  }
}