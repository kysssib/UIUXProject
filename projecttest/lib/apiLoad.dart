//flutter pub add http
//flutter pub add flutter_config
//andriod/app/src/main/AnidroidManifest.xml
// <application
//         android:usesCleartextTraffic="true"

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

//IP로 위도 경도 확인
Future<dynamic> nowLocation(String apiKey) async {
  final response = await http.get(Uri.parse('http://api.ipstack.com/check?access_key=$apiKey'));
  final result = jsonDecode(response.body);
  return [result['latitude'], result['longitude']];
}

//위치 정보 사용 요청 함수
Future<List<double>> requestLocationPermission() async {
  final permissionStatus = await Permission.location.request();
  if (permissionStatus == PermissionStatus.granted) {
    return getLocation();
  } else {
    //TODO: 권한 거부 시 구현할 함수
    return getLocation();//미구현
  }
}

//위도 경도 받는 함수
Future<List<double>> getLocation() async {
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
  bool isLocationServiceEnabled = await geolocator.isLocationServiceEnabled();
  LocationPermission permission = await geolocator.checkPermission();

  if (isLocationServiceEnabled && permission == LocationPermission.whileInUse) {
    Position position = await geolocator.getCurrentPosition();
    return [position.latitude, position.longitude];
  } else {
    throw Exception('Location permission denied');
  }
}

//Google API 지하철역 이름 요청
Future<String> GoogleStation(String apiKey, double latitude, double longitude, int radius) async {
  final response = await http.get(Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=subway_station&key=$apiKey'));
  final result = jsonDecode(response.body);
  if (result['status'] == 'ZERO_RESULTS') {
    return('가까운 지하철역을 찾을 수 없습니다.');
  } else {
    //최상단 제일 가까운 역 출력(json 파일에서 거리 순으로 데이터 정렬되어 있음)
    final subwayName = result['results'][0]['name'];
    return(subwayName);
  }
}

//KAKAO API 지하철역 이름 요청
Future<String> kakaoStation(String apiKey, double latitude, double longitude, int radius) async {
  //category_group_code=SW8 : 지하철역 x= longitude(경도) y= latitude(위도) radius= radius(반경)
  final url = 'https://dapi.kakao.com/v2/local/search/category.json?category_group_code=SW8&x=$longitude&y=$latitude&radius=$radius';
  final headers = {'Authorization': 'KakaoAK $apiKey'};
  final response = await http.get(Uri.parse(url), headers: headers);
  final result = jsonDecode(response.body);
  if (result['documents'].isEmpty) {
    return('가까운 지하철역을 찾을 수 없습니다.');
  } else {
    //최상단 제일 가까운 역 출력(json 파일에서 거리 순으로 데이터 정렬되어 있음)
    final subwayName = result['documents'][0]['place_name'];
    return(subwayName);
  }
}






