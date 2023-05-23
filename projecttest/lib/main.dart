import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projecttest/apiLoad.dart';


//Future<void> main() async{
//  await dotenv.load(fileName: "API_KEYS.env");
//  runApp(const MyApp());
//}

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List apiKeys = new  List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    //List<String>? apiKeys = DotEnv().env['API_KEYS']?.split(',');

    //받은 APIList에 아무 것도 없는 경우 화면
    if(apiKeys == null || apiKeys.isEmpty){
      return Scaffold(
          appBar: AppBar(
            title: Text('API Loading'),
          ),
          body: Center(
            child: Text('Failed to load API keys.'),
          ));
    }

    //APIList에 값이 있는 경우 화면
    return Scaffold(
      appBar: AppBar(
        title: Text('API Loading'),
      ),
      body: Center(
        child: buildFutureBuilder(apiKeys),
      ),
    );
  }

  Widget buildFutureBuilder(apiKey) {
    return FutureBuilder(
      // getStation이 Future<String>을 반환하기 때문에 `.then((stationName) => stationName)`을 추가
      // Future<dynamic>이 반환, 아래 snapshot.data as String에서 String으로 타입을 변환
      future: getStation(apiKey).then((stationName) => stationName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { //Future가 값을 받는 중
          return Text('Loading...');
        } else if (snapshot.hasError) { //Future 비정상 실행
          return Text('Error: ${snapshot.error}');
        } else {
          if (snapshot.hasData) { //Future에 데이터가 들어오면
            // snapshot.data이 dynamic 타입, as String으로 String으로 타입을 변환
            return Text(snapshot.data as String); //String
          } else {
            return Text('Loading...'); //CircularProgressIndicator(); //LoadIndicator
          }
        }
      },
    );
  }

  @override
  //일단 main에 HardCording
  void initState() {
    super.initState();
    apiKeys.add("25233830763e276f00e238fbb1dcaa22"); //ipstackKey
    apiKeys.add("AIzaSyDFar-0tkGAWhl93-u0cj54-mTq3daya8Y"); //googleApiKey
    apiKeys.add("fe85ce059fe1e217d3e2e66ded3668e6"); //kakaoApiKey
  }
}

//API Key List로 역 이름 출력 함수
Future<String> getStation(apiKeys) async {
  //List nowLOC = await nowLocation(apiKeys[0]) as List;
  List nowLOC = await requestLocationPermission(); //위도 경도 받기
  double latitude = nowLOC[0]; //위도
  double longitude = nowLOC[1]; //경도

  Future<String> stationName = kakaoStation(apiKeys[2], latitude, longitude, 2000); //역 이름 받기(apiLoad.dart)
  // GoogleStation(apiKeys[1], latitude, longitude, 2000);
  // 또는 kakaoStation(apiKeys[2], latitude, longitude, 2000);

  return stationName; //Future<string> 반환
}