import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<List<double>> nowLocation() async {
  final permissionStatus = await Permission.locationWhenInUse.request(); //위치정보 접근 허락 요청
  if(permissionStatus == PermissionStatus.granted){ //접근 허락시 위도,경도 리스트 반환
    //위치정보 반환
    return getLocation();
  } else{
    //위치정보 허용 받지 못할 시 Null List 반환
    return [];
  }
}

Future<List<double>> getLocation() async {
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance; //Geolocator 초기
  bool isLocationServiceEnabled = await geolocator.isLocationServiceEnabled(); //위치 서비스 활성화 확인
  LocationPermission permission = await geolocator.checkPermission(); //앱의 위치 정보 접근 허락 확인

  if (isLocationServiceEnabled && permission == LocationPermission.whileInUse) {
    Position position = await Geolocator.getCurrentPosition(); //위치 정보 받아오기
    return [position.latitude, position.longitude];
  } else {
    return []; //위치 정보 접속 불가 시 Null List 반환
  }
}

Future<String> kakaoStation(int radius) async { //위치 정보 문제시 error 0, 근처 역이 없을시 error 1, 정상 반환 시 '역 이름 호선'
  List<double> location = await nowLocation();
  if(location.isEmpty) {
    return('error 0');//위치 정보 관련 문제
  }

  double latitude = location[0]; //위도
  double longitude = location[1]; //경도

  String apiKey = "fe85ce059fe1e217d3e2e66ded3668e6";
  //category_group_code=SW8 : 지하철 역, x= longitude(경도), y= latitude(위도), radius= radius(반경(m))
  final url = 'https://dapi.kakao.com/v2/local/search/category.json?category_group_code=SW8&x=$longitude&y=$latitude&radius=$radius';
  final headers = {'Authorization': 'KakaoAK $apiKey'};
  final response = await http.get(Uri.parse(url), headers: headers);
  final result = json.decode(response.body);

  if (result['documents'].isEmpty) {
    return('error 1'); //근처에 역이 없는 문제
  } else {
    //최상단 제일 가까운 역 출력(json 파일에서 거리 순으로 데이터 정렬되어 있음)
    final subwayName = result['documents'][0]['place_name'];
    final words = subwayName.split('역');
    final extractedName = words[0].trim();
    return extractedName;
  }
}

Future<List<String>> kakaoStation5(int radius) async {
  List<double> location = await nowLocation();
  if(location.isEmpty) {
    return [];//위치 정보 관련 문제
  }

  double latitude = location[0]; //위도
  double longitude = location[1]; //경도

  String apiKey = "fe85ce059fe1e217d3e2e66ded3668e6";
  final url = 'https://dapi.kakao.com/v2/local/search/category.json?category_group_code=SW8&x=$longitude&y=$latitude&radius=$radius';
  final headers = {'Authorization': 'KakaoAK $apiKey'};
  final response = await http.get(Uri.parse(url), headers: headers);
  final result = json.decode(response.body);

  if (result['documents'].isEmpty) {
    return []; //근처에 역이 없는 문제
  } else {
    var subwayName = result['documents'];
    var subwaycount = subwayName.length;
    //최상단 제일 가까운 역 출력(json 파일에서 거리 순으로 데이터 정렬되어 있음)
    if (subwaycount >= 5) {
      subwayName = subwayName.sublist(0, 4);
    } else {
      subwayName = subwayName.sublist(0, subwaycount-1);
    }

    List<String> stationNames = [];
    for (var subway in subwayName) {
      stationNames.add(subway['place_name']); //각 역의 이름을 리스트에 추가
    }

    return stationNames; //역 이름 리스트 반환
  }
}