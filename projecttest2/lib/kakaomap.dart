//https://pub.dev/packages/kakaomap_webview
//flutter pub add kakaomap_webview
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
  //초기 값 설정
  double latitude = 126.989703;
  double longitude = 37.285068;

  @override
  void initState() {
    super.initState();
    _startLocationUpdate();
  }

  //위치 정보 갱신하는 함수
  Future<void> _getLocation() async {
    final GeolocatorPlatform geolocator = GeolocatorPlatform.instance; //Geolocator 초기
    bool isLocationServiceEnabled = await geolocator.isLocationServiceEnabled(); //위치 서비스 활성화 확인
    LocationPermission permission = await geolocator.checkPermission(); //앱의 위치 정보 접근 허락 확인

    if (isLocationServiceEnabled && permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(); //위치 정보 받아오기
      //stationLoader와 달리 내부 변수를 직접 변경하는 함수
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    }
  }

  //5초마다 위치정보 갱신 후 반영
  void _startLocationUpdate() {
    Timer.periodic(Duration(seconds: 3), (_) async {
      if (mounted) {
        await _getLocation();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          //지도 화면에 채우기
          Expanded(
            child: KakaoMapView(
              mapController: (controller){

              },
              //지도 크기
              width: size.width,
              height: size.height,
              kakaoMapKey: kakaoMapKey,
              //현재 위치
              lat: longitude,
              lng: latitude,
              //지도, 스카이뷰 사용, zoom 기능 사용
              showMapTypeControl: true,
              showZoomControl: true,
              //마커 이미지
              markerImageURL: 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
              overlayText : 'Your Position',
            ),
          ),
        ],
      ),
    );
  }
}